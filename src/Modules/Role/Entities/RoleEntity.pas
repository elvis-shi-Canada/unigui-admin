unit RoleEntity;

{
  Task 2 PoC 实体 —— DMVC ActiveRecord（B 路线）
  声明式 ORM：[MVCTable] 表名 + [MVCTableField] 列名注解，RTTI 内省自动映射 + 自动 SQL。
  字段对照 UniAdmin_Roles 表（与 RoleDataModule.TRoleInfo 一致）。

  依赖：DMVC ActiveRecord（d120 包，需接入 Library Path 后方可编译）。
  用法：
    LRole := TMVCActiveRecord.GetByPK<TRole>(1);  try ... finally LRole.Free;
    LList := TMVCActiveRecord.Select<TRole>('Status = :s', [1]);  try ... finally LList.Free;
    LRole := TRole.Create; LRole.RoleCode := 'admin'; LRole.Store;
}

interface

uses
  System.SysUtils,
  MVCFramework.ActiveRecord;

type
  /// <summary>角色实体（ActiveRecord，映射 UniAdmin_Roles 表）</summary>
  [MVCTable('UniAdmin_Roles')]
  TRole = class(TMVCActiveRecord)
  strict private
    [MVCTableField('RoleID', [foPrimaryKey])]
    FRoleID: Integer;
    [MVCTableField('RoleCode', [])]
    FRoleCode: string;
    [MVCTableField('RoleName', [])]
    FRoleName: string;
    [MVCTableField('Description', [])]
    FDescription: string;
    [MVCTableField('DataScope', [])]
    FDataScope: string;
    [MVCTableField('SortOrder', [])]
    FSortOrder: Integer;
    [MVCTableField('Status', [])]
    FStatus: Integer;
  public
    property RoleID: Integer read FRoleID write FRoleID;
    property RoleCode: string read FRoleCode write FRoleCode;
    property RoleName: string read FRoleName write FRoleName;
    property Description: string read FDescription write FDescription;
    property DataScope: string read FDataScope write FDataScope;
    property SortOrder: Integer read FSortOrder write FSortOrder;
    property Status: Integer read FStatus write FStatus;
  end;

implementation

end.
