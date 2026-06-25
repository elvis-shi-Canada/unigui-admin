unit UniAdminPropertyEditor;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Variants, System.Generics.Collections,
  System.UITypes,
  uniGUIBaseClasses, uniGUIClasses, uniBasicGrid, uniStringGrid, uniDateTimePicker, uniMultiItem, uniComboBox, uniCheckBox, Vcl.Grids;

type
  /// <summary>
  /// 属性编辑器类型
  /// </summary>
  TPropertyEditorType = (petText, petNumber, petBoolean, petDate, petCombo, petColor);

  /// <summary>
  /// 属性项 - 表示单个可编辑属性
  /// </summary>
  TPropertyItem = record
    Name: string;
    DisplayName: string;
    Value: Variant;
    EditorType: TPropertyEditorType;
    ReadOnly: Boolean;
    ComboItems: TArray<string>;
    OnChange: TNotifyEvent;

    /// <summary>
    /// 创建属性项
    /// </summary>
    class function Create(const AName, ADisplayName: string; AValue: Variant;
      AEditorType: TPropertyEditorType = petText): TPropertyItem; static;
  end;

  /// <summary>
  /// 属性更改事件
  /// </summary>
  TPropertyChangeEvent = procedure(Sender: TObject; const PropertyName: string;
    const OldValue, NewValue: Variant) of object;

  /// <summary>
  /// 属性编辑器 - 用于编辑对象属性
  /// 提供类似 Delphi IDE 的属性编辑器功能
  /// </summary>
  TUniAdminPropertyEditor = class(TComponent)
  private
    FProperties: TList<TPropertyItem>;
    FSelectedIndex: Integer;
    FOnPropertyChange: TNotifyEvent;
    FOnPropertyChanged: TPropertyChangeEvent;
    FGrid: TUniStringGrid;

    procedure SetPropertyIndex(const Value: Integer);
    function GetProperty(Index: Integer): TPropertyItem;
    function GetPropertyCount: Integer;
    function GetPropertyValue(const Name: string): Variant;
    procedure SetPropertyValue(const Name: string; const Value: Variant);

    procedure SetGrid(const Value: TUniStringGrid);
    procedure DoGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DoGridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    // UniGUI 可能不支持 DrawCell 事件或使用不同的参数类型
    // procedure DoGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
  protected
    // UniGUI 中可能没有 Notification 方法或签名不同
    // procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // 属性管理
    /// <summary>
    /// 添加属性项
    /// </summary>
    function Add(const AProperty: TPropertyItem): Integer; overload;

    /// <summary>
    /// 添加属性项（简化版本）
    /// </summary>
    function Add(const AName, ADisplayName: string; AValue: Variant;
      AEditorType: TPropertyEditorType = petText): Integer; overload;

    /// <summary>
    /// 清空所有属性
    /// </summary>
    procedure Clear;

    /// <summary>
    /// 删除指定索引的属性
    /// </summary>
    procedure Delete(Index: Integer);

    /// <summary>
    /// 刷新显示
    /// </summary>
    procedure Refresh;

    /// <summary>
    /// 根据名称查找属性索引
    /// </summary>
    function IndexOf(const AName: string): Integer;

    // 属性访问
    property Properties[Index: Integer]: TPropertyItem read GetProperty;
    property PropertyCount: Integer read GetPropertyCount;
    property PropertyValue[const Name: string]: Variant read GetPropertyValue write SetPropertyValue;
    property SelectedIndex: Integer read FSelectedIndex write SetPropertyIndex;

    property OnPropertyChange: TNotifyEvent read FOnPropertyChange write FOnPropertyChange;
    property OnPropertyChanged: TPropertyChangeEvent read FOnPropertyChanged write FOnPropertyChanged;
    property Grid: TUniStringGrid read FGrid write SetGrid;
  end;

implementation

{ TPropertyItem }

class function TPropertyItem.Create(const AName, ADisplayName: string;
  AValue: Variant; AEditorType: TPropertyEditorType): TPropertyItem;
begin
  Result.Name := AName;
  Result.DisplayName := ADisplayName;
  Result.Value := AValue;
  Result.EditorType := AEditorType;
  Result.ReadOnly := False;
  SetLength(Result.ComboItems, 0);
  Result.OnChange := nil;
end;

{ TUniAdminPropertyEditor }

constructor TUniAdminPropertyEditor.Create(AOwner: TComponent);
begin
  inherited;
  FProperties := TList<TPropertyItem>.Create;
  FSelectedIndex := -1;
end;

destructor TUniAdminPropertyEditor.Destroy;
begin
  FProperties.Free;
  inherited;
end;

procedure TUniAdminPropertyEditor.SetGrid(const Value: TUniStringGrid);
begin
  if FGrid <> Value then
  begin
    FGrid := Value;
    if Assigned(FGrid) then
    begin
      // FGrid.FreeNotification(Self);  // UniGUI 可能不需要此方法
      FGrid.OnSelectCell := DoGridSelectCell;
      // FGrid.OnSetEditText := DoGridSetEditText;  // UniGUI 可能不支持此事件
      // FGrid.OnDrawCell := DoGridDrawCell;  // UniGUI 可能不支持此事件
    end;
  end;
end;

function TUniAdminPropertyEditor.Add(const AProperty: TPropertyItem): Integer;
begin
  Result := FProperties.Add(AProperty);
  if Assigned(FGrid) then
  begin
    FGrid.RowCount := FProperties.Count + 1; // +1 for header
    FGrid.Refresh;
  end;
end;

function TUniAdminPropertyEditor.Add(const AName, ADisplayName: string;
  AValue: Variant; AEditorType: TPropertyEditorType): Integer;
begin
  Result := Add(TPropertyItem.Create(AName, ADisplayName, AValue, AEditorType));
end;

procedure TUniAdminPropertyEditor.Clear;
begin
  FProperties.Clear;
  FSelectedIndex := -1;
  if Assigned(FGrid) then
  begin
    FGrid.RowCount := 1; // Only header
    FGrid.Refresh;
  end;
end;

procedure TUniAdminPropertyEditor.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FProperties.Count) then
  begin
    FProperties.Delete(Index);
    if FSelectedIndex >= FProperties.Count then
      FSelectedIndex := FProperties.Count - 1;

    if Assigned(FGrid) then
    begin
      FGrid.RowCount := FProperties.Count + 1;
      FGrid.Refresh;
    end;
  end;
end;

function TUniAdminPropertyEditor.GetProperty(Index: Integer): TPropertyItem;
begin
  if (Index >= 0) and (Index < FProperties.Count) then
    Result := FProperties[Index]
  else
  begin
    Result.Name := '';
    Result.DisplayName := '';
    Result.Value := Null;
    Result.EditorType := petText;
    Result.ReadOnly := True;
  end;
end;

function TUniAdminPropertyEditor.GetPropertyCount: Integer;
begin
  Result := FProperties.Count;
end;

function TUniAdminPropertyEditor.GetPropertyValue(const Name: string): Variant;
var
  I: Integer;
begin
  Result := Null;
  for I := 0 to FProperties.Count - 1 do
  begin
    if SameText(FProperties[I].Name, Name) then
    begin
      Result := FProperties[I].Value;
      Exit;
    end;
  end;
end;

procedure TUniAdminPropertyEditor.SetPropertyValue(const Name: string; const Value: Variant);
var
  I: Integer;
  LOldValue: Variant;
  LItem: TPropertyItem;
begin
  for I := 0 to FProperties.Count - 1 do
  begin
    if SameText(FProperties[I].Name, Name) then
    begin
      LOldValue := FProperties[I].Value;
      // 记录不能直接修改字段，需要使用临时变量
      LItem := FProperties[I];
      LItem.Value := Value;
      FProperties[I] := LItem;

      if Assigned(FProperties[I].OnChange) then
        FProperties[I].OnChange(Self);

      if Assigned(FOnPropertyChanged) then
        FOnPropertyChanged(Self, Name, LOldValue, Value);

      if Assigned(FOnPropertyChange) then
        FOnPropertyChange(Self);

      if Assigned(FGrid) then
        FGrid.Refresh;

      Exit;
    end;
  end;
end;

function TUniAdminPropertyEditor.IndexOf(const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FProperties.Count - 1 do
  begin
    if SameText(FProperties[I].Name, AName) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TUniAdminPropertyEditor.SetPropertyIndex(const Value: Integer);
begin
  if (Value >= -1) and (Value < FProperties.Count) and (FSelectedIndex <> Value) then
  begin
    FSelectedIndex := Value;
    if Assigned(FGrid) then
      FGrid.Refresh;
  end;
end;

procedure TUniAdminPropertyEditor.Refresh;
begin
  if Assigned(FGrid) then
    FGrid.Refresh;
end;

procedure TUniAdminPropertyEditor.DoGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  SelectedIndex := ARow - 1; // Adjust for header row
  CanSelect := True;
end;

procedure TUniAdminPropertyEditor.DoGridSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
var
  LPropIndex: Integer;
  LNewValue: Variant;
  LProp: TPropertyItem;
  LTempFloat: Double;
  LTempDate: TDateTime;
begin
  LPropIndex := ARow - 1; // Adjust for header row

  if (ACol = 1) and (LPropIndex >= 0) and (LPropIndex < FProperties.Count) then
  begin
    LProp := FProperties[LPropIndex];

    if LProp.ReadOnly then
      Exit;

    // Convert string value based on editor type
    case LProp.EditorType of
      petText:
        LNewValue := Value;

      petNumber:
        begin
          if TryStrToFloat(Value, LTempFloat) then
            LNewValue := LTempFloat
          else
            LNewValue := LProp.Value; // Keep original if invalid
        end;

      petBoolean:
        LNewValue := SameText(Value, 'True') or SameText(Value, '是') or SameText(Value, '1');

      petDate:
        begin
          if TryStrToDateTime(Value, LTempDate) then
            LNewValue := LTempDate
          else
            LNewValue := LProp.Value;
        end;

      petCombo:
        LNewValue := Value;

      petColor:
        LNewValue := Value;
    else
      LNewValue := Value;
    end;

    SetPropertyValue(LProp.Name, LNewValue);
  end;
end;

// UniGUI 可能不支持 DrawCell 事件或使用不同的参数类型
//procedure TUniAdminPropertyEditor.DoGridDrawCell(Sender: TObject; ACol, ARow: Integer;
//  Rect: TRect; State: TGridDrawState);
//var
//  LPropIndex: Integer;
//  LText: string;
//  LProp: TPropertyItem;
//begin
//  LPropIndex := ARow - 1; // Adjust for header row
//
//  if ARow = 0 then
//  begin
//    // Draw header
//    if ACol = 0 then
//      LText := '属性'
//    else if ACol = 1 then
//      LText := '值'
//    else
//      LText := '';
//
//    TUniStringGrid(Sender).Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 4, LText);
//  end
//  else if (LPropIndex >= 0) and (LPropIndex < FProperties.Count) then
//  begin
//    LProp := FProperties[LPropIndex];
//
//    if ACol = 0 then
//      LText := LProp.DisplayName
//    else if ACol = 1 then
//    begin
//      // Format value based on editor type
//      case LProp.EditorType of
//        petBoolean:
//          LText := Boolean(LProp.Value).ToString;
//
//        petDate:
//          if VarIsNull(LProp.Value) then
//            LText := ''
//          else
//            LText := DateTimeToStr(VarToDateTime(LProp.Value));
//
//        petNumber:
//          LText := VarToStr(LProp.Value);
//
//      else
//        LText := VarToStr(LProp.Value);
//      end;
//    end
//    else
//      LText := '';
//
//    TUniStringGrid(Sender).Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 4, LText);
//  end;
//end;

end.
