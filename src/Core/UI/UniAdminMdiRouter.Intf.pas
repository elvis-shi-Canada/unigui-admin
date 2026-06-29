unit UniAdminMdiRouter.Intf;

interface

uses
  System.SysUtils, UniContext;

type
  /// <summary>How a routed target is presented to the user</summary>
  TMdiOpenMode = (omEmbed, omModal);

  /// <summary>
  /// MDI 内容初始化协议 - 由需要执行上下文和初始化的 Frame/Form 实现。
  /// Router 在创建实例后（仅新建分支，缓存命中不重复调用）通过 Supports
  /// 检测本接口，注入会话上下文并触发初始化。
  ///
  /// 设计原因：原先 Router 创建 Frame 后既不注入 Context 也不调用 Initialize，
  /// 导致 FContext=nil、DoInitialize 不执行、按钮状态/数据加载全部失效，
  /// 子类的 DoAdd 等钩子因 Context 为 nil 触发 AV 被静默吞掉（点击无响应）。
  /// </summary>
  IMdiInitializable = interface(IInterface)
    ['{D4E7A1B3-5C2F-4A9D-8E1B-6F3A7C2D9E04}']
    /// <summary>注入当前会话执行上下文</summary>
    procedure SetContext(const Context: IExecutionContext);
    /// <summary>执行初始化（加载数据、设置按钮状态、权限检查等）</summary>
    procedure Initialize;
  end;

  /// <summary>
  /// MDI router service: resolves a registered class name to a Frame/Form
  /// instance, with built-in content caching so that switching back to a
  /// previously opened frame preserves its state (filters, scroll, etc.).
  ///
  /// Design rationale: borrowed from FSThemeCrystal's FindClass-driven menu
  /// routing. Unlike the original act->Tfrm naming convention, UniAdmin stores
  /// the target class name directly in UniAdmin_Menus.RoutePath.
  /// </summary>
  IMdiRouter = interface(IInterface)
    ['{B7C4E1F2-3A5D-4E6F-9A8B-7C5D3E2F1A09}']

    /// <summary>Open target class by name. Embedded frames open as closable
    /// tabs in the host TUniPageControl and are reused on reopen (state
    /// preserved). Pass ACaption for a human-friendly tab title.
    /// AContext（可选）在新建分支注入给支持 IMdiInitializable 的内容。</summary>
    procedure Open(const AClassName: string; const ACaption: string = '';
      AOpenMode: TMdiOpenMode = omEmbed; const AContext: IExecutionContext = nil);

    /// <summary>True when the class name is registered and resolvable.</summary>
    function CanRoute(const AClassName: string): Boolean;

    /// <summary>Close and release a single cached frame.</summary>
    procedure Close(const AClassName: string);

    /// <summary>Close and release every cached frame.</summary>
    procedure CloseAll;
  end;

implementation

end.
