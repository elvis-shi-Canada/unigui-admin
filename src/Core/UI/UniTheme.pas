unit UniTheme;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Types,
  System.UITypes, Graphics;

type
  /// <summary>
  /// 主题模式枚举
  /// </summary>
  TThemeMode = (tmLight, tmDark, tmAuto);

  /// <summary>
  /// 颜色方案
  /// </summary>
  TColorScheme = record
    Name: string;
    PrimaryColor: TColor;
    SecondaryColor: TColor;
    AccentColor: TColor;
    SuccessColor: TColor;
    WarningColor: TColor;
    ErrorColor: TColor;
    InfoColor: TColor;
    BackgroundColor: TColor;
    SurfaceColor: TColor;
    PanelColor: TColor;
    HeaderColor: TColor;
    BorderColor: TColor;
    FontColor: TColor;
    SecondaryFontColor: TColor;
    DisabledColor: TColor;
    ShadowColor: TColor;
  end;

  /// <summary>
  /// 字体方案
  /// </summary>
  TFontScheme = record
    DefaultFont: string;
    DefaultFontSize: Integer;
    MonospaceFont: string;
    HeadingFont: string;
    SmallFontSize: Integer;
    MediumFontSize: Integer;
    LargeFontSize: Integer;
  end;

  /// <summary>
  /// 间距方案
  /// </summary>
  TSpacingScheme = record
    XS: Integer;
    SM: Integer;
    MD: Integer;
    LG: Integer;
    XL: Integer;
  end;

  /// <summary>
  /// 圆角方案
  /// </summary>
  TRadiusScheme = record
    SM: Integer;
    MD: Integer;
    LG: Integer;
    Full: Integer;
  end;

  /// <summary>
  /// 主题定义
  /// </summary>
  TThemeDefinition = class
  private
    FName: string;
    FMode: TThemeMode;
    FColorScheme: TColorScheme;
    FFontScheme: TFontScheme;
    FSpacingScheme: TSpacingScheme;
    FRadiusScheme: TRadiusScheme;
  public
    constructor Create(const AName: string; AMode: TThemeMode);

    property Name: string read FName;
    property Mode: TThemeMode read FMode;
    property ColorScheme: TColorScheme read FColorScheme;
    property FontScheme: TFontScheme read FFontScheme;
    property SpacingScheme: TSpacingScheme read FSpacingScheme;
    property RadiusScheme: TRadiusScheme read FRadiusScheme;
  end;

  /// <summary>
  /// 主题变更事件
  /// </summary>
  TThemeChangeEvent = procedure(Sender: TObject; const ThemeName: string) of object;

  /// <summary>
  /// 主题管理器 - 管理应用程序主题
  /// 支持运行时主题切换和深色/浅色模式
  /// </summary>
  TUniTheme = class(TComponent)
  private
    class var FCurrentTheme: TUniTheme;
    class var FThemes: TDictionary<string, TThemeDefinition>;

    FThemeName: string;
    FMode: TThemeMode;
    FColorScheme: TColorScheme;
    FFontScheme: TFontScheme;
    FSpacingScheme: TSpacingScheme;
    FRadiusScheme: TRadiusScheme;

    FOnThemeChange: TThemeChangeEvent;

    procedure SetThemeName(const Value: string);
    procedure SetMode(const Value: TThemeMode);
    procedure ApplyColorScheme(const AScheme: TColorScheme);
    procedure ApplyFontScheme(const AScheme: TFontScheme);
    procedure ApplySpacingScheme(const AScheme: TSpacingScheme);
    procedure ApplyRadiusScheme(const AScheme: TRadiusScheme);

    function GetPrimaryColor: TColor;
    function GetSecondaryColor: TColor;
    function GetAccentColor: TColor;
    function GetBackgroundColor: TColor;
    function GetPanelColor: TColor;
    function GetHeaderColor: TColor;
    function GetFontColor: TColor;
    function GetBorderColor: TColor;

    class constructor Create;
    class destructor Destroy;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// 初始化默认主题
    /// </summary>
    class procedure Initialize; static;

    /// <summary>
    /// 注册主题
    /// </summary>
    class procedure RegisterTheme(ATheme: TThemeDefinition); static;

    /// <summary>
    /// 注销主题
    /// </summary>
    class procedure UnregisterTheme(const AThemeName: string); static;

    /// <summary>
    /// 获取所有已注册的主题名称
    /// </summary>
    class function GetThemeNames: TArray<string>; static;

    /// <summary>
    /// 应用指定主题
    /// </summary>
    procedure ApplyTheme(const AThemeName: string);

    /// <summary>
    /// 切换深色/浅色模式
    /// </summary>
    procedure ToggleTheme;

    /// <summary>
    /// 重置为默认主题
    /// </summary>
    procedure ResetToDefault;

    /// <summary>
    /// 保存当前主题配置
    /// </summary>
    procedure SaveThemeConfig(const AFileName: string);

    /// <summary>
    /// 加载主题配置
    /// </summary>
    procedure LoadThemeConfig(const AFileName: string);

    // 颜色属性
    property PrimaryColor: TColor read GetPrimaryColor;
    property SecondaryColor: TColor read GetSecondaryColor;
    property AccentColor: TColor read GetAccentColor;
    property BackgroundColor: TColor read GetBackgroundColor;
    property PanelColor: TColor read GetPanelColor;
    property HeaderColor: TColor read GetHeaderColor;
    property FontColor: TColor read GetFontColor;
    property BorderColor: TColor read GetBorderColor;

    // 主题属性
    property ThemeName: string read FThemeName write SetThemeName;
    property Mode: TThemeMode read FMode write SetMode;

    property OnThemeChange: TThemeChangeEvent read FOnThemeChange write FOnThemeChange;
  end;

implementation

{ TThemeDefinition }

constructor TThemeDefinition.Create(const AName: string; AMode: TThemeMode);
begin
  FName := AName;
  FMode := AMode;

  // 初始化默认值
  FColorScheme.Name := AName;
  FColorScheme.PrimaryColor := clBlue;
  FColorScheme.SecondaryColor := clGray;
  FColorScheme.AccentColor := clPurple;
  FColorScheme.SuccessColor := clGreen;
  FColorScheme.WarningColor := clYellow;
  FColorScheme.ErrorColor := clRed;
  FColorScheme.InfoColor := clBlue;

  if AMode = tmDark then
  begin
    FColorScheme.BackgroundColor := $001E1E1E;
    FColorScheme.SurfaceColor := $00252525;
    FColorScheme.PanelColor := $002D2D2D;
    FColorScheme.HeaderColor := $00333333;
    FColorScheme.BorderColor := $00404040;
    FColorScheme.FontColor := clWhite;
    FColorScheme.SecondaryFontColor := $00CCCCCC;
    FColorScheme.DisabledColor := $00666666;
    FColorScheme.ShadowColor := $00000000;
  end
  else // tmLight
  begin
    FColorScheme.BackgroundColor := clWhite;
    FColorScheme.SurfaceColor = $00F5F5F5;
    FColorScheme.PanelColor := clWhite;
    FColorScheme.HeaderColor := $00F0F0F0;
    FColorScheme.BorderColor := $00E0E0E0;
    FColorScheme.FontColor := $001A1A1A;
    FColorScheme.SecondaryFontColor := $00666666;
    FColorScheme.DisabledColor := $00CCCCCC;
    FColorScheme.ShadowColor := $80000000;
  end;

  FFontScheme.DefaultFont := 'Segoe UI';
  FFontScheme.DefaultFontSize := 14;
  FFontScheme.MonospaceFont := 'Consolas';
  FFontScheme.HeadingFont := 'Segoe UI';
  FFontScheme.SmallFontSize := 12;
  FFontScheme.MediumFontSize := 14;
  FFontScheme.LargeFontSize := 18;

  FSpacingScheme.XS := 4;
  FSpacingScheme.SM := 8;
  FSpacingScheme.MD := 16;
  FSpacingScheme.LG := 24;
  FSpacingScheme.XL := 32;

  FRadiusScheme.SM := 4;
  FRadiusScheme.MD := 8;
  FRadiusScheme.LG := 12;
  FRadiusScheme.Full := 9999;
end;

{ TUniTheme }

class constructor TUniTheme.Create;
begin
  FThemes := TDictionary<string, TThemeDefinition>.Create;
  Initialize;
end;

class destructor TUniTheme.Destroy;
begin
  if Assigned(FThemes) then
  begin
    for var LTheme in FThemes.Values do
      LTheme.Free;
    FThemes.Clear;
    FThemes.Free;
  end;
end;

constructor TUniTheme.Create(AOwner: TComponent);
begin
  inherited;
  FThemeName := 'Default Light';
  FMode := tmLight;

  // 从全局主题复制设置
  if FThemes.ContainsKey(FThemeName) then
  begin
    var LTheme := FThemes[FThemeName];
    ApplyColorScheme(LTheme.ColorScheme);
    ApplyFontScheme(LTheme.FontScheme);
    ApplySpacingScheme(LTheme.SpacingScheme);
    ApplyRadiusScheme(LTheme.RadiusScheme);
  end;
end;

destructor TUniTheme.Destroy;
begin
  inherited;
end;

class procedure TUniTheme.Initialize;
begin
  // 注册默认主题
  RegisterTheme(TThemeDefinition.Create('Default Light', tmLight));
  RegisterTheme(TThemeDefinition.Create('Default Dark', tmDark));
  RegisterTheme(TThemeDefinition.Create('Blue Light', tmLight));
  RegisterTheme(TThemeDefinition.Create('Blue Dark', tmDark));

  // 设置当前主题
  FCurrentTheme := TUniTheme.Create(nil);

  // 自定义蓝色主题
  if FThemes.ContainsKey('Blue Light') then
  begin
    FThemes['Blue Light'].ColorScheme.PrimaryColor := clBlue;
    FThemes['Blue Light'].ColorScheme.AccentColor := $00DD7700;
  end;

  if FThemes.ContainsKey('Blue Dark') then
  begin
    FThemes['Blue Dark'].ColorScheme.PrimaryColor := $007777DD;
    FThemes['Blue Dark'].ColorScheme.AccentColor := $00FFAA00;
  end;
end;

class procedure TUniTheme.RegisterTheme(ATheme: TThemeDefinition);
begin
  if not Assigned(FThemes) then
    Exit;

  if FThemes.ContainsKey(ATheme.Name) then
    FThemes[ATheme.Name].Free
  else
    FThemes.Add(ATheme.Name, ATheme);
end;

class procedure TUniTheme.UnregisterTheme(const AThemeName: string);
begin
  if not Assigned(FThemes) then
    Exit;

  if FThemes.ContainsKey(AThemeName) then
  begin
    FThemes[AThemeName].Free;
    FThemes.Remove(AThemeName);
  end;
end;

class function TUniTheme.GetThemeNames: TArray<string>;
begin
  if not Assigned(FThemes) then
  begin
    Result := [];
    Exit;
  end;

  Result := FThemes.Keys.ToArray;
end;

procedure TUniTheme.ApplyTheme(const AThemeName: string);
begin
  if not FThemes.ContainsKey(AThemeName) then
    raise Exception.CreateFmt('Theme "%s" not found', [AThemeName]);

  FThemeName := AThemeName;
  var LTheme := FThemes[AThemeName];

  ApplyColorScheme(LTheme.ColorScheme);
  ApplyFontScheme(LTheme.FontScheme);
  ApplySpacingScheme(LTheme.SpacingScheme);
  ApplyRadiusScheme(LTheme.RadiusScheme);

  FMode := LTheme.Mode;

  if Assigned(FOnThemeChange) then
    FOnThemeChange(Self, AThemeName);
end;

procedure TUniTheme.ToggleTheme;
var
  LTargetTheme: string;
begin
  if FMode = tmLight then
    LTargetTheme := Copy(FThemeName, 1, Length(FThemeName) - 6) + 'Dark'
  else
    LTargetTheme := Copy(FThemeName, 1, Length(FThemeName) - 4) + 'Light';

  if FThemes.ContainsKey(LTargetTheme) then
    ApplyTheme(LTargetTheme)
  else
  begin
    // 回退到默认主题
    if FMode = tmLight then
      ApplyTheme('Default Dark')
    else
      ApplyTheme('Default Light');
  end;
end;

procedure TUniTheme.ResetToDefault;
begin
  ApplyTheme('Default Light');
end;

procedure TUniTheme.SetThemeName(const Value: string);
begin
  if FThemeName <> Value then
    ApplyTheme(Value);
end;

procedure TUniTheme.SetMode(const Value: TThemeMode);
begin
  if FMode <> Value then
  begin
    if Value = tmAuto then
    begin
      // 根据系统设置自动切换
      // 这里简化处理，使用浅色模式
      ApplyTheme('Default Light');
    end
    else if (Value = tmLight) and (FMode = tmDark) then
      ToggleTheme
    else if (Value = tmDark) and (FMode = tmLight) then
      ToggleTheme;
  end;
end;

procedure TUniTheme.ApplyColorScheme(const AScheme: TColorScheme);
begin
  FColorScheme := AScheme;
end;

procedure TUniTheme.ApplyFontScheme(const AScheme: TFontScheme);
begin
  FFontScheme := AScheme;
end;

procedure TUniTheme.ApplySpacingScheme(const AScheme: TSpacingScheme);
begin
  FSpacingScheme := AScheme;
end;

procedure TUniTheme.ApplyRadiusScheme(const AScheme: TRadiusScheme);
begin
  FRadiusScheme := AScheme;
end;

function TUniTheme.GetPrimaryColor: TColor;
begin
  Result := FColorScheme.PrimaryColor;
end;

function TUniTheme.GetSecondaryColor: TColor;
begin
  Result := FColorScheme.SecondaryColor;
end;

function TUniTheme.GetAccentColor: TColor;
begin
  Result := FColorScheme.AccentColor;
end;

function TUniTheme.GetBackgroundColor: TColor;
begin
  Result := FColorScheme.BackgroundColor;
end;

function TUniTheme.GetPanelColor: TColor;
begin
  Result := FColorScheme.PanelColor;
end;

function TUniTheme.GetHeaderColor: TColor;
begin
  Result := FColorScheme.HeaderColor;
end;

function TUniTheme.GetFontColor: TColor;
begin
  Result := FColorScheme.FontColor;
end;

function TUniTheme.GetBorderColor: TColor;
begin
  Result := FColorScheme.BorderColor;
end;

procedure TUniTheme.SaveThemeConfig(const AFileName: string);
var
  LIni: TStringList;
begin
  LIni := TStringList.Create;
  try
    LIni.Values['ThemeName'] := FThemeName;
    LIni.Values['Mode'] := IntToStr(Integer(FMode));

    // 保存颜色方案
    with FColorScheme do
    begin
      LIni.Values['PrimaryColor'] := IntToStr(PrimaryColor);
      LIni.Values['SecondaryColor'] := IntToStr(SecondaryColor);
      LIni.Values['AccentColor'] := IntToStr(AccentColor);
      LIni.Values['BackgroundColor'] := IntToStr(BackgroundColor);
      LIni.Values['PanelColor'] := IntToStr(PanelColor);
      LIni.Values['FontColor'] := IntToStr(FontColor);
    end;

    LIni.SaveToFile(AFileName);
  finally
    LIni.Free;
  end;
end;

procedure TUniTheme.LoadThemeConfig(const AFileName: string);
var
  LIni: TStringList;
  LThemeName: string;
begin
  if not FileExists(AFileName) then
    Exit;

  LIni := TStringList.Create;
  try
    LIni.LoadFromFile(AFileName);

    LThemeName := LIni.Values['ThemeName'];
    if FThemes.ContainsKey(LThemeName) then
      ApplyTheme(LThemeName);

    FMode := TThemeMode(StrToIntDef(LIni.Values['Mode'], 0));
  finally
    LIni.Free;
  end;
end;

end.
