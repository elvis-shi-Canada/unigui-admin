unit PermissionAuditor;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TPermissionIssue = record
    IssueType: string;
    Severity: string;
    Resource: string;
    User: string;
    Role: string;
    Description: string;
    Recommendation: string;
  end;

  TPermissionAuditResult = record
    TotalUsers: Integer;
    TotalRoles: Integer;
    TotalPermissions: Integer;
    Issues: TArray<TPermissionIssue>;
    RiskScore: Integer;
    LastAuditTime: TDateTime;
  end;

  TPermissionAuditor = class
  private
    FConnection: TFDConnection;
    FIssues: TList<TPermissionIssue>;
    procedure CheckOrphanPermissions;
    procedure CheckDuplicatePermissions;
    procedure CheckExcessivePermissions;
    procedure CheckInactiveUsersWithPermissions;
    procedure CheckAdminRoleDistribution;
    procedure CheckCircularRoleInheritance;
    function CalculateRiskScore: Integer;
  public
    constructor Create(const Connection: TFDConnection);
    destructor Destroy; override;
    function Audit: TPermissionAuditResult;
    function GetIssues: TArray<TPermissionIssue>;
    function GetReport: string;
    procedure SaveReport(const FileName: string);
    function GenerateFixScript: string;
  end;

implementation

constructor TPermissionAuditor.Create(const Connection: TFDConnection);
begin
  inherited Create;
  FConnection := Connection;
  FIssues := TList<TPermissionIssue>.Create;
end;

destructor TPermissionAuditor.Destroy;
begin
  FIssues.Free;
  inherited;
end;

procedure TPermissionAuditor.CheckOrphanPermissions;
var
  Query: TFDQuery;
  Issue: TPermissionIssue;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // 检查指向不存在的资源的权限
    Query.SQL.Text :=
      'SELECT p.* FROM sys_permissions p ' +
      'LEFT JOIN sys_resources r ON p.resource_id = r.id ' +
      'WHERE r.id IS NULL';
    Query.Open;

    while not Query.Eof do
    begin
      Issue.IssueType := 'OrphanPermission';
      Issue.Severity := 'High';
      Issue.Resource := Query.FieldByName('resource_code').AsString;
      Issue.User := '';
      Issue.Role := '';
      Issue.Description := '权限指向不存在的资源: ' + Query.FieldByName('permission_code').AsString;
      Issue.Recommendation := '删除或修复此权限记录';
      FIssues.Add(Issue);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPermissionAuditor.CheckDuplicatePermissions;
var
  Query: TFDQuery;
  Issue: TPermissionIssue;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    Query.SQL.Text :=
      'SELECT role_id, permission_id, COUNT(*) as cnt ' +
      'FROM sys_role_permissions ' +
      'GROUP BY role_id, permission_id ' +
      'HAVING COUNT(*) > 1';
    Query.Open;

    while not Query.Eof do
    begin
      Issue.IssueType := 'DuplicatePermission';
      Issue.Severity := 'Medium';
      Issue.Resource := '';
      Issue.User := '';
      Issue.Role := 'Role ID: ' + Query.FieldByName('role_id').AsString;
      Issue.Description := '角色权限重复: ' + IntToStr(Query.FieldByName('cnt').AsInteger) + ' 条';
      Issue.Recommendation := '清理重复的角色权限记录';
      FIssues.Add(Issue);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPermissionAuditor.CheckExcessivePermissions;
var
  Query: TFDQuery;
  Issue: TPermissionIssue;
  RoleName: string;
  PermissionCount: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // 检查拥有过多权限的角色（超过50个）
    Query.SQL.Text :=
      'SELECT r.role_name, COUNT(rp.permission_id) as perm_count ' +
      'FROM sys_roles r ' +
      'JOIN sys_role_permissions rp ON r.id = rp.role_id ' +
      'GROUP BY r.id, r.role_name ' +
      'HAVING COUNT(rp.permission_id) > 50';
    Query.Open;

    while not Query.Eof do
    begin
      RoleName := Query.FieldByName('role_name').AsString;
      PermissionCount := Query.FieldByName('perm_count').AsInteger;

      Issue.IssueType := 'ExcessivePermission';
      Issue.Severity := 'Warning';
      Issue.Resource := '';
      Issue.User := '';
      Issue.Role := RoleName;
      Issue.Description := Format('角色 "%s" 拥有 %d 个权限，可能存在权限过度授予',
        [RoleName, PermissionCount]);
      Issue.Recommendation := '审查角色权限，遵循最小权限原则';
      FIssues.Add(Issue);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPermissionAuditor.CheckInactiveUsersWithPermissions;
var
  Query: TFDQuery;
  Issue: TPermissionIssue;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // 检查已禁用的用户是否还有权限
    Query.SQL.Text :=
      'SELECT u.user_name, r.role_name ' +
      'FROM sys_users u ' +
      'JOIN sys_user_roles ur ON u.id = ur.user_id ' +
      'JOIN sys_roles r ON ur.role_id = r.id ' +
      'WHERE u.status = 0'; // 禁用状态
    Query.Open;

    while not Query.Eof do
    begin
      Issue.IssueType := 'InactiveUserPermission';
      Issue.Severity := 'High';
      Issue.Resource := '';
      Issue.User := Query.FieldByName('user_name').AsString;
      Issue.Role := Query.FieldByName('role_name').AsString;
      Issue.Description := Format('已禁用的用户 "%s" 仍拥有角色 "%s"',
        [Issue.User, Issue.Role]);
      Issue.Recommendation := '移除禁用用户的所有角色关联';
      FIssues.Add(Issue);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPermissionAuditor.CheckAdminRoleDistribution;
var
  Query: TFDQuery;
  Issue: TPermissionIssue;
  AdminCount: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // 检查管理员角色的分配情况
    Query.SQL.Text :=
      'SELECT COUNT(*) as admin_count ' +
      'FROM sys_user_roles ur ' +
      'JOIN sys_roles r ON ur.role_id = r.id ' +
      'WHERE r.role_name LIKE ''%admin%'' OR r.role_code = ''ADMIN''';
    Query.Open;

    AdminCount := Query.FieldByName('admin_count').AsInteger;

    if AdminCount > 5 then
    begin
      Issue.IssueType := 'AdminRoleDistribution';
      Issue.Severity := 'Warning';
      Issue.Resource := '';
      Issue.User := '';
      Issue.Role := 'Administrator';
      Issue.Description := Format('系统有 %d 个管理员账号，建议控制在5个以内', [AdminCount]);
      Issue.Recommendation := '审查管理员账号，移除不必要的管理员权限';
      FIssues.Add(Issue);
    end;

    if AdminCount = 0 then
    begin
      Issue.IssueType := 'NoAdminRole';
      Issue.Severity := 'Critical';
      Issue.Resource := '';
      Issue.User := '';
      Issue.Role := '';
      Issue.Description := '系统没有配置管理员账号';
      Issue.Recommendation := '立即创建至少一个管理员账号';
      FIssues.Add(Issue);
    end;
  finally
    Query.Free;
  end;
end;

procedure TPermissionAuditor.CheckCircularRoleInheritance;
var
  Query: TFDQuery;
  Issue: TPermissionIssue;
  ParentRole: string;
  ChildRole: string;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    // 简化的循环继承检查（实际实现需要递归）
    Query.SQL.Text :=
      'SELECT r1.role_name as parent_role, r2.role_name as child_role ' +
      'FROM sys_role_inheritance ri ' +
      'JOIN sys_roles r1 ON ri.parent_role_id = r1.id ' +
      'JOIN sys_roles r2 ON ri.child_role_id = r2.id ' +
      'WHERE ri.parent_role_id = ri.child_role_id';
    Query.Open;

    while not Query.Eof do
    begin
      ParentRole := Query.FieldByName('parent_role').AsString;
      ChildRole := Query.FieldByName('child_role').AsString;

      Issue.IssueType := 'CircularInheritance';
      Issue.Severity := 'Critical';
      Issue.Resource := '';
      Issue.User := '';
      Issue.Role := ParentRole;
      Issue.Description := Format('角色 "%s" 自循环继承', [ParentRole]);
      Issue.Recommendation := '移除角色自引用继承关系';
      FIssues.Add(Issue);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TPermissionAuditor.CalculateRiskScore: Integer;
var
  Issue: TPermissionIssue;
begin
  Result := 0;

  for Issue in FIssues do
  begin
    if Issue.Severity = 'Critical' then
      Result := Result + 10
    else if Issue.Severity = 'High' then
      Result := Result + 5
    else if Issue.Severity = 'Medium' then
      Result := Result + 3
    else if Issue.Severity = 'Warning' then
      Result := Result + 1;
  end;
end;

function TPermissionAuditor.Audit: TPermissionAuditResult;
var
  Query: TFDQuery;
begin
  FIssues.Clear;

  Writeln('开始权限审计...');
  Writeln;

  // 执行各项检查
  CheckOrphanPermissions;
  CheckDuplicatePermissions;
  CheckExcessivePermissions;
  CheckInactiveUsersWithPermissions;
  CheckAdminRoleDistribution;
  CheckCircularRoleInheritance;

  // 统计信息
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    Query.SQL.Text := 'SELECT COUNT(*) as cnt FROM sys_users';
    Query.Open;
    Result.TotalUsers := Query.FieldByName('cnt').AsInteger;

    Query.Close;
    Query.SQL.Text := 'SELECT COUNT(*) as cnt FROM sys_roles';
    Query.Open;
    Result.TotalRoles := Query.FieldByName('cnt').AsInteger;

    Query.Close;
    Query.SQL.Text := 'SELECT COUNT(*) as cnt FROM sys_permissions';
    Query.Open;
    Result.TotalPermissions := Query.FieldByName('cnt').AsInteger;
  finally
    Query.Free;
  end;

  Result.Issues := FIssues.ToArray;
  Result.RiskScore := CalculateRiskScore;
  Result.LastAuditTime := Now;

  Writeln('审计完成');
  Writeln('发现 ' + IntToStr(FIssues.Count) + ' 个问题');
  Writeln('风险评分: ' + IntToStr(Result.RiskScore));
end;

function TPermissionAuditor.GetIssues: TArray<TPermissionIssue>;
begin
  Result := FIssues.ToArray;
end;

function TPermissionAuditor.GetReport: string;
var
  SB: TStringBuilder;
  Issue: TPermissionIssue;
  CriticalCount, HighCount, MediumCount, WarningCount: Integer;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('========================================');
    SB.AppendLine('      权限审计报告');
    SB.AppendLine('========================================');
    SB.AppendLine;
    SB.AppendLine('审计时间: ' + DateTimeToStr(Now));
    SB.AppendLine;

    CriticalCount := 0;
    HighCount := 0;
    MediumCount := 0;
    WarningCount := 0;

    for Issue in FIssues do
    begin
      if Issue.Severity = 'Critical' then Inc(CriticalCount)
      else if Issue.Severity = 'High' then Inc(HighCount)
      else if Issue.Severity = 'Medium' then Inc(MediumCount)
      else if Issue.Severity = 'Warning' then Inc(WarningCount);

      SB.AppendLine(Format('[%s][%s] %s', [Issue.Severity, Issue.IssueType, Issue.Description]));
      SB.AppendLine('  建议: ' + Issue.Recommendation);
      SB.AppendLine;
    end;

    SB.AppendLine('----------------------------------------');
    SB.AppendLine('问题统计:');
    SB.AppendLine(Format('  严重: %d', [CriticalCount]));
    SB.AppendLine(Format('  高: %d', [HighCount]));
    SB.AppendLine(Format('  中: %d', [MediumCount]));
    SB.AppendLine(Format('  警告: %d', [WarningCount]));
    SB.AppendLine;
    SB.AppendLine('风险评分: ' + IntToStr(CalculateRiskScore));

    if FIssues.Count = 0 then
      SB.AppendLine('未发现问题，权限配置良好！');

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TPermissionAuditor.SaveReport(const FileName: string);
begin
  TFile.WriteAllText(FileName, GetReport, TEncoding.UTF8);
  Writeln('审计报告已保存: ' + FileName);
end;

function TPermissionAuditor.GenerateFixScript: string;
var
  SB: TStringBuilder;
  Issue: TPermissionIssue;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('-- 权限问题修复脚本');
    SB.AppendLine('-- 生成时间: ' + DateTimeToStr(Now));
    SB.AppendLine;

    for Issue in FIssues do
    begin
      SB.AppendLine('-- ' + Issue.Description);
      SB.AppendLine('-- 严重程度: ' + Issue.Severity);

      if Issue.IssueType = 'OrphanPermission' then
        SB.AppendLine(Format('DELETE FROM sys_permissions WHERE permission_code = ''%s'';', [Issue.Resource]))
      else if Issue.IssueType = 'DuplicatePermission' then
        SB.AppendLine('-- 手动清理重复的角色权限')
      else if Issue.IssueType = 'InactiveUserPermission' then
        SB.AppendLine(Format('DELETE FROM sys_user_roles WHERE user_id IN (SELECT id FROM sys_users WHERE user_name = ''%s'');', [Issue.User]));

      SB.AppendLine;
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.
