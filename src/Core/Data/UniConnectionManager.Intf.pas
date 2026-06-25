unit UniConnectionManager.Intf;

interface

uses
  System.SysUtils, FireDAC.Comp.Client;

type
  /// <summary>
  /// 数据库类型枚举
  /// </summary>
  TDatabaseType = (dbMSSQL, dbMySQL, dbOracle, dbPostgreSQL, dbSQLite);

  /// <summary>
  /// 连接参数
  /// </summary>
  TConnectionParams = record
    DatabaseType: TDatabaseType;
    Server: string;
    Port: Integer;
    Database: string;
    UserName: string;
    Password: string;
  end;

  /// <summary>
  /// 数据库连接管理器接口
  /// </summary>
  IUniConnectionManager = interface(IInterface)
    ['{B9C7E2D3-A8F5-6D4E-C1B7-7A9F2D3E8C5B}']
    function GetConnection(const Params: TConnectionParams): TFDConnection;
    function GetDefaultConnection: TFDConnection;
    procedure ReleaseConnection(var Connection: TFDConnection);
    function TestConnection(const Params: TConnectionParams): Boolean;
  end;

implementation

end.
