@echo off
SETLOCAL EnableDelayedExpansion

call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"

"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" src\UniAdmin.dproj /t:Clean,Make /verbosity:minimal /nologo > build2_result.txt 2>&1

echo EXIT_CODE: %ERRORLEVEL%
ENDLOCAL
