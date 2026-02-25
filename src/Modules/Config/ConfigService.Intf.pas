unit ConfigService.Intf;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  UniContext, UniPlugin.Types;

type
  /// <summary>
  /// 配置值类型枚举
  /// </summary>
  TConfigValueType = (cvtString, cvtInteger, cvtBoolean, cvtFloat, cvtJson, cvtXml);

  /// <summary>
  /// 系统配置记录
  /// </summary>
  TConfigInfo = record
    ConfigID: Integer;
    ConfigKey: string;
    ConfigValue: string;
    Category: string;
    CategoryName: string;
    Description: string;
    ValueType: TConfigValueType;
    ValueTypeText: string;
    SortOrder: Integer;
    Status: Integer;
    StatusText: string;
    CreatedDate: TDateTime;
    CreatedBy: Integer;
    ModifiedDate: TDateTime;
    ModifiedBy: Integer;
  end;

  /// <summary>
  /// 配置分类记录
  /// </summary>
  TConfigCategoryInfo = record
    Category: string;
    CategoryName: string;
    Description: string;
    ConfigCount: Integer;
  end;

  /// <summary>
  /// 配置服务接口
  /// </summary>
  IConfigService = interface(IInterface)
    ['{F9D0C8B2-A7E5-6D4F-B2C8-8A9F1D3E5C7B}']


    // 配置操作
    function GetConfigs(const Filter, Category: string; Status: Integer): TArray<TConfigInfo>;
    function GetConfigByID(ConfigID: Integer): TConfigInfo;
    function GetConfigByKey(const ConfigKey: string): TConfigInfo;
    function GetConfigsByCategory(const Category: string; Status: Integer): TArray<TConfigInfo>;
    function CreateConfig(const ConfigKey, ConfigValue, Category, Description: string;
      ValueType: TConfigValueType; SortOrder: Integer): Integer;
    procedure UpdateConfig(ConfigID: Integer; const ConfigValue, Description: string;
      SortOrder: Integer);
    procedure DeleteConfig(ConfigID: Integer);
    procedure SetConfigStatus(ConfigID, Status: Integer);

    // 配置分类
    function GetCategories: TArray<TConfigCategoryInfo>;

    // 配置值访问（简化方法）
    function GetValue(const ConfigKey: string): string;
    procedure SetValue(const ConfigKey, ConfigValue: string);
    function GetValueAsInteger(const ConfigKey: string; Default: Integer = 0): Integer;
    function GetValueAsBoolean(const ConfigKey: string; Default: Boolean = False): Boolean;

    // 缓存管理
    procedure ClearCache;
    procedure RefreshCache(const ConfigKey: string = '');
  end;

implementation

end.
