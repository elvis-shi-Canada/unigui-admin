unit PerformanceProfiler;

interface

uses
  System.SysUtils, System.Classes, System.Diagnostics, System.Generics.Collections,
  System.DateUtils;

type
  TPerformanceMetric = record
    Name: string;
    StartTime: TDateTime;
    EndTime: TDateTime;
    Duration: Int64; // milliseconds
    MemoryBefore: Int64;
    MemoryAfter: Int64;
    CallCount: Integer;
  end;

  TPerformanceProfiler = class
  private
    FMetrics: TDictionary<string, TPerformanceMetric>;
    FActiveTimers: TDictionary<string, TStopwatch>;
    FEnabled: Boolean;
    procedure UpdateMemoryUsage(var Metric: TPerformanceMetric; IsEnd: Boolean);
    function GetMemoryUsage: Int64;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(const Name: string);
    procedure Stop(const Name: string);
    procedure Reset;
    function GetReport: string;
    function GetMetric(const Name: string): TPerformanceMetric;
    function GetAllMetrics: TArray<TPerformanceMetric>;
    procedure SaveReport(const FileName: string);
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  // 简单性能计时器（RAII风格）
  TProfileBlock = record
  private
    FProfiler: TPerformanceProfiler;
    FName: string;
    FStopped: Boolean;
  public
    constructor Create(Profiler: TPerformanceProfiler; const Name: string);
    procedure Stop;
  end;

implementation

uses
  Winapi.Windows, Winapi.PsAPI;

constructor TPerformanceProfiler.Create;
begin
  inherited Create;
  FMetrics := TDictionary<string, TPerformanceMetric>.Create;
  FActiveTimers := TDictionary<string, TStopwatch>.Create;
  FEnabled := True;
end;

destructor TPerformanceProfiler.Destroy;
begin
  FActiveTimers.Free;
  FMetrics.Free;
  inherited;
end;

function TPerformanceProfiler.GetMemoryUsage: Int64;
var
  MemStatus: TMemoryStatusEx;
  Process: THandle;
  Pmc: PPROCESS_MEMORY_COUNTERS;
  cb: DWORD;
begin
  // 获取当前进程的内存使用情况
  Process := GetCurrentProcess;
  cb := SizeOf(PROCESS_MEMORY_COUNTERS);
  GetMem(Pmc, cb);
  try
    if GetProcessMemoryInfo(Process, Pmc, cb) then
      Result := Pmc^.WorkingSetSize
    else
      Result := 0;
  finally
    FreeMem(Pmc);
  end;
end;

procedure TPerformanceProfiler.UpdateMemoryUsage(var Metric: TPerformanceMetric; IsEnd: Boolean);
begin
  if IsEnd then
    Metric.MemoryAfter := GetMemoryUsage
  else
    Metric.MemoryBefore := GetMemoryUsage;
end;

procedure TPerformanceProfiler.Start(const Name: string);
var
  Metric: TPerformanceMetric;
  Stopwatch: TStopwatch;
begin
  if not FEnabled then Exit;

  // 如果已经存在，更新计数
  if FMetrics.TryGetValue(Name, Metric) then
  begin
    Metric.CallCount := Metric.CallCount + 1;
    FMetrics[Name] := Metric;
  end
  else
  begin
    // 创建新的指标
    Metric.Name := Name;
    Metric.StartTime := Now;
    Metric.EndTime := 0;
    Metric.Duration := 0;
    Metric.CallCount := 1;
    UpdateMemoryUsage(Metric, False);
    FMetrics.Add(Name, Metric);
  end;

  // 启动计时器
  Stopwatch := TStopwatch.StartNew;
  FActiveTimers.AddOrSetValue(Name, Stopwatch);
end;

procedure TPerformanceProfiler.Stop(const Name: string);
var
  Metric: TPerformanceMetric;
  Stopwatch: TStopwatch;
  Duration: Int64;
begin
  if not FEnabled then Exit;

  if not FActiveTimers.TryGetValue(Name, Stopwatch) then
  begin
    Writeln('Warning: Stop called without Start for ' + Name);
    Exit;
  end;

  Stopwatch.Stop;
  Duration := Stopwatch.ElapsedMilliseconds;

  if FMetrics.TryGetValue(Name, Metric) then
  begin
    Metric.EndTime := Now;
    Metric.Duration := Metric.Duration + Duration;
    UpdateMemoryUsage(Metric, True);
    FMetrics[Name] := Metric;
  end;

  FActiveTimers.Remove(Name);
end;

procedure TPerformanceProfiler.Reset;
begin
  FMetrics.Clear;
  FActiveTimers.Clear;
end;

function TPerformanceProfiler.GetReport: string;
var
  SB: TStringBuilder;
  Metric: TPerformanceMetric;
  TotalDuration: Int64;
  TotalCalls: Integer;
  MetricsArray: TArray<TPerformanceMetric>;
  I: Integer;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('========================================');
    SB.AppendLine('      性能分析报告');
    SB.AppendLine('========================================');
    SB.AppendLine;
    SB.AppendLine('生成时间: ' + DateTimeToStr(Now));
    SB.AppendLine;

    TotalDuration := 0;
    TotalCalls := 0;

    // 按持续时间排序
    MetricsArray := GetAllMetrics;
    TArray.Sort<TPerformanceMetric>(MetricsArray,
      TComparer<TPerformanceMetric>.Construct(
        function(const Left, Right: TPerformanceMetric): Integer
        begin
          Result := Right.Duration - Left.Duration;
        end));

    SB.AppendLine(Format('%-30s %10s %8s %12s %12s',
      ['名称', '总耗时(ms)', '调用次数', '平均耗时(ms)', '内存变化(KB)']));
    SB.AppendLine(StringOfChar('-', 80));

    for I := 0 to High(MetricsArray) do
    begin
      Metric := MetricsArray[I];
      TotalDuration := TotalDuration + Metric.Duration;
      TotalCalls := TotalCalls + Metric.CallCount;

      SB.AppendLine(Format('%-30s %10d %8d %12.2f %12.2f',
        [Metric.Name,
         Metric.Duration,
         Metric.CallCount,
         Metric.Duration / Metric.CallCount,
         (Metric.MemoryAfter - Metric.MemoryBefore) / 1024]));
    end;

    SB.AppendLine(StringOfChar('-', 80));
    SB.AppendLine(Format('总计: %d 个指标, %d 次调用, 总耗时 %d ms',
      [FMetrics.Count, TotalCalls, TotalDuration]));

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TPerformanceProfiler.GetMetric(const Name: string): TPerformanceMetric;
begin
  if not FMetrics.TryGetValue(Name, Result) then
    raise Exception.CreateFmt('Metric not found: %s', [Name]);
end;

function TPerformanceProfiler.GetAllMetrics: TArray<TPerformanceMetric>;
begin
  Result := FMetrics.Values.ToArray;
end;

procedure TPerformanceProfiler.SaveReport(const FileName: string);
begin
  TFile.WriteAllText(FileName, GetReport, TEncoding.UTF8);
  Writeln('性能报告已保存: ' + FileName);
end;

{ TProfileBlock }

constructor TProfileBlock.Create(Profiler: TPerformanceProfiler; const Name: string);
begin
  FProfiler := Profiler;
  FName := Name;
  FStopped := False;
  if Assigned(FProfiler) then
    FProfiler.Start(Name);
end;

procedure TProfileBlock.Stop;
begin
  if not FStopped and Assigned(FProfiler) then
  begin
    FProfiler.Stop(FName);
    FStopped := True;
  end;
end;

end.
