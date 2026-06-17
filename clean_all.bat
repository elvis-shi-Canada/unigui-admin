@echo off
echo Cleaning UniAdmin project...

REM 删除 .dcu 文件
del /s /q *.dcu

REM 删除 IDE 缓存文件
del /s /q *.~*
del /s /q *.exe
del /s /q *.cfg
del /s /q *.dof
del /s /q *.local
del /s /q *.identcache

echo Clean complete. Please rebuild the project in Delphi IDE.
pause
