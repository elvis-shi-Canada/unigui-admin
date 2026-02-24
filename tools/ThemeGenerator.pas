unit ThemeGenerator;

{$APPTYPE CONSOLE}

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  System.IOUtils, System.Generics.Collections;

type
  TThemeGenerator = class
  public
    class procedure GenerateFromConfig(const ConfigFile, OutputFile: string);
    class procedure GenerateDefaultTheme(const OutputFile: string);
  end;

implementation

{ TThemeGenerator }

class procedure TThemeGenerator.GenerateFromConfig(const ConfigFile,
  OutputFile: string);
var
  LConfig: TJSONObject;
  LThemeObj: TJSONObject;
  LColors: TJSONObject;
begin
  if not TFile.Exists(ConfigFile) then
  begin
    WriteLn('错误: 配置文件不存在: ' + ConfigFile);
    Exit;
  end;

  LConfig := TJSONObject.Parse(TFile.ReadAllText(ConfigFile));
  try
    LThemeObj := LConfig.GetValue<TJSONObject>('ui', nil);
    if LThemeObj = nil then
    begin
      WriteLn('错误: 配置文件中缺少 ui 配置');
      Exit;
    end;

    // 生成主题 CSS
    var LCSS := TStringList.Create;
    try
      LCSS.Add('/* UniAdmin Theme - 自动生成 */');
      LCSS.Add('/* 来源: ' + ConfigFile + ' */');
      LCSS.Add('');

      // 主色调
      LColors := LThemeObj.GetValue<TJSONObject>('colors', nil);
      if LColors <> nil then
      begin
        LCSS.Add(':root {');
        LCSS.Add('  --primary-color: ' + LColors.GetValue('primary', '#1890ff') + ';');
        LCSS.Add('  --success-color: ' + LColors.GetValue('success', '#52c41a') + ';');
        LCSS.Add('  --warning-color: ' + LColors.GetValue('warning', '#faad14') + ';');
        LCSS.Add('  --error-color: ' + LColors.GetValue('error', '#f5222d') + ';');
        LCSS.Add('  --info-color: ' + LColors.GetValue('info', '#1890ff') + ';');
        LCSS.Add('}');
        LCSS.Add('');
      end;

      TFile.WriteAllText(OutputFile, LCSS.Text);
      WriteLn('主题已生成: ' + OutputFile);
    finally
      LCSS.Free;
    end;
  finally
    LConfig.Free;
  end;
end;

class procedure TThemeGenerator.GenerateDefaultTheme(const OutputFile: string);
var
  LCSS: TStringList;
begin
  LCSS := TStringList.Create;
  try
    LCSS.Add('/* UniAdmin 默认主题 */');
    LCSS.Add('');
    LCSS.Add(':root {');
    LCSS.Add('  --primary-color: #1890ff;');
    LCSS.Add('  --success-color: #52c41a;');
    LCSS.Add('  --warning-color: #faad14;');
    LCSS.Add('  --error-color: #f5222d;');
    LCSS.Add('  --info-color: #1890ff;');
    LCSS.Add('  --text-color: #000000d9;');
    LCSS.Add('  --text-color-secondary: #00000073;');
    LCSS.Add('  --border-color: #d9d9d9;');
    LCSS.Add('  --bg-color: #f0f2f5;');
    LCSS.Add('}');

    TFile.WriteAllText(OutputFile, LCSS.Text);
    WriteLn('默认主题已生成: ' + OutputFile);
  finally
    LCSS.Free;
  end;
end;

end.
