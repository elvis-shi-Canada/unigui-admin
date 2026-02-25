# UniAdmin 部署指南

> **项目**: UniAdmin 通用后台管理系统框架
> **版本**: 1.0.0
> **更新日期**: 2026-02-24

---

## 目录

1. [系统要求](#系统要求)
2. [部署文件清单](#部署文件清单)
3. [数据库初始化](#数据库初始化)
4. [配置说明](#配置说明)
5. [部署步骤](#部署步骤)
6. [常见问题排查](#常见问题排查)
7. [回滚方案](#回滚方案)

---

## 系统要求

### 服务器环境

**最低配置**:
- CPU: 2 核
- 内存: 4GB
- 硬盘: 20GB
- 操作系统: Windows Server 2016+ / Linux (Ubuntu 20.04+)

**推荐配置**:
- CPU: 4 核+
- 内存: 8GB+
- 硬盘: 50GB+ SSD
- 操作系统: Windows Server 2019 / Ubuntu 22.04 LTS

### 软件依赖

**必需软件**:
- Delphi 12 Athens (用于编译)
- Microsoft SQL Server 2017+ / MySQL 8.0+ / PostgreSQL 13+
- IIS 10+ / Apache 2.4+ (生产环境)

**可选软件**:
- Redis (缓存服务)
- Nginx (反向代理)
- Docker (容器化部署)

---

## 部署文件清单

### 必需文件

```
UniAdmin/
├── bin/                      # 编译输出目录
│   ├── UniAdminServer.exe    # 服务器可执行文件
│   └── UniAdmin.isapi        # ISAPI 扩展 (IIS)
├── db/                       # 数据库脚本
│   ├── Schema/               # 表结构脚本
│   │   ├── 01_CreateCoreTables.sql
│   │   └── 02_CreateModuleTables.sql
│   └── Seed/                 # 初始数据脚本
│       └── 03_SystemPermissions.sql
├── config/                   # 配置文件目录
│   └── ProjectConfig.json    # 项目配置 (需修改)
├── assets/                   # 静态资源
│   ├── themes/               # 主题文件
│   ├── i18n/                 # 国际化文件
│   └── icons/                # 图标资源
└── logs/                     # 日志目录 (自动创建)
```

### 文件权限

| 目录/文件 | Windows 权限 | Linux 权限 |
|-----------|-------------|-----------|
| `bin/` | Read + Execute | 755 |
| `config/` | Read + Write | 644 |
| `logs/` | Read + Write | 755 |
| `uploads/` | Read + Write | 755 |
| `ProjectConfig.json` | Read + Write | 600 |

---

## 数据库初始化

### 1. 创建数据库

**SQL Server**:
```sql
CREATE DATABASE UniAdmin;
GO

USE UniAdmin;
GO

-- 创建数据库用户
CREATE LOGIN uniadmin WITH PASSWORD = 'StrongPassword123!';
CREATE USER uniadmin FOR LOGIN uniadmin;
ALTER ROLE db_owner ADD MEMBER uniadmin;
GO
```

**MySQL**:
```sql
CREATE DATABASE uniadmin CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'uniadmin'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON uniadmin.* TO 'uniadmin'@'localhost';
FLUSH PRIVILEGES;
```

**PostgreSQL**:
```sql
CREATE DATABASE uniadmin ENCODING 'UTF8';

CREATE USER uniadmin WITH PASSWORD 'StrongPassword123!';
GRANT ALL PRIVILEGES ON DATABASE uniadmin TO uniadmin;
```

### 2. 执行表结构脚本

按顺序执行以下脚本：

1. `Database/Schema/01_CreateCoreTables.sql` - 核心表
2. `Database/Schema/02_CreateModuleTables.sql` - 模块表

### 3. 执行初始数据脚本

1. `Database/Seed/03_SystemPermissions.sql` - 系统权限和菜单

### 4. 验证数据库初始化

```sql
-- 检查表是否创建成功
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo' OR TABLE_SCHEMA = 'uniadmin';

-- 检查初始数据
SELECT COUNT(*) AS PermissionCount FROM UniAdmin_Permissions;
SELECT COUNT(*) AS MenuCount FROM UniAdmin_Menus;
```

**预期结果**:
- PermissionCount >= 33
- MenuCount >= 8

---

## 配置说明

### 1. 数据库连接配置

编辑 `config/ProjectConfig.json`:

```json
{
  "database": {
    "driver": "MSSQL",           // MSSQL, MySQL, PostgreSQL, SQLite
    "server": "localhost",       // 数据库服务器地址
    "port": 1433,                // 端口号
    "database": "UniAdmin",      // 数据库名
    "username": "uniadmin",      // 用户名
    "password": "YourPassword"   // 密码 (生产环境需加密)
  }
}
```

### 2. 服务器配置

```json
{
  "server": {
    "host": "0.0.0.0",
    "port": 8077,                // HTTP 端口
    "ssl": false,
    "sslPort": 8078,             // HTTPS 端口
    "sessionTimeout": 30         // 会话超时 (分钟)
  }
}
```

### 3. 安全配置

```json
{
  "security": {
    "authentication": {
      "provider": "database",
      "sessionExpiry": 1800,     // 会话过期时间 (秒)
      "maxLoginAttempts": 5,     // 最大登录尝试次数
      "lockoutDuration": 900     // 锁定时长 (秒)
    }
  }
}
```

### 4. 日志配置

```json
{
  "logging": {
    "level": "INFO",             // DEBUG, INFO, WARN, ERROR
    "file": {
      "path": "./logs",
      "maxSize": "100MB",
      "maxFiles": 10
    }
  }
}
```

### 5. 环境变量覆盖

支持通过环境变量覆盖配置：

```bash
# Windows
set DB_SERVER=production-db
set DB_PASSWORD=SecurePassword

# Linux
export DB_SERVER=production-db
export DB_PASSWORD=SecurePassword
```

---

## 部署步骤

### 方式一: 直接部署

**步骤 1**: 准备服务器环境
```bash
# 安装 Delphi 运行时
# 安装数据库服务器
# 配置防火墙规则
```

**步骤 2**: 复制部署文件
```bash
# 创建部署目录
mkdir C:\UniAdmin
cd C:\UniAdmin

# 复制文件
xcopy /E /Y \\build-server\UniAdmin\*.* .
```

**步骤 3**: 配置数据库连接
```bash
# 编辑配置文件
notepad config\ProjectConfig.json
```

**步骤 4**: 初始化数据库
```bash
# 执行数据库脚本
sqlcmd -S localhost -U sa -P Password -i db\Schema\01_CreateCoreTables.sql
sqlcmd -S localhost -U sa -P Password -i db\Schema\02_CreateModuleTables.sql
sqlcmd -S localhost -U sa -P Password -i db\Seed\03_SystemPermissions.sql
```

**步骤 5**: 启动服务
```bash
# 启动 UniAdmin 服务器
bin\UniAdminServer.exe

# 或注册为 Windows 服务
bin\UniAdminServer.exe --install
net start UniAdminServer
```

**步骤 6**: 验证部署
```bash
# 测试服务器是否启动
curl http://localhost:8077/api/health

# 访问 Web 界面
start http://localhost:8077
```

### 方式二: IIS 部署

**步骤 1**: 安装 IIS 和 ISAPI 扩展

**步骤 2**: 配置 IIS 应用程序池
- .NET CLR 版本: 无托管代码
- 启用 32 位应用程序: True

**步骤 3**: 创建网站
- 网站名称: UniAdmin
- 物理路径: C:\UniAdmin
- 绑定: HTTP :8077:

**步骤 4**: 配置 ISAPI 处理程序映射
- 路径: *.isapi
- 可执行文件: C:\UniAdmin\bin\UniAdmin.isapi

**步骤 5**: 启用压缩
- 静态内容压缩
- 动态内容压缩

### 方式三: Docker 部署

```dockerfile
# Dockerfile
FROM delphiacademy/delphi-community:latest

WORKDIR /app
COPY . .

RUN dcc32 UniAdminServer.dpr

EXPOSE 8077

CMD ["./UniAdminServer.exe"]
```

```bash
# 构建镜像
docker build -t uniadmin:1.0.0 .

# 运行容器
docker run -d \
  -p 8077:8077 \
  -e DB_SERVER=host.docker.internal \
  -e DB_PASSWORD=YourPassword \
  --name uniadmin \
  uniadmin:1.0.0
```

---

## 常见问题排查

### 1. 服务无法启动

**现象**: 双击 `UniAdminServer.exe` 后立即退出

**排查步骤**:
1. 检查日志文件: `logs/UniAdmin.log`
2. 检查配置文件语法: `config/ProjectConfig.json`
3. 验证数据库连接字符串
4. 确认端口未被占用: `netstat -ano | findstr 8077`

**常见原因**:
- 数据库连接失败
- 配置文件格式错误
- 端口被占用
- 缺少必需的运行库

### 2. 数据库连接失败

**现象**: 日志显示 "Cannot connect to database"

**排查步骤**:
1. 验证数据库服务是否运行
2. 测试连接: `telnet localhost 1433`
3. 检查用户名密码
4. 确认防火墙规则

**SQL Server**:
```bash
sqlcmd -S localhost -U sa -P Password
```

**MySQL**:
```bash
mysql -h localhost -u uniadmin -p
```

### 3. 登录后立即退出

**现象**: 登录成功但马上返回登录页

**排查步骤**:
1. 检查会话配置: `server.sessionTimeout`
2. 验证 Session 存储
3. 检查 CSRF 配置
4. 查看浏览器开发者工具 Console

### 4. 页面显示异常

**现象**: 页面样式错乱或组件无法加载

**排查步骤**:
1. 清除浏览器缓存
2. 检查静态资源路径
3. 验证 assets 目录权限
4. 检查浏览器控制台错误

### 5. 性能问题

**现象**: 页面加载缓慢或响应超时

**排查步骤**:
1. 检查数据库查询日志
2. 验证索引是否创建
3. 检查缓存配置
4. 分析慢查询日志

---

## 回滚方案

### 快速回滚

**步骤 1**: 停止服务
```bash
net stop UniAdminServer
```

**步骤 2**: 备份当前版本
```bash
xcopy /E /Y C:\UniAdmin C:\UniAdmin.backup.%date:~0,10%
```

**步骤 3**: 恢复上一个版本
```bash
xcopy /E /Y C:\UniAdmin.previous C:\UniAdmin
```

**步骤 4**: 启动服务
```bash
net start UniAdminServer
```

### 数据库回滚

**步骤 1**: 停止应用服务

**步骤 2**: 恢复数据库备份
```sql
-- SQL Server
RESTORE DATABASE UniAdmin FROM DISK = 'C:\Backups\UniAdmin.bak' WITH REPLACE;

-- MySQL
mysql uniadmin < C:\Backups\uniadmin_backup.sql

-- PostgreSQL
psql uniadmin < C:\Backups\uniadmin_backup.sql
```

**步骤 3**: 验证数据完整性
```sql
SELECT COUNT(*) FROM UniAdmin_Users;
SELECT COUNT(*) FROM UniAdmin_Roles;
```

**步骤 4**: 启动应用服务

---

## 监控和维护

### 日志监控

关键日志文件:
- `logs/UniAdmin.log` - 主应用日志
- `logs/error.log` - 错误日志
- `logs/audit.log` - 审计日志

### 性能监控

监控指标:
- CPU 使用率
- 内存使用率
- 响应时间
- 并发连接数
- 数据库连接数

### 定期维护任务

| 任务 | 频率 | 说明 |
|------|------|------|
| 数据库备份 | 每日 | 自动备份数据库 |
| 日志清理 | 每周 | 删除过期日志文件 |
| 性能分析 | 每月 | 分析性能瓶颈 |
| 安全更新 | 按需 | 及时应用安全补丁 |

---

## 联系方式

**技术支持**: support@uniadmin.com
**文档**: https://docs.uniadmin.com
**Issues**: https://github.com/uniadmin/uniadmin/issues

---

**文档版本**: 1.0
**最后更新**: 2026-02-24
