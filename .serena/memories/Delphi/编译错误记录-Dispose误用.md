## 7️⃣ Dispose 误用规则（预防：E2003 Undeclared identifier: 'Dispose'）

### 触发场景
- 从 C# 等语言切换到 Delphi 开发
- 混淆了 Dispose 和 Free 的用法
- 使用类实例时错误调用 Dispose

### 错误模式
```pascal
FDataScopes.Dispose;  // 错误！E2003 Undeclared identifier: 'Dispose'
FLock.Dispose;        // 错误！
```

### 正确行为
1. Delphi 中 TObject 派生类使用 Free 释放：
   ```pascal
   FDataScopes.Free;
   FLock.Free;
   ```
2. Dispose 只用于配合 New 分配的指针：
   ```pascal
   var P: PInteger;
   New(P);
   Dispose(P);  // 正确用法
   ```
3. 类实例永远不要使用 Dispose
4. 从其他语言迁移代码时，将 .Dispose() 替换为 .Free

### 验证方法
- 编译前检查所有类实例的释放语句
- 确保使用 .Free 而非 .Dispose
- 预期输出：无 E2003 编译错误