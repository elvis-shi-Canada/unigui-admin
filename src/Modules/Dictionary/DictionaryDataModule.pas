unit DictionaryDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  UniContext, UniPlugin.Types, UniDataModule,
  DictionaryService.Intf;

type
  /// <summary>
  /// 数据字典数据模块 - 提供字典类型和字典项的 CRUD 操作
  /// </summary>
  TDictionaryDataModule = class(TUniDataModule)
  public
    // 字典类型操作
    function GetDictTypeByID(TypeID: Integer): TDataSet;
    function GetDictTypeByCode(const TypeCode: string): TDataSet;
    function GetDictTypes(const Filter: string; Status: Integer = -1): TDataSet;
    function CreateDictType(const TypeCode, TypeName, Description: string;
      SortOrder: Integer): Integer;
    procedure UpdateDictType(TypeID: Integer; const TypeName, Description: string;
      SortOrder: Integer);
    procedure DeleteDictType(TypeID: Integer);
    procedure SetDictTypeStatus(TypeID, Status: Integer);
    function DictTypeCodeExists(const TypeCode: string; ExcludeID: Integer = 0): Boolean;

    // 字典项操作
    function GetDictItemByID(ItemID: Integer): TDataSet;
    function GetDictItemsByType(TypeID: Integer; Status: Integer = -1): TDataSet;
    function GetDictItemsByCode(const TypeCode: string; Status: Integer = -1): TDataSet;
    function GetAllDictItems(const Filter: string; Status: Integer = -1): TDataSet;
    function CreateDictItem(TypeID: Integer; const ItemCode, ItemName, ItemValue, Remark: string;
      SortOrder: Integer): Integer;
    procedure UpdateDictItem(ItemID: Integer; const ItemCode, ItemName, ItemValue, Remark: string;
      SortOrder: Integer);
    procedure DeleteDictItem(ItemID: Integer);
    procedure SetDictItemStatus(ItemID, Status: Integer);
    function DictItemCodeExists(TypeID: Integer; const ItemCode: string;
      ExcludeID: Integer = 0): Boolean;

    // 辅助方法
    function GetDictTypeName(TypeID: Integer): string;
    function GetDictItemValue(const TypeCode, ItemCode: string): string;
    procedure ClearDictItemsByType(TypeID: Integer);
  end;

implementation

{ TDictionaryDataModule }

function TDictionaryDataModule.GetDictTypeByID(TypeID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT t.*, (SELECT COUNT(*) FROM UniAdmin_DictItems i WHERE i.TypeID = t.TypeID AND i.Status = 1) AS ItemCount ' +
      'FROM UniAdmin_DictTypes t ' +
      'WHERE t.TypeID = :TypeID';
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TDictionaryDataModule.GetDictTypeByCode(const TypeCode: string): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT t.*, (SELECT COUNT(*) FROM UniAdmin_DictItems i WHERE i.TypeID = t.TypeID AND i.Status = 1) AS ItemCount ' +
      'FROM UniAdmin_DictTypes t ' +
      'WHERE t.TypeCode = :TypeCode';
    LQuery.Params.ParamByName('TypeCode').AsString := TypeCode;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TDictionaryDataModule.GetDictTypes(const Filter: string; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT t.*, (SELECT COUNT(*) FROM UniAdmin_DictItems i WHERE i.TypeID = t.TypeID AND i.Status = 1) AS ItemCount ' +
            'FROM UniAdmin_DictTypes t';

    if Filter <> '' then
      LWhereList.Add('(t.TypeCode LIKE :Filter OR t.TypeName LIKE :Filter)');

    if Status >= 0 then
      LWhereList.Add('t.Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY t.SortOrder, t.TypeID';

    LQuery.SQL.Text := LSQL;

    if Filter <> '' then
      LQuery.Params.ParamByName('Filter').AsString := '%' + Filter + '%';

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TDictionaryDataModule.CreateDictType(const TypeCode, TypeName, Description: string;
  SortOrder: Integer): Integer;
var
  LQuery: TFDQuery;
begin
  if TypeCode.Trim.IsEmpty then
    raise Exception.Create('字典类型编码不能为空');

  if TypeName.Trim.IsEmpty then
    raise Exception.Create('字典类型名称不能为空');

  if DictTypeCodeExists(TypeCode) then
    raise Exception.Create('字典类型编码已存在');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_DictTypes ' +
      '(TypeCode, TypeName, Description, SortOrder, Status, CreatedDate, CreatedBy) ' +
      'VALUES (:TypeCode, :TypeName, :Description, :SortOrder, 1, CURRENT_TIMESTAMP, :CreatedBy)';

    LQuery.Params.ParamByName('TypeCode').AsString := TypeCode;
    LQuery.Params.ParamByName('TypeName').AsString := TypeName;
    LQuery.Params.ParamByName('Description').AsString := Description;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;
    LQuery.Params.ParamByName('CreatedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;

    LQuery.SQL.Text := 'SELECT last_insert_rowid() AS NewID';
    LQuery.Open;
    Result := LQuery.FieldByName('NewID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.UpdateDictType(TypeID: Integer; const TypeName, Description: string;
  SortOrder: Integer);
var
  LQuery: TFDQuery;
begin
  if TypeName.Trim.IsEmpty then
    raise Exception.Create('字典类型名称不能为空');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_DictTypes ' +
      'SET TypeName = :TypeName, Description = :Description, SortOrder = :SortOrder, ' +
      'ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE TypeID = :TypeID';

    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Params.ParamByName('TypeName').AsString := TypeName;
    LQuery.Params.ParamByName('Description').AsString := Description;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;

    if LQuery.RowsAffected = 0 then
      raise Exception.Create('字典类型不存在');
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.DeleteDictType(TypeID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    // 检查是否有字典项
    LQuery.SQL.Text := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_DictItems WHERE TypeID = :TypeID AND Status = 1';
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Open;

    if LQuery.FieldByName('Cnt').AsInteger > 0 then
      raise Exception.Create('该字典类型下还有字典项，无法删除');

    LQuery.Close;

    LQuery.SQL.Text := 'DELETE FROM UniAdmin_DictTypes WHERE TypeID = :TypeID';
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.SetDictTypeStatus(TypeID, Status: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_DictTypes ' +
      'SET Status = :Status, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE TypeID = :TypeID';

    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Params.ParamByName('Status').AsInteger := Status;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TDictionaryDataModule.DictTypeCodeExists(const TypeCode: string; ExcludeID: Integer): Boolean;
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_DictTypes WHERE TypeCode = :TypeCode';

    if ExcludeID > 0 then
      LSQL := LSQL + ' AND TypeID <> :ExcludeID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('TypeCode').AsString := TypeCode;

    if ExcludeID > 0 then
      LQuery.Params.ParamByName('ExcludeID').AsInteger := ExcludeID;

    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TDictionaryDataModule.GetDictItemByID(ItemID: Integer): TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT i.*, t.TypeCode, t.TypeName ' +
      'FROM UniAdmin_DictItems i ' +
      'INNER JOIN UniAdmin_DictTypes t ON i.TypeID = t.TypeID ' +
      'WHERE i.ItemID = :ItemID';
    LQuery.Params.ParamByName('ItemID').AsInteger := ItemID;
    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TDictionaryDataModule.GetDictItemsByType(TypeID: Integer; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT i.*, t.TypeCode, t.TypeName ' +
            'FROM UniAdmin_DictItems i ' +
            'INNER JOIN UniAdmin_DictTypes t ON i.TypeID = t.TypeID ' +
            'WHERE i.TypeID = :TypeID';

    if Status >= 0 then
      LSQL := LSQL + ' AND i.Status = :Status';

    LSQL := LSQL + ' ORDER BY i.SortOrder, i.ItemID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TDictionaryDataModule.GetDictItemsByCode(const TypeCode: string; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT i.*, t.TypeCode, t.TypeName ' +
            'FROM UniAdmin_DictItems i ' +
            'INNER JOIN UniAdmin_DictTypes t ON i.TypeID = t.TypeID ' +
            'WHERE t.TypeCode = :TypeCode';

    if Status >= 0 then
      LSQL := LSQL + ' AND i.Status = :Status';

    LSQL := LSQL + ' ORDER BY i.SortOrder, i.ItemID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('TypeCode').AsString := TypeCode;

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    raise;
  end;
end;

function TDictionaryDataModule.GetAllDictItems(const Filter: string; Status: Integer): TDataSet;
var
  LQuery: TFDQuery;
  LSQL: string;
  LWhere: string;
  LWhereList: TStringList;
begin
  LQuery := TFDQuery.Create(nil);
  LWhereList := TStringList.Create;
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT i.*, t.TypeCode, t.TypeName ' +
            'FROM UniAdmin_DictItems i ' +
            'INNER JOIN UniAdmin_DictTypes t ON i.TypeID = t.TypeID';

    if Filter <> '' then
      LWhereList.Add('(i.ItemCode LIKE :Filter OR i.ItemName LIKE :Filter OR t.TypeName LIKE :Filter)');

    if Status >= 0 then
      LWhereList.Add('i.Status = :Status');

    if LWhereList.Count > 0 then
    begin
      LWhere := ' WHERE ' + LWhereList.Text.Replace(#13#10, ' AND ');
      LSQL := LSQL + LWhere;
    end;

    LSQL := LSQL + ' ORDER BY t.SortOrder, t.TypeID, i.SortOrder, i.ItemID';

    LQuery.SQL.Text := LSQL;

    if Filter <> '' then
      LQuery.Params.ParamByName('Filter').AsString := '%' + Filter + '%';

    if Status >= 0 then
      LQuery.Params.ParamByName('Status').AsInteger := Status;

    LQuery.Open;
    Result := LQuery;
  except
    LQuery.Free;
    LWhereList.Free;
    raise;
  end;
  LWhereList.Free;
end;

function TDictionaryDataModule.CreateDictItem(TypeID: Integer; const ItemCode, ItemName, ItemValue,
  Remark: string; SortOrder: Integer): Integer;
var
  LQuery: TFDQuery;
begin
  if ItemCode.Trim.IsEmpty then
    raise Exception.Create('字典项编码不能为空');

  if ItemName.Trim.IsEmpty then
    raise Exception.Create('字典项名称不能为空');

  if DictItemCodeExists(TypeID, ItemCode) then
    raise Exception.Create('字典项编码在该类型下已存在');

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'INSERT INTO UniAdmin_DictItems ' +
      '(TypeID, ItemCode, ItemName, ItemValue, Remark, SortOrder, Status, CreatedDate, CreatedBy) ' +
      'VALUES (:TypeID, :ItemCode, :ItemName, :ItemValue, :Remark, :SortOrder, 1, CURRENT_TIMESTAMP, :CreatedBy)';

    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Params.ParamByName('ItemCode').AsString := ItemCode;
    LQuery.Params.ParamByName('ItemName').AsString := ItemName;
    LQuery.Params.ParamByName('ItemValue').AsString := ItemValue;
    LQuery.Params.ParamByName('Remark').AsString := Remark;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;
    LQuery.Params.ParamByName('CreatedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;

    LQuery.SQL.Text := 'SELECT last_insert_rowid() AS NewID';
    LQuery.Open;
    Result := LQuery.FieldByName('NewID').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.UpdateDictItem(ItemID: Integer; const ItemCode, ItemName, ItemValue,
  Remark: string; SortOrder: Integer);
var
  LQuery: TFDQuery;
  LTypeID: Integer;
begin
  if ItemCode.Trim.IsEmpty then
    raise Exception.Create('字典项编码不能为空');

  if ItemName.Trim.IsEmpty then
    raise Exception.Create('字典项名称不能为空');

  // 获取 TypeID 用于验证唯一性
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT TypeID FROM UniAdmin_DictItems WHERE ItemID = :ItemID';
    LQuery.Params.ParamByName('ItemID').AsInteger := ItemID;
    LQuery.Open;

    if LQuery.Eof then
      raise Exception.Create('字典项不存在');

    LTypeID := LQuery.FieldByName('TypeID').AsInteger;
    LQuery.Close;

    if DictItemCodeExists(LTypeID, ItemCode, ItemID) then
      raise Exception.Create('字典项编码在该类型下已存在');

    LQuery.SQL.Text :=
      'UPDATE UniAdmin_DictItems ' +
      'SET ItemCode = :ItemCode, ItemName = :ItemName, ItemValue = :ItemValue, ' +
      'Remark = :Remark, SortOrder = :SortOrder, ' +
      'ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE ItemID = :ItemID';

    LQuery.Params.ParamByName('ItemID').AsInteger := ItemID;
    LQuery.Params.ParamByName('ItemCode').AsString := ItemCode;
    LQuery.Params.ParamByName('ItemName').AsString := ItemName;
    LQuery.Params.ParamByName('ItemValue').AsString := ItemValue;
    LQuery.Params.ParamByName('Remark').AsString := Remark;
    LQuery.Params.ParamByName('SortOrder').AsInteger := SortOrder;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;

    if LQuery.RowsAffected = 0 then
      raise Exception.Create('字典项不存在');
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.DeleteDictItem(ItemID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_DictItems WHERE ItemID = :ItemID';
    LQuery.Params.ParamByName('ItemID').AsInteger := ItemID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.SetDictItemStatus(ItemID, Status: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'UPDATE UniAdmin_DictItems ' +
      'SET Status = :Status, ModifiedDate = CURRENT_TIMESTAMP, ModifiedBy = :ModifiedBy ' +
      'WHERE ItemID = :ItemID';

    LQuery.Params.ParamByName('ItemID').AsInteger := ItemID;
    LQuery.Params.ParamByName('Status').AsInteger := Status;
    LQuery.Params.ParamByName('ModifiedBy').AsInteger := GetCurrentUserID;

    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

function TDictionaryDataModule.DictItemCodeExists(TypeID: Integer; const ItemCode: string;
  ExcludeID: Integer): Boolean;
var
  LQuery: TFDQuery;
  LSQL: string;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;

    LSQL := 'SELECT COUNT(*) AS Cnt FROM UniAdmin_DictItems WHERE TypeID = :TypeID AND ItemCode = :ItemCode';

    if ExcludeID > 0 then
      LSQL := LSQL + ' AND ItemID <> :ExcludeID';

    LQuery.SQL.Text := LSQL;
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Params.ParamByName('ItemCode').AsString := ItemCode;

    if ExcludeID > 0 then
      LQuery.Params.ParamByName('ExcludeID').AsInteger := ExcludeID;

    LQuery.Open;
    Result := LQuery.FieldByName('Cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TDictionaryDataModule.GetDictTypeName(TypeID: Integer): string;
var
  LQuery: TFDQuery;
begin
  Result := '';

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'SELECT TypeName FROM UniAdmin_DictTypes WHERE TypeID = :TypeID';
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.Open;

    if not LQuery.Eof then
      Result := LQuery.FieldByName('TypeName').AsString;
  finally
    LQuery.Free;
  end;
end;

function TDictionaryDataModule.GetDictItemValue(const TypeCode, ItemCode: string): string;
var
  LQuery: TFDQuery;
begin
  Result := '';

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text :=
      'SELECT i.ItemValue ' +
      'FROM UniAdmin_DictItems i ' +
      'INNER JOIN UniAdmin_DictTypes t ON i.TypeID = t.TypeID ' +
      'WHERE t.TypeCode = :TypeCode AND i.ItemCode = :ItemCode AND i.Status = 1';

    LQuery.Params.ParamByName('TypeCode').AsString := TypeCode;
    LQuery.Params.ParamByName('ItemCode').AsString := ItemCode;
    LQuery.Open;

    if not LQuery.Eof then
      Result := LQuery.FieldByName('ItemValue').AsString;
  finally
    LQuery.Free;
  end;
end;

procedure TDictionaryDataModule.ClearDictItemsByType(TypeID: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := 'DELETE FROM UniAdmin_DictItems WHERE TypeID = :TypeID';
    LQuery.Params.ParamByName('TypeID').AsInteger := TypeID;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
