unit UniTaskProcessor;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  UniContext, UniPlugin.Types, UniAdminScheduler;

type
  /// <summary>
  /// 任务处理器基类 - 所有定时任务处理器的基础类
  /// </summary>
  TTaskProcessorBase = class(TInterfacedObject, ITaskProcessor)
  private
    FParameters: string;
    function GetParameters: string;
    procedure SetParameters(const Value: string);
  protected
    function GetProcessorName: string; virtual; abstract;
    function GetProcessorDescription: string; virtual; abstract;
    procedure DoInitialize; virtual;
    procedure DoExecute(const Context: IExecutionContext); virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    // ITaskProcessor 实现
    procedure Initialize(const Parameters: string);
    procedure Execute(const Context: IExecutionContext); overload;
    procedure Execute(const Context: IExecutionContext; const Parameters: string); overload;

    property ProcessorName: string read GetProcessorName;
    property ProcessorDescription: string read GetProcessorDescription;
    property Parameters: string read GetParameters write SetParameters;
  end;

  /// <summary>
  /// 任务处理器工厂类 - 负责创建和管理任务处理器
  /// </summary>
  TTaskProcessorFactory = class(TObject)
  private
    class var FProcessors: TDictionary<string, TClass>;

    class function GetProcessorClass(const HandlerClass: string): TClass;
  public
    class constructor Create;
    class destructor Destroy;

    class procedure RegisterProcessor(const HandlerClass: string; ProcessorClass: TClass);
    class function CreateProcessor(const HandlerClass: string): ITaskProcessor;
    class procedure RegisterDefaultProcessors;
  end;

implementation

{ TTaskProcessorBase }

constructor TTaskProcessorBase.Create;
begin
  inherited Create;
  FParameters := '';
end;

destructor TTaskProcessorBase.Destroy;
begin
  inherited;
end;

function TTaskProcessorBase.GetParameters: string;
begin
  Result := FParameters;
end;

procedure TTaskProcessorBase.SetParameters(const Value: string);
begin
  FParameters := Value;
end;

procedure TTaskProcessorBase.DoInitialize;
begin
  // 子类可重写此方法进行初始化
end;

procedure TTaskProcessorBase.Initialize(const Parameters: string);
begin
  FParameters := Parameters;
  DoInitialize;
end;

procedure TTaskProcessorBase.Execute(const Context: IExecutionContext);
begin
  DoExecute(Context);
end;

procedure TTaskProcessorBase.Execute(const Context: IExecutionContext; const Parameters: string);
begin
  Initialize(Parameters);
  DoExecute(Context);
end;

{ TTaskProcessorFactory }

class constructor TTaskProcessorFactory.Create;
begin
  FProcessors := TDictionary<string, TClass>.Create;
  RegisterDefaultProcessors;
end;

class destructor TTaskProcessorFactory.Destroy;
begin
  FProcessors.Clear;
  FProcessors.Free;
end;

class procedure TTaskProcessorFactory.RegisterProcessor(const HandlerClass: string;
  ProcessorClass: TClass);
begin
  if FProcessors.ContainsKey(HandlerClass) then
    FProcessors.Remove(HandlerClass);

  FProcessors.Add(HandlerClass, ProcessorClass);
end;

class function TTaskProcessorFactory.GetProcessorClass(const HandlerClass: string): TClass;
begin
  if FProcessors.ContainsKey(HandlerClass) then
    Result := FProcessors[HandlerClass]
  else
    Result := nil;
end;

class function TTaskProcessorFactory.CreateProcessor(const HandlerClass: string): ITaskProcessor;
var
  LProcessorClass: TClass;
  LProcessor: TTaskProcessorBase;
begin
  Result := nil;

  LProcessorClass := GetProcessorClass(HandlerClass);
  if Assigned(LProcessorClass) and LProcessorClass.InheritsFrom(TTaskProcessorBase) then
  begin
    LProcessor := TTaskProcessorBase(LProcessorClass.Create);
    Result := LProcessor as ITaskProcessor;
  end;
end;

class procedure TTaskProcessorFactory.RegisterDefaultProcessors;
begin
  // 注册默认的任务处理器
  // 示例任务在 SampleTasks.pas 中注册
end;

initialization
  // 初始化工厂

finalization
  // 清理资源

end.
