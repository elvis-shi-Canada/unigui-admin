unit UniMenuManager.Intf;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  /// <summary>
  /// 菜单项数据结构
  /// </summary>
  TMenuItem = record
    MenuID: Integer;
    ParentID: Integer;
    MenuName: string;
    MenuCode: string;
    Icon: string;
    RoutePath: string;
    PermissionCode: string;
    SortOrder: Integer;
    IsVisible: Boolean;
    Children: TArray<TMenuItem>;
  end;

  /// <summary>
  /// 菜单管理器接口
  /// 提供菜单树的查询、管理和缓存功能
  /// </summary>
  IUniMenuManager = interface(IInterface)
    ['{E1C9A8F2-D7B5-7E3C-A4F8-8B9D1E2F5C7A}']


    /// <summary>
    /// 获取用户的完整菜单树（带权限过滤）
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <returns>菜单树数组</returns>
    function GetMenuTree(const UserID: Integer): TArray<TMenuItem>;

    /// <summary>
    /// 根据菜单ID获取菜单项
    /// </summary>
    /// <param name="MenuID">菜单ID</param>
    /// <returns>菜单项</returns>
    function GetMenuByID(const MenuID: Integer): TMenuItem;

    /// <summary>
    /// 添加新菜单
    /// </summary>
    /// <param name="Menu">菜单项</param>
    /// <returns>是否成功</returns>
    function AddMenu(const Menu: TMenuItem): Boolean;

    /// <summary>
    /// 更新菜单信息
    /// </summary>
    /// <param name="Menu">菜单项</param>
    /// <returns>是否成功</returns>
    function UpdateMenu(const Menu: TMenuItem): Boolean;

    /// <summary>
    /// 删除菜单（级联删除子菜单）
    /// </summary>
    /// <param name="MenuID">菜单ID</param>
    /// <returns>是否成功</returns>
    function DeleteMenu(const MenuID: Integer): Boolean;

    /// <summary>
    /// 获取用户有权限访问的菜单列表（扁平）
    /// </summary>
    /// <param name="UserID">用户ID</param>
    /// <returns>菜单数组</returns>
    function GetUserMenus(const UserID: Integer): TArray<TMenuItem>;

    /// <summary>
    /// 刷新菜单缓存
    /// </summary>
    procedure RefreshCache;
  end;

implementation

end.
