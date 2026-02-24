unit GridTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Grids,
  UniGUIBaseModule, UniGUIClasses, UniGUIForm, UniGUIGrid, UniGUIToolbar,
  UniGUIButton, UniGUIEdit;

type
  /// <summary>
  /// 数据网格模板
  /// 提供标准的数据网格、分页和搜索功能
  /// </summary>
  TGridTemplate = class(TUniForm)
    UniToolBar1: TUniToolBar;
    btnAdd: TUniToolButton;
    btnEdit: TUniToolButton;
    btnDelete: TUniToolButton;
    btnRefresh: TUniToolButton;
    UniEdit1: TUniEdit;
    UniDBGrid1: TUniDBGrid;
  private
  protected
    procedure DoAdd; virtual;
    procedure DoEdit; virtual;
    procedure DoDelete; virtual;
    procedure DoRefresh; virtual;
    procedure DoSearch; virtual;
  public
  end;

implementation

{$R *.dfm}

procedure TGridTemplate.DoAdd;
begin
  // 子类实现新增逻辑
end;

procedure TGridTemplate.DoEdit;
begin
  // 子类实现编辑逻辑
end;

procedure TGridTemplate.DoDelete;
begin
  // 子类实现删除逻辑
end;

procedure TGridTemplate.DoRefresh;
begin
  // 子类实现刷新逻辑
end;

procedure TGridTemplate.DoSearch;
begin
  // 子类实现搜索逻辑
end;

initialization
  RegisterClass(TGridTemplate);

end.
