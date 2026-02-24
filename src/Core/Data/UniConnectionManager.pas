unit UniConnectionManager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client,
  UniConnectionManager.Intf, UniConfigService.Intf;

type
  TUniConnectionManager = class(TInterfacedObject, IUniConnectionManager)
  private
    class var FInstance: IUniConnectionManager;
    FConnections: TObjectList<TFDConnection>;
    FDefaultConnection: TFDConnection;
    FConfigService: IUniConfigService;

    function BuildConnectionString(const Params: TConnectionParams): string;
    function GetDriverName(const DbType: TDatabaseType): string;
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

{ TUniConnectionManager }

class function TUniConnectionManager.GetInstance: IUniConnectionManager;
begin
  if FInstance = nil then
    FInstance := TUniConnectionManager.Create;
  Result := FInstance;
end;

constructor TUniConnectionManager.Create;
begin
  inherited Create;
  FConnections := TObjectList<TFDConnection>.Create;
  FConfigService := TUniConfigService.Instance;
end;

destructor TUniConnectionManager.Destroy;
begin
  FConnections.Free;
  if Assigned(FDefaultConnection) then
    FDefaultConnection.Free;
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

function TUniConnectionManager.GetDefaultConnection: TFDConnection;
var
  LDbType: string;
  LParams: TConnectionParams;
begin
  if not Assigned(FDefaultConnection) then
  begin
    // 从配置读取数据库类型和连接信息
    // NOTE: Using GetGlobalString/GetGlobalInteger as per actual interface
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

    LParams.Server := FConfigService.GetGlobalString('database.server', 'localhost');
    LParams.Port := FConfigService.GetGlobalInteger('database.port', 1433);
    LParams.Database := FConfigService.GetGlobalString('database.name', '');
    LParams.UserName := FConfigService.GetGlobalString('database.user', 'sa');
    LParams.Password := FConfigService.GetGlobalString('database.password', '');

    FDefaultConnection := GetConnection(LParams);
  end;

  Result := FDefaultConnection;
end;

procedure TUniConnectionManager.ReleaseConnection(var Connection: TFDConnection);
begin
  if Assigned(Connection) then
  begin
    if Connection <> FDefaultConnection then
      FConnections.Remove(Connection);
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
  TUniConnectionManager.GetInstance;

finalization
  TUniConnectionManager.FInstance := nil;

end.
