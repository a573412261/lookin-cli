# lookin-cli

一个面向 AI Agent 的 [Lookin](https://lookin.work/) 命令行工具 —— 通过 TCP 连接运行了 [LookinServer](https://github.com/QMUI/LookinServer) 的 iOS 应用，获取视图层级和属性数据，输出结构化 JSON。

## 它能做什么

`lookin-cli` 让 AI 编程助手、自动化脚本和终端用户可以直接在命令行检查 iOS 应用的 UI 视图层级，无需打开任何 GUI 工具。

## 前置条件

- macOS 12.0+
- iOS 项目已集成 [LookinServer](https://github.com/QMUI/LookinServer)（CocoaPods 或 SPM）
- 应用在 iOS 模拟器中运行

## 安装

一行命令：

```bash
curl -fsSL https://raw.githubusercontent.com/a573412261/lookin-cli/main/install.sh | bash
```

或手动安装：

```bash
git clone https://github.com/a573412261/lookin-cli.git && cd lookin-cli
swift build -c release && cp .build/release/lookin-cli /usr/local/bin/
```

## 使用

### 命令行模式

```bash
# 发现可连接的 iOS 应用
lookin-cli ping

# 获取视图层级（JSON）
lookin-cli hierarchy

# 查看某个视图的详细属性
lookin-cli inspect <oid>

# 导出视图截图
lookin-cli screenshot <oid> --output view.png

# 运行时修改视图属性
lookin-cli modify <oid> --attr backgroundColor --value '"#FF0000"'
```

### MCP Server 模式

启动 MCP 服务器供 AI Agent 集成：

```bash
lookin-cli mcp
```

在 Claude Code 的 MCP 配置中添加（`.claude/settings.json`）：

```json
{
  "mcpServers": {
    "lookin": {
      "command": "lookin-cli",
      "args": ["mcp"]
    }
  }
}
```

## MCP 工具列表

| 工具 | 说明 |
|------|------|
| `lookin_ping` | 发现可连接的 iOS 应用 |
| `lookin_hierarchy` | 获取完整视图层级树 |
| `lookin_inspect` | 获取指定视图的详细属性 |
| `lookin_screenshot` | 捕获视图截图 |
| `lookin_modify` | 运行时修改视图属性 |
| `lookin_search` | 按类名、文本、无障碍标签搜索视图 |

## 输出格式

所有命令输出 JSON 到 stdout。视图层级输出示例：

```json
{
  "class": "UIWindow",
  "frame": {"x": 0, "y": 0, "width": 393, "height": 852},
  "oid": "0x7ff12340000",
  "children": [
    {
      "class": "UITabBarController",
      "frame": {"x": 0, "y": 0, "width": 393, "height": 852},
      "children": ["..."]
    }
  ]
}
```

## 工作原理

```
┌──────────────┐     TCP      ┌──────────────────┐
│  lookin-cli  │─────────────→│  iOS Simulator   │
│  (macOS)     │  localhost:  │  App + LookinServer│
│              │  47164~47169 │                  │
└──────────────┘              └──────────────────┘
       │
       ▼ stdout JSON / MCP stdio
┌──────────────┐
│  AI Agent    │
│  (Claude等)  │
└──────────────┘
```

## 许可证

MIT
