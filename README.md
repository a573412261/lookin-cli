# lookin-cli

A CLI tool and MCP server for [Lookin](https://lookin.work/) — designed for AI agents to inspect iOS app UI hierarchies.

## What It Does

`lookin-cli` connects to iOS apps running [LookinServer](https://github.com/QMUI/LookinServer) via TCP (simulator) or TCP-over-USB (real device), retrieves view hierarchy and property data, and outputs structured JSON — making iOS UI inspection accessible to AI coding agents, automation scripts, and terminal workflows.

## Prerequisites

- macOS 12.0+
- iOS app with [LookinServer](https://github.com/QMUI/LookinServer) integrated (CocoaPods or SPM)
- App running in iOS Simulator **or** on a USB-connected real device

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
| `lookin_ping` | Discover connectable iOS apps (simulator + USB real device) |
| `lookin_hierarchy` | Get the full view hierarchy tree |
| `lookin_inspect` | Get detailed attributes of a specific view |
| `lookin_modify` | Modify a view attribute at runtime |
| `lookin_search` | Search views by class name, title, or accessibility label |

All tools accept an optional `device` integer parameter to target a specific USB-connected device by its usbmuxd device ID (omit for simulator or first available).

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
lookin-cli ping                              # Discover apps (simulator + USB)
lookin-cli ping --device 5                   # Filter to a specific USB device
lookin-cli hierarchy                         # View hierarchy (JSON tree)
lookin-cli hierarchy --flat --filter UILabel # Flat list of UILabels
lookin-cli hierarchy --device 5              # Hierarchy from real device
lookin-cli inspect 0x1ed                     # Inspect a specific view
lookin-cli search --class UIButton --text OK # Search views
lookin-cli mcp                               # Start MCP server
```

`--device <id>` can be combined with any command. Get the device ID from `lookin-cli ping`.

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

`ping` output includes `connectionType` (`"simulator"` or `"usb"`) and `deviceID` (USB only):

```json
{
  "apps": [
    {"port": 47164, "serverVersion": 7, "connectionType": "simulator"},
    {"port": 47175, "serverVersion": 7, "connectionType": "usb", "deviceID": 5}
  ]
}
```

## License

MIT
