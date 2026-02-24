@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
msbuild "C:\Users\SW\Desktop\unigui-admin\tests\UniAdminTests.dproj" /p:Config=Debug /t:Build /nologo /v:minimal
