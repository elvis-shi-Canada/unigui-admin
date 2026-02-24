@echo off
REM =====================================================
REM UniAdmin 编译和测试脚本
REM =====================================================
REM 功能: 自动编译所有单元并运行 DUnitX 测试
REM 作者: UniAdmin Team
REM 版本: 1.0.0
REM =====================================================

setlocal enabledelayedexpansion

REM 颜色定义
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

REM 项目根目录
set "PROJECT_ROOT=%~dp0"
set "SRC_DIR=%PROJECT_ROOT%src"
set "TESTS_DIR=%PROJECT_ROOT%tests"
set "BIN_DIR=%PROJECT_ROOT%bin"
set "DCU_DIR=%PROJECT_ROOT%dcu"

echo %BLUE%=====================================================%RESET%
echo %BLUE%UniAdmin 编译和测试脚本%RESET%
echo %BLUE%=====================================================%RESET%
echo.

REM 检查 DCC32 编译器是否可用
where dcc32 >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%错误: 未找到 DCC32 编译器！%RESET%
    echo %YELLOW%请确保 Delphi 已安装并在 PATH 中%RESET%
    exit /b 1
)

REM 创建必要的目录
echo %BLUE%[1/5] 创建输出目录...%RESET%
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"
if not exist "%DCU_DIR%" mkdir "%DCU_DIR%"
echo %GREEN%√ 目录创建完成%RESET%
echo.

REM 清理旧的编译文件
echo %BLUE%[2/5] 清理旧的编译文件...%RESET%
if exist "%DCU_DIR%\*.dcu" del /q "%DCU_DIR%\*.dcu"
if exist "%BIN_DIR%\*.exe" del /q "%BIN_DIR%\*.exe"
echo %GREEN%√ 清理完成%RESET%
echo.

REM 编译核心单元
echo %BLUE%[3/5] 编译核心单元...%RESET%
set "CORE_OK=1"

for %%f in (
    "Core\Context\UniContext.pas"
    "Core\Context\UniSession.pas"
    "Core\Plugin\UniPlugin.Types.pas"
    "Core\Plugin\UniPlugin.Intf.pas"
    "Core\Plugin\UniPlugin.pas"
    "Core\Plugin\UniModuleRegistry.Intf.pas"
    "Core\Plugin\UniModuleRegistry.pas"
    "Core\Plugin\UniModuleRegistration.pas"
    "Core\Data\UniDataModule.pas"
    "Core\Data\UniConnectionManager.pas"
    "Core\Metadata\UniMetadataCache.pas"
    "Core\Auth\UniAuthService.pas"
    "Core\Menu\UniMenuManager.pas"
    "Core\Menu\SystemMenuSetup.pas"
    "Core\Permission\UniPermissionManager.pas"
    "Core\Services\UniServices.pas"
    "Core\Session\UniSession.pas"
) do (
    set "FILE=%SRC_DIR%\%%f"
    if exist "!FILE!" (
        echo   编译: %%~nxf
        dcc32 -B -N"%DCU_DIR%" -U"%SRC_DIR%" "!FILE!" >nul 2>&1
        if !errorlevel! neq 0 (
            echo %RED%✗ 编译失败: %%~nxf%RESET%
            set "CORE_OK=0"
        ) else (
            echo %GREEN%  √%%~nxf%RESET%
        )
    ) else (
        echo %YELLOW%  跳过 (不存在): %%~nxf%RESET%
    )
)

if %CORE_OK%==0 (
    echo.
    echo %RED%核心单元编译失败！%RESET%
    exit /b 1
)
echo %GREEN%√ 核心单元编译完成%RESET%
echo.

REM 编译模块单元
echo %BLUE%[4/5] 编译模块单元...%RESET%
set "MODULES_OK=1"

for %%d in (
    "User"
    "Role"
    "Menu"
    "Dictionary"
    "Config"
    "Log"
    "Scheduler"
) do (
    echo   模块: %%d
    for %%f in ("%SRC_DIR%\Modules\%%d\*.pas") do (
        set "BASENAME=%%~nxf"
        REM 跳过测试文件和接口文件
        echo !BASENAME! | findstr /i "test.intf.pas" >nul
        if !errorlevel!==1 (
            echo !BASENAME! | findstr /i "Test.pas" >nul
            if !errorlevel!==1 (
                dcc32 -B -N"%DCU_DIR%" -U"%SRC_DIR%;%SRC_DIR%\Modules\%%d" "%%f" >nul 2>&1
                if !errorlevel! neq 0 (
                    echo %RED%    ✗ 编译失败: %%~nxf%RESET%
                    set "MODULES_OK=0"
                )
            )
        )
    )
)

if %MODULES_OK%==0 (
    echo.
    echo %RED%模块单元编译失败！%RESET%
    exit /b 1
)
echo %GREEN%√ 模块单元编译完成%RESET%
echo.

REM 运行测试
echo %BLUE%[5/5] 运行单元测试...%RESET%
set "TESTS_OK=1"

REM 检查测试可执行文件
if exist "%TESTS_DIR%\UniAdminTests.exe" (
    echo   运行 UniAdminTests...
    "%TESTS_DIR%\UniAdminTests.exe" --runner=quiet
    if !errorlevel! neq 0 (
        echo %RED%✗ 测试失败！%RESET%
        set "TESTS_OK=0"
    ) else (
        echo %GREEN%√ 测试通过！%RESET%
    )
) else (
    echo %YELLOW%  未找到测试可执行文件，跳过测试%RESET%
)

echo.
echo %BLUE%=====================================================%RESET%
if %TESTS_OK%==1 (
    echo %GREEN%构建和测试全部通过！%RESET%
    echo %BLUE%=====================================================%RESET%
    exit /b 0
) else (
    echo %RED%构建或测试失败！%RESET%
    echo %BLUE%=====================================================%RESET%
    exit /b 1
)
