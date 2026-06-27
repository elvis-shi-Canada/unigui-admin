unit UniQueryBuilderTest;

interface

uses
  System.SysUtils, DUnitX.TestFramework,
  UniQueryBuilder;

type
  /// <summary>
  /// TQueryClauseBuilder 单元测试
  /// 验证参数化 SQL 生成与注入防护
  /// </summary>
  [TestFixture]
  TUniQueryBuilderTest = class
  private
    FBuilder: TQueryClauseBuilder;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestNoClause', '')]
    procedure TestNoClause;

    [Test]
    [TestCase('TestLikeClause', '')]
    procedure TestLikeClause;

    [Test]
    [TestCase('TestEqualClause', '')]
    procedure TestEqualClause;

    [Test]
    [TestCase('TestCombinedClause', '')]
    procedure TestCombinedClause;

    [Test]
    [TestCase('TestTableInjectionRejected', '')]
    procedure TestTableInjectionRejected;

    [Test]
    [TestCase('TestColumnInjectionRejected', '')]
    procedure TestColumnInjectionRejected;

    [Test]
    [TestCase('TestLikeAnyDedupesParam', '')]
    procedure TestLikeAnyDedupesParam;
  end;

implementation

procedure TUniQueryBuilderTest.Setup;
begin
  FBuilder := TQueryClauseBuilder.Create;
end;

procedure TUniQueryBuilderTest.TearDown;
begin
  FBuilder.Free;
end;

procedure TUniQueryBuilderTest.TestNoClause;
var
  LSQL: string;
begin
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.AreEqual('SELECT * FROM UniAdmin_Users', LSQL);
end;

procedure TUniQueryBuilderTest.TestLikeClause;
var
  LSQL: string;
begin
  FBuilder.AddLikeAny(['UserName', 'RealName', 'Email'], 'Filter');
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.AreEqual(
    'SELECT * FROM UniAdmin_Users WHERE (UserName LIKE :Filter0 OR RealName LIKE :Filter0 OR Email LIKE :Filter0)',
    LSQL);
  Assert.AreEqual(1, FBuilder.ParamCount, '应只有 1 个去重参数 Filter0');
end;

procedure TUniQueryBuilderTest.TestEqualClause;
var
  LSQL: string;
begin
  FBuilder.AddEqual('Status', 'Status');
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.AreEqual('SELECT * FROM UniAdmin_Users WHERE Status = :Status', LSQL);
end;

procedure TUniQueryBuilderTest.TestCombinedClause;
var
  LSQL: string;
begin
  FBuilder.AddLikeAny(['UserName', 'RealName'], 'Filter');
  FBuilder.AddEqual('Status', 'Status');
  LSQL := FBuilder.SelectFrom('UniAdmin_Users');
  Assert.IsTrue(LSQL.Contains('(UserName LIKE :Filter0 OR RealName LIKE :Filter0)'),
    '应含 LIKE 子句');
  Assert.IsTrue(LSQL.Contains('Status = :Status'), '应含等值子句');
  Assert.IsTrue(LSQL.Contains(' WHERE ') and LSQL.Contains(' AND '), '应含 WHERE/AND');
end;

procedure TUniQueryBuilderTest.TestTableInjectionRejected;
begin
  // 表名含分号/空格应被拒绝（防 SQL 注入）
  Assert.WillRaise(
    procedure begin FBuilder.SelectFrom('UniAdmin_Users; DROP TABLE x'); end,
    Exception);
end;

procedure TUniQueryBuilderTest.TestColumnInjectionRejected;
begin
  // 列名含非法字符应被拒绝
  Assert.WillRaise(
    procedure begin FBuilder.AddEqual('1=1; --', 'Status'); end,
    Exception);
end;

procedure TUniQueryBuilderTest.TestLikeAnyDedupesParam;
begin
  // 多次 AddLikeAny 用同一 ParamBase 应复用同一参数名
  FBuilder.AddLikeAny(['UserName'], 'Filter');
  FBuilder.AddLikeAny(['RealName'], 'Filter');
  Assert.AreEqual(1, FBuilder.ParamCount, '同 ParamBase 的参数应去重');
end;

initialization
  TDUnitX.RegisterTestFixture(TUniQueryBuilderTest);

end.
