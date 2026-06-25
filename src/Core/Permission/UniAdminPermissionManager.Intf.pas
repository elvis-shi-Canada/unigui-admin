unit UniAdminPermissionManager.Intf;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  /// <summary>
  /// 权限信息数据结构
  /// </summary>
  TPermissionInfo = record
    PermissionID: Integer;
    PermissionCode: string;
    PermissionName: string;
    ResourceType: string;
    ResourceCode: string;
    Action: string;
    Description: string;
  end;

  /// <summary>
  /// 角色信息数据结构
  /// </summary>
  TRoleInfo = record
    RoleID: Integer;
    RoleCode: string;
    RoleName: string;
    Description: string;
    DataScope: string;
  end;

  /// <summary>
  /// 数据范围类型枚举
  /// </summary>
  TDataScopeType = (
    dsAll,        // 全部数据
    dsCustom,     // 自定义数据
    dsDepartment, // 本部门数据
    dsDepartmentAndSub, // 本部门及子部门数据
    dsSelf,       // 仅本人数据
    dsNone        // 无权限
  );

  /// <summary>
  /// 权限管理器接口
  /// 提供基于角色的访问控制（RBAC）功能
  /// </summary>
  IUniAdminPermissionManager = interface(IInterface)
    ['{C8E9D7A3-6F4C-5B3E-E2D7-7A9C1F3D6E8B}']


    /// <summary>
    /// 检查用户是否拥有指定权限
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <param name="PermissionCode">权限代码</param>
    /// <returns>是否有权限</returns>
    function HasPermission(const UserID: Integer; const PermissionCode: string): Boolean;

    /// <summary>
    /// 获取用户的所有权限列表
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <returns>权限数组</returns>
    function GetUserPermissions(const UserID: Integer): TArray<TPermissionInfo>;

    /// <summary>
    /// 获取用户的所有角色
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <returns>角色数组</returns>
    function GetRoles(const UserID: Integer): TArray<TRoleInfo>;

    /// <summary>
    /// 为用户分配角色
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <param name="RoleID">角色ID</param>
    /// <returns>是否成功</returns>
    function AssignRoleToUser(const UserID, RoleID: Integer): Boolean;

    /// <summary>
    /// 取消用户的角色分配
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <param name="RoleID">角色ID</param>
    /// <returns>是否成功</returns>
    function RemoveRoleFromUser(const UserID, RoleID: Integer): Boolean;

    /// <summary>
    /// 获取用户对指定资源的数据范围
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <param name="Resource">资源代码</param>
    /// <returns>数据范围类型</returns>
    function GetDataScope(const UserID: Integer; const Resource: string): TDataScopeType;

    /// <summary>
    /// 检查用户是否有指定角色的权限
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <param name="RoleCode">角色代码</param>
    /// <returns>是否拥有该角色</returns>
    function HasRole(const UserID: Integer; const RoleCode: string): Boolean;
  end;

implementation

end.
