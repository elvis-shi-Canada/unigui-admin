unit UniAdminLogger;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.IOUtils,
  Winapi.Windows,
  UniAdminLogger.Intf;

type
  /// <summary>
  /// Thread-safe, daily-rolling file logger.
  ///
  /// Design notes:
  /// - Implemented as an independent global singleton (no database dependency),
  ///   so it stays usable during early startup (e.g. ServerModule.OnCreate),
  ///   before any DB connection exists.
  /// - The module-level LogInfo/LogWarn/LogError/LogDebug helpers are the
  ///   intended drop-in replacements for WriteLn calls scattered across the
  ///   host modules. They resolve to a single shared instance.
  /// - All disk I/O is wrapped in try-except so that a logging failure can
  ///   never crash the host application.
  /// - Unit/class names use the UniAdmin prefix to avoid any collision with
  ///   uniGUI's internal UniLogger unit / TUniLogger type.
  /// </summary>
  TUniAdminLogger = class(TInterfacedObject, IUniAdminLogger)
  private class var
    FInstance: IUniAdminLogger;
  private
    FLock: TCriticalSection;
    FLogDir: string;
    FStream: TStream;
    FWriter: TStreamWriter;
    FCurrentDate: string;
    FMinLevel: TLogLevel;
    constructor Create;
    function LevelTag(ALevel: TLogLevel): string;
    function TodayStamp: string;
    function BuildLine(ALevel: TLogLevel; const AMessage: string): string;
    procedure EnsureWriter;
    procedure CloseWriter;
    procedure InternalWrite(const ALine: string);
    procedure DoLog(ALevel: TLogLevel; const AMessage: string);
    { IUniAdminLogger }
    procedure Debug(const AMessage: string); overload;
    procedure Debug(const AFormat: string; const AArgs: array of const); overload;
    procedure Info(const AMessage: string); overload;
    procedure Info(const AFormat: string; const AArgs: array of const); overload;
    procedure Warn(const AMessage: string); overload;
    procedure Warn(const AFormat: string; const AArgs: array of const); overload;
    procedure Error(const AMessage: string); overload;
    procedure Error(const AFormat: string; const AArgs: array of const); overload;
    procedure SetMinLevel(ALevel: TLogLevel);
    function GetMinLevel: TLogLevel;
  public
    destructor Destroy; override;

    /// <summary>Returns the shared logger instance, creating it on first use.</summary>
    class function Instance: IUniAdminLogger; static;
    /// <summary>Releases the shared instance (ref-counted free).</summary>
    class procedure Release; static;
  end;

/// Writes an informational message to the application log file.
procedure LogInfo(const AMessage: string);
/// Writes a warning message to the application log file.
procedure LogWarn(const AMessage: string);
/// Writes an error message to the application log file.
procedure LogError(const AMessage: string);
/// Writes a debug message to the application log file.
procedure LogDebug(const AMessage: string);

implementation

const
  LOG_FILE_PREFIX = 'UniAdmin_';
  LOG_FILE_SUFFIX = '.log';
  LEVEL_TAGS: array[TLogLevel] of string = ('DEBUG', 'INFO', 'WARN', 'ERROR');

{ TUniAdminLogger }

constructor TUniAdminLogger.Create;
var
  LExePath: string;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FMinLevel := llDebug;
  FStream := nil;
  FWriter := nil;
  FCurrentDate := '';

  // Align with uniGUI's LOG_PATH ('log', uniGUIServer.pas) so all logs share
  // one root dir. uniGUI writes log\<module>\A*.log; app logs land here as
  // log\UniAdmin_*.log (distinguished by filename prefix) — no more 'logs' dir.
  LExePath := ExtractFilePath(ParamStr(0));
  if LExePath.IsEmpty then
    LExePath := GetCurrentDir;
  FLogDir := TPath.Combine(LExePath, 'log');
end;

destructor TUniAdminLogger.Destroy;
begin
  CloseWriter;
  FLock.Free;
  inherited Destroy;
end;

class function TUniAdminLogger.Instance: IUniAdminLogger;
begin
  // First-time creation runs during single-threaded startup; subsequent
  // multi-threaded callers always observe a non-nil instance.
  if FInstance = nil then
    FInstance := TUniAdminLogger.Create;
  Result := FInstance;
end;

class procedure TUniAdminLogger.Release;
begin
  FInstance := nil;
end;

function TUniAdminLogger.TodayStamp: string;
begin
  Result := FormatDateTime('yyyymmdd', Date);
end;

function TUniAdminLogger.LevelTag(ALevel: TLogLevel): string;
begin
  Result := LEVEL_TAGS[ALevel];
end;

function TUniAdminLogger.BuildLine(ALevel: TLogLevel; const AMessage: string): string;
begin
  Result := Format('%s [%s] [%d] %s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
     LevelTag(ALevel),
     GetCurrentThreadID,
     AMessage]);
end;

procedure TUniAdminLogger.EnsureWriter;
var
  LDate, LFileName: string;
  LFileStream: TFileStream;
  LPreamble: TBytes;
  LAppend: Boolean;
begin
  // Caller must hold FLock.
  LDate := TodayStamp;
  if (FWriter <> nil) and (FCurrentDate = LDate) then
    Exit;

  // Day changed (or very first write): roll over to a new file.
  CloseWriter;

  if not TDirectory.Exists(FLogDir) then
    TDirectory.CreateDirectory(FLogDir);

  LFileName := TPath.Combine(FLogDir, LOG_FILE_PREFIX + LDate + LOG_FILE_SUFFIX);
  FCurrentDate := LDate;
  LAppend := TFile.Exists(LFileName);

  if LAppend then
    LFileStream := TFileStream.Create(LFileName, fmOpenWrite or fmShareDenyWrite)
  else
    LFileStream := TFileStream.Create(LFileName, fmCreate or fmShareDenyWrite);

  try
    if LAppend then
      LFileStream.Seek(0, soEnd);

    // Emit the UTF-8 BOM only when creating a brand-new file.
    if not LAppend then
    begin
      LPreamble := TEncoding.UTF8.GetPreamble;
      if Length(LPreamble) > 0 then
        LFileStream.WriteBuffer(LPreamble[0], Length(LPreamble));
    end;

    FStream := LFileStream;
    FWriter := TStreamWriter.Create(FStream, TEncoding.UTF8);
  except
    LFileStream.Free;
    FStream := nil;
    FWriter := nil;
    raise;
  end;
end;

procedure TUniAdminLogger.CloseWriter;
begin
  FreeAndNil(FWriter);
  FreeAndNil(FStream);
end;

procedure TUniAdminLogger.InternalWrite(const ALine: string);
begin
  EnsureWriter;
  if FWriter <> nil then
  begin
    FWriter.WriteLine(ALine);
    FWriter.Flush;
  end;
end;

procedure TUniAdminLogger.DoLog(ALevel: TLogLevel; const AMessage: string);
begin
  if ALevel < FMinLevel then
    Exit;
  FLock.Acquire;
  try
    try
      InternalWrite(BuildLine(ALevel, AMessage));
    except
      // Swallow intentionally: logging must never crash the host application.
    end;
  finally
    FLock.Release;
  end;
end;

procedure TUniAdminLogger.Debug(const AMessage: string);
begin
  DoLog(llDebug, AMessage);
end;

procedure TUniAdminLogger.Debug(const AFormat: string; const AArgs: array of const);
begin
  DoLog(llDebug, Format(AFormat, AArgs));
end;

procedure TUniAdminLogger.Info(const AMessage: string);
begin
  DoLog(llInfo, AMessage);
end;

procedure TUniAdminLogger.Info(const AFormat: string; const AArgs: array of const);
begin
  DoLog(llInfo, Format(AFormat, AArgs));
end;

procedure TUniAdminLogger.Warn(const AMessage: string);
begin
  DoLog(llWarning, AMessage);
end;

procedure TUniAdminLogger.Warn(const AFormat: string; const AArgs: array of const);
begin
  DoLog(llWarning, Format(AFormat, AArgs));
end;

procedure TUniAdminLogger.Error(const AMessage: string);
begin
  DoLog(llError, AMessage);
end;

procedure TUniAdminLogger.Error(const AFormat: string; const AArgs: array of const);
begin
  DoLog(llError, Format(AFormat, AArgs));
end;

procedure TUniAdminLogger.SetMinLevel(ALevel: TLogLevel);
begin
  FLock.Acquire;
  try
    FMinLevel := ALevel;
  finally
    FLock.Release;
  end;
end;

function TUniAdminLogger.GetMinLevel: TLogLevel;
begin
  Result := FMinLevel;
end;

procedure LogInfo(const AMessage: string);
begin
  TUniAdminLogger.Instance.Info(AMessage);
end;

procedure LogWarn(const AMessage: string);
begin
  TUniAdminLogger.Instance.Warn(AMessage);
end;

procedure LogError(const AMessage: string);
begin
  TUniAdminLogger.Instance.Error(AMessage);
end;

procedure LogDebug(const AMessage: string);
begin
  TUniAdminLogger.Instance.Debug(AMessage);
end;

initialization
  TUniAdminLogger.FInstance := nil;

finalization
  TUniAdminLogger.Release;

end.
