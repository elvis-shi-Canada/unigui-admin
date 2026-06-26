@echo off
REM UniAdmin DUnitX 测试运行脚本
REM 用法: 双击此脚本在 Delphi IDE 中打开测试项目

setlocal

set PROJECT_DIR=%~dp0tests
set PROJECT_FILE=%PROJECT_DIR%\UniAdminTests.dproj

echo ========================================
echo  UniAdmin DUnitX 测试
echo ========================================
echo.

REM 检查项目文件是否存在
if not exist "%PROJECT_FILE%" (
    echo [错误] 找不到测试项目文件: %PROJECT_FILE%
    echo.
    pause
    exit /b 1
)

echo [选项 1] 在 Delphi IDE 中打开测试项目
echo [选项 2] 从命令行运行测试 (需要先编译)
echo [选项 3] 查看运行指南
echo [选项 4] 退出
echo.

choice /C 1234 /M "请选择操作"

if errorlevel 4 goto :eof
if errorlevel 3 (
    start "" "%PROJECT_DIR%\DUnitX-运行指南.md"
    goto :eof
)
if errorlevel 2 goto :run_cli
if errorlevel 1 goto :open_ide

:open_ide
    echo.
    echo 正在打开 Delphi IDE...
    start "" "%PROJECT_FILE%"
    goto :eof

:run_cli
    echo.
    echo 从命令行运行需要先编译项目...
    echo.
    echo 请使用以下命令:
    echo   msbuild "%PROJECT_FILE%" /p:Config=Debug
    echo   "%PROJECT_DIR%\Win32\Debug\UniAdminTests.exe"
    echo.
    pause
    goto :eof
