## 1️⃣1️⃣ UniGUI控件类到单元映射规则（预防：E2003 Undeclared identifier）

### 触发场景
- 在 Delphi 单元中使用 UniGUI 控件类
- 编译时出现"Undeclared identifier"错误
- 新增或修改窗体/框架的 uses 部分
- 从其他代码复制粘贴控件声明

### 错误模式
```pascal
// 错误：缺少必要的 uses 单元
uses
  uniGUIBaseClasses, uniGUIClasses;  // 缺少 uniBasicGrid, uniDBGrid

type
  TUserListFrame = class(TUniFrame)
    UniDBGrid: TUniDBGrid;  // 编译错误：Undeclared identifier 'TUniDBGrid'
```

### 正确行为
1. **使用控件前必须添加对应的 uses 单元**，参考以下映射表：

| 控件类 | 必需的 uses 单元 |
|--------|----------------|
| TUniDBGrid | uniGUIBaseClasses, uniGUIClasses, uniBasicGrid, uniDBGrid |
| TUniStringGrid | uniGUIBaseClasses, uniGUIClasses, uniBasicGrid, uniStringGrid |
| TUniDBEdit | uniGUIBaseClasses, uniGUIClasses, uniEdit, uniDBEdit |
| TUniDBComboBox | uniGUIBaseClasses, uniGUIClasses, uniMultiItem, uniComboBox, uniDBComboBox |
| TUniDBLookupComboBox | uniGUIBaseClasses, uniGUIClasses, uniMultiItem, uniListBox, uniDBLookupComboBox |
| TUniDBNavigator | uniGUIBaseClasses, uniGUIClasses, uniDBNavigator |
| TUniDBMemo | uniGUIBaseClasses, uniGUIClasses, uniMemo, uniDBMemo |
| TUniDBImage | uniGUIBaseClasses, uniGUIClasses, uniImage, uniDBImage |
| TUniDBText | uniGUIBaseClasses, uniGUIClasses, uniLabel, uniDBText |
| TUniDBCheckBox | uniGUIBaseClasses, uniGUIClasses, uniCheckBox, uniDBCheckBox |
| TUniDBRadioGroup | uniGUIBaseClasses, uniGUIClasses, uniRadioGroup, uniDBRadioGroup |
| TUniDBLookupListBox | uniGUIBaseClasses, uniGUIClasses, uniMultiItem, uniListBox, uniDBListBox, uniDBLookupListBox |
| TUniDBListBox | uniGUIBaseClasses, uniGUIClasses, uniMultiItem, uniListBox, uniDBListBox |
| TUniForm | uniGUITypes, uniGUIAbstractClasses, uniGUIClasses, uniGUIForm, uniGUIApplication |
| TUniButton | Controls, uniGUIClasses, uniButton |
| TUniEdit | uniGUIBaseClasses, uniGUIClasses, uniEdit |
| TUniComboBox | uniGUIBaseClasses, uniGUIClasses, uniMultiItem, uniComboBox |
| TUniListBox | uniGUIBaseClasses, uniGUIClasses, uniMultiItem, uniListBox |
| TUniCheckBox | uniGUIBaseClasses, uniGUIClasses, uniCheckBox |
| TUniRadioButton | uniGUIBaseClasses, uniGUIClasses, uniRadioButton |
| TUniRadioGroup | uniRadioGroup |
| TUniMemo | uniGUIBaseClasses, uniGUIClasses, uniMemo |
| TUniLabel | uniGUIBaseClasses, uniGUIClasses, uniLabel |
| TUniPanel | uniGUIBaseClasses, uniGUIClasses, uniPanel |
| TUniGroupBox | uniGUIBaseClasses, uniGUIClasses, uniGroupBox |
| TUniPageControl | uniGUIBaseClasses, uniGUIClasses, uniPageControl |
| TUniTabSheet | uniGUIBaseClasses, uniGUIClasses, uniTabSheet |
| TUniTabControl | uniGUIBaseClasses, uniGUIClasses, uniTabControl |
| TUniSplitter | uniGUIBaseClasses, uniGUIClasses, uniSplitter |
| TUniScrollBox | uniGUIBaseClasses, uniGUIClasses, uniScrollBox |
| TUniToolBar | uniGUIBaseClasses, uniGUIClasses, uniToolBar |
| TUniToolButton | uniGUIBaseClasses, uniGUIClasses, uniToolBar |
| TUniSpeedButton | uniGUIBaseClasses, uniGUIClasses, uniButton, uniBitBtn, uniSpeedButton |
| TUniBitBtn | uniGUIBaseClasses, uniGUIClasses, uniButton, uniBitBtn |
| TUniMainMenu | Vcl.Menus, uniMainMenu |
| TUniMenuItem | Vcl.Menus, uniMainMenu |
| TUniPopupMenu | Vcl.Menus, uniMainMenu |
| TUniStatusBar | uniGUIBaseClasses, uniGUIClasses, uniStatusBar |
| TUniProgressBar | uniGUIBaseClasses, uniGUIClasses, uniProgressBar |
| TUniSpinEdit | uniGUIBaseClasses, uniGUIClasses, uniSpinEdit |
| TUniTrackBar | uniGUIBaseClasses, uniGUIClasses, uniTrackBar |
| TUniTreeView | uniGUIBaseClasses, uniGUIClasses, uniTreeView |
| TUniCalendar | uniGUIBaseClasses, uniGUIClasses, uniCalendar |
| TUniDateTimePicker | uniGUIBaseClasses, uniGUIClasses, uniDateTimePicker |
| TUniTimer | uniGUIBaseClasses, uniGUIClasses, uniTimer |
| TUniImage | uniImage |
| TUniImageList | uniGUIBaseClasses, uniImageList |
| TUniCanvas | uniGUIBaseClasses, uniGUIClasses, uniCanvas |
| TUniChart | UniChart, uniGUIBaseClasses, uniGUIClasses, uniPanel |

2. **uses 部分单元顺序**：
   - System 单元（System.SysUtils, System.Classes 等）
   - VCL/UniGUI 基础单元（uniGUIBaseClasses, uniGUIClasses 等）
   - UniGUI 控件特定单元（uniBasicGrid, uniDBGrid 等）
   - 项目自定义单元

3. **常见模式**：
   ```pascal
   uses
     System.SysUtils, System.Classes,
     Vcl.Controls, Vcl.Forms,
     uniGUIBaseClasses, uniGUIClasses, uniBasicGrid, uniDBGrid,
     UniGUIAbstractClasses, UniGUIRegClasses, UniGUIMainModule,
     UniGUIForm, UniGUIApplication, UniButton, UniEdit, UniDBEdit,
     UniLabel, UniPanel, UniDBGrid;
   ```

### 验证方法
- 编译前检查 uses 部分是否包含控件类对应的所有必需单元
- 对照映射表确认单元引用完整性
- 编译项目验证无 E2003 "Undeclared identifier" 错误
- 预期输出：所有 UniGUI 控件类正常识别，编译通过
