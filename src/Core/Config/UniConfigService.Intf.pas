unit UniConfigService.Intf;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  /// <summary>
  /// 配置值类型枚举
  /// 定义配置支持的数据类型
  /// </summary>
  TConfigValueType = (
    cvtString,      // 字符串类型
    cvtInteger,     // 整数类型
    cvtBoolean,     // 布尔类型
    cvtFloat,       // 浮点数类型
    cvtDateTime,    // 日期时间类型
    cvtStringList,  // 字符串列表类型
    cvtObject       // 对象类型（JSON对象）
  );

  /// <summary>
  /// 配置变更事件回调类型
  /// </summary>
  TConfigChangeEvent = reference to procedure(const ModuleName, Key: string; const OldValue, NewValue: Variant);

  /// <summary>
  /// 模块配置接口
  /// 提供单个模块的配置管理功能
  /// </summary>
  IModuleConfig = interface(IInterface)
    ['{UNI-MODULE-CONFIG-001}']

    /// <summary>获取模块名称</summary>
    function GetModuleName: string;

    /// <summary>获取配置文件路径</summary>
    function GetConfigFile: string;

    /// <summary>获取所有配置键</summary>
    /// <returns>配置键数组</returns>
    function GetAllKeys: TArray<string>;

    /// <summary>检查配置键是否存在</summary>
    /// <param name="Key">配置键</param>
    /// <returns>如果键存在则返回True</returns>
    function KeyExists(const Key: string): Boolean;

    /// <summary>获取字符串值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetString(const Key: string; const DefaultValue: string = ''): string;

    /// <summary>获取整数值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetInteger(const Key: string; const DefaultValue: Integer = 0): Integer;

    /// <summary>获取布尔值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;

    /// <summary>获取浮点数值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetFloat(const Key: string; const DefaultValue: Double = 0.0): Double;

    /// <summary>获取日期时间值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetDateTime(const Key: string; const DefaultValue: TDateTime = 0): TDateTime;

    /// <summary>获取字符串列表值</summary>
    /// <param name="Key">配置键</param>
    /// <returns>字符串列表</returns>
    function GetStringList(const Key: string): TStringList;

    /// <summary>设置字符串值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetValue(const Key, Value: string); overload;

    /// <summary>设置整数值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetValue(const Key: string; Value: Integer); overload;

    /// <summary>设置布尔值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetValue(const Key: string; Value: Boolean); overload;

    /// <summary>设置浮点数值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetValue(const Key: string; Value: Double); overload;

    /// <summary>设置日期时间值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetValue(const Key: string; Value: TDateTime); overload;

    /// <summary>设置字符串列表值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">字符串列表</param>
    procedure SetStringList(const Key: string; Value: TStrings);

    /// <summary>删除配置键</summary>
    /// <param name="Key">配置键</param>
    procedure DeleteKey(const Key: string);

    /// <summary>清空所有配置</summary>
    procedure Clear;

    /// <summary>从文件加载配置</summary>
    /// <returns>如果加载成功则返回True</returns>
    function LoadFromFile: Boolean;

    /// <summary>保存配置到文件</summary>
    /// <returns>如果保存成功则返回True</returns>
    function SaveToFile: Boolean;

    /// <summary>注册配置变更事件</summary>
    /// <param name="Event">变更事件回调</param>
    procedure RegisterChangeHandler(const Event: TConfigChangeEvent);

    /// <summary>注销配置变更事件</summary>
    /// <param name="Event">变更事件回调</param>
    procedure UnregisterChangeHandler(const Event: TConfigChangeEvent);
  end;

  /// <summary>
  /// 统一配置服务接口
  /// 提供全局配置管理功能，支持多模块配置
  /// </summary>
  IUniConfigService = interface(IInterface)
    ['{UNI-CONFIG-SERVICE-001}']

    /// <summary>获取配置文件根目录</summary>
    function GetConfigRoot: string;

    /// <summary>设置配置文件根目录</summary>
    /// <param name="Path">根目录路径</param>
    procedure SetConfigRoot(const Path: string);

    /// <summary>获取全局配置文件路径</summary>
    function GetGlobalConfigFile: string;

    /// <summary>获取或创建模块配置</summary>
    /// <param name="ModuleName">模块名称</param>
    /// <returns>模块配置接口</returns>
    function GetModuleConfig(const ModuleName: string): IModuleConfig;

    /// <summary>检查模块配置是否存在</summary>
    /// <param name="ModuleName">模块名称</param>
    /// <returns>如果模块配置存在则返回True</returns>
    function HasModuleConfig(const ModuleName: string): Boolean;

    /// <summary>移除模块配置</summary>
    /// <param name="ModuleName">模块名称</param>
    procedure RemoveModuleConfig(const ModuleName: string);

    /// <summary>获取所有已注册的模块名称</summary>
    /// <returns>模块名称数组</returns>
    function GetAllModuleNames: TArray<string>;

    /// <summary>加载全局配置</summary>
    /// <returns>如果加载成功则返回True</returns>
    function LoadGlobalConfig: Boolean;

    /// <summary>保存全局配置</summary>
    /// <returns>如果保存成功则返回True</returns>
    function SaveGlobalConfig: Boolean;

    /// <summary>加载所有模块配置</summary>
    /// <returns>如果所有配置都加载成功则返回True</returns>
    function LoadAllModuleConfigs: Boolean;

    /// <summary>保存所有模块配置</summary>
    /// <returns>如果所有配置都保存成功则返回True</returns>
    function SaveAllModuleConfigs: Boolean;

    /// <summary>获取全局字符串配置值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetGlobalString(const Key: string; const DefaultValue: string = ''): string;

    /// <summary>获取全局整数配置值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetGlobalInteger(const Key: string; const DefaultValue: Integer = 0): Integer;

    /// <summary>获取全局布尔配置值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="DefaultValue">默认值</param>
    /// <returns>配置值</returns>
    function GetGlobalBoolean(const Key: string; const DefaultValue: Boolean = False): Boolean;

    /// <summary>设置全局字符串配置值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetGlobalString(const Key, Value: string);

    /// <summary>设置全局整数配置值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetGlobalInteger(const Key: string; Value: Integer);

    /// <summary>设置全局布尔配置值</summary>
    /// <param name="Key">配置键</param>
    /// <param name="Value">配置值</param>
    procedure SetGlobalBoolean(const Key: string; Value: Boolean);

    /// <summary>注册全局配置变更事件</summary>
    /// <param name="Event">变更事件回调</param>
    procedure RegisterGlobalChangeHandler(const Event: TConfigChangeEvent);

    /// <summary>注销全局配置变更事件</summary>
    /// <param name="Event">变更事件回调</param>
    procedure UnregisterGlobalChangeHandler(const Event: TConfigChangeEvent);

    /// <summary>刷新配置（重新加载所有配置文件）</summary>
    /// <returns>如果刷新成功则返回True</returns>
    function Refresh: Boolean;
  end;

implementation

end.
