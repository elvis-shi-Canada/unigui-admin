unit DictionaryDataModule;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Def,
  UniContext, UniPlugin.Types;

type
  /// <summary>
  /// 数据字典记录
  /// </summary>
  TDictionary = record
    ID: Integer;
    DictCode: string;
    DictName: string;
    DictType: string;
    Description: string;
    SortOrder: Integer;
    IsActive: Boolean;
    CreatedAt: TDateTime;
    CreatedBy: Integer;
    UpdatedAt: TDateTime;
    UpdatedBy: Integer;
  end;

  /// <summary>
  /// 数据字典项记录
  /// </summary>
  TDictionaryItem = record
    ID: Integer;
    DictID: Integer;
    ItemCode: string;
    ItemName: string;
    ItemValue: string;
    SortOrder: Integer;
    IsActive: Boolean;
    Remark: string;
    CreatedAt: TDateTime;
    CreatedBy: Integer;
    UpdatedAt: TDateTime;
    UpdatedBy: Integer;
  end;

  /// <summary>
  /// 数据字典数据模块
  /// 实现上下文感知接口，支持数据访问操作
  /// </summary>
  TDictionaryDataModule = class(TDataModule, IContextAware)
  private
    FContext: IExecutionContext;
    FDConnection: TFDConnection;
    qryDictionaries: TFDQuery;
    qryDictionaryItems: TFDQuery;
    qryInsertDict: TFDQuery;
    qryUpdateDict: TFDQuery;
    qryDeleteDict: TFDQuery;

    function GetCurrentUserID: Integer;
    procedure SetConnectionProperties;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    // IContextAware 实现
    procedure SetContext(const Context: IExecutionContext);

    // 业务方法
    function GetDictionaries(const DictType: string = ''): TArray<TDictionary>;
    function GetDictionaryItems(const DictID: Integer): TArray<TDictionaryItem>;
    function GetDictionaryByCode(const DictCode: string): TDictionary;
    function AddDictionary(const DictCode, DictName, DictType, Description: string;
      SortOrder: Integer): Integer;
    function UpdateDictionary(const ID: Integer; const DictCode, DictName,
      DictType, Description: string; SortOrder: Integer): Boolean;
    function DeleteDictionary(const ID: Integer): Boolean;
    function AddDictionaryItem(const DictID: Integer; const ItemCode, ItemName,
      ItemValue, Remark: string; SortOrder: Integer): Integer;
    function UpdateDictionaryItem(const ID: Integer; const ItemCode, ItemName,
      ItemValue, Remark: string; SortOrder: Integer): Boolean;
    function DeleteDictionaryItem(const ID: Integer): Boolean;
  end;

implementation

{ TDictionaryDataModule }

procedure TDictionaryDataModule.AfterConstruction;
begin
  inherited;

  // 创建数据库连接组件
  FDConnection := TFDConnection.Create(nil);
  FDConnection.DriverName := 'MySQL';
  FDConnection.LoginPrompt := False;

  // 创建查询组件
  qryDictionaries := TFDQuery.Create(nil);
  qryDictionaries.Connection := FDConnection;

  qryDictionaryItems := TFDQuery.Create(nil);
  qryDictionaryItems.Connection := FDConnection;

  qryInsertDict := TFDQuery.Create(nil);
  qryInsertDict.Connection := FDConnection;

  qryUpdateDict := TFDQuery.Create(nil);
  qryUpdateDict.Connection := FDConnection;

  qryDeleteDict := TFDQuery.Create(nil);
  qryDeleteDict.Connection := FDConnection;

  // 设置连接属性
  SetConnectionProperties;
end;

procedure TDictionaryDataModule.BeforeDestruction;
begin
  // 释放查询组件
  qryDictionaries.Free;
  qryDictionaryItems.Free;
  qryInsertDict.Free;
  qryUpdateDict.Free;
  qryDeleteDict.Free;

  // 释放连接组件
  FDConnection.Free;

  inherited;
end;

procedure TDictionaryDataModule.SetConnectionProperties;
begin
  // 设置连接参数
  // 注意：实际连接参数应该从配置中读取
  // 这里仅作为示例
  FDConnection.Params.DriverName := 'MySQL';
  FDConnection.Params.Database := 'uniadmin';
  // 其他参数在运行时设置
end;

procedure TDictionaryDataModule.SetContext(const Context: IExecutionContext);
begin
  FContext := Context;

  // 如果有数据库配置，更新连接参数
  if (Context <> nil) and (Context.GetDatabaseConfig <> nil) then
  begin
    FDConnection.Params.Values['Database'] :=
      Context.GetDatabaseConfig.GetDatabaseName;
    FDConnection.Params.Values['Server'] :=
      Context.GetDatabaseConfig.GetServerName;
  end;
end;

function TDictionaryDataModule.GetCurrentUserID: Integer;
begin
  if FContext <> nil then
    Result := FContext.GetCurrentUserID
  else
    Result := 0;
end;

function TDictionaryDataModule.GetDictionaries(const DictType: string): TArray<TDictionary>;
var
  LList: TList<TDictionary>;
  LDict: TDictionary;
  LSQL: string;
begin
  LList := TList<TDictionary>.Create;
  try
    LSQL := 'SELECT * FROM sys_dictionaries WHERE is_active = 1';

    if DictType <> '' then
      LSQL := LSQL + ' AND dict_type = :DictType';

    LSQL := LSQL + ' ORDER BY sort_order, id';

    with qryDictionaries do
    begin
      Close;
      SQL.Text := LSQL;

      if DictType <> '' then
        ParamByName('DictType').AsString := DictType;

      Open;

      while not Eof do
      begin
        LDict.ID := FieldByName('id').AsInteger;
        LDict.DictCode := FieldByName('dict_code').AsString;
        LDict.DictName := FieldByName('dict_name').AsString;
        LDict.DictType := FieldByName('dict_type').AsString;
        LDict.Description := FieldByName('description').AsString;
        LDict.SortOrder := FieldByName('sort_order').AsInteger;
        LDict.IsActive := FieldByName('is_active').AsBoolean;
        LDict.CreatedAt := FieldByName('created_at').AsDateTime;
        LDict.CreatedBy := FieldByName('created_by').AsInteger;
        LDict.UpdatedAt := FieldByName('updated_at').AsDateTime;
        LDict.UpdatedBy := FieldByName('updated_by').AsInteger;

        LList.Add(LDict);
        Next;
      end;

      Close;
    end;

    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TDictionaryDataModule.GetDictionaryItems(const DictID: Integer): TArray<TDictionaryItem>;
var
  LList: TList<TDictionaryItem>;
  LItem: TDictionaryItem;
begin
  LList := TList<TDictionaryItem>.Create;
  try
    with qryDictionaryItems do
    begin
      Close;
      SQL.Text := 'SELECT * FROM sys_dictionary_items ' +
                  'WHERE dict_id = :DictID AND is_active = 1 ' +
                  'ORDER BY sort_order, id';
      ParamByName('DictID').AsInteger := DictID;
      Open;

      while not Eof do
      begin
        LItem.ID := FieldByName('id').AsInteger;
        LItem.DictID := FieldByName('dict_id').AsInteger;
        LItem.ItemCode := FieldByName('item_code').AsString;
        LItem.ItemName := FieldByName('item_name').AsString;
        LItem.ItemValue := FieldByName('item_value').AsString;
        LItem.SortOrder := FieldByName('sort_order').AsInteger;
        LItem.IsActive := FieldByName('is_active').AsBoolean;
        LItem.Remark := FieldByName('remark').AsString;
        LItem.CreatedAt := FieldByName('created_at').AsDateTime;
        LItem.CreatedBy := FieldByName('created_by').AsInteger;
        LItem.UpdatedAt := FieldByName('updated_at').AsDateTime;
        LItem.UpdatedBy := FieldByName('updated_by').AsInteger;

        LList.Add(LItem);
        Next;
      end;

      Close;
    end;

    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TDictionaryDataModule.GetDictionaryByCode(const DictCode: string): TDictionary;
begin
  with qryDictionaries do
  begin
    Close;
    SQL.Text := 'SELECT * FROM sys_dictionaries ' +
                'WHERE dict_code = :DictCode AND is_active = 1';
    ParamByName('DictCode').AsString := DictCode;
    Open;

    if not Eof then
    begin
      Result.ID := FieldByName('id').AsInteger;
      Result.DictCode := FieldByName('dict_code').AsString;
      Result.DictName := FieldByName('dict_name').AsString;
      Result.DictType := FieldByName('dict_type').AsString;
      Result.Description := FieldByName('description').AsString;
      Result.SortOrder := FieldByName('sort_order').AsInteger;
      Result.IsActive := FieldByName('is_active').AsBoolean;
      Result.CreatedAt := FieldByName('created_at').AsDateTime;
      Result.CreatedBy := FieldByName('created_by').AsInteger;
      Result.UpdatedAt := FieldByName('updated_at').AsDateTime;
      Result.UpdatedBy := FieldByName('updated_by').AsInteger;
    end
    else
    begin
      Result.ID := 0;
      Result.DictCode := '';
    end;

    Close;
  end;
end;

function TDictionaryDataModule.AddDictionary(const DictCode, DictName, DictType,
  Description: string; SortOrder: Integer): Integer;
begin
  with qryInsertDict do
  begin
    Close;
    SQL.Text := 'INSERT INTO sys_dictionaries ' +
                '(dict_code, dict_name, dict_type, description, sort_order, ' +
                'is_active, created_at, created_by, updated_at, updated_by) ' +
                'VALUES (:DictCode, :DictName, :DictType, :Description, :SortOrder, ' +
                '1, NOW(), :CreatedBy, NOW(), :UpdatedBy)';

    ParamByName('DictCode').AsString := DictCode;
    ParamByName('DictName').AsString := DictName;
    ParamByName('DictType').AsString := DictType;
    ParamByName('Description').AsString := Description;
    ParamByName('SortOrder').AsInteger := SortOrder;
    ParamByName('CreatedBy').AsInteger := GetCurrentUserID;
    ParamByName('UpdatedBy').AsInteger := GetCurrentUserID;

    ExecSQL;

    // 获取插入的ID
    Result := FDConnection.GetLastAutoGenValue('sys_dictionaries');
  end;
end;

function TDictionaryDataModule.UpdateDictionary(const ID: Integer; const DictCode,
  DictName, DictType, Description: string; SortOrder: Integer): Boolean;
begin
  with qryUpdateDict do
  begin
    Close;
    SQL.Text := 'UPDATE sys_dictionaries SET ' +
                'dict_code = :DictCode, ' +
                'dict_name = :DictName, ' +
                'dict_type = :DictType, ' +
                'description = :Description, ' +
                'sort_order = :SortOrder, ' +
                'updated_at = NOW(), ' +
                'updated_by = :UpdatedBy ' +
                'WHERE id = :ID';

    ParamByName('DictCode').AsString := DictCode;
    ParamByName('DictName').AsString := DictName;
    ParamByName('DictType').AsString := DictType;
    ParamByName('Description').AsString := Description;
    ParamByName('SortOrder').AsInteger := SortOrder;
    ParamByName('UpdatedBy').AsInteger := GetCurrentUserID;
    ParamByName('ID').AsInteger := ID;

    ExecSQL;
    Result := RowsAffected > 0;
  end;
end;

function TDictionaryDataModule.DeleteDictionary(const ID: Integer): Boolean;
begin
  with qryDeleteDict do
  begin
    Close;
    SQL.Text := 'UPDATE sys_dictionaries SET is_active = 0, ' +
                'updated_at = NOW(), updated_by = :UpdatedBy WHERE id = :ID';
    ParamByName('UpdatedBy').AsInteger := GetCurrentUserID;
    ParamByName('ID').AsInteger := ID;

    ExecSQL;
    Result := RowsAffected > 0;
  end;
end;

function TDictionaryDataModule.AddDictionaryItem(const DictID: Integer;
  const ItemCode, ItemName, ItemValue, Remark: string; SortOrder: Integer): Integer;
begin
  with qryInsertDict do
  begin
    Close;
    SQL.Text := 'INSERT INTO sys_dictionary_items ' +
                '(dict_id, item_code, item_name, item_value, remark, sort_order, ' +
                'is_active, created_at, created_by, updated_at, updated_by) ' +
                'VALUES (:DictID, :ItemCode, :ItemName, :ItemValue, :Remark, :SortOrder, ' +
                '1, NOW(), :CreatedBy, NOW(), :UpdatedBy)';

    ParamByName('DictID').AsInteger := DictID;
    ParamByName('ItemCode').AsString := ItemCode;
    ParamByName('ItemName').AsString := ItemName;
    ParamByName('ItemValue').AsString := ItemValue;
    ParamByName('Remark').AsString := Remark;
    ParamByName('SortOrder').AsInteger := SortOrder;
    ParamByName('CreatedBy').AsInteger := GetCurrentUserID;
    ParamByName('UpdatedBy').AsInteger := GetCurrentUserID;

    ExecSQL;

    // 获取插入的ID
    Result := FDConnection.GetLastAutoGenValue('sys_dictionary_items');
  end;
end;

function TDictionaryDataModule.UpdateDictionaryItem(const ID: Integer;
  const ItemCode, ItemName, ItemValue, Remark: string; SortOrder: Integer): Boolean;
begin
  with qryUpdateDict do
  begin
    Close;
    SQL.Text := 'UPDATE sys_dictionary_items SET ' +
                'item_code = :ItemCode, ' +
                'item_name = :ItemName, ' +
                'item_value = :ItemValue, ' +
                'remark = :Remark, ' +
                'sort_order = :SortOrder, ' +
                'updated_at = NOW(), ' +
                'updated_by = :UpdatedBy ' +
                'WHERE id = :ID';

    ParamByName('ItemCode').AsString := ItemCode;
    ParamByName('ItemName').AsString := ItemName;
    ParamByName('ItemValue').AsString := ItemValue;
    ParamByName('Remark').AsString := Remark;
    ParamByName('SortOrder').AsInteger := SortOrder;
    ParamByName('UpdatedBy').AsInteger := GetCurrentUserID;
    ParamByName('ID').AsInteger := ID;

    ExecSQL;
    Result := RowsAffected > 0;
  end;
end;

function TDictionaryDataModule.DeleteDictionaryItem(const ID: Integer): Boolean;
begin
  with qryDeleteDict do
  begin
    Close;
    SQL.Text := 'UPDATE sys_dictionary_items SET is_active = 0, ' +
                'updated_at = NOW(), updated_by = :UpdatedBy WHERE id = :ID';
    ParamByName('UpdatedBy').AsInteger := GetCurrentUserID;
    ParamByName('ID').AsInteger := ID;

    ExecSQL;
    Result := RowsAffected > 0;
  end;
end;

end.
