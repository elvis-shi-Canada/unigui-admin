unit UniAdminMetadataCache.Intf;

interface

uses
  System.SysUtils, System.Generics.Collections,
  UniFieldMetadata;

type
  /// <summary>
  /// 元数据缓存接口
  /// </summary>
  IUniAdminMetadataCache = interface(IInterface)
    ['{D7F8E6B4-A5C9-7D2F-E3B9-9A8C2F1D7E9C}']
    function GetTableMetadata(const TableName: string): TTableMetadata;
    procedure RegisterTable(const Metadata: TTableMetadata);
    function HasTable(const TableName: string): Boolean;
    function GetAllTables: TArray<string>;
    procedure Refresh;
    procedure Clear;
  end;

implementation

end.
