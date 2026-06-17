unit GridTemplate;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms,
  UniGUIClasses, UniGUIForm,
  uniButton, uniEdit, uniDBGrid, uniToolBar, uniBasicGrid, uniGUIBaseClasses;

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
    procedure DoAdd(Sender: TObject); virtual;
    procedure DoEdit(Sender: TObject); virtual;
    procedure DoDelete(Sender: TObject); virtual;
    procedure DoRefresh(Sender: TObject); virtual;
    procedure DoSearch(Sender: TObject); virtual;
  public
  end;

implementation

{$R *.dfm}

procedure TGridTemplate.DoAdd(Sender: TObject);
begin
  // 子类实现新增逻辑
end;

procedure TGridTemplate.DoEdit(Sender: TObject);
begin
  // 子类实现编辑逻辑
end;

procedure TGridTemplate.DoDelete(Sender: TObject);
begin
  // 子类实现删除逻辑
end;

procedure TGridTemplate.DoRefresh(Sender: TObject);
begin
  // 子类实现刷新逻辑
end;

procedure TGridTemplate.DoSearch(Sender: TObject);
begin
  // 子类实现搜索逻辑
end;

initialization
  RegisterClass(TGridTemplate);

end.
