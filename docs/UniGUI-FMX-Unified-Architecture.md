# UniGUI 和 FMX 统一开发架构方案

> **版本**: 1.0
> **创建日期**: 2026-03-09
> **目标**: 减少 UniGUI (Web) 和 FMX (桌面) 开发框架的代码重复，提高开发效率

---

## 📋 目录

- [架构概述](#架构概述)
- [方案一：三层架构 + 共享业务层](#方案一三层架构--共享业务层)
- [方案二：抽象 UI 组件层](#方案二抽象-ui-组件层)
- [方案三：代码生成器](#方案三代码生成器)
- [最佳实践](#最佳实践)
- [实施建议](#实施建议)

---

## 架构概述

### 核心思路

```
┌─────────────────────────────────────────────────┐
│          共享业务逻辑层 (Business Layer)        │
│  - 数据模型 (Models)                          │
│  - 业务规则 (Business Rules)                   │
│  - 数据访问 (Data Access)                     │
│  - 服务接口 (Service Interfaces)               │
└─────────────────────────────────────────────────┘
           ↓                    ↓
    ┌─────────┐        ┌─────────┐
    │ UniGUI  │        │  FMX    │
    │  (Web)  │        │(Desktop)│
    └─────────┘        └─────────┘
```

### 项目结构设计

```
UniAdmin-Solution/
├── Shared/                    # 共享层
│   ├── Core/                 # 核心业务逻辑
│   │   ├── Models/           # 数据模型
│   │   ├── Services/          # 业务服务
│   │   ├── Data/             # 数据访问
│   │   └── Utils/            # 工具类
│   └── Interfaces/           # 接口定义
├── UniGUI/                  # UniGUI Web 项目
│   ├── Forms/                # Web 表单
│   └── Modules/              # UniGUI 模块
├── FMX/                    # FMX 桌面项目
│   ├── Forms/                # 桌面表单
│   └── Main.pas
└── Tests/                   # 单元测试
```

---

## 方案一：三层架构 + 共享业务层

### 1. 共享数据模型

```pascal
// Shared/Core/Models/User.pas
unit User;

interface

uses
  System.SysUtils, System.Classes;

type
  TUser = class
  private
    FID: Integer;
    FUserName: string;
    FEmail: string;
    FPassword: string;
    FRoleID: Integer;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    property ID: Integer read FID write FID;
    property UserName: string read FUserName write FUserName;
    property Email: string read FEmail write FEmail;
    property Password: string read FPassword write FPassword;
    property RoleID: Integer read FRoleID write FRoleID;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  
    function ToString: string; override;
    function Validate: Boolean;
  end;

implementation

function TUser.ToString: string;
begin
  Result := Format('%s (%s)', [FUserName, FEmail]);
end;

function TUser.Validate: Boolean;
begin
  Result := (FUserName <> '') and (FEmail <> '');
end;

end.
```

### 2. 共享服务接口

```pascal
// Shared/Core/Services/IUserService.pas
unit IUserService;

interface

uses
  User;

type
  IUserService = interface(IInterface)
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
  
    function GetUserByID(ID: Integer): TUser;
    function GetAllUsers: TArray<TUser>;
    function CreateUser(const User: TUser): Boolean;
    function UpdateUser(const User: TUser): Boolean;
    function DeleteUser(ID: Integer): Boolean;
    function SearchUsers(const Keyword: string): TArray<TUser>;
  end;

implementation

end.
```

### 3. 共享服务实现

```pascal
// Shared/Core/Services/UserService.pas
unit UserService;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Def,
  IUserService, User, DataRepository;

type
  TUserService = class(TInterfacedObject, IUserService)
  private
    FRepository: IDataRepository;
  public
    constructor Create(const Repository: IDataRepository);
    destructor Destroy; override;
  
    function GetUserByID(ID: Integer): TUser;
    function GetAllUsers: TArray<TUser>;
    function CreateUser(const User: TUser): Boolean;
    function UpdateUser(const User: TUser): Boolean;
    function DeleteUser(ID: Integer): Boolean;
    function SearchUsers(const Keyword: string): TArray<TUser>;
  end;

implementation

constructor TUserService.Create(const Repository: IDataRepository);
begin
  inherited Create;
  FRepository := Repository;
end;

destructor TUserService.Destroy;
begin
  FRepository := nil;
  inherited;
end;

function TUserService.GetUserByID(ID: Integer): TUser;
var
  Query: TFDQuery;
begin
  Query := FRepository.CreateQuery;
  try
    Query.SQL.Text := 'SELECT * FROM Users WHERE ID = :ID';
    Query.ParamByName('ID').AsInteger := ID;
    Query.Open;
  
    if not Query.Eof then
    begin
      Result := TUser.Create;
      Result.ID := Query.FieldByName('ID').AsInteger;
      Result.UserName := Query.FieldByName('UserName').AsString;
      Result.Email := Query.FieldByName('Email').AsString;
      Result.RoleID := Query.FieldByName('RoleID').AsInteger;
      Result.CreatedAt := Query.FieldByName('CreatedAt').AsDateTime;
      Result.UpdatedAt := Query.FieldByName('UpdatedAt').AsDateTime;
    end
    else
      Result := nil;
  finally
    Query.Free;
  end;
end;

function TUserService.GetAllUsers: TArray<TUser>;
var
  Query: TFDQuery;
  List: TList<TUser>;
begin
  Query := FRepository.CreateQuery;
  List := TList<TUser>.Create;
  try
    Query.SQL.Text := 'SELECT * FROM Users ORDER BY CreatedAt DESC';
    Query.Open;
  
    while not Query.Eof do
    begin
      var User := TUser.Create;
      User.ID := Query.FieldByName('ID').AsInteger;
      User.UserName := Query.FieldByName('UserName').AsString;
      User.Email := Query.FieldByName('Email').AsString;
      User.RoleID := Query.FieldByName('RoleID').AsInteger;
      User.CreatedAt := Query.FieldByName('CreatedAt').AsDateTime;
      User.UpdatedAt := Query.FieldByName('UpdatedAt').AsDateTime;
    
      List.Add(User);
      Query.Next;
    end;
  
    Result := List.ToArray;
  finally
    List.Free;
    Query.Free;
  end;
end;

function TUserService.CreateUser(const User: TUser): Boolean;
var
  Query: TFDQuery;
begin
  Query := FRepository.CreateQuery;
  try
    Query.SQL.Text := 
      'INSERT INTO Users (UserName, Email, Password, RoleID, CreatedAt, UpdatedAt) ' +
      'VALUES (:UserName, :Email, :Password, :RoleID, :CreatedAt, :UpdatedAt)';
    Query.ParamByName('UserName').AsString := User.UserName;
    Query.ParamByName('Email').AsString := User.Email;
    Query.ParamByName('Password').AsString := User.Password;
    Query.ParamByName('RoleID').AsInteger := User.RoleID;
    Query.ParamByName('CreatedAt').AsDateTime := Now;
    Query.ParamByName('UpdatedAt').AsDateTime := Now;
  
    Result := Query.ExecSQL > 0;
  finally
    Query.Free;
  end;
end;

function TUserService.UpdateUser(const User: TUser): Boolean;
var
  Query: TFDQuery;
begin
  Query := FRepository.CreateQuery;
  try
    Query.SQL.Text := 
      'UPDATE Users SET UserName = :UserName, Email = :Email, ' +
      'RoleID = :RoleID, UpdatedAt = :UpdatedAt WHERE ID = :ID';
    Query.ParamByName('UserName').AsString := User.UserName;
    Query.ParamByName('Email').AsString := User.Email;
    Query.ParamByName('RoleID').AsInteger := User.RoleID;
    Query.ParamByName('UpdatedAt').AsDateTime := Now;
    Query.ParamByName('ID').AsInteger := User.ID;
  
    Result := Query.ExecSQL > 0;
  finally
    Query.Free;
  end;
end;

function TUserService.DeleteUser(ID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := FRepository.CreateQuery;
  try
    Query.SQL.Text := 'DELETE FROM Users WHERE ID = :ID';
    Query.ParamByName('ID').AsInteger := ID;
  
    Result := Query.ExecSQL > 0;
  finally
    Query.Free;
  end;
end;

function TUserService.SearchUsers(const Keyword: string): TArray<TUser>;
var
  Query: TFDQuery;
  List: TList<TUser>;
begin
  Query := FRepository.CreateQuery;
  List := TList<TUser>.Create;
  try
    Query.SQL.Text := 
      'SELECT * FROM Users WHERE UserName LIKE :Keyword OR Email LIKE :Keyword ' +
      'ORDER BY CreatedAt DESC';
    Query.ParamByName('Keyword').AsString := '%' + Keyword + '%';
    Query.Open;
  
    while not Query.Eof do
    begin
      var User := TUser.Create;
      User.ID := Query.FieldByName('ID').AsInteger;
      User.UserName := Query.FieldByName('UserName').AsString;
      User.Email := Query.FieldByName('Email').AsString;
      User.RoleID := Query.FieldByName('RoleID').AsInteger;
      User.CreatedAt := Query.FieldByName('CreatedAt').AsDateTime;
      User.UpdatedAt := Query.FieldByName('UpdatedAt').AsDateTime;
    
      List.Add(User);
      Query.Next;
    end;
  
    Result := List.ToArray;
  finally
    List.Free;
    Query.Free;
  end;
end;

end.
```

### 4. UniGUI 表单使用共享服务

```pascal
// UniGUI/Forms/UserListFrame.pas
unit UserListFrame;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniGUIClasses, uniPanel, uniBasicGrid, uniDBGrid,
  uniEdit, uniButton, uniLabel, uniGUIForm,
  Shared.Core.Services.IUserService, Shared.Core.Models.User,
  Data.DB, FireDAC.Comp.Client;

type
  TUserListFrame = class(TUniForm)
    UniDBGrid1: TUniDBGrid;
    UniEditSearch: TUniEdit;
    UniButtonSearch: TUniButton;
    UniButtonAdd: TUniButton;
    UniButtonEdit: TUniButton;
    UniButtonDelete: TUniButton;
    DataSource1: TDataSource;
    FDQuery1: TFDQuery;
    procedure UniFormCreate(Sender: TObject);
    procedure UniButtonSearchClick(Sender: TObject);
    procedure UniButtonAddClick(Sender: TObject);
    procedure UniButtonEditClick(Sender: TObject);
    procedure UniButtonDeleteClick(Sender: TObject);
  private
    FUserService: IUserService;
    procedure LoadUsers;
    procedure LoadUser(const User: TUser);
  public
  end;

implementation

{$R *.dfm}

uses
  Shared.Core.Services.UserService, Shared.Core.Data.DataRepository;

procedure TUserListFrame.UniFormCreate(Sender: TObject);
begin
  FUserService := TUserService.Create(TDataRepository.Create);
  LoadUsers;
end;

procedure TUserListFrame.LoadUsers;
var
  Users: TArray<TUser>;
  i: Integer;
begin
  Users := FUserService.GetAllUsers;
  
  FDQuery1.Close;
  FDQuery1.CreateDataSet;
  FDQuery1.FieldDefs.Clear;
  FDQuery1.FieldDefs.Add('ID', ftInteger);
  FDQuery1.FieldDefs.Add('UserName', ftString, 50);
  FDQuery1.FieldDefs.Add('Email', ftString, 100);
  FDQuery1.FieldDefs.Add('RoleID', ftInteger);
  FDQuery1.Open;
  
  for i := 0 to High(Users) do
  begin
    FDQuery1.Append;
    FDQuery1.FieldByName('ID').AsInteger := Users[i].ID;
    FDQuery1.FieldByName('UserName').AsString := Users[i].UserName;
    FDQuery1.FieldByName('Email').AsString := Users[i].Email;
    FDQuery1.FieldByName('RoleID').AsInteger := Users[i].RoleID;
    FDQuery1.Post;
  end;
end;

procedure TUserListFrame.UniButtonSearchClick(Sender: TObject);
var
  Users: TArray<TUser>;
  i: Integer;
begin
  if UniEditSearch.Text <> '' then
  begin
    Users := FUserService.SearchUsers(UniEditSearch.Text);
  
    FDQuery1.Close;
    FDQuery1.CreateDataSet;
    FDQuery1.Open;
  
    for i := 0 to High(Users) do
    begin
      FDQuery1.Append;
      FDQuery1.FieldByName('ID').AsInteger := Users[i].ID;
      FDQuery1.FieldByName('UserName').AsString := Users[i].UserName;
      FDQuery1.FieldByName('Email').AsString := Users[i].Email;
      FDQuery1.Post;
    end;
  end
  else
    LoadUsers;
end;

procedure TUserListFrame.UniButtonAddClick(Sender: TObject);
begin
  ShowMessage('Add User');
end;

procedure TUserListFrame.UniButtonEditClick(Sender: TObject);
begin
  ShowMessage('Edit User');
end;

procedure TUserListFrame.UniButtonDeleteClick(Sender: TObject);
begin
  if FDQuery1.RecordCount > 0 then
  begin
    if FUserService.DeleteUser(FDQuery1.FieldByName('ID').AsInteger) then
    begin
      ShowMessage('删除成功');
      LoadUsers;
    end
    else
      ShowMessage('删除失败');
  end;
end;

procedure TUserListFrame.LoadUser(const User: TUser);
begin
end;

end.
```

### 5. FMX 表单使用共享服务

```pascal
// FMX/Forms/UserListForm.pas
unit UserListForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,
  FMX.Edit, FMX.Grid, FMX.Controls.Presentation,
  Shared.Core.Services.IUserService, Shared.Core.Models.User,
  Data.DB, FireDAC.Comp.Client;

type
  TUserListForm = class(TForm)
    StringGrid1: TStringGrid;
    EditSearch: TEdit;
    ButtonSearch: TButton;
    ButtonAdd: TButton;
    ButtonEdit: TButton;
    ButtonDelete: TButton;
    DataSource1: TDataSource;
    FDQuery1: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSearchClick(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonEditClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
  private
    FUserService: IUserService;
    procedure LoadUsers;
  public
  end;

implementation

{$R *.fmx}

uses
  Shared.Core.Services.UserService, Shared.Core.Data.DataRepository;

procedure TUserListForm.FormCreate(Sender: TObject);
begin
  FUserService := TUserService.Create(TDataRepository.Create);
  LoadUsers;
end;

procedure TUserListForm.LoadUsers;
var
  Users: TArray<TUser>;
  i: Integer;
begin
  Users := FUserService.GetAllUsers;
  
  StringGrid1.RowCount := Length(Users) + 1;
  StringGrid1.Cells[0, 0] := 'ID';
  StringGrid1.Cells[1, 0] := '用户名';
  StringGrid1.Cells[2, 0] := '邮箱';
  
  for i := 0 to High(Users) do
  begin
    StringGrid1.Cells[0, i + 1] := IntToStr(Users[i].ID);
    StringGrid1.Cells[1, i + 1] := Users[i].UserName;
    StringGrid1.Cells[2, i + 1] := Users[i].Email;
  end;
end;

procedure TUserListForm.ButtonSearchClick(Sender: TObject);
var
  Users: TArray<TUser>;
  i: Integer;
begin
  if EditSearch.Text <> '' then
  begin
    Users := FUserService.SearchUsers(EditSearch.Text);
  
    StringGrid1.RowCount := Length(Users) + 1;
  
    for i := 0 to High(Users) do
    begin
      StringGrid1.Cells[0, i + 1] := IntToStr(Users[i].ID);
      StringGrid1.Cells[1, i + 1] := Users[i].UserName;
      StringGrid1.Cells[2, i + 1] := Users[i].Email;
    end;
  end
  else
    LoadUsers;
end;

procedure TUserListForm.ButtonAddClick(Sender: TObject);
begin
  ShowMessage('Add User');
end;

procedure TUserListForm.ButtonEditClick(Sender: TObject);
begin
  ShowMessage('Edit User');
end;

procedure TUserListForm.ButtonDeleteClick(Sender: TObject);
begin
  if StringGrid1.Row > 0 then
  begin
    var ID := StrToInt(StringGrid1.Cells[0, StringGrid1.Row]);
    if FUserService.DeleteUser(ID) then
    begin
      ShowMessage('删除成功');
      LoadUsers;
    end
    else
      ShowMessage('删除失败');
  end;
end;

end.
```

---

## 方案二：抽象 UI 组件层

### 1. 创建抽象 UI 接口

```pascal
// Shared/Interfaces/IModelAdmin.pas
unit IModelAdmin;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TFieldConfig = record
    FieldName: string;
    DisplayName: string;
    FieldType: string;
    Visible: Boolean;
    Editable: Boolean;
  end;
  
  IModelAdmin = interface(IInterface)
    ['{B2C3D4E5-F6A7-8901-BCDE-F23456789012}']
  
    procedure Initialize;
    procedure LoadData;
    procedure SaveData;
    procedure DeleteData;
    procedure Refresh;
  
    function GetFieldConfigs: TArray<TFieldConfig>;
    function GetListData: TArray<TDictionary<string, Variant>>;
    function GetFormData: TDictionary<string, Variant>;
  end;

implementation

end.
```

### 2. 创建基础 ModelAdmin 实现

```pascal
// Shared/Core/BaseModelAdmin.pas
unit BaseModelAdmin;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Variants,
  Shared.Interfaces.IModelAdmin;

type
  TBaseModelAdmin = class(TInterfacedObject, IModelAdmin)
  private
    FTableName: string;
    FPrimaryKey: string;
    FFieldConfigs: TArray<TFieldConfig>;
  protected
    function GetTableName: string; virtual;
    function GetPrimaryKey: string; virtual;
    function GetFieldConfigs: TArray<TFieldConfig>; virtual;
  public
    constructor Create(const ATableName, APrimaryKey: string);
  
    procedure Initialize; virtual;
    procedure LoadData; virtual;
    procedure SaveData; virtual;
    procedure DeleteData; virtual;
    procedure Refresh; virtual;
  
    function GetListData: TArray<TDictionary<string, Variant>>; virtual;
    function GetFormData: TDictionary<string, Variant>; virtual;
  end;

implementation

constructor TBaseModelAdmin.Create(const ATableName, APrimaryKey: string);
begin
  inherited Create;
  FTableName := ATableName;
  FPrimaryKey := APrimaryKey;
end;

function TBaseModelAdmin.GetTableName: string;
begin
  Result := FTableName;
end;

function TBaseModelAdmin.GetPrimaryKey: string;
begin
  Result := FPrimaryKey;
end;

function TBaseModelAdmin.GetFieldConfigs: TArray<TFieldConfig>;
begin
  Result := FFieldConfigs;
end;

procedure TBaseModelAdmin.Initialize;
begin
end;

procedure TBaseModelAdmin.LoadData;
begin
end;

procedure TBaseModelAdmin.SaveData;
begin
end;

procedure TBaseModelAdmin.DeleteData;
begin
end;

procedure TBaseModelAdmin.Refresh;
begin
  LoadData;
end;

function TBaseModelAdmin.GetListData: TArray<TDictionary<string, Variant>>;
begin
  Result := nil;
end;

function TBaseModelAdmin.GetFormData: TDictionary<string, Variant>;
begin
  Result := TDictionary<string, Variant>.Create;
end;

end.
```

### 3. UniGUI 适配器

```pascal
// UniGUI/Core/UniModelAdminAdapter.pas
unit UniModelAdminAdapter;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Variants,
  Vcl.Controls, Vcl.Forms,
  uniGUIBaseClasses, uniGUIClasses, uniPanel, uniBasicGrid, uniDBGrid,
  uniEdit, uniButton, uniLabel, uniGUIForm,
  Shared.Interfaces.IModelAdmin, Shared.Core.BaseModelAdmin,
  Data.DB, FireDAC.Comp.Client;

type
  TUniModelAdminAdapter = class(TComponent)
  private
    FModelAdmin: IModelAdmin;
    FGrid: TUniDBGrid;
    FDataSource: TDataSource;
    FQuery: TFDQuery;
    procedure SetupGrid;
    procedure LoadDataToGrid;
  public
    constructor Create(AOwner: TComponent; const AModelAdmin: IModelAdmin); reintroduce;
    destructor Destroy; override;
  
    procedure Initialize;
    procedure Refresh;
    procedure EditRecord;
    procedure DeleteRecord;
  end;

implementation

constructor TUniModelAdminAdapter.Create(AOwner: TComponent; const AModelAdmin: IModelAdmin);
begin
  inherited Create(AOwner);
  FModelAdmin := AModelAdmin;
  FQuery := TFDQuery.Create(nil);
  FDataSource := TDataSource.Create(nil);
  FDataSource.DataSet := FQuery;
end;

destructor TUniModelAdminAdapter.Destroy;
begin
  FQuery.Free;
  FDataSource.Free;
  inherited;
end;

procedure TUniModelAdminAdapter.SetupGrid;
var
  FieldConfigs: TArray<TFieldConfig>;
  Config: TFieldConfig;
begin
  FieldConfigs := FModelAdmin.GetFieldConfigs;
  
  for Config in FieldConfigs do
  begin
    if Config.Visible then
    begin
    end;
  end;
end;

procedure TUniModelAdminAdapter.LoadDataToGrid;
var
  Data: TArray<TDictionary<string, Variant>>;
  i, j: Integer;
  Keys: TArray<string>;
begin
  Data := FModelAdmin.GetListData;
  
  FQuery.Close;
  FQuery.CreateDataSet;
  
  if Length(Data) > 0 then
  begin
    Keys := Data[0].Keys.ToArray;
  
    for i := 0 to High(Keys) do
    begin
      FQuery.FieldDefs.Add(Keys[i], ftVariant);
    end;
  
    FQuery.Open;
  
    for i := 0 to High(Data) do
    begin
      FQuery.Append;
      for j := 0 to High(Keys) do
      begin
        FQuery.FieldByName(Keys[j]).Value := Data[i][Keys[j]];
      end;
      FQuery.Post;
    end;
  end;
end;

procedure TUniModelAdminAdapter.Initialize;
begin
  FModelAdmin.Initialize;
  SetupGrid;
  LoadDataToGrid;
end;

procedure TUniModelAdminAdapter.Refresh;
begin
  FModelAdmin.Refresh;
  LoadDataToGrid;
end;

procedure TUniModelAdminAdapter.EditRecord;
begin
end;

procedure TUniModelAdminAdapter.DeleteRecord;
begin
  FModelAdmin.DeleteData;
  Refresh;
end;

end.
```

### 4. FMX 适配器

```pascal
// FMX/Core/FMXModelAdminAdapter.pas
unit FMXModelAdminAdapter;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Variants,
  FMX.Types, FMX.Controls, FMX.StdCtrls, FMX.Grid,
  Shared.Interfaces.IModelAdmin, Shared.Core.BaseModelAdmin;

type
  TFMXModelAdminAdapter = class(TComponent)
  private
    FModelAdmin: IModelAdmin;
    FGrid: TStringGrid;
    procedure SetupGrid;
    procedure LoadDataToGrid;
  public
    constructor Create(AOwner: TComponent; const AModelAdmin: IModelAdmin); reintroduce;
    destructor Destroy; override;
  
    procedure Initialize;
    procedure Refresh;
    procedure EditRecord;
    procedure DeleteRecord;
  end;

implementation

constructor TFMXModelAdminAdapter.Create(AOwner: TComponent; const AModelAdmin: IModelAdmin);
begin
  inherited Create(AOwner);
  FModelAdmin := AModelAdmin;
end;

destructor TFMXModelAdminAdapter.Destroy;
begin
  inherited;
end;

procedure TFMXModelAdminAdapter.SetupGrid;
var
  FieldConfigs: TArray<TFieldConfig>;
  Config: TFieldConfig;
  i: Integer;
begin
  FieldConfigs := FModelAdmin.GetFieldConfigs;
  
  FGrid.RowCount := 1;
  FGrid.ColumnCount := Length(FieldConfigs);
  
  for i := 0 to High(FieldConfigs) do
  begin
    if FieldConfigs[i].Visible then
    begin
      FGrid.Cells[i, 0] := FieldConfigs[i].DisplayName;
    end;
  end;
end;

procedure TFMXModelAdminAdapter.LoadDataToGrid;
var
  Data: TArray<TDictionary<string, Variant>>;
  i, j: Integer;
  Keys: TArray<string>;
begin
  Data := FModelAdmin.GetListData;
  
  if Length(Data) > 0 then
  begin
    Keys := Data[0].Keys.ToArray;
    FGrid.RowCount := Length(Data) + 1;
  
    for i := 0 to High(Data) do
    begin
      for j := 0 to High(Keys) do
      begin
        FGrid.Cells[j, i + 1] := VarToStr(Data[i][Keys[j]]);
      end;
    end;
  end;
end;

procedure TFMXModelAdminAdapter.Initialize;
begin
  FModelAdmin.Initialize;
  SetupGrid;
  LoadDataToGrid;
end;

procedure TFMXModelAdminAdapter.Refresh;
begin
  FModelAdmin.Refresh;
  LoadDataToGrid;
end;

procedure TFMXModelAdminAdapter.EditRecord;
begin
end;

procedure TFMXModelAdminAdapter.DeleteRecord;
begin
  FModelAdmin.DeleteData;
  Refresh;
end;

end.
```

---

## 方案三：代码生成器

### 1. 元数据驱动的代码生成

```pascal
// Shared/Core/Metadata/ModelMetadata.pas
unit ModelMetadata;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TFieldMetadata = class
  private
    FName: string;
    FDisplayName: string;
    FDataType: string;
    FLength: Integer;
    FRequired: Boolean;
    FVisible: Boolean;
    FEditable: Boolean;
  public
    property Name: string read FName write FName;
    property DisplayName: string read FDisplayName write FDisplayName;
    property DataType: string read FDataType write FDataType;
    property Length: Integer read FLength write FLength;
    property Required: Boolean read FRequired write FRequired;
    property Visible: Boolean read FVisible write FVisible;
    property Editable: Boolean read FEditable write FEditable;
  end;
  
  TModelMetadata = class
  private
    FTableName: string;
    FPrimaryKey: string;
    FFields: TList<TFieldMetadata>;
  public
    constructor Create;
    destructor Destroy; override;
  
    property TableName: string read FTableName write FTableName;
    property PrimaryKey: string read FPrimaryKey write FPrimaryKey;
    property Fields: TList<TFieldMetadata> read FFields;
  
    function AddField(const Name, DisplayName, DataType: string): TFieldMetadata;
  end;

implementation

constructor TModelMetadata.Create;
begin
  inherited;
  FFields := TList<TFieldMetadata>.Create;
end;

destructor TModelMetadata.Destroy;
var
  Field: TFieldMetadata;
begin
  for Field in FFields do
    Field.Free;
  FFields.Free;
  inherited;
end;

function TModelMetadata.AddField(const Name, DisplayName, DataType: string): TFieldMetadata;
begin
  Result := TFieldMetadata.Create;
  Result.Name := Name;
  Result.DisplayName := DisplayName;
  Result.DataType := DataType;
  Result.Visible := True;
  Result.Editable := True;
  FFields.Add(Result);
end;

end.
```

### 2. 代码生成器

```pascal
// Shared/Tools/CodeGenerator.pas
unit CodeGenerator;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  Shared.Core.Metadata.ModelMetadata;

type
  TCodeGenerator = class
  public
    class procedure GenerateModel(const Metadata: TModelMetadata; const OutputPath: string);
    class procedure GenerateService(const Metadata: TModelMetadata; const OutputPath: string);
    class procedure GenerateUniGUIForm(const Metadata: TModelMetadata; const OutputPath: string);
    class procedure GenerateFMXForm(const Metadata: TModelMetadata; const OutputPath: string);
  end;

implementation

class procedure TCodeGenerator.GenerateModel(const Metadata: TModelMetadata; const OutputPath: string);
var
  Builder: TStringBuilder;
  Field: TFieldMetadata;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('unit ' + Metadata.TableName + ';');
    Builder.AppendLine;
    Builder.AppendLine('interface');
    Builder.AppendLine;
    Builder.AppendLine('uses');
    Builder.AppendLine('  System.SysUtils, System.Classes;');
    Builder.AppendLine;
    Builder.AppendLine('type');
    Builder.AppendLine('  T' + Metadata.TableName + ' = class');
    Builder.AppendLine('  private');
  
    for Field in Metadata.Fields do
    begin
      Builder.AppendLine('    F' + Field.Name + ': ' + Field.DataType + ';');
    end;
  
    Builder.AppendLine('  public');
  
    for Field in Metadata.Fields do
    begin
      Builder.AppendLine('    property ' + Field.Name + ': ' + Field.DataType + 
                     ' read F' + Field.Name + ' write F' + Field.Name + ';');
    end;
  
    Builder.AppendLine('  end;');
    Builder.AppendLine;
    Builder.AppendLine('implementation');
    Builder.AppendLine;
    Builder.AppendLine('end.');
  
    TFile.WriteAllText(OutputPath + Metadata.TableName + '.pas', Builder.ToString);
  finally
    Builder.Free;
  end;
end;

class procedure TCodeGenerator.GenerateService(const Metadata: TModelMetadata; const OutputPath: string);
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('unit ' + Metadata.TableName + 'Service;');
    Builder.AppendLine;
    Builder.AppendLine('interface');
    Builder.AppendLine;
    Builder.AppendLine('uses');
    Builder.AppendLine('  System.SysUtils, System.Classes, System.Generics.Collections,');
    Builder.AppendLine('  Data.DB, FireDAC.Comp.Client,');
    Builder.AppendLine('  Shared.Core.Models.' + Metadata.TableName + ',');
    Builder.AppendLine('  Shared.Core.Data.DataRepository;');
    Builder.AppendLine;
    Builder.AppendLine('type');
    Builder.AppendLine('  T' + Metadata.TableName + 'Service = class');
    Builder.AppendLine('  public');
    Builder.AppendLine('    function GetAll: TArray<T' + Metadata.TableName + '>;');
    Builder.AppendLine('    function GetByID(ID: Integer): T' + Metadata.TableName + ';');
    Builder.AppendLine('    function Create(const Item: T' + Metadata.TableName + '): Boolean;');
    Builder.AppendLine('    function Update(const Item: T' + Metadata.TableName + '): Boolean;');
    Builder.AppendLine('    function Delete(ID: Integer): Boolean;');
    Builder.AppendLine('  end;');
    Builder.AppendLine;
    Builder.AppendLine('implementation');
    Builder.AppendLine;
    Builder.AppendLine('// 实现代码...');
    Builder.AppendLine;
    Builder.AppendLine('end.');
  
    TFile.WriteAllText(OutputPath + Metadata.TableName + 'Service.pas', Builder.ToString);
  finally
    Builder.Free;
  end;
end;

class procedure TCodeGenerator.GenerateUniGUIForm(const Metadata: TModelMetadata; const OutputPath: string);
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('unit ' + Metadata.TableName + 'ListFrame;');
    Builder.AppendLine;
    Builder.AppendLine('interface');
    Builder.AppendLine;
    Builder.AppendLine('uses');
    Builder.AppendLine('  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,');
    Builder.AppendLine('  uniGUIBaseClasses, uniGUIClasses, uniPanel, uniBasicGrid, uniDBGrid,');
    Builder.AppendLine('  uniEdit, uniButton, uniLabel, uniGUIForm,');
    Builder.AppendLine('  Shared.Core.Services.' + Metadata.TableName + 'Service,');
    Builder.AppendLine('  Shared.Core.Models.' + Metadata.TableName + ',');
    Builder.AppendLine('  Data.DB, FireDAC.Comp.Client;');
    Builder.AppendLine;
    Builder.AppendLine('type');
    Builder.AppendLine('  T' + Metadata.TableName + 'ListFrame = class(TUniForm)');
    Builder.AppendLine('    UniDBGrid1: TUniDBGrid;');
    Builder.AppendLine('    UniButtonAdd: TUniButton;');
    Builder.AppendLine('    UniButtonEdit: TUniButton;');
    Builder.AppendLine('    UniButtonDelete: TUniButton;');
    Builder.AppendLine('    DataSource1: TDataSource;');
    Builder.AppendLine('    FDQuery1: TFDQuery;');
    Builder.AppendLine('    procedure UniFormCreate(Sender: TObject);');
    Builder.AppendLine('  private');
    Builder.AppendLine('    FService: T' + Metadata.TableName + 'Service;');
    Builder.AppendLine('    procedure LoadData;');
    Builder.AppendLine('  public');
    Builder.AppendLine('  end;');
    Builder.AppendLine;
    Builder.AppendLine('implementation');
    Builder.AppendLine;
    Builder.AppendLine('{$R *.dfm}');
    Builder.AppendLine;
    Builder.AppendLine('procedure T' + Metadata.TableName + 'ListFrame.UniFormCreate(Sender: TObject);');
    Builder.AppendLine('begin');
    Builder.AppendLine('  FService := T' + Metadata.TableName + 'Service.Create;');
    Builder.AppendLine('  LoadData;');
    Builder.AppendLine('end;');
    Builder.AppendLine;
    Builder.AppendLine('procedure T' + Metadata.TableName + 'ListFrame.LoadData;');
    Builder.AppendLine('begin');
    Builder.AppendLine('  // 加载数据逻辑');
    Builder.AppendLine('end;');
    Builder.AppendLine;
    Builder.AppendLine('end.');
  
    TFile.WriteAllText(OutputPath + Metadata.TableName + 'ListFrame.pas', Builder.ToString);
  finally
    Builder.Free;
  end;
end;

class procedure TCodeGenerator.GenerateFMXForm(const Metadata: TModelMetadata; const OutputPath: string);
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('unit ' + Metadata.TableName + 'ListForm;');
    Builder.AppendLine;
    Builder.AppendLine('interface');
    Builder.AppendLine;
    Builder.AppendLine('uses');
    Builder.AppendLine('  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,');
    Builder.AppendLine('  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,');
    Builder.AppendLine('  FMX.Edit, FMX.Grid, FMX.Controls.Presentation,');
    Builder.AppendLine('  Shared.Core.Services.' + Metadata.TableName + 'Service,');
    Builder.AppendLine('  Shared.Core.Models.' + Metadata.TableName + ';');
    Builder.AppendLine;
    Builder.AppendLine('type');
    Builder.AppendLine('  T' + Metadata.TableName + 'ListForm = class(TForm)');
    Builder.AppendLine('    StringGrid1: TStringGrid;');
    Builder.AppendLine('    ButtonAdd: TButton;');
    Builder.AppendLine('    ButtonEdit: TButton;');
    Builder.AppendLine('    ButtonDelete: TButton;');
    Builder.AppendLine('    procedure FormCreate(Sender: TObject);');
    Builder.AppendLine('  private');
    Builder.AppendLine('    FService: T' + Metadata.TableName + 'Service;');
    Builder.AppendLine('    procedure LoadData;');
    Builder.AppendLine('  public');
    Builder.AppendLine('  end;');
    Builder.AppendLine;
    Builder.AppendLine('implementation');
    Builder.AppendLine;
    Builder.AppendLine('{$R *.fmx}');
    Builder.AppendLine;
    Builder.AppendLine('procedure T' + Metadata.TableName + 'ListForm.FormCreate(Sender: TObject);');
    Builder.AppendLine('begin');
    Builder.AppendLine('  FService := T' + Metadata.TableName + 'Service.Create;');
    Builder.AppendLine('  LoadData;');
    Builder.AppendLine('end;');
    Builder.AppendLine;
    Builder.AppendLine('procedure T' + Metadata.TableName + 'ListForm.LoadData;');
    Builder.AppendLine('begin');
    Builder.AppendLine('  // 加载数据逻辑');
    Builder.AppendLine('end;');
    Builder.AppendLine;
    Builder.AppendLine('end.');
  
    TFile.WriteAllText(OutputPath + Metadata.TableName + 'ListForm.pas', Builder.ToString);
  finally
    Builder.Free;
  end;
end;

end.
```

### 3. 使用代码生成器

```pascal
// 生成代码示例
procedure GenerateUserModule;
var
  Metadata: TModelMetadata;
begin
  Metadata := TModelMetadata.Create;
  try
    Metadata.TableName := 'User';
    Metadata.PrimaryKey := 'ID';
  
    with Metadata.AddField('ID', 'ID', 'Integer') do
    begin
      Visible := False;
      Editable := False;
    end;
  
    Metadata.AddField('UserName', '用户名', 'String');
    Metadata.AddField('Email', '邮箱', 'String');
    Metadata.AddField('Password', '密码', 'String');
    Metadata.AddField('RoleID', '角色ID', 'Integer');
  
    // 生成所有代码
    TCodeGenerator.GenerateModel(Metadata, 'Shared/Core/Models/');
    TCodeGenerator.GenerateService(Metadata, 'Shared/Core/Services/');
    TCodeGenerator.GenerateUniGUIForm(Metadata, 'UniGUI/Forms/');
    TCodeGenerator.GenerateFMXForm(Metadata, 'FMX/Forms/');
  finally
    Metadata.Free;
  end;
end;
```

---

## 最佳实践

### 1. 代码组织规范

```
Shared/
├── Core/
│   ├── Models/              # 数据模型
│   ├── Services/            # 业务服务
│   │   ├── I*.pas         # 接口
│   │   └── *.pas          # 实现
│   ├── Data/               # 数据访问
│   └── Utils/              # 工具类
└── Interfaces/             # 跨平台接口
    └── I*.pas
```

### 2. 命名规范

```pascal
// 接口：I + PascalCase
IUserService
IModelAdmin

// 实现：T + PascalCase
TUserService
TUserRepository

// 适配器：平台前缀 + PascalCase
TUniModelAdminAdapter
TFMXModelAdminAdapter

// 元数据：T + PascalCase + Metadata
TUserMetadata
TModelMetadata
```

### 3. 依赖注入

```pascal
// 使用接口和依赖注入
type
  TServiceLocator = class
  private
    class var FServices: TDictionary<string, IInterface>;
  public
    class procedure Register<T: IInterface>(const Service: T);
    class function Resolve<T: IInterface>: T;
  end;

// 使用
TServiceLocator.Register<IUserService>(TUserService.Create);
var UserService := TServiceLocator.Resolve<IUserService>;
```

### 4. 错误处理

```pascal
// 统一错误处理
type
  EBusinessException = class(Exception)
  public
    ErrorCode: Integer;
    constructor Create(const AMessage: string; AErrorCode: Integer = 0);
  end;

// 使用
try
  UserService.CreateUser(User);
except
  on E: EBusinessException do
    ShowMessage('错误 ' + IntToStr(E.ErrorCode) + ': ' + E.Message);
  on E: Exception do
    ShowMessage('系统错误: ' + E.Message);
end;
```

---

## 实施建议

### 1. 分阶段实施

#### 第一阶段：共享业务层

- [ ] 创建 Shared 项目
- [ ] 提取数据模型
- [ ] 提取业务服务
- [ ] 提取数据访问层

#### 第二阶段：UI 适配器

- [ ] 创建抽象 UI 接口
- [ ] 实现 UniGUI 适配器
- [ ] 实现 FMX 适配器
- [ ] 重构现有表单

#### 第三阶段：代码生成器

- [ ] 设计元数据结构
- [ ] 实现代码生成器
- [ ] 创建生成模板
- [ ] 集成到开发流程

### 2. 代码量减少效果

| 层级                | 传统方式 | 统一框架 | 减少比例 |
| ------------------- | -------- | -------- | -------- |
| **数据模型**  | 2 份     | 1 份     | 50%      |
| **业务逻辑**  | 2 份     | 1 份     | 50%      |
| **数据访问**  | 2 份     | 1 份     | 50%      |
| **UI 适配器** | 0 份     | 1 份     | +1 份    |
| **总体**      | 100%     | 55%      | 45%      |

### 3. 推荐方案组合

#### 小型项目

**方案一（三层架构 + 共享业务层）**

- 简单直接
- 代码复用率高
- 易于维护

#### 中型项目

**方案二（抽象 UI 组件层）**

- 更好的抽象
- UI 层解耦
- 易于扩展

#### 大型项目

**方案三（代码生成器）**

- 自动化生成
- 一致性高
- 开发效率最高

---

## 总结

通过统一 UniGUI 和 FMX 开发框架，可以实现：

1. **代码复用**：共享业务逻辑层，减少 45% 的代码量
2. **一致性**：统一的接口和实现，保证行为一致
3. **可维护性**：单一数据源，修改一处即可
4. **可扩展性**：易于添加新的平台支持
5. **开发效率**：自动化代码生成，快速开发

**下一步建议**：

1. 从共享业务层开始，先提取数据模型和服务
2. 逐步重构，不要一次性重构所有代码
3. 使用代码生成器，自动化重复工作
4. 建立规范，制定统一的编码规范

---

*文档版本: 1.0*
*最后更新: 2026-03-09*
*维护者: UniAdmin 开发团队*
