unit UniMetadataCache.Intf;

interface

uses
  System.SysUtils, System.Generics.Collections,
  UniFieldMetadata;

type
  /// <summary>
  /// 元数据缓存接口
  /// </summary>
  IUniMetadataCache = interface(IInterface)
    ['{UNI-METADATA-CACHE-001}']
    function GetTableMetadata(const TableName: string): TTableMetadata;
    procedure RegisterTable(const Metadata: TTableMetadata);
    function HasTable(const TableName: string): Boolean;
    function GetAllTables: TArray<string>;
    procedure Refresh;
    procedure Clear;
  end;

implementation

end.
