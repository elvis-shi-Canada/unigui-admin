@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
msbuild src\UniAdmin.dproj /t:Clean,Make /v:m /nologo
