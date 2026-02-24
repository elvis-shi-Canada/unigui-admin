unit UniFieldMetadata;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  /// <summary>
  /// 字段数据类型
  /// </summary>
  TFieldType = (ftString, ftInteger, ftFloat, ftDateTime, ftBoolean, ftText, ftBlob, ftGuid, ftUnknown);

  /// <summary>
  /// 字段元数据
  /// </summary>
  TFieldMetadata = record
    FieldName: string;
    DisplayName: string;
    DataType: TFieldType;
    Size: Integer;
    Precision: Integer;
    IsRequired: Boolean;
    IsPrimaryKey: Boolean;
    IsUnique: Boolean;
    DefaultValue: string;
    Description: string;

    class function Create(const AFieldName, ADisplayName: string;
      ADataType: TFieldType): TFieldMetadata; static;
  end;

  /// <summary>
  /// 表元数据
  /// </summary>
  TTableMetadata = record
    TableName: string;
    DisplayName: string;
    PrimaryKey: string;
    Fields: TList<TFieldMetadata>;
    DisplayNameField: string;

    procedure AddField(const Field: TFieldMetadata);
    function GetField(const FieldName: string): TFieldMetadata;
    function HasField(const FieldName: string): Boolean;
    procedure Clear;
  end;

implementation

{ TFieldMetadata }

class function TFieldMetadata.Create(const AFieldName, ADisplayName: string;
  ADataType: TFieldType): TFieldMetadata;
begin
  Result.FieldName := AFieldName;
  Result.DisplayName := ADisplayName;
  Result.DataType := ADataType;
  Result.Size := 0;
  Result.Precision := 0;
  Result.IsRequired := False;
  Result.IsPrimaryKey := False;
  Result.IsUnique := False;
  Result.DefaultValue := '';
  Result.Description := '';
end;

{ TTableMetadata }

procedure TTableMetadata.AddField(const Field: TFieldMetadata);
begin
  if Fields = nil then
    Fields := TList<TFieldMetadata>.Create;
  Fields.Add(Field);

  if Field.IsPrimaryKey then
    PrimaryKey := Field.FieldName;
end;

function TTableMetadata.GetField(const FieldName: string): TFieldMetadata;
var
  LField: TFieldMetadata;
begin
  Result.FieldName := '';
  if Assigned(Fields) then
  begin
    for LField in Fields do
    begin
      if SameText(LField.FieldName, FieldName) then
        Exit(LField);
    end;
  end;
end;

function TTableMetadata.HasField(const FieldName: string): Boolean;
begin
  Result := GetField(FieldName).FieldName <> '';
end;

procedure TTableMetadata.Clear;
begin
  if Assigned(Fields) then
  begin
    Fields.Clear;
    Fields.Free;
    Fields := nil;
  end;
end;

end.
