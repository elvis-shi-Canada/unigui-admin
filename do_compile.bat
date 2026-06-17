@echo off
SETLOCAL EnableDelayedExpansion

call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"

echo Running MSBuild...
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe" src\UniAdmin.dproj /t:Clean,Make /verbosity:detailed /nologo

echo Exit code: %ERRORLEVEL%
ENDLOCAL
