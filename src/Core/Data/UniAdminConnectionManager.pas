unit UniAdminConnectionManager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniAdminConnectionManager.Intf, UniAdminConfigService.Intf, UniAdminConfigService;

type
  TUniAdminConnectionManager = class(TInterfacedObject, IUniAdminConnectionManager)
  private
    class var FInstance: IUniAdminConnectionManager;
    class var FLock: TObject;
    FConnections: TObjectList<TFDConnection>;
    FConfigService: IUniAdminConfigService;

    function BuildConnectionString(const Params: TConnectionParams): string;
    function GetDriverName(const DbType: TDatabaseType): string;
    /// <summary>创建并配置默认连接（非池化兼容路径，GetDefaultConnection 已不调用，保留备用）</summary>
    function CreateDefaultConnection: TFDConnection;
    /// <summary>确保池化连接定义已注册（首次按 config 创建；借鉴 BeeCloudERP Config.DataBase.pas）</summary>
    procedure EnsurePooledConnDef;
    /// <summary>解析 SQLite 数据库文件绝对路径：优先 database.name，否则从 connectionString 提取，相对路径补 exe 目录</summary>
    function ResolveSqliteDatabasePath: string;
  public
    constructor Create;
    destructor Destroy; override;

    function GetConnection(const Params: TConnectionParams): TFDConnection;
    function GetDefaultConnection: TFDConnection;
    procedure ReleaseConnection(var Connection: TFDConnection);
    function TestConnection(const Params: TConnectionParams): Boolean;
    /// <summary>确保池化连接定义已注册（public 入口，供启动时显式调用，如 DMVC ActiveRecord 集成）</summary>
    procedure EnsurePooledConnectionDef;

    class function GetInstance: IUniAdminConnectionManager; static;
    class property Instance: IUniAdminConnectionManager read GetInstance;
  end;

implementation

uses
  UniAdminLogger;

const
  /// 池化连接定义名（FireDAC Private ConnDef，借鉴 BeeCloudERP Config.DataBase.pas）
  CON_DEF_NAME = 'UniAdmin_Pooled';
  /// 池最大物理连接数
  POOL_MAX_ITEMS = 100;

{ TUniAdminConnectionManager }

class function TUniAdminConnectionManager.GetInstance: IUniAdminConnectionManager;
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TUniAdminConnectionManager.Create;
    finally
      TMonitor.Exit(FLock);
    end;
  end;
  Result := FInstance;
end;

constructor TUniAdminConnectionManager.Create;
begin
  inherited Create;
  FConnections := TObjectList<TFDConnection>.Create;
  FConfigService := TUniAdminConfigService.GetInstance;
end;

destructor TUniAdminConnectionManager.Destroy;
begin
  FConnections.Free;  // TObjectList(OwnsObjects=True) 释放残留非池化连接
  inherited;
end;

function TUniAdminConnectionManager.GetDriverName(const DbType: TDatabaseType): string;
begin
  case DbType of
    dbMSSQL: Result := 'MSSQL';
    dbMySQL: Result := 'MySQL';
    dbOracle: Result := 'Ora';
    dbPostgreSQL: Result := 'PG';
    dbSQLite: Result := 'SQLite';
  else
    Result := '';
  end;
end;

procedure TUniAdminConnectionManager.EnsurePooledConnDef;
var
  LParams: TStringList;
  LDbType: string;
  LDbEnum: TDatabaseType;
begin
  // 首次调用按 config 创建池化 Private ConnDef（FireDAC 接管物理连接复用）。
  // 借鉴 BeeCloudERP BASE/Unit/Config.DataBase.pas 的 CreateXxxPrivateConnDef + Pooled=True。
  if FDManager.IsConnectionDef(CON_DEF_NAME) then
    Exit;

  LDbType := FConfigService.GetGlobalString('database.type', 'MSSQL');
  if SameText(LDbType, 'MSSQL') then
    LDbEnum := dbMSSQL
  else if SameText(LDbType, 'MySQL') then
    LDbEnum := dbMySQL
  else if SameText(LDbType, 'Oracle') then
    LDbEnum := dbOracle
  else if SameText(LDbType, 'PostgreSQL') then
    LDbEnum := dbPostgreSQL
  else if SameText(LDbType, 'SQLite') then
    LDbEnum := dbSQLite
  else
    LDbEnum := dbMSSQL;

  LParams := TStringList.Create;
  try
    LParams.Add('Pooled=True');
    LParams.Add('POOL_MaximumItems=' + IntToStr(POOL_MAX_ITEMS));
    if LDbEnum = dbSQLite then
      // SQLite: 从 connectionString 解析文件名并补 exe 绝对路径
      // （修复 Database= 空导致连到空库，触发 no such table）
      LParams.Add('Database=' + ResolveSqliteDatabasePath)
    else
    begin
      LParams.Add('Server=' + FConfigService.GetGlobalString('database.server', 'localhost'));
      LParams.Add('Port=' + IntToStr(FConfigService.GetGlobalInteger('database.port', 1433)));
      LParams.Add('User_Name=' + FConfigService.GetGlobalString('database.user', 'sa'));
      LParams.Add('Password=' + FConfigService.GetGlobalString('database.password', ''));
      LParams.Add('Database=' + FConfigService.GetGlobalString('database.name', ''));
    end;
    FDManager.AddConnectionDef(CON_DEF_NAME, GetDriverName(LDbEnum), LParams);
  finally
    LParams.Free;
  end;
end;

function TUniAdminConnectionManager.ResolveSqliteDatabasePath: string;
var
  LConnStr, LExeDir: string;
  LParts: TStringList;
begin
  // 优先 database.name；为空则从 database.connectionString 提取 Database= 值
  // （app.json 契约为 connectionString="Database=UniAdmin.db"，无 name 字段）
  Result := FConfigService.GetGlobalString('database.name', '');
  if Result = '' then
  begin
    LConnStr := FConfigService.GetGlobalString('database.connectionString', '');
    if LConnStr <> '' then
    begin
      LParts := TStringList.Create;
      try
        LParts.LineBreak := ';';
        LParts.Text := LConnStr;
        Result := Trim(LParts.Values['Database']);
      finally
        LParts.Free;
      end;
    end;
  end;
  // 相对路径补 exe 目录绝对路径（exe 在 bin/，库文件也在 bin/，避免 cwd 依赖）
  if (Result <> '') and (ExtractFilePath(Result) = '') then
  begin
    LExeDir := ExtractFilePath(ParamStr(0));
    if LExeDir <> '' then
      Result := LExeDir + Result;
  end;
end;

function TUniAdminConnectionManager.BuildConnectionString(const Params: TConnectionParams): string;
begin
  case Params.DatabaseType of
    dbMSSQL:
      Result := Format('Server=%s;Port=%d;Database=%s;User_Name=%s;Password=%s',
        [Params.Server, Params.Port, Params.Database, Params.UserName, Params.Password]);

    dbMySQL:
      Result := Format('Server=%s;Port=%d;Database=%s;User_Name=%s;Password=%s',
        [Params.Server, Params.Port, Params.Database, Params.UserName, Params.Password]);

    dbPostgreSQL:
      Result := Format('Server=%s;Port=%d;Database=%s;User_Name=%s;Password=%s',
        [Params.Server, Params.Port, Params.Database, Params.UserName, Params.Password]);

    dbSQLite:
      Result := Format('Database=%s', [Params.Database]);

    dbOracle:
      Result := Format('Server=%s;Port=%d;Database=%s;User_Name=%s;Password=%s',
        [Params.Server, Params.Port, Params.Database, Params.UserName, Params.Password]);
  else
    Result := '';
  end;
end;

function TUniAdminConnectionManager.GetConnection(const Params: TConnectionParams): TFDConnection;
begin
  // 非池化临时连接（供 TestConnection 用）；默认连接请走 GetDefaultConnection（池化）。
  Result := TFDConnection.Create(nil);
  try
    Result.DriverName := GetDriverName(Params.DatabaseType);
    Result.Params.Text := BuildConnectionString(Params);
    Result.Connected := True;
    FConnections.Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TUniAdminConnectionManager.CreateDefaultConnection: TFDConnection;
var
  LDbType, LConnStr, LExeDir: string;
  LParams: TConnectionParams;
begin
  // 非池化兼容路径（GetDefaultConnection 已改走池化 con_def，此方法保留备用）。
  LDbType := FConfigService.GetGlobalString('database.type', 'MSSQL');

  if SameText(LDbType, 'MSSQL') then
    LParams.DatabaseType := dbMSSQL
  else if SameText(LDbType, 'MySQL') then
    LParams.DatabaseType := dbMySQL
  else if SameText(LDbType, 'Oracle') then
    LParams.DatabaseType := dbOracle
  else if SameText(LDbType, 'PostgreSQL') then
    LParams.DatabaseType := dbPostgreSQL
  else if SameText(LDbType, 'SQLite') then
    LParams.DatabaseType := dbSQLite
  else
    LParams.DatabaseType := dbMSSQL;

  // 优先使用 app.json 的完整连接串（database.connectionString）
  LConnStr := FConfigService.GetGlobalString('database.connectionString', '');

  // SQLite 相对路径解析为 exe 目录绝对路径
  if (LParams.DatabaseType = dbSQLite) and (LConnStr <> '') then
  begin
    LExeDir := ExtractFilePath(ParamStr(0));
    if LExeDir <> '' then
      LConnStr := StringReplace(LConnStr, 'Database=', 'Database=' + LExeDir, [rfIgnoreCase]);
  end;

  if LConnStr <> '' then
  begin
    Result := TFDConnection.Create(nil);
    try
      // 顺序关键：先设 Params.Text（连接参数），再设 DriverName（驱动）。
      Result.Params.Text := LConnStr;
      Result.DriverName := GetDriverName(LParams.DatabaseType);
      Result.Connected := True;
    except
      Result.Free;
      raise;
    end;
  end
  else
  begin
    // 向后兼容：使用分散字段构造连接
    LParams.Server := FConfigService.GetGlobalString('database.server', 'localhost');
    LParams.Port := FConfigService.GetGlobalInteger('database.port', 1433);
    LParams.Database := FConfigService.GetGlobalString('database.name', '');
    LParams.UserName := FConfigService.GetGlobalString('database.user', 'sa');
    LParams.Password := FConfigService.GetGlobalString('database.password', '');
    Result := GetConnection(LParams);
    // 从 FConnections 取出——调用者拥有生命周期
    FConnections.Extract(Result);
  end;
end;

procedure TUniAdminConnectionManager.EnsurePooledConnectionDef;
begin
  // public 包装：供启动时（ServerModule.OnCreate）显式建池化 con_def，
  // 配合 DMVC ActiveRecord AddDefaultConnection 注册。
  EnsurePooledConnDef;
end;

function TUniAdminConnectionManager.GetDefaultConnection: TFDConnection;
begin
  // 走 FireDAC 池化 con_def（借鉴 BeeCloudERP）：物理连接由池复用，
  // 根治 LRN-20260627-003 启动连接泄漏 + 提升多会话并发性能。
  // 返回的句柄所有权归调用方；ReleaseConnection 时 Connected:=False 归还池。
  EnsurePooledConnDef;
  Result := TFDConnection.Create(nil);
  Result.ConnectionDefName := CON_DEF_NAME;
  Result.Connected := True;
end;

procedure TUniAdminConnectionManager.ReleaseConnection(var Connection: TFDConnection);
begin
  if Assigned(Connection) then
  begin
    if Connection.Connected then
      Connection.Connected := False;  // 池化：归还池（物理连接留池复用）

    if Connection.ConnectionDefName = CON_DEF_NAME then
      Connection.Free  // 池化句柄：释放客户端句柄，物理连接由池保留
    else if FConnections.Remove(Connection) < 0 then
      Connection.Free;  // 非池化（GetConnection/CreateDefaultConnection）：直接 Free

    Connection := nil;
  end;
end;

function TUniAdminConnectionManager.TestConnection(const Params: TConnectionParams): Boolean;
var
  LConn: TFDConnection;
begin
  LConn := nil;
  try
    LConn := GetConnection(Params);
    Result := LConn.Connected;
  finally
    if Assigned(LConn) then
      ReleaseConnection(LConn);
  end;
end;

initialization
  TUniAdminConnectionManager.FLock := TObject.Create;
  TUniAdminConnectionManager.GetInstance;

finalization
  TUniAdminConnectionManager.FInstance := nil;
  FreeAndNil(TUniAdminConnectionManager.FLock);

end.
