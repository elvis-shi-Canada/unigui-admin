unit UniAdminLogger.Intf;

interface

type
  /// <summary>
  /// Log severity levels, ordered from least to most severe.
  /// </summary>
  TLogLevel = (llDebug, llInfo, llWarning, llError);

  /// <summary>
  /// Runtime logging service contract.
  ///
  /// Provides thread-safe, file-based logging that is intentionally independent
  /// of the database layer, so it remains available during early application
  /// startup (for example inside ServerModule.OnCreate) before any DB
  /// connection has been established.
  ///
  /// Note: This unit is intentionally named UniAdminLogger (not UniLogger) to
  /// avoid clashing with uniGUI's own internal UniLogger unit / TUniLogger type.
  /// </summary>
  IUniAdminLogger = interface
    ['{B5C2D3E4-5678-4ABC-9DEF-0123456789AB}']

    procedure Debug(const AMessage: string); overload;
    procedure Debug(const AFormat: string; const AArgs: array of const); overload;

    procedure Info(const AMessage: string); overload;
    procedure Info(const AFormat: string; const AArgs: array of const); overload;

    procedure Warn(const AMessage: string); overload;
    procedure Warn(const AFormat: string; const AArgs: array of const); overload;

    procedure Error(const AMessage: string); overload;
    procedure Error(const AFormat: string; const AArgs: array of const); overload;

    /// <summary>Minimum severity that will be persisted to the log file.</summary>
    procedure SetMinLevel(ALevel: TLogLevel);
    function GetMinLevel: TLogLevel;
    property MinLevel: TLogLevel read GetMinLevel write SetMinLevel;
  end;

implementation

end.
