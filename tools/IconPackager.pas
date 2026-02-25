unit IconPackager;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Zip,
  System.Generics.Collections;

type
  TIconPackager = class
  private
    FSourceDir: string;
    FOutputDir: string;
    FIconFiles: TList<string>;
    FPackageName: string;
    function IsIconFile(const FileName: string): Boolean;
    procedure CollectIconFiles;
    function CreatePackage: Boolean;
    function GenerateManifest: string;
  public
    constructor Create(const SourceDir, OutputDir, PackageName: string);
    destructor Destroy; override;
    function Execute: Boolean;
    property IconFiles: TList<string> read FIconFiles;
  end;

  TIconPackageInfo = record
    Name: string;
    Version: string;
    Description: string;
    IconCount: Integer;
    CreatedDate: TDateTime;
  end;

implementation

constructor TIconPackager.Create(const SourceDir, OutputDir, PackageName: string);
begin
  inherited Create;
  FSourceDir := SourceDir;
  FOutputDir := OutputDir;
  FPackageName := PackageName;
  FIconFiles := TList<string>.Create;
end;

destructor TIconPackager.Destroy;
begin
  FIconFiles.Free;
  inherited;
end;

function TIconPackager.IsIconFile(const FileName: string): Boolean;
var
  Ext: string;
  IconExts: array[0..5] of string;
  I: Integer;
begin
  IconExts[0] := '.ico';
  IconExts[1] := '.png';
  IconExts[2] := '.jpg';
  IconExts[3] := '.jpeg';
  IconExts[4] := '.gif';
  IconExts[5] := '.bmp';

  Ext := LowerCase(ExtractFileExt(FileName));
  Result := False;

  for I := Low(IconExts) to High(IconExts) do
  begin
    if Ext = IconExts[I] then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TIconPackager.CollectIconFiles;
var
  Files: TArray<string>;
  FileName: string;
begin
  FIconFiles.Clear;

  if not TDirectory.Exists(FSourceDir) then
    Exit;

  Files := TDirectory.GetFiles(FSourceDir, '*.*', TSearchOption.soAllDirectories);

  for FileName in Files do
  begin
    if IsIconFile(FileName) then
      FIconFiles.Add(FileName);
  end;
end;

function TIconPackager.GenerateManifest: string;
var
  Manifest: TStringBuilder;
  IconFile: string;
  Info: TIconPackageInfo;
begin
  Info.Name := FPackageName;
  Info.Version := '1.0.0';
  Info.Description := '图标资源包';
  Info.IconCount := FIconFiles.Count;
  Info.CreatedDate := Now;

  Manifest := TStringBuilder.Create;
  try
    Manifest.AppendLine('{');
    Manifest.AppendLine('  "name": "' + Info.Name + '",');
    Manifest.AppendLine('  "version": "' + Info.Version + '",');
    Manifest.AppendLine('  "description": "' + Info.Description + '",');
    Manifest.AppendLine('  "iconCount": ' + IntToStr(Info.IconCount) + ',');
    Manifest.AppendLine('  "createdDate": "' + DateTimeToStr(Info.CreatedDate) + '",');
    Manifest.AppendLine('  "icons": [');

    for IconFile in FIconFiles do
    begin
      Manifest.AppendLine('    {');
      Manifest.AppendLine('      "fileName": "' + ExtractFileName(IconFile) + '",');
      Manifest.AppendLine('      "relativePath": "' + StringReplace(IconFile, FSourceDir, '', [rfReplaceAll]) + '",');
      Manifest.AppendLine('      "size": ' + IntToStr(FileSize(IconFile)));
      Manifest.AppendLine('    },');
    end;

    Manifest.AppendLine('  ]');
    Manifest.AppendLine('}');

    Result := Manifest.ToString;
  finally
    Manifest.Free;
  end;
end;

function TIconPackager.CreatePackage: Boolean;
var
  ZipFile: TZipFile;
  IconFile: string;
  ManifestPath: string;
  TempDir: string;
begin
  Result := False;

  if FIconFiles.Count = 0 then
  begin
    Writeln('没有找到图标文件');
    Exit;
  end;

  TempDir := TPath.Combine(TPath.GetTempPath, 'IconPackager_' + IntToStr(GetTickCount));
  TDirectory.CreateDirectory(TempDir);

  try
    // 复制所有图标文件到临时目录
    for IconFile in FIconFiles do
    begin
      TFile.Copy(IconFile, TPath.Combine(TempDir, ExtractFileName(IconFile)), True);
    end;

    // 生成清单文件
    ManifestPath := TPath.Combine(TempDir, 'manifest.json');
    TFile.WriteAllText(ManifestPath, GenerateManifest, TEncoding.UTF8);

    // 创建ZIP包
    if not TDirectory.Exists(FOutputDir) then
      TDirectory.CreateDirectory(FOutputDir);

    ZipFile := TZipFile.Create;
    try
      ZipFile.ZipDirectoryContents(TPath.Combine(FOutputDir, FPackageName + '.zip'), TempDir);
      Result := True;
      Writeln('图标包创建成功: ' + TPath.Combine(FOutputDir, FPackageName + '.zip'));
      Writeln('包含 ' + IntToStr(FIconFiles.Count) + ' 个图标文件');
    finally
      ZipFile.Free;
    end;
  finally
    // 清理临时目录
    if TDirectory.Exists(TempDir) then
      TDirectory.Delete(TempDir, True);
  end;
end;

function TIconPackager.Execute: Boolean;
begin
  Writeln('开始打包图标...');
  Writeln('源目录: ' + FSourceDir);
  Writeln('输出目录: ' + FOutputDir);
  Writeln('包名称: ' + FPackageName);
  Writeln;

  CollectIconFiles;
  Result := CreatePackage;
end;

end.
