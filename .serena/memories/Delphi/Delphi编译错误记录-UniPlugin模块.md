# Delphi 编译错误记录 - UniPlugin 模块修复汇总

## 错误 1: E2204 Improper GUID syntax

**文件**: `src/Core/Plugin/UniPlugin.Types.pas` (第 14 行)

**问题描述**:
接口 IContextAware 的 GUID 格式不正确，使用了非十六进制字符:
```pascal
['{UNI-CONTEXT-AWARE-001}']  // 错误！
```

**解决方法**:
替换为有效 UUID 格式:
```pascal
['{7A3F9C2E-1B5D-4E8A-9C6F-2D4E8B1A5C3F}']  // 正确
```

**规则**: Delphi GUID 必须是 32 个十六进制字符，格式为 `{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}`

---

## 错误 2: E2086 Type 'TPlugin' is not yet completely defined

**文件**: `src/Core/Plugin/UniPlugin.Intf.pas` (第 13, 48 行)

**问题描述**:
使用 `TPluginClass = class of TPlugin;` 时，`TPlugin` 只有前向声明，未完全定义:
```pascal
TPlugin = class;  // 前向声明 - 不完整
TPluginClass = class of TPlugin;  // 错误！
```

**解决方法**:
1. 从 `UniPlugin.Intf.pas` 中移除 `TPlugin` 前向声明
2. 从 `UniPlugin.Intf.pas` 中移除 `TPluginClass` 定义
3. 保留在 `UniPlugin.pas` 中的正确定义（TPlugin 完全定义后再声明 TPluginClass）

**规则**: `class of` 引用的类必须在**同一单元的 interface 部分完整定义**，不能只是前向声明

---

## 错误 3: E2467 Record or object type required

**文件**: `src/Core/Plugin/UniPlugin.pas` (第 118 行)

**问题描述**:
Property 的 read 访问器直接调用接口方法:
```pascal
property CurrentUserID: Integer read FExecutionContext.GetCurrentUserID;  // 错误！
```

**解决方法**:
添加 getter 方法:
```pascal
// 类声明中
function GetCurrentUserID: Integer;
property CurrentUserID: Integer read GetCurrentUserID;

// 实现中
function TPlugin.GetCurrentUserID: Integer;
begin
  if Assigned(FExecutionContext) then
    Result := FExecutionContext.GetCurrentUserID
  else
    Result := 0;
end;
```

**规则**: Property 的 read 访问器必须是**字段**或**无参数方法**，不能直接调用接口方法

---

## 总结

| 错误代码 | 常见原因 | 解决思路 |
|---------|---------|---------|
| E2204 | GUID 包含非十六进制字符 | 使用标准 UUID 生成器生成 GUID |
| E2086 | `class of` 引用未完全定义的类 | 确保类在 interface 部分完整定义后再使用 |
| E2467 | Property read 使用了不合法的表达式 | 使用字段或 getter 方法 |
