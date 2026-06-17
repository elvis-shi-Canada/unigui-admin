@echo off
setlocal
set UNIGUI_PATH=D:\BaiduNetdiskDownload\vcl\UniGUI_1600
set DCC_UNITPATH=src;src\Core;src\Modules;src\Plugins;src\Frames
set DCC_INCLUDE=%UNIGUI_PATH%\Lib;%UNIGUI_PATH%\Lib\Win32;%UNIGUI_PATH%\Lib\Core

echo Compiling UniAdmin...
echo.

"C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\dcc32.exe" -B -E..\bin -N..\dcu\Win32\Debug -U"%UNIGUI_PATH%\Lib";"%UNIGUI_PATH%\Lib\Win32";"%UNIGUI_PATH%\Lib\Core";src\Core;src\Modules;src\Plugins;src\Frames -I"%UNIGUI_PATH%\Include" -NSWinapi;System.Win;Vcl;Vcl.Imaging;Data;Datasnap;Web;Soap;Xml;$(DCC_Namespace) src\UniAdmin.dpr

echo.
echo Exit code: %ERRORLEVEL%
if %ERRORLEVEL% neq 0 (
    echo Compilation failed!
) else (
    echo Compilation succeeded!
)
endlocal
