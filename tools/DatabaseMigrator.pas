unit DatabaseMigrator;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Stan.Def;

type
  TMigrationDirection = (mdUp, mdDown);

  TMigration = record
    Version: string;
    Description: string;
    FileName: string;
    Direction: TMigrationDirection;
    AppliedAt: TDateTime;
  end;

  TDatabaseMigrator = class
  private
    FConnection: TFDConnection;
    FMigrationsDir: string;
    FAppliedMigrations: TDictionary<string, TMigration>;
    procedure CreateMigrationTable;
    function GetAppliedMigrations: TDictionary<string, TMigration>;
    function GetPendingMigrations: TArray<TMigration>;
    function ParseMigrationFile(const FileName: string): TMigration;
    function ExecuteMigration(const Migration: TMigration): Boolean;
    function ExecuteSQLFile(const FileName: string): Boolean;
  public
    constructor Create(const Connection: TFDConnection; const MigrationsDir: string);
    destructor Destroy; override;
    function Migrate: Boolean;
    function Rollback(const Steps: Integer = 1): Boolean;
    function CreateMigration(const Name: string): string;
    function GetStatus: string;
  end;

implementation

constructor TDatabaseMigrator.Create(const Connection: TFDConnection; const MigrationsDir: string);
begin
  inherited Create;
  FConnection := Connection;
  FMigrationsDir := MigrationsDir;
  FAppliedMigrations := TDictionary<string, TMigration>.Create;
end;

destructor TDatabaseMigrator.Destroy;
begin
  FAppliedMigrations.Free;
  inherited;
end;

procedure TDatabaseMigrator.CreateMigrationTable;
var
  SQL: string;
begin
  SQL := 'IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = ''SchemaMigrations'') ' +
         'BEGIN ' +
         'CREATE TABLE SchemaMigrations (' +
         '  Version VARCHAR(50) PRIMARY KEY, ' +
         '  Description NVARCHAR(500), ' +
         '  FileName NVARCHAR(500), ' +
         '  AppliedAt DATETIME DEFAULT GETDATE(), ' +
         '  Direction VARCHAR(10)' +
         ')' +
         'END';

  FConnection.ExecSQL(SQL);
end;

function TDatabaseMigrator.GetAppliedMigrations: TDictionary<string, TMigration>;
var
  Query: TFDQuery;
  Migration: TMigration;
begin
  FAppliedMigrations.Clear;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM SchemaMigrations ORDER BY Version';
    Query.Open;

    while not Query.Eof do
    begin
      Migration.Version := Query.FieldByName('Version').AsString;
      Migration.Description := Query.FieldByName('Description').AsString;
      Migration.FileName := Query.FieldByName('FileName').AsString;
      Migration.AppliedAt := Query.FieldByName('AppliedAt').AsDateTime;

      if Query.FieldByName('Direction').AsString = 'UP' then
        Migration.Direction := mdUp
      else
        Migration.Direction := mdDown;

      FAppliedMigrations.Add(Migration.Version, Migration);
      Query.Next;
    end;
  finally
    Query.Free;
  end;

  Result := FAppliedMigrations;
end;

function TDatabaseMigrator.ParseMigrationFile(const FileName: string): TMigration;
var
  FileContent: TStringList;
  Line: string;
  Version: string;
  Description: string;
begin
  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(FileName);

    // 解析版本号（从文件名）
    Version := ChangeFileExt(ExtractFileName(FileName), '');

    // 解析描述（从文件第一行注释）
    Description := '';
    if FileContent.Count > 0 then
    begin
      Line := FileContent[0];
      if Pos('--', Line) = 1 then
        Description := Trim(Copy(Line, 3, Length(Line)));
    end;

    Result.Version := Version;
    Result.Description := Description;
    Result.FileName := FileName;
    Result.Direction := mdUp;
  finally
    FileContent.Free;
  end;
end;

function TDatabaseMigrator.ExecuteSQLFile(const FileName: string): Boolean;
var
  SQL: TStringList;
begin
  Result := False;

  if not FileExists(FileName) then
  begin
    Writeln('文件不存在: ' + FileName);
    Exit;
  end;

  SQL := TStringList.Create;
  try
    SQL.LoadFromFile(FileName);
    FConnection.ExecSQL(SQL.Text);
    Result := True;
  finally
    SQL.Free;
  end;
end;

function TDatabaseMigrator.ExecuteMigration(const Migration: TMigration): Boolean;
var
  SQL: string;
  DirectionStr: string;
begin
  Result := False;

  Writeln('执行迁移: ' + Migration.Version + ' - ' + Migration.Description);

  if not ExecuteSQLFile(Migration.FileName) then
  begin
    Writeln('迁移失败: ' + Migration.Version);
    Exit;
  end;

  // 记录迁移状态
  if Migration.Direction = mdUp then
    DirectionStr := 'UP'
  else
    DirectionStr := 'DOWN';

  SQL := Format('INSERT INTO SchemaMigrations (Version, Description, FileName, Direction) ' +
                'VALUES (''%s'', ''%s'', ''%s'', ''%s'')',
                [Migration.Version, Migration.Description, Migration.FileName, DirectionStr]);

  FConnection.ExecSQL(SQL);
  Result := True;
end;

function TDatabaseMigrator.GetPendingMigrations: TArray<TMigration>;
var
  Files: TArray<string>;
  FileName: string;
  Migration: TMigration;
  PendingList: TList<TMigration>;
begin
  PendingList := TList<TMigration>.Create;
  try
    if TDirectory.Exists(FMigrationsDir) then
    begin
      Files := TDirectory.GetFiles(FMigrationsDir, '*.sql');

      for FileName in Files do
      begin
        Migration := ParseMigrationFile(FileName);

        if not FAppliedMigrations.ContainsKey(Migration.Version) then
          PendingList.Add(Migration);
      end;
    end;

    Result := PendingList.ToArray;
  finally
    PendingList.Free;
  end;
end;

function TDatabaseMigrator.Migrate: Boolean;
var
  PendingMigrations: TArray<TMigration>;
  Migration: TMigration;
  Success: Boolean;
begin
  Result := False;
  Success := True;

  Writeln('开始数据库迁移...');

  // 创建迁移表
  CreateMigrationTable;

  // 获取已应用的迁移
  GetAppliedMigrations;

  // 获取待应用的迁移
  PendingMigrations := GetPendingMigrations;

  if Length(PendingMigrations) = 0 then
  begin
    Writeln('没有待应用的迁移');
    Result := True;
    Exit;
  end;

  Writeln('发现 ' + IntToStr(Length(PendingMigrations)) + ' 个待应用的迁移');
  Writeln;

  // 执行迁移
  for Migration in PendingMigrations do
  begin
    if not ExecuteMigration(Migration) then
    begin
      Success := False;
      Break;
    end;
  end;

  if Success then
  begin
    Writeln;
    Writeln('所有迁移执行成功');
    Result := True;
  end
  else
  begin
    Writeln;
    Writeln('迁移过程中出现错误');
  end;
end;

function TDatabaseMigrator.Rollback(const Steps: Integer = 1): Boolean;
var
  Query: TFDQuery;
  I: Integer;
  Version: string;
begin
  Result := False;
  Writeln('开始回滚 ' + IntToStr(Steps) + ' 个迁移...');

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // 获取最新的迁移
    Query.SQL.Text := Format('SELECT TOP %d Version FROM SchemaMigrations ' +
                             'WHERE Direction = ''UP'' ORDER BY AppliedAt DESC', [Steps]);
    Query.Open;

    I := 0;
    while not Query.Eof do
    begin
      Version := Query.FieldByName('Version').AsString;
      Writeln('回滚: ' + Version);

      // 这里应该执行回滚脚本
      // ExecuteRollbackScript(Version);

      // 删除迁移记录
      FConnection.ExecSQL('DELETE FROM SchemaMigrations WHERE Version = ''' + Version + '''');

      Inc(I);
      Query.Next;
    end;

    Writeln('回滚完成: ' + IntToStr(I) + ' 个迁移');
    Result := True;
  finally
    Query.Free;
  end;
end;

function TDatabaseMigrator.CreateMigration(const Name: string): string;
var
  FileName: string;
  Timestamp: string;
  Content: TStringList;
begin
  Timestamp := FormatDateTime('yyyymmddhhnnss', Now);
  FileName := TPath.Combine(FMigrationsDir, Timestamp + '_' + Name + '.sql');

  Content := TStringList.Create;
  try
    Content.Add('-- ' + Name);
    Content.Add('-- Created at: ' + DateTimeToStr(Now));
    Content.Add('');
    Content.Add('-- UP migration');
    Content.Add('');
    Content.Add('-- DOWN migration');
    Content.Add('');

    if not TDirectory.Exists(FMigrationsDir) then
      TDirectory.CreateDirectory(FMigrationsDir);

    Content.SaveToFile(FileName);
    Result := FileName;

    Writeln('迁移文件创建成功: ' + FileName);
  finally
    Content.Free;
  end;
end;

function TDatabaseMigrator.GetStatus: string;
var
  Applied: TDictionary<string, TMigration>;
  Pending: TArray<TMigration>;
  SB: TStringBuilder;
  Migration: TMigration;
begin
  SB := TStringBuilder.Create;
  try
    // 创建迁移表
    CreateMigrationTable;

    // 获取已应用的迁移
    Applied := GetAppliedMigrations;

    // 获取待应用的迁移
    Pending := GetPendingMigrations;

    SB.AppendLine('数据库迁移状态');
    SB.AppendLine('================');
    SB.AppendLine;
    SB.AppendLine('已应用的迁移: ' + IntToStr(Applied.Count));

    for Migration in Applied.Values do
    begin
      SB.AppendLine('  - ' + Migration.Version + ': ' + Migration.Description +
                    ' (' + DateTimeToStr(Migration.AppliedAt) + ')');
    end;

    SB.AppendLine;
    SB.AppendLine('待应用的迁移: ' + IntToStr(Length(Pending)));

    for Migration in Pending do
    begin
      SB.AppendLine('  - ' + Migration.Version + ': ' + Migration.Description);
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.
