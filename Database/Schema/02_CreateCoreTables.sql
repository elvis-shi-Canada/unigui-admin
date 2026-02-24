-- =============================================
-- UniAdmin 核心框架层数据库表
-- =============================================

-- 用户表
CREATE TABLE UniAdmin_Users (
    UserID          INT PRIMARY KEY IDENTITY(1,1),
    UserName        NVARCHAR(50)       NOT NULL UNIQUE,
    Password        NVARCHAR(255)      NOT NULL,
    RealName        NVARCHAR(100),
    Email           NVARCHAR(100),
    Phone           NVARCHAR(20),
    Avatar          NVARCHAR(255),
    Status          INT                NOT NULL DEFAULT 1,
    LastLoginDate   DATETIME,
    LastLoginIP     NVARCHAR(50),
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CreatedBy       INT,
    ModifiedDate     DATETIME,
    ModifiedBy      INT
);
GO

-- 角色表
CREATE TABLE UniAdmin_Roles (
    RoleID          INT PRIMARY KEY IDENTITY(1,1),
    RoleCode        NVARCHAR(50)       NOT NULL UNIQUE,
    RoleName        NVARCHAR(100)      NOT NULL,
    Description     NVARCHAR(500),
    DataScope      NVARCHAR(20)       NOT NULL DEFAULT 'self',
    SortOrder       INT                NOT NULL DEFAULT 0,
    Status          INT                NOT NULL DEFAULT 1,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    ModifiedDate     DATETIME
);
GO

-- 权限表
CREATE TABLE UniAdmin_Permissions (
    PermissionID    INT PRIMARY KEY IDENTITY(1,1),
    PermissionCode  NVARCHAR(100)      NOT NULL UNIQUE,
    PermissionName  NVARCHAR(100)      NOT NULL,
    ResourceType    NVARCHAR(50)       NOT NULL,
    ResourceCode    NVARCHAR(100)      NOT NULL,
    Action          NVARCHAR(20)       NOT NULL,
    Description     NVARCHAR(500),
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE()
);
GO

-- 用户-角色关联表
CREATE TABLE UniAdmin_UserRoles (
    ID              INT PRIMARY KEY IDENTITY(1,1),
    UserID          INT NOT NULL,
    RoleID          INT NOT NULL,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_UserRole_User FOREIGN KEY (UserID) REFERENCES UniAdmin_Users(UserID),
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (RoleID) REFERENCES UniAdmin_Roles(RoleID),
    CONSTRAINT UQ_UserRole UNIQUE(UserID, RoleID)
);
GO

-- 角色-权限关联表
CREATE TABLE UniAdmin_RolePermissions (
    ID              INT PRIMARY KEY IDENTITY(1,1),
    RoleID          INT NOT NULL,
    PermissionID    INT NOT NULL,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (RoleID) REFERENCES UniAdmin_Roles(RoleID),
    CONSTRAINT FK_RolePermission_Perm FOREIGN KEY (PermissionID) REFERENCES UniAdmin_Permissions(PermissionID),
    CONSTRAINT UQ_RolePermission UNIQUE(RoleID, PermissionID)
);
GO

-- 菜单表
CREATE TABLE UniAdmin_Menus (
    MenuID          INT PRIMARY KEY IDENTITY(1,1),
    ParentID        INT                NULL,
    MenuName        NVARCHAR(100)      NOT NULL,
    MenuCode        NVARCHAR(100)      NOT NULL UNIQUE,
    Icon            NVARCHAR(50),
    RoutePath       NVARCHAR(255),
    PermissionCode  NVARCHAR(100),
    SortOrder       INT                NOT NULL DEFAULT 0,
    IsVisible       BIT                NOT NULL DEFAULT 1,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    ModifiedDate     DATETIME,
    CONSTRAINT FK_Menu_Parent FOREIGN KEY (ParentID) REFERENCES UniAdmin_Menus(MenuID)
);
GO

-- 用户菜单缓存表（可选,用于快速加载）
CREATE TABLE UniAdmin_UserMenus (
    ID              INT PRIMARY KEY IDENTITY(1,1),
    UserID          INT NOT NULL,
    MenuID          INT NOT NULL,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_UserMenu_User FOREIGN KEY (UserID) REFERENCES UniAdmin_Users(UserID),
    CONSTRAINT FK_UserMenu_Menu FOREIGN KEY (MenuID) REFERENCES UniAdmin_Menus(MenuID),
    CONSTRAINT UQ_UserMenu UNIQUE(UserID, MenuID)
);
GO

-- 创建索引
CREATE INDEX IX_Users_UserName ON UniAdmin_Users(UserName);
CREATE INDEX IX_Users_Status ON UniAdmin_Users(Status);
CREATE INDEX IX_Roles_Code ON UniAdmin_Roles(RoleCode);
CREATE INDEX IX_Permissions_Code ON UniAdmin_Permissions(PermissionCode);
CREATE INDEX IX_Menus_Parent ON UniAdmin_Menus(ParentID);
CREATE INDEX IX_Menus_Code ON UniAdmin_Menus(MenuCode);
GO
