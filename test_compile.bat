@echo off
SETLOCAL EnableDelayedExpansion

SET MSBUILD="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
SET RSVARS="C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
SET PROJECT="C:\Users\SW\Desktop\unigui-admin\src\UniAdmin.dproj"

call %RSVARS%
%MSBUILD% %PROJECT% "/t:Clean,Make" "/verbosity:minimal"

echo EXIT_CODE: %ERRORLEVEL%
ENDLOCAL
