# lookin-cli

A CLI tool and MCP server for [Lookin](https://lookin.work/) — designed for AI agents to inspect iOS app UI hierarchies.

## What It Does

`lookin-cli` connects to iOS apps running [LookinServer](https://github.com/QMUI/LookinServer) via TCP, retrieves view hierarchy and property data, and outputs structured JSON — making iOS UI inspection accessible to AI coding agents, automation scripts, and terminal workflows.

## Prerequisites

- macOS 12.0+
- iOS app with [LookinServer](https://github.com/QMUI/LookinServer) integrated (CocoaPods or SPM)
- App running in iOS Simulator

## Installation

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/a573412261/lookin-cli/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/a573412261/lookin-cli.git && cd lookin-cli
swift build -c release && cp .build/release/lookin-cli /usr/local/bin/
```

## AI Agent Integration

There are two ways to integrate with AI agents. Choose one:

### Option 1: MCP Server (Recommended)

MCP gives the AI agent native tool access — it calls `lookin_ping`, `lookin_hierarchy` etc. as built-in tools, no shell commands involved.

Add the following `mcpServers` config to your AI client settings:

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

After configuration, the AI agent gets these tools:

| Tool | Description |
|------|-------------|
| `lookin_ping` | Discover connectable iOS apps |
| `lookin_hierarchy` | Get the full view hierarchy tree |
| `lookin_inspect` | Get detailed attributes of a specific view |
| `lookin_screenshot` | Capture a view's screenshot |
| `lookin_modify` | Modify a view attribute at runtime |
| `lookin_search` | Search views by class name, title, or accessibility label |

### Option 2: Skill

Skill gives the AI agent instructions on how to use `lookin-cli` via shell commands — lighter weight, no MCP config needed. Run in your project directory to install:

```bash
curl -fsSL https://raw.githubusercontent.com/a573412261/lookin-cli/main/skills/install.sh | sh
```

This installs the skill into your project's local directories (`.claude/skills/`, `.cursor/rules/`, etc.). Supported: Claude Code, Copilot, Codex CLI, Gemini CLI, Kiro, Goose, OpenCode, Cursor, Windsurf, Cline, Roo Code, Trae.

### Which to choose?

| | MCP | Skill |
|---|---|---|
| Setup | Add JSON config | One-line curl install |
| Invocation | AI calls tools natively | AI runs shell commands |
| Best for | Claude Code, Cursor, etc. | Any AI that can run bash |
| Output handling | Structured tool results | Stdout JSON parsing |

## CLI Usage (for humans or scripts)

```bash
lookin-cli ping                              # Discover connectable apps
lookin-cli hierarchy                         # View hierarchy (JSON tree)
lookin-cli hierarchy --flat --filter UILabel # Flat list of UILabels
lookin-cli inspect 0x1ed                     # Inspect a specific view
lookin-cli search --class UIButton --text OK # Search views
lookin-cli screenshot --oid 0x1ed -o x.png   # Export screenshot
lookin-cli mcp                               # Start MCP server
```

## Output Format

All commands output JSON to stdout:

```json
{
  "class": "UIButton",
  "oid": "0x1ed",
  "frame": {"x": 12, "y": 413, "width": 48, "height": 48},
  "isHidden": false,
  "alpha": 1,
  "children": [...]
}
```

## License

MIT
