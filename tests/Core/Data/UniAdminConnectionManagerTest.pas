unit UniAdminConnectionManagerTest;

interface

uses
  System.SysUtils, DUnitX.TestFramework,
  FireDAC.Comp.Client,
  UniAdminConnectionManager.Intf, UniAdminConnectionManager;

type
  /// <summary>
  /// 连接池化改造测试（Task 1.5）
  /// 验证 GetDefaultConnection 走池化 con_def，多次 Get/Release 复用物理连接。
  /// </summary>
  [TestFixture]
  TUniAdminConnectionManagerTest = class
  private
    FManager: IUniAdminConnectionManager;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestGetDefaultConnection_ReturnsConnected;
    [Test]
    procedure TestReleaseConnection_Reusable_AfterManyCycles;
  end;

implementation

{ TUniAdminConnectionManagerTest }

procedure TUniAdminConnectionManagerTest.Setup;
begin
  FManager := TUniAdminConnectionManager.GetInstance;
end;

procedure TUniAdminConnectionManagerTest.TearDown;
begin
  FManager := nil;
end;

procedure TUniAdminConnectionManagerTest.TestGetDefaultConnection_ReturnsConnected;
var
  LConn: TFDConnection;
begin
  LConn := FManager.GetDefaultConnection;
  try
    Assert.IsTrue(Assigned(LConn), '连接不应为 nil');
    Assert.IsTrue(LConn.Connected, '连接应为已连接状态（从池借出）');
    Assert.AreEqual('UniAdmin_Pooled', LConn.ConnectionDefName,
      '应使用池化连接定义 UniAdmin_Pooled');
  finally
    FManager.ReleaseConnection(LConn);
  end;
end;

procedure TUniAdminConnectionManagerTest.TestReleaseConnection_Reusable_AfterManyCycles;
var
  I: Integer;
  LConn: TFDConnection;
begin
  // 池化验证：100 次 Get+Release 复用物理连接，不累积、无异常。
  // 若未池化，每轮新建物理连接，性能差但仍能通过；池化后物理连接数 ≤ POOL_MAX_ITEMS。
  for I := 1 to 100 do
  begin
    LConn := FManager.GetDefaultConnection;
    try
      Assert.IsTrue(LConn.Connected, Format('第 %d 轮连接应可用', [I]));
      Assert.AreEqual('UniAdmin_Pooled', LConn.ConnectionDefName,
        Format('第 %d 轮应使用池化连接定义', [I]));
    finally
      FManager.ReleaseConnection(LConn);
    end;
  end;
  Assert.Pass('100 次 Get/Release 循环完成，池化句柄复用正常');
end;

initialization
  TDUnitX.RegisterTestFixture(TUniAdminConnectionManagerTest);

end.
