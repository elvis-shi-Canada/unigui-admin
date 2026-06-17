@echo off
SETLOCAL EnableDelayedExpansion

call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"

echo Compiling with dcc32...
"C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\dcc32.exe" -B -E..\bin -N..\dcu\Win32\Debug src\UniAdmin.dpr

echo EXIT_CODE: %ERRORLEVEL%
ENDLOCAL
