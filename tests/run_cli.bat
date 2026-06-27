@echo off
REM Compile and run the DUnitX test project (pure ASCII per AGENTS.md rule 13)
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
if errorlevel 1 (
  echo [ERROR] rsvars.bat not found
  exit /b 1
)
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" "D:\Code\delphi\unigui-admin\tests\UniAdminTests.dproj" /t:Make /verbosity:minimal /p:Config=Debug
if errorlevel 1 (
  echo [ERROR] Build failed
  exit /b 1
)
echo [INFO] Build OK, running tests...
"D:\Code\delphi\unigui-admin\tests\Win32\Debug\UniAdminTests.exe"
