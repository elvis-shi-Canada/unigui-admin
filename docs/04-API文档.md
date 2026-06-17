# UniAdmin API 文档

## 目录
- [API 概述](#api-概述)
- [认证 API](#认证-api)
- [用户管理 API](#用户管理-api)
- [角色管理 API](#角色管理-api)
- [权限管理 API](#权限管理-api)
- [通用 CRUD API](#通用-crud-api)
- [系统管理 API](#系统管理-api)
- [错误处理](#错误处理)
- [API 版本控制](#api-版本控制)

---

## API 概述

### 1. 基本信息

- **Base URL**: `http://localhost:8077/api`
- **协议**: HTTP/HTTPS
- **数据格式**: JSON
- **字符编码**: UTF-8
- **认证方式**: Bearer Token (JWT)

### 2. 通用请求头

```http
Content-Type: application/json
Authorization: Bearer {access_token}
Accept: application/json
```

### 3. 通用响应格式

#### 成功响应
```json
{
  "success": true,
  "data": {
    // 响应数据
  },
  "message": "操作成功",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 失败响应
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": "详细错误信息"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 分页响应
```json
{
  "success": true,
  "data": {
    "items": [
      // 数据项
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### 4. HTTP 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 认证 API

### 1. 用户登录

**接口**: `POST /api/auth/login`

**请求参数**:
```json
{
  "username": "admin",
  "password": "password123",
  "rememberMe": false
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "firstName": "Admin",
      "lastName": "User",
      "roles": ["admin"]
    }
  },
  "message": "登录成功"
}
```

### 2. 用户登出

**接口**: `POST /api/auth/logout`

**请求头**:
```http
Authorization: Bearer {access_token}
```

**响应示例**:
```json
{
  "success": true,
  "message": "登出成功"
}
```

### 3. 刷新 Token

**接口**: `POST /api/auth/refresh`

**请求参数**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

### 4. 获取当前用户信息

**接口**: `GET /api/auth/me`

**请求头**:
```http
Authorization: Bearer {access_token}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "firstName": "Admin",
    "lastName": "User",
    "roles": ["admin"],
    "permissions": [
      "user.view",
      "user.add",
      "user.edit",
      "user.delete"
    ]
  }
}
```

### 5. 修改密码

**接口**: `PUT /api/auth/change-password`

**请求头**:
```http
Authorization: Bearer {access_token}
```

**请求参数**:
```json
{
  "oldPassword": "oldpassword123",
  "newPassword": "newpassword123",
  "confirmPassword": "newpassword123"
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "密码修改成功"
}
```

---

## 用户管理 API

### 1. 获取用户列表

**接口**: `GET /api/users`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | integer | 否 | 页码，默认 1 |
| pageSize | integer | 否 | 每页数量，默认 20 |
| keyword | string | 否 | 搜索关键词 |
| roleId | integer | 否 | 角色ID筛选 |
| isActive | boolean | 否 | 是否启用筛选 |

**请求示例**:
```http
GET /api/users?page=1&pageSize=20&keyword=admin
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "username": "admin",
        "email": "admin@example.com",
        "firstName": "Admin",
        "lastName": "User",
        "isActive": true,
        "createdDate": "2024-01-01T00:00:00Z",
        "roles": [
          {
            "id": 1,
            "name": "admin"
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

### 2. 获取用户详情

**接口**: `GET /api/users/{id}`

**请求示例**:
```http
GET /api/users/1
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "firstName": "Admin",
    "lastName": "User",
    "isActive": true,
    "createdDate": "2024-01-01T00:00:00Z",
    "lastLoginDate": "2024-01-01T10:00:00Z",
    "roles": [
      {
        "id": 1,
        "name": "admin",
        "description": "系统管理员"
      }
    ],
    "permissions": [
      "user.view",
      "user.add",
      "user.edit",
      "user.delete"
    ]
  }
}
```

### 3. 创建用户

**接口**: `POST /api/users`

**权限**: `user.add`

**请求参数**:
```json
{
  "username": "newuser",
  "password": "password123",
  "email": "newuser@example.com",
  "firstName": "New",
  "lastName": "User",
  "isActive": true,
  "roleIds": [2]
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "newuser",
    "email": "newuser@example.com",
    "firstName": "New",
    "lastName": "User",
    "isActive": true,
    "createdDate": "2024-01-01T00:00:00Z"
  },
  "message": "用户创建成功"
}
```

### 4. 更新用户

**接口**: `PUT /api/users/{id}`

**权限**: `user.edit`

**请求参数**:
```json
{
  "email": "updated@example.com",
  "firstName": "Updated",
  "lastName": "User",
  "isActive": true,
  "roleIds": [2, 3]
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "username": "newuser",
    "email": "updated@example.com",
    "firstName": "Updated",
    "lastName": "User",
    "isActive": true
  },
  "message": "用户更新成功"
}
```

### 5. 删除用户

**接口**: `DELETE /api/users/{id}`

**权限**: `user.delete`

**响应示例**:
```json
{
  "success": true,
  "message": "用户删除成功"
}
```

### 6. 重置用户密码

**接口**: `POST /api/users/{id}/reset-password`

**权限**: `user.edit`

**请求参数**:
```json
{
  "newPassword": "newpassword123"
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "密码重置成功"
}
```

### 7. 批量删除用户

**接口**: `POST /api/users/batch-delete`

**权限**: `user.delete`

**请求参数**:
```json
{
  "ids": [2, 3, 4]
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "批量删除成功，共删除 3 个用户"
}
```

---

## 角色管理 API

### 1. 获取角色列表

**接口**: `GET /api/roles`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | integer | 否 | 页码，默认 1 |
| pageSize | integer | 否 | 每页数量，默认 20 |
| keyword | string | 否 | 搜索关键词 |

**响应示例**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "admin",
        "description": "系统管理员",
        "isSystem": true,
        "createdDate": "2024-01-01T00:00:00Z",
        "userCount": 1,
        "permissionCount": 50
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

### 2. 获取角色详情

**接口**: `GET /api/roles/{id}`

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "admin",
    "description": "系统管理员",
    "isSystem": true,
    "createdDate": "2024-01-01T00:00:00Z",
    "permissions": [
      {
        "id": 1,
        "code": "user.view",
        "name": "查看用户",
        "module": "用户管理"
      }
    ]
  }
}
```

### 3. 创建角色

**接口**: `POST /api/roles`

**权限**: `role.add`

**请求参数**:
```json
{
  "name": "manager",
  "description": "部门经理",
  "permissionIds": [1, 2, 3]
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "manager",
    "description": "部门经理",
    "createdDate": "2024-01-01T00:00:00Z"
  },
  "message": "角色创建成功"
}
```

### 4. 更新角色

**接口**: `PUT /api/roles/{id}`

**权限**: `role.edit`

**请求参数**:
```json
{
  "description": "部门经理（更新）",
  "permissionIds": [1, 2, 3, 4]
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "角色更新成功"
}
```

### 5. 删除角色

**接口**: `DELETE /api/roles/{id}`

**权限**: `role.delete`

**响应示例**:
```json
{
  "success": true,
  "message": "角色删除成功"
}
```

### 6. 分配权限

**接口**: `POST /api/roles/{id}/permissions`

**权限**: `role.edit`

**请求参数**:
```json
{
  "permissionIds": [1, 2, 3, 4, 5]
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "权限分配成功"
}
```

---

## 权限管理 API

### 1. 获取权限列表

**接口**: `GET /api/permissions`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| module | string | 否 | 模块筛选 |
| category | string | 否 | 分类筛选 |

**响应示例**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "user.view",
      "name": "查看用户",
      "description": "查看用户列表和详情",
      "module": "用户管理",
      "category": "查看"
    },
    {
      "id": 2,
      "code": "user.add",
      "name": "添加用户",
      "description": "创建新用户",
      "module": "用户管理",
      "category": "编辑"
    }
  ]
}
```

### 2. 获取权限树

**接口**: `GET /api/permissions/tree`

**响应示例**:
```json
{
  "success": true,
  "data": [
    {
      "module": "用户管理",
      "categories": [
        {
          "category": "查看",
          "permissions": [
            {
              "id": 1,
              "code": "user.view",
              "name": "查看用户"
            }
          ]
        },
        {
          "category": "编辑",
          "permissions": [
            {
              "id": 2,
              "code": "user.add",
              "name": "添加用户"
            },
            {
              "id": 3,
              "code": "user.edit",
              "name": "编辑用户"
            },
            {
              "id": 4,
              "code": "user.delete",
              "name": "删除用户"
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 通用 CRUD API

### 1. 获取数据列表

**接口**: `GET /api/crud/{entity}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | integer | 否 | 页码，默认 1 |
| pageSize | integer | 否 | 每页数量，默认 20 |
| sort | string | 否 | 排序字段 |
| order | string | 否 | 排序方向：asc/desc |
| filter | string | 否 | 过滤条件（JSON 格式） |

**请求示例**:
```http
GET /api/crud/products?page=1&pageSize=20&sort=createdDate&order=desc
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "name": "产品A",
        "code": "P001",
        "price": 100.00,
        "stock": 50,
        "isActive": true
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

### 2. 获取数据详情

**接口**: `GET /api/crud/{entity}/{id}`

**请求示例**:
```http
GET /api/crud/products/1
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "产品A",
    "code": "P001",
    "price": 100.00,
    "stock": 50,
    "isActive": true,
    "createdDate": "2024-01-01T00:00:00Z"
  }
}
```

### 3. 创建数据

**接口**: `POST /api/crud/{entity}`

**权限**: `{entity}.add`

**请求参数**:
```json
{
  "name": "新产品",
  "code": "P002",
  "price": 200.00,
  "stock": 100,
  "isActive": true
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "新产品",
    "code": "P002",
    "price": 200.00,
    "stock": 100,
    "isActive": true
  },
  "message": "创建成功"
}
```

### 4. 更新数据

**接口**: `PUT /api/cruders/{entity}/{id}`

**权限**: `{entity}.edit`

**请求参数**:
```json
{
  "name": "更新产品",
  "price": 250.00,
  "stock": 80
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "更新产品",
    "code": "P002",
    "price": 250.00,
    "stock": 80,
    "isActive": true
  },
  "message": "更新成功"
}
```

### 5. 删除数据

**接口**: `DELETE /api/crud/{entity}/{id}`

**权限**: `{entity}.delete`

**响应示例**:
```json
{
  "success": true,
  "message": "删除成功"
}
```

### 6. 批量删除

**接口**: `POST /api/crud/{entity}/batch-delete`

**权限**: `{entity}.delete`

**请求参数**:
```json
{
  "ids": [1, 2, 3]
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "批量删除成功"
}
```

### 7. 导出数据

**接口**: `GET /api/crud/{entity}/export`

**权限**: `{entity}.export`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| format | string | 否 | 导出格式：excel/csv，默认 excel |
| filter | string | 否 | 过滤条件 |

**响应**: 返回文件流

### 8. 导入数据

**接口**: `POST /api/crud/{entity}/import`

**权限**: `{entity}.import`

**请求**: multipart/form-data

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 导入文件 |

**响应示例**:
```json
{
  "success": true,
  "data": {
    "successCount": 10,
    "failureCount": 2,
    "errors": [
      {
        "row": 3,
        "message": "必填字段为空"
      }
    ]
  },
  "message": "导入完成"
}
```

---

## 系统管理 API

### 1. 获取系统信息

**接口**: `GET /api/system/info`

**响应示例**:
```json
{
  "success": true,
  "data": {
    "version": "1.0.0",
    "buildDate": "2024-01-01",
    "serverTime": "2024-01-01T00:00:00Z",
    "environment": "production",
    "database": {
      "type": "MSSQL",
      "version": "2016",
      "status": "connected"
    }
  }
}
```

### 2. 获取系统配置

**接口**: `GET /api/system/config`

**权限**: `system.config.view`

**响应示例**:
```json
{
  "success": true,
  "data": {
    "server": {
      "port": 8077,
      "host": "0.0.0.0"
    },
    "security": {
      "sessionTimeout": 1800,
      "passwordPolicy": {
        "minLength": 8,
        "requireUppercase": true,
        "requireLowercase": true,
        "requireNumbers": true,
        "requireSpecialChars": true
      }
    }
  }
}
```

### 3. 更新系统配置

**接口**: `PUT /api/system/config`

**权限**: `system.config.edit`

**请求参数**:
```json
{
  "security": {
    "sessionTimeout": 3600
  }
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "配置更新成功"
}
```

### 4. 获取系统日志

**接口**: `GET /api/system/logs`

**权限**: `system.logs.view`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| level | string | 否 | 日志级别：debug/info/warning/error |
| startDate | string | 否 | 开始日期 |
| endDate | string | 否 | 结束日期 |
| page | integer | 否 | 页码 |
| pageSize | integer | 否 | 每页数量 |

**响应示例**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "level": "info",
        "message": "用户登录",
        "timestamp": "2024-01-01T00:00:00Z",
        "userId": 1,
        "userName": "admin"
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}
```

### 5. 清理系统日志

**接口**: `DELETE /api/system/logs`

**权限**: `system.logs.delete`

**请求参数**:
```json
{
  "beforeDate": "2024-01-01T00:00:00Z"
}
```

**响应示例**:
```json
{
  "success": true,
  "message": "日志清理成功"
}
```

### 6. 获取系统统计

**接口**: `GET /api/system/statistics`

**权限**: `system.statistics.view`

**响应示例**:
```json
{
  "success": true,
  "data": {
    "users": {
      "total": 100,
      "active": 95,
      "online": 10
    },
    "roles": {
      "total": 5
    },
    "permissions": {
      "total": 50
    },
    "database": {
      "size": "1.5 GB",
      "tables": 20
    },
    "performance": {
      "avgResponseTime": 100,
      "requestsPerMinute": 60
    }
  }
}
```

---

## 错误处理

### 1. 错误码列表

| 错误码 | 说明 |
|--------|------|
| AUTH_001 | 用户名或密码错误 |
| AUTH_002 | Token 无效或已过期 |
| AUTH_003 | 用户已被禁用 |
| AUTH_004 | 密码不符合要求 |
| AUTH_005 | 旧密码错误 |
| AUTH_006 | 用户已存在 |
| AUTH_007 | 邮箱已被使用 |
| PERM_001 | 无权限访问 |
| PERM_002 | 权限不存在 |
| PERM_003 | 角色不存在 |
| PERM_004 | 系统角色不可删除 |
| VAL_001 | 参数验证失败 |
| VAL_002 | 必填字段为空 |
| VAL_003 | 字段格式错误 |
| VAL_004 | 唯一性约束冲突 |
| DB_001 | 数据库连接失败 |
| DB_002 | 数据库操作失败 |
| DB_003 | 记录不存在 |
| SYS_001 | 系统错误 |
| SYS_002 | 文件上传失败 |
| SYS_003 | 文件下载失败 |

### 2. 错误响应示例

#### 认证错误
```json
{
  "success": false,
  "error": {
    "code": "AUTH_001",
    "message": "用户名或密码错误",
    "details": "请检查用户名和密码是否正确"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 权限错误
```json
{
  "success": false,
  "error": {
    "code": "PERM_001",
    "message": "无权限访问",
    "details": "需要权限: user.delete"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 验证错误
```json
{
  "success": false,
  "error": {
    "code": "VAL_001",
    "message": "参数验证失败",
    "details": {
      "fields": [
        {
          "field": "email",
          "message": "邮箱格式不正确"
        },
        {
          "field": "password",
          "message": "密码长度不能少于8位"
        }
      ]
    }
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

#### 数据库错误
```json
{
  "success": false,
  "error": {
    "code": "DB_003",
    "message": "记录不存在",
    "details": "用户ID: 999 不存在"
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## API 版本控制

### 1. 版本策略

采用 URL 路径版本控制：

```
/api/v1/auth/login
/api/v2/auth/login
```

### 2. 版本兼容性

- **v1**: 当前稳定版本
- **v2**: 最新版本（可能包含破坏性更改）

### 3. 版本弃用通知

当版本即将弃用时，响应头会包含警告：

```http
X-API-Deprecated: true
X-API-Deprecation-Date: 2024-12-31
X-API-Sunset-Date: 2025-06-30
X-API-Recommended-Version: v2
```

---

## 最佳实践

### 1. 认证流程

```javascript
// 1. 登录获取 Token
const loginResponse = await fetch('/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'admin',
    password: 'password123'
  })
});

const { data } = await loginResponse.json();
const token = data.accessToken;

// 2. 使用 Token 访问受保护的 API
const response = await fetch('/api/users', {
  headers: {
    'Authorization': `Bearer ${token}`
}`
});
```

### 2. 错误处理

```javascript
try {
  const response = await fetch('/api/users');
  const result = await response.json();

  if (!result.success) {
    // 处理错误
    switch (result.error.code) {
      case 'AUTH_001':
        showMessage('用户名或密码错误');
        break;
      case 'PERM_001':
        showMessage('无权限访问');
        break;
      default:
        showMessage(result.error.message);
    }
  } else {
    // 处理成功响应
    console.log(result.data);
  }
} catch (error) {
  // 处理网络错误
  console.error('请求失败:', error);
}
```

### 3. 分页加载

```javascript
async function loadUsers(page = 1, pageSize = 20) {
  const response = await fetch(
    `/api/users?page=${page}&pageSize=${pageSize}`
  );
  const result = await response.json();

  if (result.success) {
    const { items, pagination } = result.data;
    console.log(`第 ${pagination.page} 页，共 ${pagination.totalPages} 页`);
    return items;
  }
}
```

### 4. Token 刷新

```javascript
async function refreshToken() {
  const refreshToken = localStorage.getItem('refreshToken');

  const response = await fetch('/api/auth/refresh', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ refreshToken })
  });

  const result = await response.json();

  if (result.success) {
    localStorage.setItem('accessToken', result.data.accessToken);
    return result.data.accessToken;
  } else {
    // Token 刷新失败，跳转到登录页
    window.location.href = '/login';
  }
}
```

---

## 总结

UniAdmin API 提供了完整的 RESTful 接口，支持用户管理、角色管理、权限管理和通用 CRUD 操作。所有接口都遵循统一的请求和响应格式，并支持 JWT 认证和 RBAC 权限控制。

---

**文档版本**: 1.0
**最后更新**: 2024-01-01
**维护者**: UniAdmin 开发团队
