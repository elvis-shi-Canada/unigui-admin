unit UniPlugin.Types;

interface

uses
  System.SysUtils, System.Classes,
  UniContext, Vcl.Forms, uniGUIForm;

type
  /// <summary>
  /// 上下文感知接口 - 用于组件注入执行上下文
  /// </summary>
  IContextAware = interface(IInterface)
    ['{7A3F9C2E-1B5D-4E8A-9C6F-2D4E8B1A5C3F}']
    procedure SetContext(const Context: IExecutionContext);
  end;

  /// <summary>
  /// 窗体类类型别名
  /// TUniForm 由 uniGUIForm 单元定义
  /// </summary>
  TFormClass = class of TUniForm;

  /// <summary>
  /// DataModule 类类型别名
  /// </summary>
  TDataModuleClass = class of TDataModule;

implementation

end.
