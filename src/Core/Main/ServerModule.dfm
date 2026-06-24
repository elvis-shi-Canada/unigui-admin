object ServerModule: TServerModule
  OnCreate = OnCreate
  OnDestroy = OnDestroy
  TempFolder = 'temp\'
  Title = #26032#24212#29992#31243#24207
  SuppressErrors = []
  Bindings = <>
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
end
