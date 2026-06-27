unit UniModelAdmin;

interface

uses
  System.SysUtils, System.Generics.Collections, System.SyncObjs,
  UniModelAdmin.Intf;

type
  /// <summary>
  /// ModelAdmin 注册中心实现（进程级单例）
  /// 设计参照 TUniAdminModuleRegistry 的 GetInstance / CleanupInstance 模式
  /// </summary>
  TModelAdminRegistry = class(TInterfacedObject, IModelAdminRegistry)
  private
    class var FInstance: IModelAdminRegistry;
    class var FLock: TCriticalSection;
    FAdmins: TDictionary<string, TModelAdmin>;

    class function GetInstance: IModelAdminRegistry; static;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Register(const AAdmin: TModelAdmin);
    function Find(const AAdminID: string; out AAdmin: TModelAdmin): Boolean;
    function GetByTableName(const ATableName: string): TModelAdmin;
    function GetAll: TArray<TModelAdmin>;
    function Count: Integer;
    procedure Clear;

    /// <summary>获取进程级单例（首次调用时惰性创建）</summary>
    class function CreateInstance: IModelAdminRegistry; static;
    /// <summary>进程退出时清理（与 initialization/finalization 配合）</summary>
    class procedure CleanupInstance; static;
    class destructor Destroy;
  end;

implementation

{ TModelAdminRegistry }

class function TModelAdminRegistry.CreateInstance: IModelAdminRegistry;
begin
  Result := GetInstance;
end;

class function TModelAdminRegistry.GetInstance: IModelAdminRegistry;
begin
  if FInstance = nil then
  begin
    FLock.Enter;
    try
      if FInstance = nil then
        FInstance := TModelAdminRegistry.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TModelAdminRegistry.CleanupInstance;
begin
  FInstance := nil;
end;

class destructor TModelAdminRegistry.Destroy;
begin
  CleanupInstance;
  if Assigned(FLock) then
  begin
    FLock.Free;
    FLock := nil;
  end;
end;

constructor TModelAdminRegistry.Create;
begin
  inherited;
  // TModelAdmin 是 record（值类型），TDictionary 按值拷贝存储，
  // 外部后续修改 record 不会影响已注册内容。
  FAdmins := TDictionary<string, TModelAdmin>.Create;
end;

destructor TModelAdminRegistry.Destroy;
begin
  FAdmins.Free;
  inherited;
end;

procedure TModelAdminRegistry.Register(const AAdmin: TModelAdmin);
begin
  // record 按值拷贝存储，杜绝外部后续修改影响注册内容
  FAdmins.AddOrSetValue(LowerCase(AAdmin.AdminID), AAdmin);
end;

function TModelAdminRegistry.Find(const AAdminID: string;
  out AAdmin: TModelAdmin): Boolean;
begin
  Result := FAdmins.TryGetValue(LowerCase(AAdminID), AAdmin);
  if not Result then
  begin
    AAdmin.AdminID := '';
    AAdmin.TableName := '';
  end;
end;

function TModelAdminRegistry.GetByTableName(const ATableName: string): TModelAdmin;
var
  LPair: TPair<string, TModelAdmin>;
begin
  Result.AdminID := '';
  for LPair in FAdmins do
    if SameText(LPair.Value.TableName, ATableName) then
      Exit(LPair.Value);
end;

function TModelAdminRegistry.GetAll: TArray<TModelAdmin>;
var
  LPair: TPair<string, TModelAdmin>;
  LList: TList<TModelAdmin>;
begin
  LList := TList<TModelAdmin>.Create;
  try
    for LPair in FAdmins do
      LList.Add(LPair.Value);
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TModelAdminRegistry.Count: Integer;
begin
  Result := FAdmins.Count;
end;

procedure TModelAdminRegistry.Clear;
begin
  FAdmins.Clear;
end;

initialization
  TModelAdminRegistry.FLock := TCriticalSection.Create;

finalization
  TModelAdminRegistry.CleanupInstance;
  if Assigned(TModelAdminRegistry.FLock) then
  begin
    TModelAdminRegistry.FLock.Free;
    TModelAdminRegistry.FLock := nil;
  end;

end.
