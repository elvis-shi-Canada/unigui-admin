unit UniConnectionManager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniConnectionManager.Intf, UniConfigService.Intf, UniConfigService;

type
  TUniConnectionManager = class(TInterfacedObject, IUniConnectionManager)
  private
    class var FInstance: IUniConnectionManager;
    class var FLock: TObject;
    FConnections: TObjectList<TFDConnection>;
    FConfigService: IUniConfigService;

    function BuildConnectionString(const Params: TConnectionParams): string;
    function GetDriverName(const DbType: TDatabaseType): string;
    /// <summary>创建并配置默认连接（工厂方法，调用者负责释放）</summary>
    function CreateDefaultConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;

    function GetConnection(const Params: TConnectionParams): TFDConnection;
    function GetDefaultConnection: TFDConnection;
    procedure ReleaseConnection(var Connection: TFDConnection);
    function TestConnection(const Params: TConnectionParams): Boolean;

    class function GetInstance: IUniConnectionManager; static;
    class property Instance: IUniConnectionManager read GetInstance;
  end;

implementation

uses
  UniAdminLogger;

{ TUniConnectionManager }

class function TUniConnectionManager.GetInstance: IUniConnectionManager;
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TUniConnectionManager.Create;
    finally
      TMonitor.Exit(FLock);
    end;
  end;
  Result := FInstance;
end;

constructor TUniConnectionManager.Create;
begin
  inherited Create;
  FConnections := TObjectList<TFDConnection>.Create;
  FConfigService := TUniConfigService.GetInstance;
end;

destructor TUniConnectionManager.Destroy;
begin
  FConnections.Free;  // TObjectList(OwnsObjects=True) 释放所有连接
  inherited;
end;

function TUniConnectionManager.GetDriverName(const DbType: TDatabaseType): string;
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

function TUniConnectionManager.BuildConnectionString(const Params: TConnectionParams): string;
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

function TUniConnectionManager.GetConnection(const Params: TConnectionParams): TFDConnection;
begin
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

function TUniConnectionManager.CreateDefaultConnection: TFDConnection;
var
  LDbType, LConnStr, LExeDir: string;
  LParams: TConnectionParams;
begin
  // 从配置读取数据库类型
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
    // 从 FConnections 取出——调用者（MainModule → TUniServices）拥有生命周期
    FConnections.Extract(Result);
  end;
end;

function TUniConnectionManager.GetDefaultConnection: TFDConnection;
begin
  Result := CreateDefaultConnection;
end;

procedure TUniConnectionManager.ReleaseConnection(var Connection: TFDConnection);
begin
  if Assigned(Connection) then
  begin
    if Connection.Connected then
      Connection.Connected := False;
    FConnections.Remove(Connection);  // TObjectList(OwnsObjects=True) 自动释放
    Connection := nil;
  end;
end;

function TUniConnectionManager.TestConnection(const Params: TConnectionParams): Boolean;
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
  TUniConnectionManager.FLock := TObject.Create;
  TUniConnectionManager.GetInstance;

finalization
  TUniConnectionManager.FInstance := nil;
  FreeAndNil(TUniConnectionManager.FLock);

end.
