unit UniModelAdmin.Intf;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  /// <summary>
  /// 字段显示配置：用于 list_display / 编辑表单列
  /// </summary>
  TAdminFieldConfig = record
    FieldName: string;
    DisplayName: string;
    Width: Integer;
    /// <summary>留空则从元数据推断</summary>
    EditorType: string;
    class function Create(const AFieldName, ADisplayName: string;
      AWidth: Integer = 100): TAdminFieldConfig; static;
  end;

  /// <summary>
  /// 单张表的声明式 Admin 配置（类比 Django 的 ModelAdmin）
  /// 在业务单元 initialization 段填充后注册到 IModelAdminRegistry
  /// </summary>
  TModelAdmin = record
    /// <summary>逻辑 ID，如 'user'。用作菜单 RouteKey 与权限前缀</summary>
    AdminID: string;
    /// <summary>目标数据库表名（用于元数据读取与查询生成）</summary>
    TableName: string;
    /// <summary>菜单显示名（中文，GBK 原文保留）</summary>
    DisplayName: string;
    /// <summary>承载此表的 Frame 类名；为空则用 TAutoCrudFrame</summary>
    FrameClassName: string;
    /// <summary>列表显示字段；为空则取元数据全部字段</summary>
    ListDisplay: TArray<TAdminFieldConfig>;
    /// <summary>参与 LIKE 搜索的字段名（数据库列名）</summary>
    SearchFields: TArray<string>;
    /// <summary>等值过滤字段名，如 ['Status']</summary>
    FilterFields: TArray<string>;
    /// <summary>权限前缀，如 'user'，自动派生 user:view/add/edit/delete</summary>
    PermissionPrefix: string;
    /// <summary>菜单排序号</summary>
    SortOrder: Integer;
    /// <summary>父菜单代码（如 'system'），用于挂载菜单树</summary>
    ParentMenuCode: string;
    /// <summary>图标文件名</summary>
    Icon: string;

    class function Create(const AAdminID, ATableName, ADisplayName: string): TModelAdmin; static;

    // Fluent 链式 API（便于在 initialization 段紧凑声明）
    function WithFrame(const AClassName: string): TModelAdmin;
    function WithListDisplay(const AFields: TArray<TAdminFieldConfig>): TModelAdmin;
    function WithSearchFields(const AFields: TArray<string>): TModelAdmin;
    function WithFilterFields(const AFields: TArray<string>): TModelAdmin;
    function WithPermissionPrefix(const APrefix: string): TModelAdmin;
    function WithSortOrder(const AOrder: Integer): TModelAdmin;
    function WithParentMenuCode(const ACode: string): TModelAdmin;
    function WithIcon(const AIcon: string): TModelAdmin;
  end;

  /// <summary>
  /// ModelAdmin 注册中心接口（进程级单例语义）
  /// </summary>
  IModelAdminRegistry = interface(IInterface)
    ['{F1A2B3C4-D5E6-7890-ABCD-1234567890AB}']
    procedure Register(const AAdmin: TModelAdmin);
    function Find(const AAdminID: string; out AAdmin: TModelAdmin): Boolean;
    function GetByTableName(const ATableName: string): TModelAdmin;
    function GetAll: TArray<TModelAdmin>;
    function Count: Integer;
    procedure Clear;
  end;

implementation

{ TAdminFieldConfig }

class function TAdminFieldConfig.Create(const AFieldName, ADisplayName: string;
  AWidth: Integer): TAdminFieldConfig;
begin
  Result.FieldName := AFieldName;
  Result.DisplayName := ADisplayName;
  Result.Width := AWidth;
  Result.EditorType := '';
end;

{ TModelAdmin }

class function TModelAdmin.Create(const AAdminID, ATableName,
  ADisplayName: string): TModelAdmin;
begin
  Result.AdminID := AAdminID;
  Result.TableName := ATableName;
  Result.DisplayName := ADisplayName;
  Result.FrameClassName := '';
  Result.ListDisplay := nil;
  Result.SearchFields := nil;
  Result.FilterFields := nil;
  Result.PermissionPrefix := AAdminID;
  Result.SortOrder := 999;
  Result.ParentMenuCode := '';
  Result.Icon := '';
end;

function TModelAdmin.WithFrame(const AClassName: string): TModelAdmin;
begin
  Result := Self;
  Result.FrameClassName := AClassName;
end;

function TModelAdmin.WithListDisplay(const AFields: TArray<TAdminFieldConfig>): TModelAdmin;
begin
  Result := Self;
  Result.ListDisplay := AFields;
end;

function TModelAdmin.WithSearchFields(const AFields: TArray<string>): TModelAdmin;
begin
  Result := Self;
  Result.SearchFields := AFields;
end;

function TModelAdmin.WithFilterFields(const AFields: TArray<string>): TModelAdmin;
begin
  Result := Self;
  Result.FilterFields := AFields;
end;

function TModelAdmin.WithPermissionPrefix(const APrefix: string): TModelAdmin;
begin
  Result := Self;
  Result.PermissionPrefix := APrefix;
end;

function TModelAdmin.WithSortOrder(const AOrder: Integer): TModelAdmin;
begin
  Result := Self;
  Result.SortOrder := AOrder;
end;

function TModelAdmin.WithParentMenuCode(const ACode: string): TModelAdmin;
begin
  Result := Self;
  Result.ParentMenuCode := ACode;
end;

function TModelAdmin.WithIcon(const AIcon: string): TModelAdmin;
begin
  Result := Self;
  Result.Icon := AIcon;
end;

end.
