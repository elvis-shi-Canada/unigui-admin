unit DictionaryService.Intf;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  UniContext, UniPlugin.Types;

type
  /// <summary>
  /// 字典类型记录
  /// </summary>
  TDictTypeInfo = record
    TypeID: Integer;
    TypeCode: string;
    TypeName: string;
    Description: string;
    SortOrder: Integer;
    Status: Integer;
    StatusText: string;
    CreatedDate: TDateTime;
    CreatedBy: Integer;
    ModifiedDate: TDateTime;
    ModifiedBy: Integer;
    ItemCount: Integer;
  end;

  /// <summary>
  /// 字典项记录
  /// </summary>
  TDictItemInfo = record
    ItemID: Integer;
    TypeID: Integer;
    TypeCode: string;
    TypeName: string;
    ItemCode: string;
    ItemName: string;
    ItemValue: string;
    SortOrder: Integer;
    Status: Integer;
    StatusText: string;
    Remark: string;
    CreatedDate: TDateTime;
    CreatedBy: Integer;
    ModifiedDate: TDateTime;
    ModifiedBy: Integer;
  end;

  /// <summary>
  /// 字典服务接口
  /// </summary>
  IDictionaryService = interface(IInterface)
    ['{C8E9D7B4-A5F6-3E8C-D2A7-7B9F1E3D6C8A}']


    // 字典类型操作
    function GetDictTypes(const Filter: string; Status: Integer): TArray<TDictTypeInfo>;
    function GetDictTypeByID(TypeID: Integer): TDictTypeInfo;
    function GetDictTypeByCode(const TypeCode: string): TDictTypeInfo;
    function CreateDictType(const TypeCode, TypeName, Description: string;
      SortOrder: Integer): Integer;
    procedure UpdateDictType(TypeID: Integer; const TypeName, Description: string;
      SortOrder: Integer);
    procedure DeleteDictType(TypeID: Integer);
    procedure SetDictTypeStatus(TypeID, Status: Integer);

    // 字典项操作
    function GetDictItemsByType(TypeID: Integer; Status: Integer): TArray<TDictItemInfo>;
    function GetDictItemsByCode(const TypeCode: string; Status: Integer): TArray<TDictItemInfo>;
    function GetAllDictItems(const Filter: string; Status: Integer): TArray<TDictItemInfo>;
    function GetDictItemByID(ItemID: Integer): TDictItemInfo;
    function CreateDictItem(TypeID: Integer; const ItemCode, ItemName, ItemValue,
      Remark: string; SortOrder: Integer): Integer;
    procedure UpdateDictItem(ItemID: Integer; const ItemCode, ItemName, ItemValue,
      Remark: string; SortOrder: Integer);
    procedure DeleteDictItem(ItemID: Integer);
    procedure SetDictItemStatus(ItemID, Status: Integer);

    // 辅助方法
    function GetDictItemValue(const TypeCode, ItemCode: string): string;
    function GetDictItemText(const TypeCode, ItemValue: string): string;
    procedure ClearDictCache;
  end;

implementation

end.
