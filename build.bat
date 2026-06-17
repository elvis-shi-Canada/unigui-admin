@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars32.bat"
msbuild "src\UniAdmin.dproj" /p:Configuration=Debug /t:Build /v:minimal
echo Build completed with exit code %ERRORLEVEL%
