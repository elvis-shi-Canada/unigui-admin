unit LogViewer;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.RegularExpressions, System.DateUtils;

type
  TLogLevel = (llDebug, llInfo, llWarning, llError, llFatal);

  TLogEntry = record
    Timestamp: TDateTime;
    Level: TLogLevel;
    Source: string;
    Message: string;
    Details: string;
  end;

  TLogViewer = class
  private
    FLogFile: string;
    FEntries: TList<TLogEntry>;
    FFilterLevel: TLogLevel;
    FFilterSource: string;
    FFilterStartDate: TDateTime;
    FFilterEndDate: TDateTime;
    FSearchText: string;
    function ParseLogLine(const Line: string): TLogEntry;
    function ParseLogLevel(const LevelStr: string): TLogLevel;
    function MatchesFilter(const Entry: TLogEntry): Boolean;
    procedure LoadLogFile;
  public
    constructor Create(const LogFile: string);
    destructor Destroy; override;
    procedure Refresh;
    function GetEntries(StartIndex, Count: Integer): TArray<TLogEntry>;
    function GetFilteredEntries: TArray<TLogEntry>;
    function Search(const Text: string): TArray<TLogEntry>;
    function ExportToCSV(const FileName: string): Boolean;
    function GetStatistics: string;
    procedure SetFilter(const Level: TLogLevel; const Source: string);
    procedure SetDateRange(const StartDate, EndDate: TDateTime);
    procedure SetSearchText(const Text: string);
    property EntryCount: Integer read FEntries.Count;
  end;

implementation

constructor TLogViewer.Create(const LogFile: string);
begin
  inherited Create;
  FLogFile := LogFile;
  FEntries := TList<TLogEntry>.Create;
  FFilterLevel := llDebug; // 显示所有级别
  FFilterSource := '';
  FFilterStartDate := 0;
  FFilterEndDate := 0;
  FSearchText := '';

  if FileExists(FLogFile) then
    LoadLogFile;
end;

destructor TLogViewer.Destroy;
begin
  FEntries.Free;
  inherited;
end;

function TLogViewer.ParseLogLevel(const LevelStr: string): TLogLevel;
begin
  if SameText(LevelStr, 'DEBUG') then
    Result := llDebug
  else if SameText(LevelStr, 'INFO') then
    Result := llInfo
  else if SameText(LevelStr, 'WARNING') then
    Result := llWarning
  else if SameText(LevelStr, 'ERROR') then
    Result := llError
  else if SameText(LevelStr, 'FATAL') then
    Result := llFatal
  else
    Result := llInfo; // 默认
end;

function TLogViewer.ParseLogLine(const Line: string): TLogEntry;
var
  Regex: TRegEx;
  Match: TMatch;
  DateTimeStr: string;
  LevelStr: string;
begin
  // 解析标准日志格式: [2024-01-15 10:30:45] [INFO] [Source] Message
  Regex := TRegEx.Create('\[(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\]\s*\[(\w+)\]\s*\[([^\]]*)\]\s*(.+)');
  Match := Regex.Match(Line);

  if Match.Success then
  begin
    DateTimeStr := Match.Groups[1].Value;
    LevelStr := Match.Groups[2].Value;

    Result.Timestamp := StrToDateTime(DateTimeStr);
    Result.Level := ParseLogLevel(LevelStr);
    Result.Source := Match.Groups[3].Value;
    Result.Message := Match.Groups[4].Value;
    Result.Details := '';
  end
  else
  begin
    // 无法解析的日志行
    Result.Timestamp := Now;
    Result.Level := llInfo;
    Result.Source := 'Unknown';
    Result.Message := Line;
    Result.Details := '';
  end;
end;

procedure TLogViewer.LoadLogFile;
var
  Lines: TArray<string>;
  Line: string;
  Entry: TLogEntry;
  LastEntry: TLogEntry;
  IsMultiLine: Boolean;
begin
  FEntries.Clear;

  if not FileExists(FLogFile) then Exit;

  Lines := TFile.ReadAllLines(FLogFile, TEncoding.UTF8);
  LastEntry.Message := '';
  IsMultiLine := False;

  for Line in Lines do
  begin
    if Trim(Line) = '' then Continue;

    // 检查是否是新的日志行（以日期开头）
    if TRegEx.IsMatch(Line, '^\[\d{4}-\d{2}-\d{2}') then
    begin
      // 保存之前的条目
      if IsMultiLine then
      begin
        LastEntry.Details := LastEntry.Message;
        LastEntry.Message := '...';
        FEntries.Add(LastEntry);
      end
      else if LastEntry.Message <> '' then
      begin
        FEntries.Add(LastEntry);
      end;

      // 解析新条目
      Entry := ParseLogLine(Line);
      LastEntry := Entry;
      IsMultiLine := False;
    end
    else
    begin
      // 多行日志的延续
      LastEntry.Message := LastEntry.Message + sLineBreak + Line;
      IsMultiLine := True;
    end;
  end;

  // 添加最后一个条目
  if LastEntry.Message <> '' then
    FEntries.Add(LastEntry);
end;

function TLogViewer.MatchesFilter(const Entry: TLogEntry): Boolean;
begin
  Result := True;

  // 级别过滤
  if Ord(Entry.Level) < Ord(FFilterLevel) then
  begin
    Result := False;
    Exit;
  end;

  // 来源过滤
  if (FFilterSource <> '') and (Pos(FFilterSource, Entry.Source) = 0) then
  begin
    Result := False;
    Exit;
  end;

  // 日期范围过滤
  if (FFilterStartDate > 0) and (Entry.Timestamp < FFilterStartDate) then
  begin
    Result := False;
    Exit;
  end;

  if (FFilterEndDate > 0) and (Entry.Timestamp > FFilterEndDate) then
  begin
    Result := False;
    Exit;
  end;

  // 文本搜索
  if FSearchText <> '' then
  begin
    Result := (Pos(FSearchText, Entry.Message) > 0) or
              (Pos(FSearchText, Entry.Source) > 0) or
              (Pos(FSearchText, Entry.Details) > 0);
  end;
end;

procedure TLogViewer.Refresh;
begin
  LoadLogFile;
end;

function TLogViewer.GetEntries(StartIndex, Count: Integer): TArray<TLogEntry>;
var
  I: Integer;
  ResultList: TList<TLogEntry>;
  MaxIndex: Integer;
begin
  ResultList := TList<TLogEntry>.Create;
  try
    MaxIndex := Min(StartIndex + Count - 1, FEntries.Count - 1);

    for I := StartIndex to MaxIndex do
    begin
      ResultList.Add(FEntries[I]);
    end;

    Result := ResultList.ToArray;
  finally
    ResultList.Free;
  end;
end;

function TLogViewer.GetFilteredEntries: TArray<TLogEntry>;
var
  Entry: TLogEntry;
  ResultList: TList<TLogEntry>;
begin
  ResultList := TList<TLogEntry>.Create;
  try
    for Entry in FEntries do
    begin
      if MatchesFilter(Entry) then
        ResultList.Add(Entry);
    end;

    Result := ResultList.ToArray;
  finally
    ResultList.Free;
  end;
end;

function TLogViewer.Search(const Text: string): TArray<TLogEntry>;
var
  Entry: TLogEntry;
  ResultList: TList<TLogEntry>;
begin
  ResultList := TList<TLogEntry>.Create;
  try
    for Entry in FEntries do
    begin
      if (Pos(Text, Entry.Message) > 0) or
         (Pos(Text, Entry.Source) > 0) or
         (Pos(Text, Entry.Details) > 0) then
        ResultList.Add(Entry);
    end;

    Result := ResultList.ToArray;
  finally
    ResultList.Free;
  end;
end;

function TLogViewer.ExportToCSV(const FileName: string): Boolean;
var
  SB: TStringBuilder;
  Entry: TLogEntry;
  Filtered: TArray<TLogEntry>;
begin
  Result := False;

  SB := TStringBuilder.Create;
  try
    // CSV 头部
    SB.AppendLine('Timestamp,Level,Source,Message');

    Filtered := GetFilteredEntries;

    for Entry in Filtered do
    begin
      SB.AppendLine(Format('"%s","%s","%s","%s"',
        [DateTimeToStr(Entry.Timestamp),
         GetEnumName(TypeInfo(TLogLevel), Ord(Entry.Level)),
         Entry.Source,
         StringReplace(Entry.Message, '"', '""', [rfReplaceAll])]));
    end;

    TFile.WriteAllText(FileName, SB.ToString, TEncoding.UTF8);
    Result := True;

    Writeln('日志已导出到: ' + FileName);
    Writeln('导出记录数: ' + IntToStr(Length(Filtered)));
  finally
    SB.Free;
  end;
end;

function TLogViewer.GetStatistics: string;
var
  SB: TStringBuilder;
  Entry: TLogEntry;
  LevelCounts: array[TLogLevel] of Integer;
  Level: TLogLevel;
  Earliest, Latest: TDateTime;
begin
  SB := TStringBuilder.Create;
  try
    // 初始化计数
    for Level := Low(TLogLevel) to High(TLogLevel) do
      LevelCounts[Level] := 0;

    if FEntries.Count = 0 then
    begin
      Result := '没有日志记录';
      Exit;
    end;

    Earliest := FEntries[0].Timestamp;
    Latest := FEntries[0].Timestamp;

    for Entry in FEntries do
    begin
      Inc(LevelCounts[Entry.Level]);

      if Entry.Timestamp < Earliest then
        Earliest := Entry.Timestamp;

      if Entry.Timestamp > Latest then
        Latest := Entry.Timestamp;
    end;

    SB.AppendLine('日志统计');
    SB.AppendLine('========');
    SB.AppendLine;
    SB.AppendLine('总记录数: ' + IntToStr(FEntries.Count));
    SB.AppendLine('时间范围: ' + DateTimeToStr(Earliest) + ' - ' + DateTimeToStr(Latest));
    SB.AppendLine;
    SB.AppendLine('级别分布:');

    for Level := Low(TLogLevel) to High(TLogLevel) do
    begin
      if LevelCounts[Level] > 0 then
        SB.AppendLine(Format('  %s: %d (%.1f%%)',
          [GetEnumName(TypeInfo(TLogLevel), Ord(Level)),
           LevelCounts[Level],
           LevelCounts[Level] * 100.0 / FEntries.Count]));
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TLogViewer.SetFilter(const Level: TLogLevel; const Source: string);
begin
  FFilterLevel := Level;
  FFilterSource := Source;
end;

procedure TLogViewer.SetDateRange(const StartDate, EndDate: TDateTime);
begin
  FFilterStartDate := StartDate;
  FFilterEndDate := EndDate;
end;

procedure TLogViewer.SetSearchText(const Text: string);
beginn  FSearchText := Text;
end;

end.
