@echo off
setlocal
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
"C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\dcc32.exe" -B -Ebin -Ndcu\Win32\Debug -UD:\BaiduNetdiskDownload\vcl\UniGUI_1600\Lib;D:\BaiduNetdiskDownload\vcl\UniGUI_1600\Lib\Win32;D:\BaiduNetdiskDownload\vcl\UniGUI_1600\Lib\Core;src\Core;src\Modules;src\Plugins;src\Frames src\UniAdmin.dpr
echo RESULT=%ERRORLEVEL%
endlocal
