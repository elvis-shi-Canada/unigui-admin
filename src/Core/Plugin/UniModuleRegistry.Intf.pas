unit UniModuleRegistry.Intf;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  /// <summary>
  /// 插件类信息记录
  /// 用于存储插件类的元数据和配置信息
  /// </summary>
  TPluginClassInfo = record
    /// <summary>插件唯一标识符</summary>
    PluginID: string;
    /// <summary>插件类名</summary>
    ClassName: string;
    /// <summary>插件类引用</summary>
    PluginClass: TClass;
    /// <summary>插件显示名称</summary>
    DisplayName: string;
    /// <summary>插件版本</summary>
    Version: string;
    /// <summary>插件描述</summary>
    Description: string;
    /// <summary>插件作者</summary>
    Author: string;
    /// <summary>插件分类</summary>
    Category: string;
    /// <summary>是否自动启动</summary>
    AutoStart: Boolean;
    /// <summary>配置文件路径</summary>
    ConfigFile: string;
    /// <summary>依赖的插件ID列表</summary>
    Dependencies: TArray<string>;
    /// <summary>优先级（数值越小优先级越高）</summary>
    Priority: Integer;
    /// <summary>是否已加载</summary>
    IsLoaded: Boolean;
    /// <summary>是否已激活</summary>
    IsActivated: Boolean;
  end;

  /// <summary>
  /// 依赖关系信息记录
  /// 用于描述插件之间的依赖关系
  /// </summary>
  TDependencyInfo = record
    /// <summary>依赖源插件ID</summary>
    FromPluginID: string;
    /// <summary>依赖目标插件ID</summary>
    ToPluginID: string;
    /// <summary>依赖类型（强依赖/弱依赖）</summary>
    DependencyType: string;
    /// <summary>最小版本要求</summary>
    MinVersion: string;
  end;

  /// <summary>
  /// 插件加载顺序信息
  /// 用于描述插件的加载顺序和依赖链
  /// </summary>
  TLoadOrderInfo = record
    /// <summary>插件ID</summary>
    PluginID: string;
    /// <summary>加载顺序（从0开始）</summary>
    LoadOrder: Integer;
    /// <summary>依赖层级（0表示无依赖）</summary>
    DependencyLevel: Integer;
  end;

  /// <summary>
  /// 插件注册表接口
  /// 提供插件类的注册、查找和依赖管理功能
  /// </summary>
  IUniModuleRegistry = interface(IInterface)
    ['{UNI-MODULE-REGISTRY-001}']

    /// <summary>注册插件类</summary>
    /// <param name="PluginClass">插件类</param>
    /// <param name="PluginID">插件唯一标识符</param>
    /// <param name="Info">插件信息记录</param>
    procedure RegisterPluginClass(const PluginClass: TClass; const PluginID: string;
      const Info: TPluginClassInfo);

    /// <summary>注销插件类</summary>
    /// <param name="PluginID">插件唯一标识符</param>
    procedure UnregisterPluginClass(const PluginID: string);

    /// <summary>检查插件是否已注册</summary>
    /// <param name="PluginID">插件唯一标识符</param>
    /// <returns>如果插件已注册则返回True</returns>
    function IsPluginRegistered(const PluginID: string): Boolean;

    /// <summary>获取插件类信息</summary>
    /// <param name="PluginID">插件唯一标识符</param>
    /// <returns>插件类信息记录</returns>
    function GetPluginClassInfo(const PluginID: string): TPluginClassInfo;

    /// <summary>获取所有已注册的插件ID列表</summary>
    /// <returns>插件ID数组</returns>
    function GetAllPluginIDs: TArray<string>;

    /// <summary>根据分类获取插件ID列表</summary>
    /// <param name="Category">插件分类</param>
    /// <returns>该分类下的插件ID数组</returns>
    function GetPluginsByCategory(const Category: string): TArray<string>;

    /// <summary>添加依赖关系</summary>
    /// <param name="FromPluginID">依赖源插件ID</param>
    /// <param name="ToPluginID">依赖目标插件ID</param>
    /// <param name="MinVersion">最小版本要求</param>
    procedure AddDependency(const FromPluginID, ToPluginID, MinVersion: string);

    /// <summary>移除依赖关系</summary>
    /// <param name="FromPluginID">依赖源插件ID</param>
    /// <param name="ToPluginID">依赖目标插件ID</param>
    procedure RemoveDependency(const FromPluginID, ToPluginID: string);

    /// <summary>获取插件的所有依赖项</summary>
    /// <param name="PluginID">插件ID</param>
    /// <returns>依赖的插件ID数组</returns>
    function GetDependencies(const PluginID: string): TArray<string>;

    /// <summary>获取依赖于指定插件的所有插件</summary>
    /// <param name="PluginID">插件ID</param>
    /// <returns>依赖该插件的插件ID数组</summary>
    function GetDependents(const PluginID: string): TArray<string>;

    /// <summary>检测是否存在循环依赖</summary>
    /// <returns>如果存在循环依赖则返回True，并输出循环路径</returns>
    function DetectCircularDependency(out CircularPath: string): Boolean;

    /// <summary>计算插件加载顺序（拓扑排序）</summary>
    /// <returns>按加载顺序排列的插件信息数组</returns>
    /// <remarks>如果存在循环依赖，将抛出异常</remarks>
    function CalculateLoadOrder: TArray<TLoadOrderInfo>;

    /// <summary>验证依赖关系是否完整</summary>
    /// <param name="MissingPlugins">缺失的插件ID列表（输出参数）</param>
    /// <returns>如果所有依赖都满足则返回True</returns>
    function ValidateDependencies(out MissingPlugins: TArray<string>): Boolean;

    /// <summary>获取注册的插件数量</summary>
    function GetPluginCount: Integer;

    /// <summary>清空所有注册信息</summary>
    procedure Clear;
  end;

implementation

end.
