# UniAdmin 安全审计文档

## 安全架构概述

### 认证机制
- **密码哈希**：SHA256（TODO: 升级到 bcrypt）
- **会话管理**：基于 Token 的会话系统
- **登录验证**：用户名/密码 + 用户状态检查

### 授权机制
- **RBAC 模型**：用户-角色-权限三层结构
- **数据权限**：支持 all/custom/self 数据范围
- **菜单权限**：基于权限码的菜单显示控制

### 安全特性

#### 1. SQL 注入防护
- 所有数据库查询使用参数化查询
- 表名验证（白名单机制）
- FireDAC 参数绑定自动转义

**实现位置**：
- `src/Core/Data/UniAdminConnectionManager.pas` - 连接管理
- `src/Core/Metadata/UniMetadataManager.pas` - 元数据查询
- `src/Core/Services/*.pas` - 所有服务层查询

#### 2. 线程安全
- 所有单例使用 `TMonitor` 保护
- 双重检查锁定模式
- 连接池线程安全

**实现位置**：
- `src/Core/Data/UniAdminConnectionManager.pas`
- `src/Core/Metadata/UniMetadataManager.pas`
- `src/Core/Services/UniServiceLocator.pas`

#### 3. 输入验证
- **密码强度验证**：6+ 字符，必须包含大小写字母和数字
- **表单字段验证**：必填项、长度限制
- **类型安全**：强类型 Pascal 语言

**实现位置**：
- `src/Core/Services/UniAdminAuthService.pas` - `ValidatePassword`
- `src/UI/Framework/UniBaseCrudFrame.pas` - 表单验证

#### 4. 审计日志
- `CreatedDate`/`CreatedBy` 自动填充
- `ModifiedDate`/`ModifiedBy` 自动填充
- 敏感操作记录

**实现位置**：
- `src/Core/Metadata/UniMetadataManager.pas` - `FillAuditFields`

## 已知安全限制

### 1. 密码哈希算法 🔴 高优先级
**当前实现**：SHA256  
**位置**：`src/Core/Services/UniAdminAuthService.pas`  
**风险等级**：中等  
**说明**：SHA256 可被 GPU 加速破解，不适合密码存储

**攻击场景**：
- 攻击者获取数据库后，使用 GPU 破解哈希
- 彩虹表攻击（虽有 salt，但仍可能被破解）

**建议修复**：
```pascal
// 当前实现
function HashPassword(const Password, Salt: string): string;
var
  Hash: THashSHA2;
begin
  Hash := THashSHA2.Create;
  try
    Hash.Update(BytesOf(Password + Salt));
    Result := Hash.HashAsString;
  finally
    Hash.Free;
  end;
end;

// 建议实现 - 使用 bcrypt
// 需要 DelphiCryptex 或类似库
```

**工作量**：2-3 小时  
**优先级**：高

### 2. Token 永久有效 🟡 中优先级
**当前实现**：Token 无过期时间  
**位置**：`src/Core/Services/UniAdminAuthService.pas`  
**风险等级**：中低  
**说明**：会话劫持后 Token 永久有效

**攻击场景**：
- XSS 攻击窃取 Token
- 中间人攻击获取 Token
- Token 泄露后长期有效

**建议修复**：
```pascal
type
  TLoginResult = record
    Token: string;
    ExpiresAt: TDateTime;  // 添加过期时间
    RefreshToken: string;  // 添加刷新令牌
  end;

function ValidateToken(const Token: string): Boolean;
begin
  // 检查 Token 是否过期
  Result := (TokenInfo.ExpiresAt > Now) and 
            (TokenInfo.Token = Token);
end;
```

**工作量**：4-6 小时  
**优先级**：中

### 3. 单实例缓存 🟢 信息性
**当前实现**：每种服务只有全局单例  
**位置**：所有服务类  
**风险等级**：低（已文档化）  
**说明**：无法支持多连接场景

**影响范围**：
- 不支持多租户
- 不支持多数据库连接
- 已在代码中文档说明

**建议**：
- 如需多租户，考虑引入作用域缓存
- 当前设计适用于单租户场景

**工作量**：架构级别改动  
**优先级**：低（Phase 4+）

### 4. 无 HTTPS 强制 🟡 中优先级
**当前实现**：无 HTTPS 强制机制  
**位置**：N/A  
**风险等级**：中  
**说明**：Token 和密码可能被窃听

**建议修复**：
- 在 Web 服务器配置 HTTPS
- 添加 HTTP 到 HTTPS 重定向
- 考虑实现 CSP (Content Security Policy)

### 5. 无防暴力破解机制 🟡 中优先级
**当前实现**：无登录尝试限制  
**位置**：`src/Core/Services/UniAdminAuthService.pas`  
**风险等级**：中  
**说明**：可能被暴力破解

**建议修复**：
```pascal
type
  TLoginAttempt = record
    IP: string;
    UserName: string;
    AttemptCount: Integer;
    LastAttempt: TDateTime;
    LockedUntil: TDateTime;
  end;

function Login(const UserName, Password: string): TLoginResult;
begin
  // 检查账户是否被锁定
  if IsAccountLocked(UserName) then
    Exit(TLoginResult.Create(False, '账户已锁定，请稍后再试'));
  
  // 验证密码
  // ...
  
  // 失败则增加计数
  // 5次失败锁定30分钟
end;
```

**工作量**：3-4 小时  
**优先级**：中

## 安全检查清单

### 数据访问层
- [x] 所有 SQL 查询使用参数化
- [x] 表名验证（白名单机制）
- [x] 连接字符串加密存储
- [x] 敏感字段加密（TODO）

### 服务层
- [x] 密码以哈希形式存储
- [x] 权限检查在服务层实现
- [x] 用户输入经过验证
- [ ] Token 过期机制（TODO）
- [ ] 防暴力破解（TODO）

### UI 层
- [x] 表单字段验证
- [x] 密码强度要求
- [ ] XSS 防护（uniGUI 框架处理）
- [ ] CSRF 防护（TODO）

### 审计
- [x] 敏感操作有审计日志
- [x] 登录/登出记录
- [x] 数据修改记录
- [ ] 权限变更审计（TODO）

## 安全最佳实践建议

### 开发阶段
1. 使用强类型语言特性
2. 遵循最小权限原则
3. 实施代码审查
4. 定期安全扫描

### 部署阶段
1. 配置 HTTPS
2. 使用防火墙
3. 定期备份
4. 日志监控

### 运维阶段
1. 定期更新依赖
2. 安全补丁管理
3. 入侵检测
4. 应急响应计划

## 安全测试建议

### 单元测试
- 密码验证测试
- 权限检查测试
- SQL 注入测试

### 集成测试
- 登录流程测试
- 权限流程测试
- 会话管理测试

### 渗透测试
- SQL 注入
- XSS 攻击
- CSRF 攻击
- 会话劫持

## 合规性考虑

### 数据保护
- [ ] GDPR 合规（如适用）
- [ ] 等保 2.0（如适用）
- [ ] 密码策略合规

### 审计要求
- [ ] 操作日志保留
- [ ] 日志完整性
- [ ] 异常检测

## 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-02-24 | 1.0 | 初始版本，Phase 2 安全审计 |

## 参考资源

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Delphi 安全编码指南](https://docwiki.embarcadero.com/RADStudio/Athens/en/Secure_Coding)
- [FireDAC 安全最佳实践](https://docwiki.embarcadero.com/RADStudio/Athens/en/FireDAC)
