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

## Usage

### CLI Mode

```bash
# Discover connectable apps
lookin-cli ping

# Get view hierarchy as JSON
lookin-cli hierarchy

# Inspect a specific view
lookin-cli inspect <oid>

# Export view screenshot
lookin-cli screenshot <oid> --output view.png

# Modify a view attribute
lookin-cli modify <oid> --attr backgroundColor --value '"#FF0000"'
```

### MCP Server Mode

Start as an MCP server for AI agent integration:

```bash
lookin-cli mcp
```

Configure in Claude Code's MCP settings (`.claude/settings.json`):

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

## MCP Tools

When running as an MCP server, the following tools are available:

| Tool | Description |
|------|-------------|
| `lookin_ping` | Discover connectable iOS apps |
| `lookin_hierarchy` | Get the full view hierarchy tree |
| `lookin_inspect` | Get detailed attributes of a specific view |
| `lookin_screenshot` | Capture a view's screenshot |
| `lookin_modify` | Modify a view attribute at runtime |
| `lookin_search` | Search views by class name, title, or accessibility label |

## Output Format

All commands output JSON to stdout. Example hierarchy output:

```json
{
  "class": "UIWindow",
  "frame": {"x": 0, "y": 0, "width": 393, "height": 852},
  "oid": "0x7ff12340000",
  "children": [
    {
      "class": "UITabBarController",
      "frame": {"x": 0, "y": 0, "width": 393, "height": 852},
      "children": [...]
    }
  ]
}
```

## License

MIT
