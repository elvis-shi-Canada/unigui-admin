unit UniAdminMdiRouter.Intf;

interface

uses
  System.SysUtils;

type
  /// <summary>How a routed target is presented to the user</summary>
  TMdiOpenMode = (omEmbed, omModal);

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
    /// preserved). Pass ACaption for a human-friendly tab title.</summary>
    procedure Open(const AClassName: string; const ACaption: string = '';
      AOpenMode: TMdiOpenMode = omEmbed);

    /// <summary>True when the class name is registered and resolvable.</summary>
    function CanRoute(const AClassName: string): Boolean;

    /// <summary>Close and release a single cached frame.</summary>
    procedure Close(const AClassName: string);

    /// <summary>Close and release every cached frame.</summary>
    procedure CloseAll;
  end;

implementation

end.
