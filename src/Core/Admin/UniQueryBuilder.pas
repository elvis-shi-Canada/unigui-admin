unit UniQueryBuilder;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Character;

type
  /// <summary>
  /// 通用参数化 SELECT/WHERE 子句生成器
  /// 产出 100% 参数化 SQL，杜绝 SQL 注入。表名/列名经标识符白名单校验。
  /// </summary>
  TQueryClauseBuilder = class
  private
    FClauses: TList<string>;
    FParams: TList<string>;   // 去重后的参数名（保持顺序）
    function IsValidIdentifier(const AName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>添加一个 LIKE-OR 组：所有列共享同一参数（参数名后缀 0）</summary>
    procedure AddLikeAny(const AFields: TArray<string>; const AParamBase: string);
    /// <summary>添加等值条件</summary>
    procedure AddEqual(const AField, AParam: string);
    /// <summary>产出 SELECT 语句（自动拼 WHERE/AND）</summary>
    function SelectFrom(const ATable: string): string;
    /// <summary>已注册参数个数（供调用方遍历 ParamByName 设值）</summary>
    function ParamCount: Integer;
    /// <summary>按索引取参数名</summary>
    function ParamName(AIndex: Integer): string;
    procedure Clear;
  end;

implementation

{ TQueryClauseBuilder }

constructor TQueryClauseBuilder.Create;
begin
  inherited;
  FClauses := TList<string>.Create;
  FParams := TList<string>.Create;
end;

destructor TQueryClauseBuilder.Destroy;
begin
  FClauses.Free;
  FParams.Free;
  inherited;
end;

function TQueryClauseBuilder.IsValidIdentifier(const AName: string): Boolean;
var
  I: Integer;
  C: Char;
begin
  // 仅允许字母/数字/下划线，首字符必须字母或下划线
  // 这是一道防 SQL 注入的白名单：任何空格/分号/引号/注释符都会被拒绝
  Result := (AName <> '');
  if not Result then
    Exit;
  for I := 1 to AName.Length do
  begin
    C := AName[I];
    if I = 1 then
    begin
      if not (C.IsLetter or (C = '_')) then
        Exit(False);
    end
    else if not (C.IsLetterOrDigit or (C = '_')) then
      Exit(False);
  end;
end;

procedure TQueryClauseBuilder.AddLikeAny(const AFields: TArray<string>;
  const AParamBase: string);
var
  LField: string;
  LParts: TStringList;
  LParam: string;
  LJoined: string;
begin
  if Length(AFields) = 0 then
    Exit;
  if not IsValidIdentifier(AParamBase) then
    raise Exception.CreateFmt('非法参数名: %s', [AParamBase]);

  LParam := AParamBase + '0';

  LParts := TStringList.Create;
  try
    // 先校验全部列名，全部通过后才注册参数和子句，
    // 避免中途 raise 导致 builder 处于"已注册参数但无子句"的不一致状态。
    for LField in AFields do
    begin
      if not IsValidIdentifier(LField) then
        raise Exception.CreateFmt('非法列名: %s', [LField]);
      LParts.Add(Format('%s LIKE :%s', [LField, LParam]));
    end;

    if not FParams.Contains(LParam) then
      FParams.Add(LParam);

    LJoined := String.Join(' OR ', LParts.ToStringArray);
    FClauses.Add('(' + LJoined + ')');
  finally
    LParts.Free;
  end;
end;

procedure TQueryClauseBuilder.AddEqual(const AField, AParam: string);
begin
  if not IsValidIdentifier(AField) then
    raise Exception.CreateFmt('非法列名: %s', [AField]);
  if not IsValidIdentifier(AParam) then
    raise Exception.CreateFmt('非法参数名: %s', [AParam]);
  if not FParams.Contains(AParam) then
    FParams.Add(AParam);
  FClauses.Add(Format('%s = :%s', [AField, AParam]));
end;

function TQueryClauseBuilder.SelectFrom(const ATable: string): string;
var
  LWhere: string;
  I: Integer;
begin
  if not IsValidIdentifier(ATable) then
    raise Exception.CreateFmt('非法表名: %s', [ATable]);

  Result := 'SELECT * FROM ' + ATable;

  if FClauses.Count > 0 then
  begin
    LWhere := '';
    for I := 0 to FClauses.Count - 1 do
    begin
      if I = 0 then
        LWhere := FClauses[I]
      else
        LWhere := LWhere + ' AND ' + FClauses[I];
    end;
    Result := Result + ' WHERE ' + LWhere;
  end;
end;

function TQueryClauseBuilder.ParamCount: Integer;
begin
  Result := FParams.Count;
end;

function TQueryClauseBuilder.ParamName(AIndex: Integer): string;
begin
  Result := FParams[AIndex];
end;

procedure TQueryClauseBuilder.Clear;
begin
  FClauses.Clear;
  FParams.Clear;
end;

end.
