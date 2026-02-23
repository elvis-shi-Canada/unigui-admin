unit UniPlugin.Types;

interface

uses
  System.SysUtils, System.Classes,
  UniContext;

type
  /// <summary>
  /// 上下文感知接口 - 用于组件注入执行上下文
  /// </summary>
  IContextAware = interface(IInterface)
    ['{UNI-CONTEXT-AWARE-001}']
    procedure SetContext(const Context: IExecutionContext);
  end;

  /// <summary>
  /// UniGUI 窗体基类前向声明
  /// 实际类型由 UniGUI 框架提供
  /// </summary>
  TUniForm = class(TComponent)
  private
    // UniGUI 特定的实现将在运行时由框架提供
  end;

  /// <summary>
  /// 窗体类类型别名
  /// </summary>
  TFormClass = class of TUniForm;

  /// <summary>
  /// DataModule 类类型别名
  /// </summary>
  TDataModuleClass = class of TDataModule;

implementation

end.
