# lookin-cli

一个面向 AI Agent 的 [Lookin](https://lookin.work/) 命令行工具 —— 通过 TCP 连接运行了 [LookinServer](https://github.com/QMUI/LookinServer) 的 iOS 应用，获取视图层级和属性数据，输出结构化 JSON。

## 它能做什么

`lookin-cli` 让 AI 编程助手可以直接在命令行检查 iOS 应用的 UI 视图层级，无需打开任何 GUI 工具。

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

## AI Agent 接入方式

提供两种接入方式，选其一即可：

### 方式一：MCP Server（推荐）

MCP 让 AI Agent 获得原生工具调用能力 —— 直接以 `lookin_ping`、`lookin_hierarchy` 等内置工具的形式调用，无需拼 shell 命令。

在项目的 `.claude/settings.json` 中添加：

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

也可以加到 `~/.claude/settings.json` 全局生效。

配置后 AI Agent 自动获得以下工具：

| 工具 | 说明 |
|------|------|
| `lookin_ping` | 发现可连接的 iOS 应用 |
| `lookin_hierarchy` | 获取完整视图层级树 |
| `lookin_inspect` | 获取指定视图的详细属性 |
| `lookin_screenshot` | 捕获视图截图 |
| `lookin_modify` | 运行时修改视图属性 |
| `lookin_search` | 按类名、文本搜索视图 |

### 方式二：Skill

Skill 给 AI Agent 提供使用说明 —— AI 通过 bash 直接运行 `lookin-cli` 命令，更轻量，无需 MCP 配置。

将 `skill.md` 复制到项目目录：

```bash
cp lookin-cli/skill.md /path/to/your/project/.claude/skills/lookin.md
```

AI Agent 会在需要调试 UI 时自动调用 `lookin-cli` 命令。

### 怎么选？

| | MCP | Skill |
|---|---|---|
| 配置方式 | 加一段 JSON | 复制一个文件 |
| 调用方式 | AI 原生工具调用 | AI 执行 shell 命令 |
| 适合场景 | Claude Code、Cursor 等 | 任何能执行 bash 的 AI |
| 输出处理 | 结构化工具结果 | 解析 stdout JSON |

## 命令行用法（供人类或脚本使用）

```bash
lookin-cli ping                              # 发现可连接的 App
lookin-cli hierarchy                         # 视图层级（JSON 树）
lookin-cli hierarchy --flat --filter UILabel # UILabel 扁平列表
lookin-cli inspect 0x1ed                     # 查看指定视图详情
lookin-cli search --class UIButton --text OK # 搜索视图
lookin-cli screenshot --oid 0x1ed -o x.png   # 导出截图
lookin-cli mcp                               # 启动 MCP 服务器
```

## 输出格式

所有命令输出 JSON 到 stdout：

```json
{
  "class": "UIButton",
  "oid": "0x1ed",
  "frame": {"x": 12, "y": 413, "width": 48, "height": 48},
  "isHidden": false,
  "alpha": 1,
  "children": ["..."]
}
```

## 许可证

MIT
