program UniAdminTests;

{
  DUnitX 测试项目 - UniAdmin 框架单元测试

  使用方法:
  1. 在 Delphi IDE 中打开此文件
  2. 设置项目选项中的搜索路径 (Search Path)
  3. 按 F9 或点击 "Run" 运行测试
}

{$IFNDEF TEST_INSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  DUnitX.TestFramework,
  System.SysUtils,
  WinApi.Windows,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  UniPluginTest in 'Core\Plugin\UniPluginTest.pas' {UniPluginTest},
  UniPlugin in '..\src\Core\Plugin\UniPlugin.pas',
  UniPlugin.Intf in '..\src\Core\Plugin\UniPlugin.Intf.pas',
  UniPlugin.Types in '..\src\Core\Plugin\UniPlugin.Types.pas',
  UniContext in '..\src\Core\Context\UniContext.pas',
  UniAdminModuleRegistry in '..\src\Core\Plugin\UniAdminModuleRegistry.pas',
  UniAdminModuleRegistry.Intf in '..\src\Core\Plugin\UniAdminModuleRegistry.Intf.pas';

var
  {$IFNDEF TESTINSIGHT}
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
  {$ENDIF}
begin
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  {$ELSE}
  // 设置控制台输出编码
  SetConsoleOutputCP(CP_UTF8);

  // 创建测试运行器
  runner := TDUnitX.CreateRunner;
  runner.useRTTI := True;

  // 添加控制台日志记录器
  logger := TDUnitXConsoleLogger.Create(true);
  runner.AddLogger(logger);

  // 生成 NUnit 格式的 XML 报告 (可选)
  nunitLogger := TDUnitXXMLNUnitFileLogger.Create('..\tests\TestResults.xml');
  runner.AddLogger(nunitLogger);
  {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
  {$ENDIF}
  // 执行测试
  try
    results := runner.Execute;
    System.Write('Done.. press <Enter> key to quit.');
    System.Readln;

  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
  {$ENDIF}
end.
