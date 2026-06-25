# UniAdmin CRUD 框架文档

## 目录
- [框架概述](#框架概述)
- [TUniAdminModel 组件](#tunimodeladmin-组件)
- [元数据配置](#元数据配置)
- [快速开始](#快速开始)
- [高级功能](#高级功能)
- [最佳实践](#最佳实践)
- [示例代码](#示例代码)

---

## 框架概述

### 1. 什么是 CRUD 框架

CRUD 框架是 UniAdmin 的核心功能之一，通过 `TUniAdminModel` 组件实现零代码的增删改查操作。开发者只需配置元数据，框架自动生成完整的 CRUD 界面和逻辑。

### 2. 核心特性

- **零代码开发**: 无需编写增删改查代码
- **元数据驱动**: 通过 JSON 配置定义行为
- **自动验证**: 内置数据验证规则
- **权限集成**: 自动集成 RBAC 权限系统
- **自定义扩展**: 支持自定义逻辑和界面
- **多表关联**: 支持主从表和关联查询

### 3. 适用场景

- 标准的 CRUD 业务模块
- 数据管理界面
- 配置管理界面
- 字典管理界面
- 简单的业务表单

---

## TUniAdminModel 组件

### 1. 组件属性

#### 基本属性

| 属性 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `Connection` | `TFDConnection` | 数据库连接对象 | 必需 |
| `TableName` | `string` | 数据表名称 | 必需 |
| `PrimaryKey` | `string` | 主键字段名 | 'Id' |
| `Metadata` | `string` | 元数据 JSON 配置 | '' |
| `MetadataFile` | `string` | 元数据文件路径 | '' |
| `AutoCreate` | `Boolean` | 自动创建界面 | True |
| `AutoLoadMetadata` | `Boolean` | 自动加载元数据 | True |

#### 界面属性

| 属性 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `ShowGrid` | `Boolean` | 显示数据网格 | True |
| `ShowToolbar` | `Boolean` | 显示工具栏 | True |
| `ShowSearchPanel` | `Boolean` | 显示搜索面板 | True |
| `ShowPagination` | `Boolean` | 显示分页 | True |
| `PageSize` | `Integer` | 每页记录数 | 20 |
| `GridEditable` | `Boolean` | 网格可编辑 | False |

#### 权限属性

| 属性 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `PermissionPrefix` | `string` | 权限前缀 | '' |
| `CheckPermission` | `Boolean` | 检查权限 | True |
| `ViewPermission` | `string` | 查看权限 | '' |
| `AddPermission` | `string` | 添加权限 | '' |
| `EditPermission` | `string` | 编辑权限 | '' |
| `DeletePermission` | `string` | 删除权限 | '' |

### 2. 组件事件

| 事件 | 说明 | 参数 |
|------|------|------|
| `OnBeforeLoad` | 加载数据前触发 | `Sender: TObject` |
| `OnAfterLoad` | 加载数据后触发 | `Sender: TObject; RecordCount: Integer` |
| `OnBeforeInsert` | 插入前触发 | `Sender: TObject; DataSet: TDataSet` |
| `OnAfterInsert` | 插入后触发 | `Sender: TObject; DataSet: TDataSet` |
| `OnBeforeUpdate` | 更新前触发 | `Sender: TObject; DataSet: TDataSet` |
| `OnAfterUpdate` | 更新后触发 | `Sender: TObject; DataSet: TDataSet` |
| `OnBeforeDelete` | 删除前触发 | `Sender: TObject; Id: Variant` |
| `OnAfterDelete` | 删除后触发 | `Sender: TObject; Id: Variant` |
| `OnValidationError` | 验证失败时触发 | `Sender: TObject; FieldName: string; ErrorMessage: string` |
| `OnCustomAction` | 自定义操作触发 | `Sender: TObject; ActionName: string; Params: TStrings` |

### 3. 组件方法

```delphi
// 加载数据
procedure LoadData(const Filter: string = ''; const Params: array of const);

// 刷新数据
procedure Refresh;

// 新增记录
procedure Insert;

// 编辑记录
procedure Edit(Id: Variant);

// 删除记录
procedure Delete(Id: Variant);

// 保存记录
function Save: Boolean;

// 取消编辑
procedure Cancel;

// 导出数据
procedure ExportToExcel(const FileName: string);

// 导入数据
procedure ImportFromExcel(const FileName: string);

// 执行自定义操作
procedure ExecuteCustomAction(const ActionName: string; const Params: TStrings);
```

---

## 元数据配置

### 1. 完整元数据结构

```json
{
  "entity": "Product",
  "table": "Products",
  "primaryKey": "Id",
  "title": "产品管理",
  "description": "产品信息管理",

  "fields": [
    {
      "name": "Id",
      "type": "integer",
      "label": "ID",
      "visible": false,
      "editable": false,
      "primaryKey": true
    },
    {
      "name": "Name",
      "type": "string",
      "label": "产品名称",
      "required": true,
      "maxLength": 100,
      "searchable": true,
      "sortable": true,
      "gridWidth": 200
    },
    {
      "name": "Code",
      "type": "string",
      "label": "产品编码",
      "required": true,
      "unique": true,
      "maxLength": 50,
      "searchable": true
    },
    {
      "name": "CategoryId",
      "type": "integer",
      "label": "产品分类",
      "required": true,
      "lookup": {
        "table": "Categories",
        "keyField": "Id",
        "displayField": "Name",
        "orderBy": "Name"
      }
    },
    {
      "name": "Price",
      "type": "decimal",
      "label": "价格",
      "required": true,
      "precision": 10,
      "scale": 2,
      "minValue": 0,
      "gridWidth": 100
    },
    {
      "name": "Stock",
      "type": "integer",
      "label": "库存",
      "required": true,
      "minValue": 0,
      "defaultValue": 0
    },
    {
      "name": "Description",
      "type": "text",
      "label": "产品描述",
      "gridVisible": false,
      "formHeight": 100
    },
    {
      "name": "ImageUrl",
      "type": "string",
      "label": "产品图片",
      "inputType": "image",
      "gridVisible": false
    },
    {
      "name": "IsActive",
      "type": "boolean",
      "label": "是否启用",
      "defaultValue": true,
      "gridWidth": 80
    },
    {
      "name": "CreatedDate",
      "type": "datetime",
      "label": "创建时间",
      "editable": false,
      "gridWidth": 150
    },
    {
      "name": "UpdatedDate",
      "type": "datetime",
      "label": "更新时间",
      "editable": false,
      "gridWidth": 150
    }
  ],

  "searchFields": ["Name", "Code"],

  "defaultSort": {
    "field": "CreatedDate",
    "direction": "desc"
  },

  "permissions": {
    "view": "product.view",
    "add": "product.add",
    "edit": "product.edit",
    "delete": "product.delete",
    "export": "product.export"
  },

  "validation": {
    "rules": [
      {
        "field": "Price",
        "rule": "custom",
        "message": "价格必须大于0",
        "expression": "Price > 0"
      }
    ]
  },

  "actions": [
    {
      "name": "approve",
      "label": "审核",
      "icon": "check",
      "permission": "product.approve",
      "handler": "OnApprove"
    },
    {
      "name": "reject",
      "label": "驳回",
      "icon": "close",
      "permission": "product.reject",
      "handler": "OnReject"
    }
  ],

  "toolbar": {
    "showAdd": true,
    "showEdit": true,
    "showDelete": true,
    "showRefresh": true,
    "showExport": true,
    "showImport": true,
    "showSearch": true
  },

  "grid": {
    "showRowNumber": true,
    "allowMultiSelect": true,
    "allowCellEdit": false,
    "showSummary": false
  },

  "form": {
    "layout": "vertical",
    "columns": 2,
    "showConfirmOnSave": true,
    "showConfirmOnDelete": true
  }
}
```

### 2. 字段类型

| 类型 | 说明 | 对应 Delphi 类型 | 验证规则 |
|------|------|------------------|----------|
| `integer` | 整数 | `Integer` | `minValue`, `maxValue` |
| `string` | 字符串 | `string` | `maxLength`, `minLength`, `pattern` |
| `text` | 多行文本 | `string` | `maxLength` |
| `decimal` | 小数 | `Double` | `precision`, `scale`, `minValue`, `maxValue` |
| `boolean` | 布尔值 | `Boolean` | - |
| `date` | 日期 | `TDate` | `minDate`, `maxDate` |
| `datetime` | 日期时间 | `TDateTime` | `minDate`, `maxDate` |
| `time` | 时间 | `TTime` | - |
| `enum` | 枚举 | `Integer` | `enumValues` |
| `image` | 图片 | `string` | - |
| `file` | 文件 | `string` | `fileTypes`, `maxSize` |

### 3. 字段属性

#### 通用属性

```json
{
  "name": "FieldName",           // 字段名（必需）
  "type": "string",              // 字段类型（必需）
  "label": "字段标签",            // 显示标签
  "description": "字段描述",      // 提示信息
  "required": false,             // 是否必填
  "defaultValue": "",            // 默认值
  "visible": true,               // 是否可见
  "editable": true,              // 是否可编辑
  "searchable": false,           // 是否可搜索
  "sortable": false,             // 是否可排序
  "unique": false                // 是否唯一
}
```

#### 网格属性

```json
{
  "gridVisible": true,           // 网格中是否可见
  "gridWidth": 100,              // 网格列宽
  "gridAlign": "left",           // 对齐方式: left, center, right
  "gridFormat": "",              // 格式化字符串
  "gridRenderer": ""             // 自定义渲染器
}
```

#### 表单属性

```json
{
  "formVisible": true,           // 表单中是否可见
  "formWidth": 100,              // 表单控件宽度
  "formHeight": 30,              // 表单控件高度
  "inputType": "text",           // 输入类型: text, password, textarea, select, checkbox, radio, date, datetime, image, file
  "placeholder": "",             // 占位符
  "helpText": ""                  // 帮助文本
}
```

#### 验证属性

```json
{
  "maxLength": 255,              // 最大长度
  "minLength": 0,                // 最小长度
  "minValue": null,              // 最小值
  "maxValue": null,              // 最大值
  "pattern": "",                 // 正则表达式
  "customValidator": ""          // 自定义验证器
}
```

#### 关联属性

```json
{
  "lookup": {
    "table": "LookupTable",       // 关联表
    "keyField": "Id",             // 键字段
    "displayField": "Name",       // 显示字段
    "orderBy": "Name",            // 排序字段
    "filter": "",                 // 过滤条件
    "allowNull": false            // 是否允许为空
  }
}
```

---

## 快速开始

### 1. 创建数据表

```sql
CREATE TABLE Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Code NVARCHAR(50) UNIQUE NOT NULL,
    CategoryId INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT DEFAULT 0,
    Description NVARCHAR(MAX),
    ImageUrl NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);

CREATE INDEX IX_Products_Name ON Products(Name);
CREATE INDEX IX_Products_Code ON Products(Code);
CREATE INDEX IX_Products_CategoryId ON Products(CategoryId);
```

### 2. 创建表单

```delphi
unit ProductAdminFM;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniGUIClasses, uniModelAdmin, FireDAC.Comp.Client,
  App.Core.Form;

type
  TProductAdminForm = class(TAppForm)
    UniModelAdmin1: TUniAdminModel;
    FDConnection1: TFDConnection;
    procedure UniModelAdmin1BeforeInsert(Sender: TObject; DataSet: TDataSet);
    procedure UniModelAdmin1BeforeUpdate(Sender: TObject; DataSet: TDataSet);
    procedure UniModelAdmin1CustomAction(Sender: TObject; ActionName: string;
      Params: TStrings);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TProductAdminForm.UniModelAdmin1BeforeInsert(Sender: TObject;
  DataSet: TDataSet);
begin
  // 设置默认值
  DataSet.FieldByName('CreatedDate').AsDateTime := Now;
  DataSet.FieldByName('IsActive').AsBoolean := True;
end;

procedure TProductAdminForm.UniModelAdmin1BeforeUpdate(Sender: TObject;
  DataSet: TDataSet);
begin
  // 更新时间戳
  DataSet.FieldByName('UpdatedDate').AsDateTime := Now;
end;

procedure TProductAdminForm.UniModelAdmin1CustomAction(Sender: TObject;
  ActionName: string; Params: TStrings);
begin
  if ActionName = 'approve' then
  begin
    // 审核逻辑
    ShowMessage('审核通过');
  end
  else if ActionName = 'reject' then
  begin
    // 驳回逻辑
    ShowMessage('已驳回');
  end;
end;

initialization
  RegisterClass(TProductAdminForm);

end.
```

### 3. 配置元数据

#### 方式一: 直接设置 Metadata 属性

```delphi
procedure TProductAdminForm.FormCreate(Sender: TObject);
begin
  inherited;

  UniModelAdmin1.Connection := FDConnection1;
  UniModelAdmin1.TableName := 'Products';
  UniModelAdmin1.PrimaryKey := 'Id';

  UniModelAdmin1.Metadata := '{
    "entity": "Product",
    "table": "Products",
    "primaryKey": "Id",
    "title": "产品管理",
    "fields": [
      {
        "name": "Id",
        "type": "integer",
        "label": "ID",
        "visible": false
      },
      {
        "name": "Name",
        "type": "string",
        "label": "产品名称",
        "required": true,
        "maxLength": 100
      },
      {
        "name": "Code",
        "type": "string",
        "label": "产品编码",
        "required": true,
        "unique": true,
        "maxLength": 50
      },
      {
        "name": "CategoryId",
        "type": "integer",
        "label": "产品分类",
        "required": true,
        "lookup": {
          "table": "Categories",
          "keyField": "Id",
          "displayField": "Name"
        }
      },
      {
        "name": "Price",
        "type": "decimal",
        "label": "价格",
        "required": true,
        "precision": 10,
        "scale": 2
      },
      {
        "name": "Stock",
        "type": "integer",
        "label": "库存",
        "required": true,
        "minValue": 0,
        "defaultValue": 0
      },
      {
        "name": "IsActive",
        "type": "boolean",
        "label": "是否启用",
        "defaultValue": true
      }
    ],
    "permissions": {
      "view": "product.view",
      "add": "product.add",
      "edit": "product.edit",
      "delete": "product.delete"
    }
  }';

  UniModelAdmin1.LoadData;
end;
```

#### 方式二: 使用元数据文件

创建 `ProductMetadata.json` 文件：

```json
{
  "entity": "Product",
  "table": "Products",
  "primaryKey": "Id",
  "title": "产品管理",
  "fields": [
    {
      "name": "Id",
      "type": "integer",
      "label": "ID",
      "visible": false
    },
    {
      "name": "Name",
      "type": "string",
      "label": "产品名称",
      "required": true,
      "maxLength": 100
    }
  ]
}
```

在表单中引用：

```delphi
procedure TProductAdminForm.FormCreate(Sender: TObject);
begin
  inherited;

  UniModelAdmin1.Connection := FDConnection1;
  UniModelAdmin1.TableName := 'Products';
  UniModelAdmin1.PrimaryKey := 'Id';
  UniModelAdmin1.MetadataFile := 'ProductMetadata.json';

  UniModelAdmin1.LoadData;
end;
```

### 4. 运行效果

运行表单后，自动生成以下界面：
- 数据网格: 显示产品列表
- 工具栏: 新增、编辑、删除、刷新、导出按钮
- 搜索面板: 支持按名称、编码搜索
- 编辑表单: 自动生成表单控件
- 分页控件: 支持分页浏览

---

## 高级功能

### 1. 主从表

#### 配置主从关系

```json
{
  "entity": "Order",
  "table": "Orders",
  "primaryKey": "Id",
  "fields": [
    {
      "name": "Id",
      "type": "integer",
      "label": "订单ID",
      "visible": false
    },
    {
      "name": "OrderNo",
      "type": "string",
      "label": "订单号",
      "required": true
    }
  ],
  "detailTables": [
    {
      "name": "OrderItems",
      "table": "OrderItems",
      "foreignKey": "OrderId",
      "fields": [
        {
          "name": "Id",
          "type": "integer",
          "label": "ID",
          "visible": false
        },
        {
          "name": "ProductId",
          "type": "integer",
          "label": "产品",
          "lookup": {
            "table": "Products",
            "keyField": "Id",
            "displayField": "Name"
          }
        },
        {
          "name": "Quantity",
          "type": "integer",
          "label": "数量",
          "required": true
        },
        {
          "name": "Price",
          "type": "decimal",
          "label": "单价",
          "required": true
        }
      ]
    }
  ]
}
```

### 2. 自定义验证

#### 添加验证规则

```json
{
  "validation": {
    "rules": [
      {
        "field": "Price",
        "rule": "min",
        "value": 0,
        "message": "价格必须大于等于0"
      },
      {
        "field": "Code",
        "rule": "pattern",
        "value": "^[A-Z]{2}\\d{4}$",
        "message": "编码格式不正确，应为2个大写字母+4位数字"
      },
      {
        "field": "Stock",
        "rule": "custom",
        "message": "库存不能为负数",
        "expression": "Stock >= 0"
      }
    ]
  }
}
```

#### 在代码中处理验证

```delphi
procedure TProductAdminForm.UniModelAdmin1ValidationError(Sender: TObject;
  FieldName, ErrorMessage: string);
begin
  ShowMessage('字段 [' + FieldName + '] 验证失败: ' + ErrorMessage);
end;
```

### 3. 自定义操作

#### 定义操作

```json
{
  "actions": [
    {
      "name": "approve",
      "label": "审核",
      "icon": "check",
      "permission": "product.approve",
      "confirm": true,
      "confirmMessage": "确定要审核通过吗？"
    },
    {
      "name": "reject",
      "label": "驳回",
      "icon": "close",
      "permission": "product.reject",
      "confirm": true,
      "confirmMessage": "确定要驳回吗？"
    },
    {
      "name": "exportReport",
      "label": "导出报表",
      "icon": "download",
      "permission": "product.export"
    }
  ]
}
```

#### 处理操作

```delphi
procedure TProductAdminForm.UniModelAdmin1CustomAction(Sender: TObject;
  ActionName: string; Params: TStrings);
var
  SelectedIds: string;
begin
  SelectedIds := Params.Values['ids'];

  if ActionName = 'approve' then
  begin
    // 审核通过
    ApproveProducts(SelectedIds);
    ShowMessage('审核成功');
    UniModelAdmin1.Refresh;
  end
  else if ActionName = 'reject' then
  begin
    // 驳回
    RejectProducts(SelectedIds);
    ShowMessage('已驳回');
    UniModelAdmin1.Refresh;
  end
  else if ActionName = 'exportReport' then
  begin
    // 导出报表
    ExportProductReport(SelectedIds);
  end;
end;
```

### 4. 数据过滤

#### 预设过滤条件

```delphi
procedure TProductAdminForm.FormCreate(Sender: TObject);
begin
  inherited;

  // 只显示启用的产品
  UniModelAdmin1.LoadData('IsActive = 1');

  // 或者使用参数
  UniModelAdmin1.LoadData('CategoryId = :CategoryId', [CategoryId]);
end;
```

#### 动态过滤

```delphi
procedure TProductAdminForm.btnSearchClick(Sender: TObject);
var
  Filter: string;
  Params: array of const;
begin
  Filter := '';
  if edtName.Text <> '' then
    Filter := Filter + ' AND Name LIKE :Name';

  if edtCode.Text <> '' then
    Filter := Filter + ' AND Code = :Code';

  Filter := Copy(Filter, 6, Length(Filter) - 5); // 去掉第一个 ' AND '

  UniModelAdmin1.LoadData(Filter, [edtName.Text + '%', edtCode.Text]);
end;
```

### 5. 数据导出

#### 导出为 Excel

```delphi
procedure TProductAdminForm.btnExportClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := 'Products_' + FormatDateTime('yyyyMMdd', Now) + '.xlsx';
  UniModelAdmin1.ExportToExcel(FileName);
  ShowMessage('导出成功: ' + FileName);
end;
```

#### 导出为 CSV

```delphi
procedure TProductAdminForm.ExportToCSV(const FileName: string);
var
  CSV: TStringList;
  Row: string;
  I: Integer;
begin
  CSV := TStringList.Create;
  try
    // 写入表头
    Row := '';
    for I := 0 to UniModelAdmin1.Grid.Columns.Count - 1 do
    begin
      if Row <> '' then Row := Row + ',';
      Row := Row + '"' + UniModelAdmin1.Grid.Columns[I].Title.Caption + '"';
    end;
    CSV.Add(Row);

    // 写入数据
    UniModelAdmin1.DataSet.First;
    while not UniModelAdmin1.DataSet.Eof do
    begin
      Row := '';
      for I := 0 to UniModelAdmin1.Grid.Columns.Count - 1 do
      begin
        if Row <> '' then Row := Row + ',';
        Row := Row + '"' + UniModelAdmin1.DataSet.Fields[I].AsString + '"';
      end;
      CSV.Add(Row);
      UniModelAdmin1.DataSet.Next;
    end;

    CSV.SaveToFile(FileName);
  finally
    CSV.Free;
  end;
end;
```

### 6. 数据导入

#### 从 Excel 导入

```delphi
procedure TProductAdminForm.btnImportClick(Sender: TObject);
var
  FileName: string;
begin
  if OpenDialog1.Execute then
  begin
    FileName := OpenDialog1.FileName;
    UniModelAdmin1.ImportFromExcel(FileName);
    ShowMessage('导入成功');
    UniModelAdmin1.Refresh;
  end;
end;
```

---

## 最佳实践

### 1. 性能优化

#### 使用分页
```json
{
  "grid": {
    "showPagination": true,
    "pageSize": 20
  }
}
```

#### 只加载必要字段
```json
{
  "fields": [
    {
      "name": "Description",
      "type": "text",
      "loadOnDemand": true  // 按需加载
    }
  ]
}
```

#### 使用索引
```sql
CREATE INDEX IX_Products_Name ON Products(Name);
CREATE INDEX IX_Products_Code ON Products(Code);
CREATE INDEX IX_Products_CategoryId ON Products(CategoryId);
```

### 2. 安全性

#### 启用权限检查
```delphi
UniModelAdmin1.CheckPermission := True;
UniModelAdmin1.PermissionPrefix := 'product';
```

#### 防止 SQL 注入
```delphi
// 使用参数化查询
UniModelAdmin1.LoadData('Name LIKE :Name', ['%keyword%']);
```

#### 验证输入
```json
{
  "fields": [
    {
      "name": "Price",
      "type": "decimal",
      "minValue": 0,
      "maxValue": 999999.99
    }
  ]
}
```

### 3. 用户体验

#### 提供友好的提示
```json
{
  "fields": [
    {
      "name": "Code",
      "label": "产品编码",
      "helpText": "格式：为2个大写字母+4位数字，如：AB1234",
      "placeholder": "请输入产品编码"
    }
  ]
}
```

#### 使用查找字段
```json
{
  "name": "CategoryId",
  "type": "integer",
  "label": "产品分类",
  "lookup": {
    "table": "Categories",
    "keyField": "Id",
    "displayField": "Name",
    "orderBy": "Name"
  }
}
```

#### 启用确认对话框
```json
{
  "form": {
    "showConfirmOnSave": true,
    "showConfirmOnDelete": true
  }
}
```

### 4. 代码组织

#### 分离元数据
```
Modules/
└── Product/
    ├── FM/
    │   ├── ProductAdminFM.pas
    │   └── ProductMetadata.json  // 元数据文件
    └── ...
```

#### 使用基类
```delphi
TBaseAdminForm = class(TAppForm)
  UniModelAdmin1: TUniAdminModel;
protected
  procedure InitializeModelAdmin; virtual;
end;

TProductAdminForm = class(TBaseAdminForm)
protected
  procedure InitializeModelAdmin; override;
end;
```

---

## 示例代码

### 1. 完整的产品管理表单

```delphi
unit ProductAdminFM;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniGUIClasses, uniModelAdmin, uniButton, uniEdit,
  uniPanel, uniLabel, FireDAC.Comp.Client, App.Core.Form;

type
  TProductAdminForm = class(TAppForm)
    UniModelAdmin1: TUniAdminModel;
    FDConnection1: TFDConnection;
    pnlSearch: TUniPanel;
    edtName: TUniEdit;
    edtCode: TUniEdit;
    btnSearch: TUniButton;
    btnReset: TUniButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure UniModelAdmin1BeforeInsert(Sender: TObject; DataSet: TDataSet);
    procedure UniModelAdmin1BeforeUpdate(Sender: TObject; DataSet: TDataSet);
    procedure UniModelAdmin1CustomAction(Sender: TObject; ActionName: string;
      Params: TStrings);
  private
    { Private declarations }
    procedure LoadMetadata;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TProductAdminForm.FormCreate(Sender: TObject);
begin
  inherited;

  // 初始化数据库连接
  FDConnection1.DriverName := 'MSSQL';
  FDConnection1.Params.Values['Server'] := 'localhost';
  FDConnection1.Params.Values['Database'] := 'UniAdminDB';
  FDConnection1.Params.Values['User_Name'] := 'sa';
  FDConnection1.Params.Values['Password'] := 'password';
  FDConnection1.Connected := True;

  // 配置 ModelAdmin
  UniModelAdmin1.Connection := FDConnection1;
  UniModelAdmin1.TableName := 'Products';
  UniModelAdmin1.PrimaryKey := 'Id';
  UniModelAdmin1.CheckPermission := True;
  UniModelAdmin1.PermissionPrefix := 'product';

  // 加载元数据
  LoadMetadata;

  // 加载数据
  UniModelAdmin1.LoadData;
end;

procedure TProductAdminForm.LoadMetadata;
begin
  UniModelAdmin1.Metadata := '{
    "entity": "Product",
    "table": "Products",
    "primaryKey": "Id",
    "title": "产品管理",
    "fields": [
      {
        "name": "Id",
        "type": "integer",
        "label": "ID",
        "visible": false
      },
      {
        "name": "Name",
        "type": "string",
        "label": "产品名称",
        "required": true,
        "maxLength": 100,
        "searchable": true
      },
      {
        "name": "Code",
        "type": "string",
        "label": "产品编码",
        "required": true,
        "unique": true,
        "maxLength": 50,
        "searchable": true
      },
      {
        "name": "CategoryId",
        "type": "integer",
        "label": "产品分类",
        "required": true,
        "lookup": {
          "table": "Categories",
          "keyField": "Id",
          "displayField": "Name"
        }
      },
      {
        "name": "Price",
        "type": "decimal",
        "label": "价格",
        "required": true,
        "precision": 10,
        "scale": 2,
        "minValue": 0
      },
      {
        "name": "Stock",
        "type": "integer",
        "label": "库存",
        "required": true,
        "minValue": 0,
        "defaultValue": 0
      },
      {
        "name": "Description",
        "type": "text",
        "label": "产品描述",
        "gridVisible": false
      },
      {
        "name": "IsActive",
        "type": "boolean",
        "label": "是否启用",
        "defaultValue": true
      }
    ],
    "searchFields": ["Name", "Code"],
    "permissions": {
      "view": "product.view",
      "add": "product.add",
      "edit": "product.edit",
      "delete": "product.delete"
    },
    "actions": [
      {
        "name": "approve",
        "label": "审核",
        "icon": "check",
        "permission": "product.approve"
      },
      {
        "name": "reject",
        "label": "驳回",
        "icon": "close",
        "permission": "product.reject"
      }
    ]
  }';
end;

procedure TProductAdminForm.btnSearchClick(Sender: TObject);
var
  Filter: string;
  Params: array of const;
begin
  Filter := '';

  if edtName.Text <> '' then
    Filter := Filter + ' AND Name LIKE :Name';

  if edtCode.Text <> '' then
    Filter := Filter + ' AND Code = :Code';

  if Filter <> '' then
    Filter := CopyCopy(Filter, 6, Length(Filter) - 5);

  UniModelAdmin1.LoadData(Filter, [edtName.Text + '%', edtCode.Text]);
end;

procedure TProductAdminForm.btnResetClick(Sender: TObject);
begin
  edtName.Clear;
  edtCode.Clear;
  UniModelAdmin1.LoadData;
end;

procedure TProductAdminForm.UniModelAdmin1BeforeInsert(Sender: TObject;
  DataSet: TDataSet);
begin
  DataSet.FieldByName('CreatedDate').AsDateTime := Now;
  DataSet.FieldByName('IsActive').AsBoolean := True;
end;

procedure TProductAdminForm.UniModelAdmin1BeforeUpdate(Sender: TObject;
  DataSet: TDataSet);
begin
  DataSet.FieldByName('UpdatedDate').AsDateTime := Now;
end;

procedure TProductAdminForm.UniModelAdmin1CustomAction(Sender: TObject;
  ActionName: string; Params: TStrings);
begin
  if ActionName = 'approve' then
  begin
    ShowMessage('审核通过');
    UniModelAdmin1.Refresh;
  end
  else if ActionName = 'reject' then
  begin
    ShowMessage('已驳回');
    UniModelAdmin1.Refresh;
  end;
end;

initialization
  RegisterClass(TProductAdminForm);

end.
```

---

## 常见问题

### Q1: 如何自定义网格列的显示格式？

**A**: 使用 `gridFormat` 属性：

```json
{
  "name": "Price",
  "type": "decimal",
  "label": "价格",
  "gridFormat": "¥#,##0.00"
}
```

### Q2: 如何实现级联选择？

**A**: 在 `BeforeInsert` 事件中处理：

```delphi
procedure TProductAdminForm.UniModelAdmin1BeforeInsert(Sender: TObject;
  DataSet: TDataSet);
begin
  // 根据分类ID设置默认值
  if DataSet.FieldByName('CategoryId').AsInteger = 1 then
    DataSet.FieldByName('Price').AsFloat := 100.0;
end;
```

### Q3: 如何实现批量操作？

**A**: 使用自定义操作，处理选中的记录：

```delphi
procedure TProductAdminForm.UniModelAdmin1CustomAction(Sender: TObject;
  ActionName: string; Params: TStrings);
var
  Ids: string;
  IdList: TStringList;
  I: Integer;
begin
  Ids := Params.Values['ids'];
  IdList := TStringList.Create;
  try
    IdList.Delimiter := ',';
    IdList.DelimitedText := Ids;

    for I := 0 to IdList.Count - 1 do
    begin
      // 处理每个ID
      ProcessProduct(StrToInt(IdList[I]));
    end;
  finally
    IdList.Free;
  end;
end;
```

---

## 总结

CRUD 框架通过 `TUniAdminModel` 组件和元数据配置，实现了零代码的增删改查功能。开发者只需关注业务逻辑，框架自动处理界面生成、数据验证、权限控制等通用功能，大大提高了开发效率。

---

**文档版本**: 1.0
**最后更新**: 2024-01-01
**维护者**: UniAdmin 开发团队
