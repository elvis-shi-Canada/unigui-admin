## 使用 Serena MCP 进行语义代码分析

### 核心原则
优先使用 Serena MCP 替代常规代码搜索和编辑，特别是在符号导航和精确代码操作时。

### 何时使用 Serena
- 符号导航（查找定义、引用、实现）
- 结构化代码库中的精确代码操作
- 优先使用符号级操作，而非基于文件的 grep/sed

### 关键工具
| 工具 | 用途 |
|------|------|
| find_symbol | 跨代码库按名称查找符号 |
| find_referencing_symbols | 查找引用给定符号的所有符号 |
| get_symbols_overview | 获取文件的顶层符号概览 |
| read_file | 读取项目目录内的文件内容 |

### 使用建议
- 理解代码结构时，先用 get_symbols_overview
- 查找类型/方法定义时，用 find_symbol
- 查找所有调用点时，用 find_referencing_symbols
- 避免简单的文本 grep，优先使用语义分析
- 记忆文件可在 .serena/memories/ 中查看/编辑