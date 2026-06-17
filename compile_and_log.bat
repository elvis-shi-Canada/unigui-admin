@echo off
setlocal
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars32.bat"
echo Starting build at %date% %time% > build_output.txt
msbuild "src\UniAdmin.dproj" /p:Configuration=Debug /t:Build /v:normal >> build_output.txt 2>&1
echo Build completed at %date% %time% >> build_output.txt
echo Exit code: %ERRORLEVEL% >> build_output.txt
type build_output.txt
endlocal
