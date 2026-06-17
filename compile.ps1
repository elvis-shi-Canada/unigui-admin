$ErrorActionPreference = "Continue"

# UniGUI 路径配置
$uniGuiBasePath = "D:\BaiduNetdiskDownload\vcl\UniGUI_1600"
$corePath = "$uniGuiBasePath\uniGUI\source\core"
$vclPath = "$uniGuiBasePath\uniGUI\source\VCL"
$uniToolsPath = "$uniGuiBasePath\uniTools"
$uIndyPath = "$uniGuiBasePath\uniGUI\uIndy"

# 编译器路径
$dcc32 = "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\dcc32.exe"

# 输出路径 - 使用绝对路径
$projectRoot = "C:\Users\SW\Desktop\unigui-admin"
$dcuOutput = "$projectRoot\dcu\Win32\Debug"
$exeOutput = "$projectRoot\bin"

# 搜索路径 - 包含 Delphi VCL 和 UniGUI 路径
$delphiLibPath = "C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\win32\release"
$uniToolsDcuPath = "$uniToolsPath\Dcu\Delphi2023"
$unitPath = "$delphiLibPath;$corePath;$vclPath;$uIndyPath;$uniToolsDcuPath;src\Core;src\Modules;src\Plugins;src\Frames"
$includePath = "$corePath;$vclPath;$uniToolsPath"

# 构建命令
$args = @(
    "-B",
    "-E$exeOutput",
    "-N$dcuOutput",
    "-U$unitPath",
    "-I$includePath",
    "-R$corePath;$vclPath",
    "-NSSystem;Winapi;System.Win;Vcl;Vcl.Imaging;Data;Datasnap;Web;Soap;Xml",
    "src\UniAdmin.dpr"
)

Write-Host "=================================================="
Write-Host "Compiling UniAdmin Project"
Write-Host "=================================================="
Write-Host "UniGUI Core Path: $corePath"
Write-Host "UniGUI VCL Path:  $vclPath"
Write-Host "Unit Search Path: $unitPath"
Write-Host "=================================================="
Write-Host ""

# 执行编译
& $dcc32 $args 2>&1 | Tee-Object -FilePath "compile_output.txt"

Write-Host ""
Write-Host "=================================================="
Write-Host "Exit code: $LASTEXITCODE"
Write-Host "=================================================="

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Compilation FAILED!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check compile_output.txt for details."
} else {
    Write-Host "✓ Compilation SUCCEEDED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Executable: ..\bin\UniAdmin.exe"
}
