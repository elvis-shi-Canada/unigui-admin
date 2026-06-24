@echo off

SET MSBUILD="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
SET RSVARS="C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"

REM Project root relative to this bat file location (no hardcoded paths)
SET ROOT=%~dp0..
SET PROJECT="%ROOT%\src\UniAdmin.dproj"

call %RSVARS%
%MSBUILD% %PROJECT% "/t:Clean,Make" "/verbosity:minimal"

if %ERRORLEVEL% NEQ 0 GOTO END

echo. 

if "%1"=="" goto END

if /i %1%==test (
  pushd "%ROOT%\bin"
  "%ROOT%\bin\UniAdmin.exe" 
  popd
)
:END
