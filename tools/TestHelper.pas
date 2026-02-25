unit TestHelper;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.JSON, System.DateUtils;

type
  TTestCase = record
    Name: string;
    Category: string;
    SetupCode: string;
    TestCode: string;
    TeardownCode: string;
    ExpectedResult: string;
    Tags: TArray<string>;
  end;

  TTestSuite = record
    Name: string;
    Description: string;
    TestCases: TArray<TTestCase>;
  end;

  TTestHelper = class
  private
    FTestCases: TList<TTestCase>;
    FOutputDir: string;
    procedure GenerateDUnitXTest(const TestCase: TTestCase; const Output: TStringBuilder);
    procedure GenerateTestData(const Count: Integer; const OutputDir: string);
    function GenerateRandomString(const Length: Integer): string;
    function GenerateRandomDate: TDateTime;
    function GenerateRandomNumber(const Min, Max: Integer): Integer;
  public
    constructor Create(const OutputDir: string);
    destructor Destroy; override;
    procedure AddTestCase(const TestCase: TTestCase);
    function GenerateTestFile(const FileName: string; const SuiteName: string): string;
    function GenerateMockData(const EntityName: string; const Count: Integer): string;
    function GenerateTestReport(const TestResults: string): string;
    function ListTestCases: TArray<TTestCase>;
    procedure ClearTestCases;
  end;

implementation

constructor TTestHelper.Create(const OutputDir: string);
begin
  inherited Create;
  FOutputDir := OutputDir;
  FTestCases := TList<TTestCase>.Create;
end;

destructor TTestHelper.Destroy;
begin
  FTestCases.Free;
  inherited;
end;

procedure TTestHelper.AddTestCase(const TestCase: TTestCase);
begin
  FTestCases.Add(TestCase);
end;

procedure TTestHelper.GenerateDUnitXTest(const TestCase: TTestCase; const Output: TStringBuilder);
const
  INDENT = '  ';
begin
  Output.AppendLine('[Test]');
  Output.AppendLine(Format('procedure T%sTest.%s;', [TestCase.Category, TestCase.Name]));
  Output.AppendLine('var');
  Output.AppendLine(INDENT + 'Expected, Actual: Variant;');
  Output.AppendLine('begin');

  // Setup
  if TestCase.SetupCode <> '' then
  begin
    Output.AppendLine(INDENT + '// Setup');
    Output.AppendLine(INDENT + TestCase.SetupCode);
    Output.AppendLine;
  end;

  // Test
  Output.AppendLine(INDENT + '// Act');
  Output.AppendLine(INDENT + TestCase.TestCode);
  Output.AppendLine;

  // Assert
  Output.AppendLine(INDENT + '// Assert');
  if TestCase.ExpectedResult <> '' then
    Output.AppendLine(INDENT + Format('Assert.AreEqual(%s, Actual);', [TestCase.ExpectedResult]))
  else
    Output.AppendLine(INDENT + 'Assert.IsTrue(True); // TODO: Add assertion');

  Output.AppendLine;

  // Teardown
  if TestCase.TeardownCode <> '' then
  begin
    Output.AppendLine(INDENT + '// Teardown');
    Output.AppendLine(INDENT + TestCase.TeardownCode);
  end;

  Output.AppendLine('end;');
  Output.AppendLine;
end;

function TTestHelper.GenerateTestFile(const FileName: string; const SuiteName: string): string;
var
  SB: TStringBuilder;
  TestCase: TTestCase;
  OutputPath: string;
  Categories: TDictionary<string, TList<TTestCase>>;
  Category: string;
  CategoryTests: TList<TTestCase>;
begin
  Categories := TDictionary<string, TList<TTestCase>>.Create;
  try
    // 按类别分组
    for TestCase in FTestCases do
    begin
      if not Categories.TryGetValue(TestCase.Category, CategoryTests) then
      begin
        CategoryTests := TList<TTestCase>.Create;
        Categories.Add(TestCase.Category, CategoryTests);
      end;
      CategoryTests.Add(TestCase);
    end;

    SB := TStringBuilder.Create;
    try
      // 文件头部
      SB.AppendLine('unit ' + ChangeFileExt(FileName, '') + ';');
      SB.AppendLine;
      SB.AppendLine('interface');
      SB.AppendLine;
      SB.AppendLine('uses');
      SB.AppendLine('  System.SysUtils, DUnitX.TestFramework;');
      SB.AppendLine;

      // 测试夹具声明
      for Category in Categories.Keys do
      begin
        SB.AppendLine(Format('type', [Category]));
        SB.AppendLine(Format('  [TestFixture]', [Category]));
        SB.AppendLine(Format('  T%sTest = class(TObject)', [Category]));
        SB.AppendLine('  public');
        SB.AppendLine('    [Setup]');
        SB.AppendLine('    procedure Setup;');
        SB.AppendLine('    [TearDown]');
        SB.AppendLine('    procedure TearDown;');
        SB.AppendLine;

        CategoryTests := Categories[Category];
        for TestCase in CategoryTests.ToArray do
        begin
          SB.AppendLine(Format('    [Test]', []));
          SB.AppendLine(Format('    procedure %s;', [TestCase.Name]));
        end;

        SB.AppendLine('  end;');
        SB.AppendLine;
      end;

      SB.AppendLine('implementation');
      SB.AppendLine;

      // 实现
      for Category in Categories.Keys do
      begin
        SB.AppendLine(Format('{ T%sTest }', [Category]));
        SB.AppendLine;

        // Setup
        SB.AppendLine(Format('procedure T%sTest.Setup;', [Category]));
        SB.AppendLine('begin');
        SB.AppendLine('end;');
        SB.AppendLine;

        // TearDown
        SB.AppendLine(Format('procedure T%sTest.TearDown;', [Category]));
        SB.AppendLine('begin');
        SB.AppendLine('end;');
        SB.AppendLine;

        CategoryTests := Categories[Category];
        for TestCase in CategoryTests.ToArray do
        begin
          GenerateDUnitXTest(TestCase, SB);
        end;
      end;

      SB.AppendLine('end.');

      if not TDirectory.Exists(FOutputDir) then
        TDirectory.CreateDirectory(FOutputDir);

      OutputPath := TPath.Combine(FOutputDir, FileName);
      TFile.WriteAllText(OutputPath, SB.ToString, TEncoding.UTF8);

      Result := OutputPath;
      Writeln('测试文件已生成: ' + OutputPath);
      Writeln('包含 ' + IntToStr(FTestCases.Count) + ' 个测试用例');
    finally
      SB.Free;
    end;
  finally
    for CategoryTests in Categories.Values do
      CategoryTests.Free;
    Categories.Free;
  end;
end;

function TTestHelper.GenerateRandomString(const Length: Integer): string;
const
  CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length do
    Result := Result + CHARS[Random(Length(CHARS)) + 1];
end;

function TTestHelper.GenerateRandomDate: TDateTime;
begin
  Result := IncYear(Now, -Random(10)) + Random(365);
end;

function TTestHelper.GenerateRandomNumber(const Min, Max: Integer): Integer;
begin
  Result := Min + Random(Max - Min + 1);
end;

function TTestHelper.GenerateMockData(const EntityName: string; const Count: Integer): string;
var
  JSONArr: TJSONArray;
  JSONObject: TJSONObject;
  I: Integer;
  FileName: string;
  Names: array[0..9] of string;
  Cities: array[0..9] of string;
begin
  Names[0] := '张三'; Names[1] := '李四'; Names[2] := '王五';
  Names[3] := '赵六'; Names[4] := '钱七'; Names[5] := '孙八';
  Names[6] := '周九'; Names[7] := '吴十'; Names[8] := '郑一';
  Names[9] := '王二';

  Cities[0] := '北京'; Cities[1] := '上海'; Cities[2] := '广州';
  Cities[3] := '深圳'; Cities[4] := '杭州'; Cities[5] := '南京';
  Cities[6] := '成都'; Cities[7] := '武汉'; Cities[8] := '西安';
  Cities[9] := '重庆';

  JSONArr := TJSONArray.Create;
  try
    for I := 1 to Count do
    begin
      JSONObject := TJSONObject.Create;
      JSONObject.AddPair('id', TJSONNumber.Create(I));
      JSONObject.AddPair('name', TJSONString.Create(Names[Random(10)] + IntToStr(I)));
      JSONObject.AddPair('email', TJSONString.Create(Format('user%d@test.com', [I])));
      JSONObject.AddPair('phone', TJSONString.Create(Format('138%08d', [Random(100000000)])));
      JSONObject.AddPair('city', TJSONString.Create(Cities[Random(10)]));
      JSONObject.AddPair('age', TJSONNumber.Create(GenerateRandomNumber(18, 60)));
      JSONObject.AddPair('created_at', TJSONString.Create(DateTimeToStr(GenerateRandomDate)));
      JSONObject.AddPair('is_active', TJSONBool.Create(Random(2) = 1));

      JSONArr.AddElement(JSONObject);
    end;

    if not TDirectory.Exists(FOutputDir) then
      TDirectory.CreateDirectory(FOutputDir);

    FileName := TPath.Combine(FOutputDir, Format('mock_%s_data.json', [EntityName]));
    TFile.WriteAllText(FileName, JSONArr.Format(2), TEncoding.UTF8);

    Result := FileName;
    Writeln('模拟数据已生成: ' + FileName);
    Writeln('记录数: ' + IntToStr(Count));
  finally
    JSONArr.Free;
  end;
end;

function TTestHelper.GenerateTestReport(const TestResults: string): string;
var
  SB: TStringBuilder;
  JSONObj: TJSONObject;
  TestsArray: TJSONArray;
  I: Integer;
  TestObj: TJSONObject;
  Passed, Failed, Skipped: Integer;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('<!DOCTYPE html>');
    SB.AppendLine('<html>');
    SB.AppendLine('<head>');
    SB.AppendLine('  <title>测试报告</title>');
    SB.AppendLine('  <style>');
    SB.AppendLine('    body { font-family: Arial, sans-serif; margin: 20px; }');
    SB.AppendLine('    .header { background: #f0f0f0; padding: 15px; border-radius: 5px; }');
    SB.AppendLine('    .summary { margin: 20px 0; }');
    SB.AppendLine('    .pass { color: green; }');
    SB.AppendLine('    .fail { color: red; }');
    SB.AppendLine('    .skip { color: orange; }');
    SB.AppendLine('    table { width: 100%; border-collapse: collapse; }');
    SB.AppendLine('    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }');
    SB.AppendLine('    th { background-color: #4CAF50; color: white; }');
    SB.AppendLine('    tr:hover { background-color: #f5f5f5; }');
    SB.AppendLine('  </style>');
    SB.AppendLine('</head>');
    SB.AppendLine('<body>');
    SB.AppendLine('  <div class="header">');
    SB.AppendLine('    <h1>单元测试报告</h1>');
    SB.AppendLine('    <p>生成时间: ' + DateTimeToStr(Now) + '</p>');
    SB.AppendLine('  </div>');

    try
      JSONObj := TJSONObject.ParseJSONValue(TestResults) as TJSONObject;
      if Assigned(JSONObj) then
      begin
        try
          TestsArray := JSONObj.GetValue('tests') as TJSONArray;
          if Assigned(TestsArray) then
          begin
            Passed := 0; Failed := 0; Skipped := 0;

            for I := 0 to TestsArray.Count - 1 do
            begin
              TestObj := TestsArray.Items[I] as TJSONObject;
              if TestObj.GetValue('status').Value = 'passed' then
                Inc(Passed)
              else if TestObj.GetValue('status').Value = 'failed' then
                Inc(Failed)
              else
                Inc(Skipped);
            end;

            SB.AppendLine('  <div class="summary">');
            SB.AppendLine('    <h2>摘要</h2>');
            SB.AppendLine(Format('    <p><span class="pass">通过: %d</span> | ', [Passed]));
            SB.AppendLine(Format('    <span class="fail">失败: %d</span> | ', [Failed]));
            SB.AppendLine(Format('    <span class="skip">跳过: %d</span></p>', [Skipped]));
            SB.AppendLine('  </div>');

            SB.AppendLine('  <table>');
            SB.AppendLine('    <tr>');
            SB.AppendLine('      <th>测试名称</th>');
            SB.AppendLine('      <th>状态</th>');
            SB.AppendLine('      <th>耗时(ms)</th>');
            SB.AppendLine('      <th>消息</th>');
            SB.AppendLine('    </tr>');

            for I := 0 to TestsArray.Count - 1 do
            begin
              TestObj := TestsArray.Items[I] as TJSONObject;
              SB.AppendLine('    <tr>');
              SB.AppendLine('      <td>' + TestObj.GetValue('name').Value + '</td>');
              SB.AppendLine('      <td class="' + TestObj.GetValue('status').Value + '">' +
                TestObj.GetValue('status').Value + '</td>');
              SB.AppendLine('      <td>' + TestObj.GetValue('duration').Value + '</td>');
              SB.AppendLine('      <td>' + TestObj.GetValue('message').Value + '</td>');
              SB.AppendLine('    </tr>');
            end;

            SB.AppendLine('  </table>');
          end;
        finally
          JSONObj.Free;
        end;
      end;
    except
      on E: Exception do
      begin
        SB.AppendLine('  <p>解析测试结果失败: ' + E.Message + '</p>');
      end;
    end;

    SB.AppendLine('</body>');
    SB.AppendLine('</html>');

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TTestHelper.ListTestCases: TArray<TTestCase>;
begin
  Result := FTestCases.ToArray;
end;

procedure TTestHelper.ClearTestCases;
begin
  FTestCases.Clear;
end;

end.
