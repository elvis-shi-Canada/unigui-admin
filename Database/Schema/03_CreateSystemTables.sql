-- =============================================
-- UniAdmin 系统模块层数据库表
-- =============================================

-- 数据字典类型表
CREATE TABLE UniAdmin_DictTypes (
    TypeID          INT PRIMARY KEY IDENTITY(1,1),
    TypeCode        NVARCHAR(50)       NOT NULL UNIQUE,
    TypeName        NVARCHAR(100)      NOT NULL,
    Description     NVARCHAR(500),
    SortOrder       INT                NOT NULL DEFAULT 0,
    Status          INT                NOT NULL DEFAULT 1,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CreatedBy       INT,
    ModifiedDate     DATETIME,
    ModifiedBy      INT
);
GO

-- 数据字典项表
CREATE TABLE UniAdmin_DictItems (
    ItemID          INT PRIMARY KEY IDENTITY(1,1),
    TypeID          INT                NOT NULL,
    ItemCode        NVARCHAR(50)       NOT NULL,
    ItemName        NVARCHAR(100)      NOT NULL,
    ItemValue       NVARCHAR(255),
    SortOrder       INT                NOT NULL DEFAULT 0,
    Status          INT                NOT NULL DEFAULT 1,
    Remark          NVARCHAR(500),
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CreatedBy       INT,
    ModifiedDate     DATETIME,
    ModifiedBy      INT,
    CONSTRAINT FK_DictItem_Type FOREIGN KEY (TypeID) REFERENCES UniAdmin_DictTypes(TypeID),
    CONSTRAINT UQ_DictItem_Code UNIQUE(TypeID, ItemCode)
);
GO

-- 系统配置表
CREATE TABLE UniAdmin_Configs (
    ConfigID        INT PRIMARY KEY IDENTITY(1,1),
    ConfigKey       NVARCHAR(100)      NOT NULL UNIQUE,
    ConfigValue     NVARCHAR(MAX),
    Category        NVARCHAR(50)       NOT NULL,
    Description     NVARCHAR(500),
    ValueType       NVARCHAR(20)       NOT NULL DEFAULT 'string',
    SortOrder       INT                NOT NULL DEFAULT 0,
    Status          INT                NOT NULL DEFAULT 1,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CreatedBy       INT,
    ModifiedDate     DATETIME,
    ModifiedBy      INT
);
GO

-- 登录日志表
CREATE TABLE UniAdmin_LoginLogs (
    LogID           INT PRIMARY KEY IDENTITY(1,1),
    UserID          INT,
    UserName        NVARCHAR(50),
    LoginIP         NVARCHAR(50),
    LoginTime       DATETIME           NOT NULL DEFAULT GETDATE(),
    LogoutTime      DATETIME,
    Status          INT                NOT NULL DEFAULT 1,
    UserAgent       NVARCHAR(500),
    FailReason      NVARCHAR(255),
    CONSTRAINT FK_LoginLog_User FOREIGN KEY (UserID) REFERENCES UniAdmin_Users(UserID)
);
GO

-- 操作日志表
CREATE TABLE UniAdmin_OperationLogs (
    LogID           INT PRIMARY KEY IDENTITY(1,1),
    UserID          INT,
    UserName        NVARCHAR(50),
    Module          NVARCHAR(50)       NOT NULL,
    Operation       NVARCHAR(50)       NOT NULL,
    Description     NVARCHAR(500),
    RequestData     NVARCHAR(MAX),
    ResponseData    NVARCHAR(MAX),
    IP              NVARCHAR(50),
    UserAgent       NVARCHAR(500),
    Duration        INT,
    Status          INT                NOT NULL DEFAULT 1,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE()
);
GO

-- 数据变更日志表
CREATE TABLE UniAdmin_DataChangeLogs (
    LogID           INT PRIMARY KEY IDENTITY(1,1),
    UserID          INT,
    UserName        NVARCHAR(50),
    TableName       NVARCHAR(100)      NOT NULL,
    RecordID        INT,
    Operation       NVARCHAR(20)       NOT NULL,
    OldValue        NVARCHAR(MAX),
    NewValue        NVARCHAR(MAX),
    IP              NVARCHAR(50),
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE()
);
GO

-- 定时任务表
CREATE TABLE UniAdmin_ScheduledTasks (
    TaskID          INT PRIMARY KEY IDENTITY(1,1),
    TaskName        NVARCHAR(100)      NOT NULL,
    TaskCode        NVARCHAR(100)      NOT NULL UNIQUE,
    CronExpression  NVARCHAR(100)      NOT NULL,
    HandlerClass    NVARCHAR(200)      NOT NULL,
    Parameters      NVARCHAR(MAX),
    Description     NVARCHAR(500),
    Status          INT                NOT NULL DEFAULT 0,
    LastRunTime     DATETIME,
    NextRunTime     DATETIME,
    LastRunStatus   INT,
    LastRunMessage  NVARCHAR(500),
    SortOrder       INT                NOT NULL DEFAULT 0,
    CreatedDate     DATETIME           NOT NULL DEFAULT GETDATE(),
    CreatedBy       INT,
    ModifiedDate     DATETIME,
    ModifiedBy      INT
);
GO

-- 任务执行日志表
CREATE TABLE UniAdmin_TaskExecutionLogs (
    LogID           INT PRIMARY KEY IDENTITY(1,1),
    TaskID          INT                NOT NULL,
    StartTime       DATETIME           NOT NULL DEFAULT GETDATE(),
    EndTime         DATETIME,
    Status          INT                NOT NULL DEFAULT 0,
    ErrorMessage    NVARCHAR(MAX),
    Result          NVARCHAR(MAX),
    Duration        INT,
    CONSTRAINT FK_TaskLog_Task FOREIGN KEY (TaskID) REFERENCES UniAdmin_ScheduledTasks(TaskID)
);
GO

-- 创建索引
CREATE INDEX IX_DictTypes_Code ON UniAdmin_DictTypes(TypeCode);
CREATE INDEX IX_DictTypes_Status ON UniAdmin_DictTypes(Status);
CREATE INDEX IX_DictItems_TypeID ON UniAdmin_DictItems(TypeID);
CREATE INDEX IX_DictItems_Code ON UniAdmin_DictItems(ItemCode);
CREATE INDEX IX_Configs_Key ON UniAdmin_Configs(ConfigKey);
CREATE INDEX IX_Configs_Category ON UniAdmin_Configs(Category);
CREATE INDEX IX_LoginLogs_UserID ON UniAdmin_LoginLogs(UserID);
CREATE INDEX IX_LoginLogs_LoginTime ON UniAdmin_LoginLogs(LoginTime);
CREATE INDEX IX_OperationLogs_UserID ON UniAdmin_OperationLogs(UserID);
CREATE INDEX IX_OperationLogs_CreatedDate ON UniAdmin_OperationLogs(CreatedDate);
CREATE INDEX IX_DataChangeLogs_Table ON UniAdmin_DataChangeLogs(TableName);
CREATE INDEX IX_DataChangeLogs_RecordID ON UniAdmin_DataChangeLogs(RecordID);
CREATE INDEX IX_ScheduledTasks_Code ON UniAdmin_ScheduledTasks(TaskCode);
CREATE INDEX IX_ScheduledTasks_Status ON UniAdmin_ScheduledTasks(Status);
CREATE INDEX IX_TaskExecutionLogs_TaskID ON UniAdmin_TaskExecutionLogs(TaskID);
CREATE INDEX IX_TaskExecutionLogs_StartTime ON UniAdmin_TaskExecutionLogs(StartTime);
GO
