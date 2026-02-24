unit LogTest;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  DUnitX.TestFramework,
  UniContext, UniPlugin.Types,
  LogService, LogDataModule;

type
  /// <summary>
  /// 日志审计模块测试
  /// </summary>
  [TestFixture]
  TLogTest = class(TObject)
  private
    FContext: IExecutionContext;
    FService: TLogService;

    procedure CreateTestContext;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // 登录日志测试
    [Test]
    procedure TestLogLogin_Success_Success;
    [Test]
    procedure TestLogLogin_Failure_Success;
    [Test]
    procedure TestLogLogout_Success;
    [Test]
    procedure TestGetLoginLogs_Filter_Success;

    // 操作日志测试
    [Test]
    procedure TestLogOperation_Success_Success;
    [Test]
    procedure TestLogOperation_Failure_Success;
    [Test]
    procedure TestGetOperationLogs_Filter_Success;

    // 数据变更日志测试
    [Test]
    procedure TestLogDataChange_Insert_Success;
    [Test]
    procedure TestLogDataChange_Update_Success;
    [Test]
    procedure TestLogDataChange_Delete_Success;
    [Test]
    procedure TestGetDataChangeLogs_Filter_Success;

    // 日志清理测试
    [Test]
    procedure TestCleanOldLogs_Success;
  end;

implementation

{ TLogTest }

procedure TLogTest.Setup;
begin
  CreateTestContext;
  FService := TLogService.Create(FContext);
end;

procedure TLogTest.TearDown;
begin
  if Assigned(FService) then
    FService.Free;
end;

procedure TLogTest.CreateTestContext;
begin
  // 创建测试上下文
end;

procedure TLogTest.TestLogLogin_Success_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogLogin(1, 'testuser', '192.168.1.100', 'Mozilla/5.0', 1, '');
    end
  );
end;

procedure TLogTest.TestLogLogin_Failure_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogLogin(0, 'testuser', '192.168.1.100', 'Mozilla/5.0', 0, 'Invalid password');
    end
  );
end;

procedure TLogTest.TestLogLogout_Success;
begin
  // 先记录登录
  FService.LogLogin(1, 'testuser', '192.168.1.100', 'Mozilla/5.0', 1, '');

  Assert.WillNotRaise(
    procedure
    begin
      FService.LogLogout(1, 'testuser');
    end
  );
end;

procedure TLogTest.TestGetLoginLogs_Filter_Success;
var
  LLogs: TDataSet;
  LCount: Integer;
begin
  // 创建一些测试日志
  FService.LogLogin(1, 'testuser', '192.168.1.100', 'Mozilla/5.0', 1, '');
  FService.LogLogin(2, 'adminuser', '192.168.1.101', 'Mozilla/5.0', 1, '');

  LCount := FService.GetLoginLogCount('testuser', '', 0, 0, -1);
  Assert.IsTrue(LCount >= 1, 'Should have at least one log for testuser');

  LLogs := FService.GetLoginLogs('testuser', '', 0, 0, -1, 1, 10);
  try
    Assert.IsTrue(LLogs.RecordCount >= 1, 'Should return at least one log');
  finally
    LLogs.Free;
  end;
end;

procedure TLogTest.TestLogOperation_Success_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogOperation(
        1,
        'testuser',
        'User',
        'Create',
        'Create new user',
        '{"username":"test"}',
        '{"success":true}',
        '192.168.1.100',
        'Mozilla/5.0',
        100,
        1
      );
    end
  );
end;

procedure TLogTest.TestLogOperation_Failure_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogOperation(
        1,
        'testuser',
        'User',
        'Create',
        'Create new user',
        '{"username":"test"}',
        '{"success":false,"error":"Validation failed"}',
        '192.168.1.100',
        'Mozilla/5.0',
        50,
        0
      );
    end
  );
end;

procedure TLogTest.TestGetOperationLogs_Filter_Success;
var
  LLogs: TDataSet;
  LCount: Integer;
begin
  FService.LogOperation(
    1,
    'testuser',
    'User',
    'Create',
    'Create new user',
    '{}',
    '{}',
    '192.168.1.100',
    'Mozilla/5.0',
    100,
    1
  );

  LCount := FService.GetOperationLogCount('testuser', '', 0, 0, -1);
  Assert.IsTrue(LCount >= 1, 'Should have at least one operation log for testuser');

  LLogs := FService.GetOperationLogs('testuser', '', 0, 0, -1, 1, 10);
  try
    Assert.IsTrue(LLogs.RecordCount >= 1, 'Should return at least one log');
  finally
    LLogs.Free;
  end;
end;

procedure TLogTest.TestLogDataChange_Insert_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogDataChange(
        1,
        'testuser',
        'UniAdmin_Users',
        100,
        'INSERT',
        '',
        '{"UserID":100,"UserName":"test"}'
      );
    end
  );
end;

procedure TLogTest.TestLogDataChange_Update_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogDataChange(
        1,
        'testuser',
        'UniAdmin_Users',
        100,
        'UPDATE',
        '{"UserName":"oldname"}',
        '{"UserName":"newname"}'
      );
    end
  );
end;

procedure TLogTest.TestLogDataChange_Delete_Success;
begin
  Assert.WillNotRaise(
    procedure
    begin
      FService.LogDataChange(
        1,
        'testuser',
        'UniAdmin_Users',
        100,
        'DELETE',
        '{"UserID":100,"UserName":"test"}',
        ''
      );
    end
  );
end;

procedure TLogTest.TestGetDataChangeLogs_Filter_Success;
var
  LLogs: TDataSet;
  LCount: Integer;
begin
  FService.LogDataChange(
    1,
    'testuser',
    'UniAdmin_Users',
    100,
    'INSERT',
    '',
    '{"UserID":100}'
  );

  LCount := FService.GetDataChangeLogCount('testuser', 'UniAdmin_Users', 0, 0);
  Assert.IsTrue(LCount >= 1, 'Should have at least one data change log');

  LLogs := FService.GetDataChangeLogs('testuser', 'UniAdmin_Users', 0, 0, 1, 10);
  try
    Assert.IsTrue(LLogs.RecordCount >= 1, 'Should return at least one log');
  finally
    LLogs.Free;
  end;
end;

procedure TLogTest.TestCleanOldLogs_Success;
begin
  // 清理365天前的日志（应该不会删除任何数据）
  Assert.WillNotRaise(
    procedure
    begin
      FService.CleanOldLogs(365);
    end
  );
end;

initialization
  TDUnitX.RegisterTestFixture(TLogTest);

end.
