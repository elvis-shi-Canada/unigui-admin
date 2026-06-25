unit UniFormStyler;

interface

uses
  System.SysUtils, System.Classes, System.UITypes,
  uniGUIForm, uniPanel, uniButton, uniLabel, uniEdit,
  uniGUIClasses, uniGUIBaseClasses, uniGUIFrame;

type
  /// <summary>
  /// 统一窗体样式应用器
  /// 为项目中所有窗体提供一致的 CSS 类应用方法。
  /// 配合 ServerModule.CustomCSS 中定义的统一设计系统使用。
  /// </summary>
  TUniFormStyler = class
  public
    // ---------- 面板样式 ----------
    /// <summary>将面板样式为卡片（白底 + 圆角 + 阴影）</summary>
    class procedure StyleAsCard(APanel: TUniPanel);
    /// <summary>将面板样式为头部栏（渐变背景）</summary>
    class procedure StyleAsHeader(APanel: TUniPanel);
    /// <summary>将面板样式为底部栏（浅灰背景）</summary>
    class procedure StyleAsFooter(APanel: TUniPanel);

    // ---------- 按钮样式 ----------
    /// <summary>将按钮样式为主按钮（渐变蓝紫）</summary>
    class procedure StylePrimaryButton(AButton: TUniButton);
    /// <summary>将按钮样式为成功按钮（绿色）</summary>
    class procedure StyleSuccessButton(AButton: TUniButton);
    /// <summary>将按钮样式为危险按钮（红色）</summary>
    class procedure StyleDangerButton(AButton: TUniButton);
    /// <summary>将按钮样式为警告按钮（橙色）</summary>
    class procedure StyleWarningButton(AButton: TUniButton);

    // ---------- 批量样式 ----------
    /// <summary>自动识别并样式化窗体中的按钮。
    /// 根据 ModalResult 和名称自动判断：OK/保存→主按钮，删除→危险按钮。</summary>
    class procedure AutoStyleButtons(AForm: TUniForm); overload;
    /// <summary>自动识别并样式化框架中的按钮。</summary>
    class procedure AutoStyleButtons(AFrame: TUniFrame); overload;

    /// <summary>递归遍历容器，将头部/底部/卡片面板应用对应样式类。
    /// 识别规则：名称含 Header→uni-header，名称含 Footer→uni-footer。</summary>
    class procedure AutoStylePanels(AForm: TUniForm);
  end;

implementation

{ TUniFormStyler }

// ---------- 面板样式 ----------

class procedure TUniFormStyler.StyleAsCard(APanel: TUniPanel);
begin
  if APanel <> nil then
    APanel.JSInterface.JSAssign('addCls', ['uni-card']);
end;

class procedure TUniFormStyler.StyleAsHeader(APanel: TUniPanel);
begin
  if APanel <> nil then
  begin
    APanel.JSInterface.JSAssign('addCls', ['uni-header']);
    // 头部栏内文字默认白色
    APanel.Color := $00A24E66; // 紫蓝色 BGR 作为后备色
  end;
end;

class procedure TUniFormStyler.StyleAsFooter(APanel: TUniPanel);
begin
  if APanel <> nil then
    APanel.JSInterface.JSAssign('addCls', ['uni-footer']);
end;

// ---------- 按钮样式 ----------

class procedure TUniFormStyler.StylePrimaryButton(AButton: TUniButton);
begin
  if AButton <> nil then
    AButton.JSInterface.JSAssign('addCls', ['uni-btn-primary']);
end;

class procedure TUniFormStyler.StyleSuccessButton(AButton: TUniButton);
begin
  if AButton <> nil then
    AButton.JSInterface.JSAssign('addCls', ['uni-btn-success']);
end;

class procedure TUniFormStyler.StyleDangerButton(AButton: TUniButton);
begin
  if AButton <> nil then
    AButton.JSInterface.JSAssign('addCls', ['uni-btn-danger']);
end;

class procedure TUniFormStyler.StyleWarningButton(AButton: TUniButton);
begin
  if AButton <> nil then
    AButton.JSInterface.JSAssign('addCls', ['uni-btn-warning']);
end;

// ---------- 批量样式 ----------

class procedure TUniFormStyler.AutoStyleButtons(AForm: TUniForm);
var
  I: Integer;
  LBtn: TUniButton;
  LName: string;
begin
  if AForm = nil then
    Exit;

  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[I] is TUniButton then
    begin
      LBtn := TUniButton(AForm.Components[I]);
      LName := LowerCase(LBtn.Name);

      // 确定/保存/登录 → 主按钮
      if (LBtn.ModalResult = mrOk) or
         LName.Contains('save') or LName.Contains('ok') or
         LName.Contains('login') or LName.Contains('submit') or
         LName.Contains('confirm') or LName.Contains('add') or
         LName.Contains('edit') or LName.Contains('next') or
         LName.Contains('apply') or LName.Contains('yes') then
        StylePrimaryButton(LBtn)
      // 删除 → 危险按钮
      else if LName.Contains('delete') or LName.Contains('remove') then
        StyleDangerButton(LBtn)
      // 保存成功类 → 成功按钮
      else if LName.Contains('export') or LName.Contains('import') then
        StyleSuccessButton(LBtn);
    end;
  end;
end;

class procedure TUniFormStyler.AutoStyleButtons(AFrame: TUniFrame);
var
  I: Integer;
  LBtn: TUniButton;
  LName: string;
begin
  if AFrame = nil then
    Exit;

  for I := 0 to AFrame.ComponentCount - 1 do
  begin
    if AFrame.Components[I] is TUniButton then
    begin
      LBtn := TUniButton(AFrame.Components[I]);
      LName := LowerCase(LBtn.Name);

      if LName.Contains('save') or LName.Contains('ok') or
         LName.Contains('submit') or LName.Contains('confirm') or
         LName.Contains('add') or LName.Contains('edit') or
         LName.Contains('refresh') or LName.Contains('next') then
        StylePrimaryButton(LBtn)
      else if LName.Contains('delete') or LName.Contains('remove') then
        StyleDangerButton(LBtn)
      else if LName.Contains('export') or LName.Contains('import') then
        StyleSuccessButton(LBtn);
    end;
  end;
end;

class procedure TUniFormStyler.AutoStylePanels(AForm: TUniForm);
var
  I: Integer;
  LPanel: TUniPanel;
  LName: string;
begin
  if AForm = nil then
    Exit;

  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[I] is TUniPanel then
    begin
      LPanel := TUniPanel(AForm.Components[I]);
      LName := LowerCase(LPanel.Name);

      if LName.Contains('header') then
        StyleAsHeader(LPanel)
      else if LName.Contains('footer') then
        StyleAsFooter(LPanel)
      else if LName.Contains('body') or LName.Contains('content') then
        StyleAsCard(LPanel);
    end;
  end;
end;

end.
