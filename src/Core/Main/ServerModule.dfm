object ServerModule: TServerModule
  OnCreate = OnCreate
  OnDestroy = OnDestroy
  TempFolder = 'temp\'
  Title = #26032#24212#29992#31243#24207
  SuppressErrors = []
  Bindings = <>
  MainFormDisplayMode = mfPage
  CustomCSS.Strings = (
    '/* ===== UniAdmin Unified Design System ===== */'
    
      '.x-body{font-family:Segoe UI,system-ui,-apple-system,sans-serif!' +
      'important;font-size:14px!important;color:#1f2937!important}'
    
      '.x-window{border-radius:12px!important;overflow:hidden!important' +
      ';box-shadow:0 20px 60px rgba(0,0,0,0.12)!important}'
    
      '.x-window-header{background:linear-gradient(135deg,#667eea 0%,#7' +
      '64ba2 100%)!important;padding:10px 18px!important;border-bottom:' +
      'none!important}'
    
      '.x-window-header .x-window-header-title{color:#ffffff!important;' +
      'font-weight:600!important;font-size:15px!important}'
    '.x-window-header .x-tool-close:before{color:#ffffff!important}'
    '.x-window-body{background:#ffffff!important}'
    '.x-panel-default{border-color:#e5e7eb!important}'
    
      '.x-panel-header-default{background:#f8fafc!important;border-bott' +
      'om:1px solid #e5e7eb!important}'
    
      '.x-panel-header-text{font-weight:600!important;color:#1f2937!imp' +
      'ortant}'
    
      '.x-btn{border-radius:8px!important;transition:all 0.2s ease!impo' +
      'rtant}'
    '.x-btn .x-btn-inner{font-weight:500!important}'
    
      '.uni-btn-primary{background:linear-gradient(135deg,#667eea 0%,#7' +
      '64ba2 100%)!important;border:none!important;background-image:non' +
      'e!important}'
    
      '.uni-btn-primary .x-btn-inner{color:#ffffff!important;font-weigh' +
      't:600!important}'
    '.uni-btn-primary.x-btn-over{opacity:0.9!important}'
    
      '.uni-btn-success{background-color:#10b981!important;border:1px s' +
      'olid #059669!important;background-image:none!important}'
    '.uni-btn-success .x-btn-inner{color:#ffffff!important}'
    
      '.uni-btn-danger{background-color:#ef4444!important;border:1px so' +
      'lid #dc2626!important;background-image:none!important}'
    '.uni-btn-danger .x-btn-inner{color:#ffffff!important}'
    
      '.uni-btn-warning{background-color:#f59e0b!important;border:1px s' +
      'olid #d97706!important;background-image:none!important}'
    '.uni-btn-warning .x-btn-inner{color:#ffffff!important}'
    
      '.x-form-text{border-radius:6px!important;transition:border-color' +
      ' 0.2s,box-shadow 0.2s!important}'
    
      '.x-form-text.x-form-focus{border-color:#667eea!important;box-sha' +
      'dow:0 0 0 3px rgba(102,126,234,0.12)!important}'
    
      '.x-form-item-label{font-weight:500!important;color:#374151!impor' +
      'tant}'
    
      '.x-grid-header-ct{background:#f8fafc!important;border-bottom:2px' +
      ' solid #e5e7eb!important}'
    '.x-column-header{background:#f8fafc!important}'
    '.x-column-header-over{background:#eef2ff!important}'
    '.x-grid-row-over .x-grid-td{background-color:#f0f4ff!important}'
    
      '.x-grid-row-selected .x-grid-td{background-color:#e0e7ff!importa' +
      'nt}'
    
      '.x-toolbar{background:#f8fafc!important;border-bottom:1px solid ' +
      '#e5e7eb!important;padding:6px 8px!important}'
    '.x-toolbar .x-btn{margin-right:4px!important}'
    '.x-tab-bar{background:#f8fafc!important}'
    
      '.x-tab{border-radius:8px 8px 0 0!important;margin-right:2px!impo' +
      'rtant}'
    '.x-tab-active{background:#ffffff!important}'
    
      '.x-tab-active .x-tab-inner{color:#667eea!important;font-weight:6' +
      '00!important}'
    
      '.x-menu{border-radius:8px!important;box-shadow:0 10px 30px rgba(' +
      '0,0,0,0.1)!important;border:1px solid #e5e7eb!important}'
    '.x-menu-item-link{padding:8px 24px!important}'
    '.x-menu-item-active{background:#eef2ff!important}'
    '.x-menu-item-active .x-menu-item-text{color:#667eea!important}'
    
      '.uni-card{background:#ffffff!important;border:1px solid #e5e7eb!' +
      'important;border-radius:12px!important;box-shadow:0 2px 8px rgba' +
      '(0,0,0,0.06)!important}'
    '.uni-card .x-panel-body{background:transparent!important}'
    
      '.uni-header{background:linear-gradient(135deg,#667eea 0%,#764ba2' +
      ' 100%)!important;border:none!important}'
    '.uni-header .x-panel-body{background:transparent!important}'
    
      '.uni-footer{background:#f8fafc!important;border-top:1px solid #e' +
      '5e7eb!important}'
    '.uni-footer .x-panel-body{background:transparent!important}'
    
      '.uni-section-title{font-size:18px!important;font-weight:700!impo' +
      'rtant;color:#1f2937!important}'
    
      '.login-form-bg,.login-form-bg .x-panel-body{background:linear-gr' +
      'adient(135deg,#667eea 0%,#764ba2 100%)!important}'
    
      '.login-card{background:#ffffff!important;border:none!important;b' +
      'order-radius:16px!important;box-shadow:0 20px 60px rgba(0,0,0,0.' +
      '15)!important;overflow:hidden!important}'
    
      '.login-card .x-panel-body{background:transparent!important;borde' +
      'r:none!important}'
    '.login-title{color:#1a1a1a!important}'
    '.login-subtitle{color:#999999!important}'
    
      '.login-input .x-form-text{border:2px solid #e5e7eb!important;bor' +
      'der-radius:8px!important;padding:10px 14px!important;font-size:1' +
      '5px!important;height:auto!important;transition:border-color 0.2s' +
      ' ease,box-shadow 0.2s ease!important}'
    
      '.login-input .x-form-text.x-form-focus{border-color:#667eea!impo' +
      'rtant;box-shadow:0 0 0 3px rgba(102,126,234,0.15)!important}'
    
      '.login-btn-primary{background:linear-gradient(135deg,#667eea 0%,' +
      '#764ba2 100%)!important;border:none!important;border-radius:8px!' +
      'important;box-shadow:0 4px 14px rgba(102,126,234,0.35)!important' +
      ';transition:transform 0.15s ease,box-shadow 0.15s ease!important' +
      '}'
    
      '.login-btn-primary .x-btn-inner{color:#ffffff!important;font-wei' +
      'ght:700!important;font-size:16px!important}'
    
      '.login-btn-primary:hover{transform:translateY(-1px)!important;bo' +
      'x-shadow:0 6px 20px rgba(102,126,234,0.45)!important}'
    
      '.login-btn-primary:active{transform:translateY(0)!important;box-' +
      'shadow:0 2px 8px rgba(102,126,234,0.3)!important}'
    
      '.login-btn-secondary{background:#ffffff!important;border:2px sol' +
      'id #e5e7eb!important;border-radius:8px!important;transition:bord' +
      'er-color 0.2s ease!important}'
    
      '.login-btn-secondary .x-btn-inner{color:#6b7280!important;font-w' +
      'eight:500!important}'
    '.login-btn-secondary:hover{border-color:#667eea!important}'
    '.login-btn-secondary:hover .x-btn-inner{color:#667eea!important}'
    '.login-footer{color:#999999!important}'
    '/* ===== End Design System ===== */')
  SSL.SSLOptions.RootCertFile = 'root.pem'
  SSL.SSLOptions.CertFile = 'cert.pem'
  SSL.SSLOptions.KeyFile = 'key.pem'
  SSL.SSLOptions.Method = sslvSSLv23
  SSL.SSLOptions.SSLVersions = [sslvTLSv1_1, sslvTLSv1_2]
  SSL.SSLOptions.Mode = sslmUnassigned
  SSL.SSLOptions.VerifyMode = []
  SSL.SSLOptions.VerifyDepth = 0
  ConnectionFailureRecovery.ErrorMessage = #36830#25509#38169#35823
  ConnectionFailureRecovery.RetryMessage = #37325#35797'...'
  Height = 480
  Width = 640
  object FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink
    Left = 320
    Top = 136
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 320
    Top = 240
  end
  object FDManager: TFDManager
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Left = 264
    Top = 64
  end
end
