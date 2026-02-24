unit DictionaryService;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB,
  UniContext, UniPlugin.Types,
  DictionaryService.Intf, DictionaryDataModule;

type
  /// <summary>
  /// 字典服务类 - 字典业务逻辑实现
  /// </summary>
  TDictionaryService = class(TInterfacedObject, IDictionaryService)
  private
    FContext: IExecutionContext;
    FDataModule: TDictionaryDataModule;
    FDictCache: TDictionary<string, TDictionary<string, string>>; // TypeCode -> (ItemCode -> ItemValue)

    procedure InitializeDataModule;
    procedure FinalizeDataModule;
    procedure InitializeCache;
    procedure FinalizeCache;
    function DataSetToDictTypeInfo(const DataSet: TDataSet): TDictTypeInfo;
    function DataSetToDictItemInfo(const DataSet: TDataSet): TDictItemInfo;
    function GetStatusText(Status: Integer): string;
    procedure LoadDictCache;
    procedure RefreshDictCache(const TypeCode: string = '');
  public
    constructor Create(const Context: IExecutionContext); reintroduce;
    destructor Destroy; override;

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

{ TDictionaryService }

constructor TDictionaryService.Create(const Context: IExecutionContext);
begin
  inherited Create;
  FContext := Context;
  InitializeDataModule;
  InitializeCache;
  LoadDictCache;
end;

destructor TDictionaryService.Destroy;
begin
  FinalizeCache;
  FinalizeDataModule;
  inherited;
end;

procedure TDictionaryService.InitializeDataModule;
begin
  FDataModule := TDictionaryDataModule.Create(nil);
  if Supports(FDataModule, IContextAware) then
    (FDataModule as IContextAware).SetContext(FContext);
  FDataModule.Open;
end;

procedure TDictionaryService.FinalizeDataModule;
begin
  if Assigned(FDataModule) then
  begin
    FDataModule.Close;
    FDataModule.Free;
  end;
end;

procedure TDictionaryService.InitializeCache;
begin
  FDictCache := TDictionary<string, TDictionary<string, string>>.Create;
end;

procedure TDictionaryService.FinalizeCache;
var
  LPair: TPair<string, TDictionary<string, string>>;
begin
  if Assigned(FDictCache) then
  begin
    for LPair in FDictCache do
      LPair.Value.Free;
    FDictCache.Clear;
    FDictCache.Free;
  end;
end;

procedure TDictionaryService.LoadDictCache;
var
  LTypesDataSet: TDataSet;
  LItemsDataSet: TDataSet;
  LTypeCode: string;
  LItemDict: TDictionary<string, string>;
begin
  FDictCache.Clear;

  // 加载所有字典类型
  LTypesDataSet := FDataModule.GetDictTypes('', 1);
  try
    while not LTypesDataSet.Eof do
    begin
      LTypeCode := LTypesDataSet.FieldByName('TypeCode').AsString;

      // 创建该类型的字典项缓存
      LItemDict := TDictionary<string, string>.Create;
      FDictCache.Add(LTypeCode, LItemDict);

      // 加载该类型的字典项
      LItemsDataSet := FDataModule.GetDictItemsByCode(LTypeCode, 1);
      try
        while not LItemsDataSet.Eof do
        begin
          LItemDict.Add(
            LItemsDataSet.FieldByName('ItemCode').AsString,
            LItemsDataSet.FieldByName('ItemValue').AsString
          );
          LItemsDataSet.Next;
        end;
      finally
        LItemsDataSet.Free;
      end;

      LTypesDataSet.Next;
    end;
  finally
    LTypesDataSet.Free;
  end;
end;

procedure TDictionaryService.RefreshDictCache(const TypeCode: string);
begin
  if TypeCode.IsEmpty then
    LoadDictCache
  else
  begin
    // 刷新指定类型的缓存
    if FDictCache.ContainsKey(TypeCode) then
    begin
      FDictCache[TypeCode].Clear;
      FDictCache.Remove(TypeCode);
    end;

    // 重新加载该类型
    LItemDict := TDictionary<string, string>.Create;
    FDictCache.Add(TypeCode, LItemDict);

    LItemsDataSet := FDataModule.GetDictItemsByCode(TypeCode, 1);
    try
      while not LItemsDataSet.Eof do
      begin
        LItemDict.Add(
          LItemsDataSet.FieldByName('ItemCode').AsString,
          LItemsDataSet.FieldByName('ItemValue').AsString
        );
        LItemsDataSet.Next;
      end;
    finally
      LItemsDataSet.Free;
    end;
  end;
end;

function TDictionaryService.DataSetToDictTypeInfo(const DataSet: TDataSet): TDictTypeInfo;
begin
  Result.TypeID := DataSet.FieldByName('TypeID').AsInteger;
  Result.TypeCode := DataSet.FieldByName('TypeCode').AsString;
  Result.TypeName := DataSet.FieldByName('TypeName').AsString;
  Result.Description := DataSet.FieldByName('Description').AsString;
  Result.SortOrder := DataSet.FieldByName('SortOrder').AsInteger;
  Result.Status := DataSet.FieldByName('Status').AsInteger;
  Result.StatusText := GetStatusText(Result.Status);

  if not DataSet.FieldByName('CreatedDate').IsNull then
    Result.CreatedDate := DataSet.FieldByName('CreatedDate').AsDateTime
  else
    Result.CreatedDate := 0;

  Result.CreatedBy := DataSet.FieldByName('CreatedBy').AsInteger;

  if not DataSet.FieldByName('ModifiedDate').IsNull then
    Result.ModifiedDate := DataSet.FieldByName('ModifiedDate').AsDateTime
  else
    Result.ModifiedDate := 0;

  Result.ModifiedBy := DataSet.FieldByName('ModifiedBy').AsInteger;
  Result.ItemCount := DataSet.FieldByName('ItemCount').AsInteger;
end;

function TDictionaryService.DataSetToDictItemInfo(const DataSet: TDataSet): TDictItemInfo;
begin
  Result.ItemID := DataSet.FieldByName('ItemID').AsInteger;
  Result.TypeID := DataSet.FieldByName('TypeID').AsInteger;
  Result.TypeCode := DataSet.FieldByName('TypeCode').AsString;
  Result.TypeName := DataSet.FieldByName('TypeName').AsString;
  Result.ItemCode := DataSet.FieldByName('ItemCode').AsString;
  Result.ItemName := DataSet.FieldByName('ItemName').AsString;
  Result.ItemValue := DataSet.FieldByName('ItemValue').AsString;
  Result.SortOrder := DataSet.FieldByName('SortOrder').AsInteger;
  Result.Status := DataSet.FieldByName('Status').AsInteger;
  Result.StatusText := GetStatusText(Result.Status);
  Result.Remark := DataSet.FieldByName('Remark').AsString;

  if not DataSet.FieldByName('CreatedDate').IsNull then
    Result.CreatedDate := DataSet.FieldByName('CreatedDate').AsDateTime
  else
    Result.CreatedDate := 0;

  Result.CreatedBy := DataSet.FieldByName('CreatedBy').AsInteger;

  if not DataSet.FieldByName('ModifiedDate').IsNull then
    Result.ModifiedDate := DataSet.FieldByName('ModifiedDate').AsDateTime
  else
    Result.ModifiedDate := 0;

  Result.ModifiedBy := DataSet.FieldByName('ModifiedBy').AsInteger;
end;

function TDictionaryService.GetStatusText(Status: Integer): string;
begin
  case Status of
    0: Result := '禁用';
    1: Result := '启用';
    else
      Result := '未知';
  end;
end;

function TDictionaryService.GetDictTypes(const Filter: string; Status: Integer): TArray<TDictTypeInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TDictTypeInfo>;
begin
  LList := TList<TDictTypeInfo>.Create;
  try
    LDataSet := FDataModule.GetDictTypes(Filter, Status);
    try
      while not LDataSet.Eof do
      begin
        LList.Add(DataSetToDictTypeInfo(LDataSet));
        LDataSet.Next;
      end;
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TDictionaryService.GetDictTypeByID(TypeID: Integer): TDictTypeInfo;
var
  LDataSet: TDataSet;
begin
  Result := TDictTypeInfo.Create;

  LDataSet := FDataModule.GetDictTypeByID(TypeID);
  try
    if not LDataSet.Eof then
      Result := DataSetToDictTypeInfo(LDataSet)
    else
      raise Exception.CreateFmt('字典类型 ID %d 不存在', [TypeID]);
  finally
    LDataSet.Free;
  end;
end;

function TDictionaryService.GetDictTypeByCode(const TypeCode: string): TDictTypeInfo;
var
  LDataSet: TDataSet;
begin
  Result := TDictTypeInfo.Create;

  LDataSet := FDataModule.GetDictTypeByCode(TypeCode);
  try
    if not LDataSet.Eof then
      Result := DataSetToDictTypeInfo(LDataSet)
    else
      raise Exception.CreateFmt('字典类型 %s 不存在', [TypeCode]);
  finally
    LDataSet.Free;
  end;
end;

function TDictionaryService.CreateDictType(const TypeCode, TypeName, Description: string;
  SortOrder: Integer): Integer;
begin
  Result := FDataModule.CreateDictType(TypeCode, TypeName, Description, SortOrder);
  RefreshDictCache;
end;

procedure TDictionaryService.UpdateDictType(TypeID: Integer; const TypeName, Description: string;
  SortOrder: Integer);
begin
  FDataModule.UpdateDictType(TypeID, TypeName, Description, SortOrder);
  RefreshDictCache;
end;

procedure TDictionaryService.DeleteDictType(TypeID: Integer);
begin
  FDataModule.DeleteDictType(TypeID);
  RefreshDictCache;
end;

procedure TDictionaryService.SetDictTypeStatus(TypeID, Status: Integer);
begin
  FDataModule.SetDictTypeStatus(TypeID, Status);
  RefreshDictCache;
end;

function TDictionaryService.GetDictItemsByType(TypeID: Integer; Status: Integer): TArray<TDictItemInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TDictItemInfo>;
begin
  LList := TList<TDictItemInfo>.Create;
  try
    LDataSet := FDataModule.GetDictItemsByType(TypeID, Status);
    try
      while not LDataSet.Eof do
      begin
        LList.Add(DataSetToDictItemInfo(LDataSet));
        LDataSet.Next;
      end;
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TDictionaryService.GetDictItemsByCode(const TypeCode: string; Status: Integer): TArray<TDictItemInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TDictItemInfo>;
begin
  LList := TList<TDictItemInfo>.Create;
  try
    LDataSet := FDataModule.GetDictItemsByCode(TypeCode, Status);
    try
      while not LDataSet.Eof do
      begin
        LList.Add(DataSetToDictItemInfo(LDataSet));
        LDataSet.Next;
      end;
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TDictionaryService.GetAllDictItems(const Filter: string; Status: Integer): TArray<TDictItemInfo>;
var
  LDataSet: TDataSet;
  LList: TList<TDictItemInfo>;
begin
  LList := TList<TDictItemInfo>.Create;
  try
    LDataSet := FDataModule.GetAllDictItems(Filter, Status);
    try
      while not LDataSet.Eof do
      begin
        LList.Add(DataSetToDictItemInfo(LDataSet));
        LDataSet.Next;
      end;
      Result := LList.ToArray;
    finally
      LDataSet.Free;
    end;
  finally
    LList.Free;
  end;
end;

function TDictionaryService.GetDictItemByID(ItemID: Integer): TDictItemInfo;
var
  LDataSet: TDataSet;
begin
  Result := TDictItemInfo.Create;

  LDataSet := FDataModule.GetDictItemByID(ItemID);
  try
    if not LDataSet.Eof then
      Result := DataSetToDictItemInfo(LDataSet)
    else
      raise Exception.CreateFmt('字典项 ID %d 不存在', [ItemID]);
  finally
    LDataSet.Free;
  end;
end;

function TDictionaryService.CreateDictItem(TypeID: Integer; const ItemCode, ItemName, ItemValue,
  Remark: string; SortOrder: Integer): Integer;
begin
  Result := FDataModule.CreateDictItem(TypeID, ItemCode, ItemName, ItemValue, Remark, SortOrder);
  RefreshDictCache;
end;

procedure TDictionaryService.UpdateDictItem(ItemID: Integer; const ItemCode, ItemName, ItemValue,
  Remark: string; SortOrder: Integer);
begin
  FDataModule.UpdateDictItem(ItemID, ItemCode, ItemName, ItemValue, Remark, SortOrder);
  RefreshDictCache;
end;

procedure TDictionaryService.DeleteDictItem(ItemID: Integer);
begin
  FDataModule.DeleteDictItem(ItemID);
  RefreshDictCache;
end;

procedure TDictionaryService.SetDictItemStatus(ItemID, Status: Integer);
begin
  FDataModule.SetDictItemStatus(ItemID, Status);
  RefreshDictCache;
end;

function TDictionaryService.GetDictItemValue(const TypeCode, ItemCode: string): string;
begin
  if FDictCache.ContainsKey(TypeCode) then
  begin
    if FDictCache[TypeCode].ContainsKey(ItemCode) then
      Result := FDictCache[TypeCode][ItemCode]
    else
      Result := '';
  end
  else
  begin
    // 缓存中没有，从数据库查询
    Result := FDataModule.GetDictItemValue(TypeCode, ItemCode);
  end;
end;

function TDictionaryService.GetDictItemText(const TypeCode, ItemValue: string): string;
var
  LItems: TArray<TDictItemInfo>;
  LItem: TDictItemInfo;
begin
  Result := '';

  // 从缓存中查找（反向查找）
  if FDictCache.ContainsKey(TypeCode) then
  begin
    for LPair in FDictCache[TypeCode] do
    begin
      if LPair.Value = ItemValue then
      begin
        Result := LPair.Key;
        Exit;
      end;
    end;
  end;

  // 缓存中没有，从数据库查询
  LItems := GetDictItemsByCode(TypeCode, 1);
  for LItem in LItems do
  begin
    if LItem.ItemValue = ItemValue then
    begin
      Result := LItem.ItemCode;
      Exit;
    end;
  end;
end;

procedure TDictionaryService.ClearDictCache;
begin
  LoadDictCache;
end;

end.
