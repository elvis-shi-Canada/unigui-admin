unit DictionaryListFrame;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Data.DB,
  UniContext, UniPlugin.Types,
  DictionaryDataModule;

type
  /// <summary>
  /// 数据字典列表窗体框架
  /// 提供数据字典的可视化管理界面
  /// </summary>
  TDictionaryListFrame = class(TFrame)
    pnlToolBar: TPanel;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    btnRefresh: TButton;
    pnlSearch: TPanel;
    edtSearch: TEdit;
    btnSearch: TButton;
    pcMain: TPageControl;
    tsDictionaries: TTabSheet;
    tsDictionaryItems: TTabSheet;
    grdDictionaries: TStringGrid;
    grdDictionaryItems: TStringGrid;
    splMain: TSplitter;
    StatusBar: TStatusBar;
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure grdDictionariesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    FDataModule: TDictionaryDataModule;
    FCurrentDictID: Integer;
    FDictionaries: TArray<TDictionary>;
    FDictionaryItems: TArray<TDictionaryItem>;

    procedure InitializeGrids;
    procedure LoadDictionaries;
    procedure LoadDictionaryItems(const DictID: Integer);
    procedure RefreshDictionaries;
    procedure RefreshDictionaryItems;
    procedure DisplayDictionaries;
    procedure DisplayDictionaryItems;
    function GetSelectedDictionaryID: Integer;
    function GetSelectedDictionaryItemID: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetDataModule(const ADataModule: TDictionaryDataModule);
  end;

implementation

uses
  System.Generics.Collections;

{ TDictionaryListFrame }

constructor TDictionaryListFrame.Create(AOwner: TComponent);
begin
  inherited;
  FCurrentDictID := 0;
  InitializeGrids;
end;

destructor TDictionaryListFrame.Destroy;
begin
  inherited;
end;

procedure TDictionaryListFrame.SetDataModule(const ADataModule: TDictionaryDataModule);
begin
  FDataModule := ADataModule;
  LoadDictionaries;
end;

procedure TDictionaryListFrame.InitializeGrids;
begin
  // 初始化数据字典网格
  with grdDictionaries do
  begin
    ColCount := 6;
    RowCount := 2;  // 标题行 + 一数据行
    FixedRows := 1;
    Cells[0, 0] := 'ID';
    Cells[1, 0] := '字典编码';
    Cells[2, 0] := '字典名称';
    Cells[3, 0] := '字典类型';
    Cells[4, 0] := '排序';
    Cells[5, 0] := '描述';

    ColWidths[0] := 50;
    ColWidths[1] := 120;
    ColWidths[2] := 150;
    ColWidths[3] := 100;
    ColWidths[4] := 60;
    ColWidths[5] := 200;
  end;

  // 初始化字典项网格
  with grdDictionaryItems do
  begin
    ColCount := 6;
    RowCount := 2;
    FixedRows := 1;
    Cells[0, 0] := 'ID';
    Cells[1, 0] := '项编码';
    Cells[2, 0] := '项名称';
    Cells[3, 0] := '项值';
    Cells[4, 0] := '排序';
    Cells[5, 0] := '备注';

    ColWidths[0] := 50;
    ColWidths[1] := 100;
    ColWidths[2] := 120;
    ColWidths[3] := 100;
    ColWidths[4] := 60;
    ColWidths[5] := 200;
  end;
end;

procedure TDictionaryListFrame.LoadDictionaries;
begin
  if Assigned(FDataModule) then
  begin
    FDictionaries := FDataModule.GetDictionaries;
    DisplayDictionaries;
  end;
end;

procedure TDictionaryListFrame.LoadDictionaryItems(const DictID: Integer);
begin
  if Assigned(FDataModule) and (DictID > 0) then
  begin
    FCurrentDictID := DictID;
    FDictionaryItems := FDataModule.GetDictionaryItems(DictID);
    DisplayDictionaryItems;
  end;
end;

procedure TDictionaryListFrame.DisplayDictionaries;
var
  I, Row: Integer;
begin
  with grdDictionaries do
  begin
    RowCount := Length(FDictionaries) + 2;

    for I := 0 to High(FDictionaries) do
    begin
      Row := I + 1;
      Cells[0, Row] := IntToStr(FDictionaries[I].ID);
      Cells[1, Row] := FDictionaries[I].DictCode;
      Cells[2, Row] := FDictionaries[I].DictName;
      Cells[3, Row] := FDictionaries[I].DictType;
      Cells[4, Row] := IntToStr(FDictionaries[I].SortOrder);
      Cells[5, Row] := FDictionaries[I].Description;
    end;
  end;
end;

procedure TDictionaryListFrame.DisplayDictionaryItems;
var
  I, Row: Integer;
begin
  with grdDictionaryItems do
  begin
    RowCount := Length(FDictionaryItems) + 2;

    for I := 0 to High(FDictionaryItems) do
    begin
      Row := I + 1;
      Cells[0, Row] := IntToStr(FDictionaryItems[I].ID);
      Cells[1, Row] := FDictionaryItems[I].ItemCode;
      Cells[2, Row] := FDictionaryItems[I].ItemName;
      Cells[3, Row] := FDictionaryItems[I].ItemValue;
      Cells[4, Row] := IntToStr(FDictionaryItems[I].SortOrder);
      Cells[5, Row] := FDictionaryItems[I].Remark;
    end;
  end;
end;

procedure TDictionaryListFrame.RefreshDictionaries;
begin
  LoadDictionaries;
  StatusBar.SimpleText := '刷新完成 - ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

procedure TDictionaryListFrame.RefreshDictionaryItems;
begin
  if FCurrentDictID > 0 then
    LoadDictionaryItems(FCurrentDictID);
end;

function TDictionaryListFrame.GetSelectedDictionaryID: Integer;
var
  Row: Integer;
begin
  Result := 0;

  // 检查网格是否已初始化
  if not Assigned(grdDictionaries) then
    Exit;

  // 检查是否有数据
  if Length(FDictionaries) = 0 then
    Exit;

  Row := grdDictionaries.Row;

  // 修复边界检查：Row 必须大于 FixedRows（标题行）且在有效范围内
  // Row - 1 是数组索引，所以检查 Row - 1 < Length(FDictionaries)
  if (Row > grdDictionaries.FixedRows) and (Row - 1 < Length(FDictionaries)) then
    Result := FDictionaries[Row - 1].ID;
end;

function TDictionaryListFrame.GetSelectedDictionaryItemID: Integer;
var
  Row: Integer;
begin
  Result := 0;

  // 检查网格是否已初始化
  if not Assigned(grdDictionaryItems) then
    Exit;

  // 检查是否有数据
  if Length(FDictionaryItems) = 0 then
    Exit;

  Row := grdDictionaryItems.Row;

  // 修复边界检查：Row 必须大于 FixedRows（标题行）且在有效范围内
  if (Row > grdDictionaryItems.FixedRows) and (Row - 1 < Length(FDictionaryItems)) then
    Result := FDictionaryItems[Row - 1].ID;
end;

procedure TDictionaryListFrame.btnAddClick(Sender: TObject);
var
  LDictCode, LDictName, LDictType, LDescription: string;
begin
  LDictCode := InputBox('添加字典', '字典编码:', '');
  if LDictCode = '' then Exit;
  LDictName := InputBox('添加字典', '字典名称:', '');
  if LDictName = '' then Exit;
  LDictType := InputBox('添加字典', '字典类型:', '');
  LDescription := InputBox('添加字典', '描述:', '');

  if Assigned(FDataModule) then
  begin
    FDataModule.AddDictionary(LDictCode, LDictName, LDictType, LDescription, 0);
    RefreshDictionaries;
    StatusBar.SimpleText := '添加成功';
  end;
end;

procedure TDictionaryListFrame.btnEditClick(Sender: TObject);
var
  LDictID, LIdx: Integer;
begin
  LDictID := GetSelectedDictionaryID;
  if LDictID = 0 then
  begin
    ShowMessage('请先选择要编辑的数据字典');
    Exit;
  end;

  // 查找当前值
  LIdx := -1;
  for var I := 0 to High(FDictionaries) do
    if FDictionaries[I].ID = LDictID then begin LIdx := I; Break; end;
  if LIdx < 0 then Exit;

  var LDictCode := InputBox('编辑字典', '字典编码:', FDictionaries[LIdx].DictCode);
  var LDictName := InputBox('编辑字典', '字典名称:', FDictionaries[LIdx].DictName);
  var LDictType := InputBox('编辑字典', '字典类型:', FDictionaries[LIdx].DictType);
  var LDescription := InputBox('编辑字典', '描述:', FDictionaries[LIdx].Description);

  if Assigned(FDataModule) then
  begin
    FDataModule.UpdateDictionary(LDictID, LDictCode, LDictName, LDictType, LDescription, FDictionaries[LIdx].SortOrder);
    RefreshDictionaries;
    StatusBar.SimpleText := '编辑成功';
  end;
end;

procedure TDictionaryListFrame.btnDeleteClick(Sender: TObject);
var
  LDictID: Integer;
begin
  LDictID := GetSelectedDictionaryID;
  if LDictID = 0 then
  begin
    ShowMessage('请先选择要删除的数据字典');
    Exit;
  end;

  if MessageDlg('确定要删除选中的数据字典吗？', mtConfirmation,
     [mbYes, mbNo], 0) = mrYes then
  begin
    if Assigned(FDataModule) then
    begin
      if FDataModule.DeleteDictionary(LDictID) then
      begin
        RefreshDictionaries;
        StatusBar.SimpleText := '删除成功';
      end
      else
        ShowMessage('删除失败');
    end;
  end;
end;

procedure TDictionaryListFrame.btnRefreshClick(Sender: TObject);
begin
  RefreshDictionaries;
  RefreshDictionaryItems;
end;

procedure TDictionaryListFrame.btnSearchClick(Sender: TObject);
var
  LSearchText: string;
  LList: TList<TDictionary>;
  LDict: TDictionary;
begin
  LSearchText := Trim(edtSearch.Text);
  if LSearchText = '' then
  begin
    LoadDictionaries;
    Exit;
  end;

  if Assigned(FDataModule) then
  begin
    var LAll := FDataModule.GetDictionaries;
    LList := TList<TDictionary>.Create;
    try
      for LDict in LAll do
      begin
        if LDict.DictCode.Contains(LSearchText) or
           LDict.DictName.Contains(LSearchText) or
           LDict.Description.Contains(LSearchText) then
          LList.Add(LDict);
      end;
      FDictionaries := LList.ToArray;
      DisplayDictionaries;
      StatusBar.SimpleText := Format('搜索完成 - 找到 %d 条记录', [Length(FDictionaries)]);
    finally
      LList.Free;
    end;
  end;
end;

procedure TDictionaryListFrame.grdDictionariesSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  LDictID: Integer;
begin
  LDictID := GetSelectedDictionaryID;
  if LDictID > 0 then
    LoadDictionaryItems(LDictID);
end;

initialization
  // Register for FindClass-driven MDI routing (UniAdmin_Menus.RoutePath)
  RegisterClass(TDictionaryListFrame);

end.
