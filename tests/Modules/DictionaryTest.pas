unit DictionaryTest;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  UniContext, UniPlugin.Types,
  DictionaryService.Intf, DictionaryService, DictionaryDataModule;

type
  /// <summary>
  /// 数据字典模块测试
  /// </summary>
  [TestFixture]
  TDictionaryTest = class(TObject)
  private
    FContext: IExecutionContext;
    FService: IDictionaryService;
    FTestTypeID: Integer;
    FTestItemID: Integer;

    procedure CreateTestContext;
    procedure CleanupTestData;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 字典类型测试
    [Test]
    procedure TestCreateDictType_ValidInput_Success;
    [Test]
    procedure TestCreateDictType_DuplicateCode_Failure;
    [Test]
    procedure TestUpdateDictType_ValidInput_Success;
    [Test]
    procedure TestDeleteDictType_HasItems_Failure;
    [Test]
    procedure TestSetDictTypeStatus_Success;

    // 字典项测试
    [Test]
    procedure TestCreateDictItem_ValidInput_Success;
    [Test]
    procedure TestCreateDictItem_DuplicateCode_Failure;
    [Test]
    procedure TestUpdateDictItem_ValidInput_Success;
    [Test]
    procedure TestDeleteDictItem_Success;
    [Test]
    procedure TestGetDictItemsByType_Success;

    // 辅助方法测试
    [Test]
    procedure TestGetDictItemValue_ValidCode_Success;
    [Test]
    procedure TestGetDictItemValue_InvalidCode_EmptyString;
  end;

implementation

{ TDictionaryTest }

procedure TDictionaryTest.Setup;
begin
  CreateTestContext;

  FService := TDictionaryService.Create(FContext);
end;

procedure TDictionaryTest.TearDown;
begin
  CleanupTestData;

  if Assigned(FService) then
    FService := nil;
end;

procedure TDictionaryTest.CreateTestContext;
begin
  // 创建测试上下文
  // TODO: 实现 Mock 上下文
end;

procedure TDictionaryTest.CleanupTestData;
begin
  // 清理测试数据
  if FTestItemID > 0 then
  begin
    // FService.DeleteDictItem(FTestItemID);
    FTestItemID := 0;
  end;

  if FTestTypeID > 0 then
  begin
    // FService.DeleteDictType(FTestTypeID);
    FTestTypeID := 0;
  end;
end;

procedure TDictionaryTest.TestCreateDictType_ValidInput_Success;
begin
  FTestTypeID := FService.CreateDictType('TEST_TYPE', '测试类型', '单元测试类型', 0);

  Assert.WillNotRaise(
    procedure
    var
      LTypeInfo: TDictTypeInfo;
    begin
      LTypeInfo := FService.GetDictTypeByID(FTestTypeID);
      Assert.AreEqual('TEST_TYPE', LTypeInfo.TypeCode);
      Assert.AreEqual('测试类型', LTypeInfo.TypeName);
    end
  );
end;

procedure TDictionaryTest.TestCreateDictType_DuplicateCode_Failure;
var
  LFirstID, LSecondID: Integer;
begin
  LFirstID := FService.CreateDictType('DUP_TYPE', '重复类型', '测试重复类型', 0);

  Assert.WillRaise(
    procedure
    begin
      LSecondID := FService.CreateDictType('DUP_TYPE', '重复类型2', '测试重复类型2', 0);
    end,
    Exception
  );

  // Cleanup
  // FService.DeleteDictType(LFirstID);
end;

procedure TDictionaryTest.TestUpdateDictType_ValidInput_Success;
var
  LTypeInfo: TDictTypeInfo;
begin
  FTestTypeID := FService.CreateDictType('UPDATE_TYPE', '更新类型', '测试更新类型', 0);

  FService.UpdateDictType(FTestTypeID, '更新类型修改', '测试更新类型修改', 10);

  LTypeInfo := FService.GetDictTypeByID(FTestTypeID);
  Assert.AreEqual('更新类型修改', LTypeInfo.TypeName);
  Assert.AreEqual(10, LTypeInfo.SortOrder);
end;

procedure TDictionaryTest.TestDeleteDictType_HasItems_Failure;
begin
  FTestTypeID := FService.CreateDictType('HAS_ITEMS_TYPE', '有项目类型', '测试有项目类型', 0);
  FTestItemID := FService.CreateDictItem(FTestTypeID, 'ITEM1', '项目1', '值1', '', 0);

  Assert.WillRaise(
    procedure
    begin
      FService.DeleteDictType(FTestTypeID);
    end,
    Exception
  );
end;

procedure TDictionaryTest.TestSetDictTypeStatus_Success;
var
  LTypeInfo: TDictTypeInfo;
begin
  FTestTypeID := FService.CreateDictType('STATUS_TYPE', '状态类型', '测试状态类型', 0);

  FService.SetDictTypeStatus(FTestTypeID, 0);

  LTypeInfo := FService.GetDictTypeByID(FTestTypeID);
  Assert.AreEqual(0, LTypeInfo.Status);
end;

procedure TDictionaryTest.TestCreateDictItem_ValidInput_Success;
begin
  FTestTypeID := FService.CreateDictType('ITEM_TYPE', '字典项类型', '测试字典项类型', 0);
  FTestItemID := FService.CreateDictItem(FTestTypeID, 'ITEM_CODE', '项目名称', '项目值', '', 0);

  Assert.WillNotRaise(
    procedure
    var
      LItemInfo: TDictItemInfo;
    begin
      LItemInfo := FService.GetDictItemByID(FTestItemID);
      Assert.AreEqual('ITEM_CODE', LItemInfo.ItemCode);
      Assert.AreEqual('项目名称', LItemInfo.ItemName);
    end
  );
end;

procedure TDictionaryTest.TestCreateDictItem_DuplicateCode_Failure;
var
  LFirstID, LSecondID: Integer;
begin
  FTestTypeID := FService.CreateDictType('DUP_ITEM_TYPE', '重复项目类型', '测试重复项目类型', 0);

  LFirstID := FService.CreateDictItem(FTestTypeID, 'DUP_ITEM', '重复项目', '值1', '', 0);

  Assert.WillRaise(
    procedure
    begin
      LSecondID := FService.CreateDictItem(FTestTypeID, 'DUP_ITEM', '重复项目2', '值2', '', 0);
    end,
    Exception
  );
end;

procedure TDictionaryTest.TestUpdateDictItem_ValidInput_Success;
var
  LItemInfo: TDictItemInfo;
begin
  FTestTypeID := FService.CreateDictType('UPDATE_ITEM_TYPE', '更新项目类型', '测试更新项目类型', 0);
  FTestItemID := FService.CreateDictItem(FTestTypeID, 'UPDATE_ITEM', '更新项目', '值1', '', 0);

  FService.UpdateDictItem(FTestItemID, 'UPDATE_ITEM', '更新项目修改', '值2', '备注', 10);

  LItemInfo := FService.GetDictItemByID(FTestItemID);
  Assert.AreEqual('更新项目修改', LItemInfo.ItemName);
  Assert.AreEqual('值2', LItemInfo.ItemValue);
end;

procedure TDictionaryTest.TestDeleteDictItem_Success;
begin
  FTestTypeID := FService.CreateDictType('DEL_ITEM_TYPE', '删除项目类型', '测试删除项目类型', 0);
  FTestItemID := FService.CreateDictItem(FTestTypeID, 'DEL_ITEM', '删除项目', '值1', '', 0);

  Assert.WillNotRaise(
    procedure
    begin
      FService.DeleteDictItem(FTestItemID);
    end
  );

  FTestItemID := 0; // 已删除
end;

procedure TDictionaryTest.TestGetDictItemsByType_Success;
var
  LItems: TArray<TDictItemInfo>;
begin
  FTestTypeID := FService.CreateDictType('GET_ITEMS_TYPE', '获取项目类型', '测试获取项目类型', 0);
  FService.CreateDictItem(FTestTypeID, 'ITEM1', '项目1', '值1', '', 0);
  FService.CreateDictItem(FTestTypeID, 'ITEM2', '项目2', '值2', '', 0);

  LItems := FService.GetDictItemsByType(FTestTypeID, 1);

  Assert.AreEqual(2, Length(LItems));
end;

procedure TDictionaryTest.TestGetDictItemValue_ValidCode_Success;
var
  LValue: string;
begin
  FTestTypeID := FService.CreateDictType('GET_VALUE_TYPE', '获取值类型', '测试获取值类型', 0);
  FService.CreateDictItem(FTestTypeID, 'KEY1', '键1', 'VALUE1', '', 0);

  LValue := FService.GetDictItemValue('GET_VALUE_TYPE', 'KEY1');

  Assert.AreEqual('VALUE1', LValue);
end;

procedure TDictionaryTest.TestGetDictItemValue_InvalidCode_EmptyString;
var
  LValue: string;
begin
  LValue := FService.GetDictItemValue('INVALID_TYPE', 'INVALID_KEY');

  Assert.AreEqual('', LValue);
end;

initialization
  TDUnitX.RegisterTestFixture(TDictionaryTest);

end.
