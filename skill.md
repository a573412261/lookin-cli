---
name: lookin-cli
description: iOS UI inspection tool for AI agents. Connects to iOS apps running LookinServer and retrieves view hierarchy, properties, and screenshots as JSON.
---

# Lookin CLI — AI Agent Skill

## Overview

`lookin-cli` is a command-line tool that connects to iOS applications running [LookinServer](https://github.com/QMUI/LookinServer) in the iOS Simulator. It retrieves view hierarchy, view attributes, layout constraints, and screenshots, outputting structured JSON — designed for AI coding agents to inspect and debug iOS UI programmatically.

## Prerequisites

Before using this tool, ensure:

1. The target iOS app has [LookinServer](https://github.com/QMUI/LookinServer) integrated:
   - **CocoaPods**: `pod 'LookinServer', :configurations => ['Debug']`
   - **SPM**: Add `https://github.com/QMUI/LookinServer.git` as a dependency
2. The app is running in the **iOS Simulator** (physical device USB connections not yet supported in CLI)
3. `lookin-cli` is installed and available in `$PATH`

## When to Use

Use this skill when the user needs to:

- **Debug UI layout issues** — "this button is off-screen", "the spacing looks wrong"
- **Find UI elements** — "where is the login button", "what views are on this screen"
- **Inspect view properties** — "what color is this label", "what's the font size"
- **Verify UI changes** — after modifying code, check the rendered result
- **Understand view hierarchy** — "what's the structure of this screen"
- **Debug accessibility** — check accessibility labels, traits, and hints
- **Inspect Auto Layout constraints** — find conflicting or missing constraints

## Commands

### `lookin-cli ping`

Discover iOS apps that are running LookinServer and available for connection.

**Output:**
```json
{
  "apps": [
    {
      "name": "MyApp",
      "bundleId": "com.example.myapp",
      "device": "iPhone 15 Pro",
      "os": "iOS 17.2",
      "serverVersion": 7,
      "port": 47164
    }
  ]
}
```

**When to use:** Always start with `ping` to verify a connectable app exists before running other commands.

---

### `lookin-cli hierarchy [--flat] [--filter CLASS_NAME]`

Get the view hierarchy of the frontmost app window.

**Options:**
- `--flat` — Output as a flat list instead of a tree (easier for programmatic filtering)
- `--filter CLASS_NAME` — Only include views matching the class name (case-insensitive substring match)

**Output (tree mode, default):**
```json
{
  "class": "UIWindow",
  "oid": "0x7ff12340000",
  "frame": {"x": 0, "y": 0, "width": 393, "height": 852},
  "isHidden": false,
  "alpha": 1.0,
  "children": [
    {
      "class": "UITabBarController",
      "oid": "0x7ff12340001",
      "frame": {"x": 0, "y": 0, "width": 393, "height": 852},
      "children": [
        {
          "class": "UINavigationController",
          "oid": "0x7ff12340002",
          "children": [
            {
              "class": "HomeViewController",
              "oid": "0x7ff12340003",
              "children": [
                {
                  "class": "UICollectionView",
                  "oid": "0x7ff12340004",
                  "children": [
                    {
                      "class": "ProductCell",
                      "oid": "0x7ff12340005",
                      "accessibilityLabel": "Product: iPhone Case",
                      "children": [
                        {"class": "UIImageView", "oid": "0x7ff12340006"},
                        {"class": "UILabel", "oid": "0x7ff12340007", "text": "$29.99"}
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

**When to use:**
- To understand screen structure
- To locate specific views for further inspection
- Use `--flat` + `--filter UIButton` to quickly find all buttons

---

### `lookin-cli inspect <oid> [--screenshot]`

Get detailed attributes of a specific view, including properties, constraints, event handlers, and class information.

**Arguments:**
- `oid` — Object identifier from hierarchy output (e.g., `0x7ff12340005`)

**Options:**
- `--screenshot` — Include a base64-encoded PNG screenshot of the view

**Output:**
```json
{
  "class": "UILabel",
  "classChain": ["UILabel", "UIView", "UIResponder", "NSObject"],
  "oid": "0x7ff12340007",
  "frame": {"x": 0, "y": 40, "width": 200, "height": 21},
  "bounds": {"x": 0, "y": 0, "width": 200, "height": 21},
  "isHidden": false,
  "alpha": 1.0,
  "isUserInteractionEnabled": false,
  "backgroundColor": "#FFFFFF",
  "attributes": {
    "text": "Hello World",
    "font": "SFProText-Regular 17.0pt",
    "textColor": "#000000",
    "textAlignment": "left",
    "numberOfLines": 1,
    "lineBreakMode": "tailTruncation"
  },
  "constraints": [
    {
      "firstItem": "0x7ff12340007",
      "firstAttribute": "leading",
      "relation": "equal",
      "constant": 16,
      "priority": 1000
    },
    {
      "firstItem": "0x7ff12340007",
      "firstAttribute": "top",
      "secondItem": "0x7ff12340006",
      "secondAttribute": "bottom",
      "constant": 8,
      "priority": 1000
    }
  ],
  "eventHandlers": [],
  "hostViewController": "HomeViewController"
}
```

**When to use:**
- To get detailed property values of a specific view
- To debug layout issues by checking frame, bounds, and constraints
- To understand why a view is not visible (check `isHidden`, `alpha`, `frame`)
- To inspect text content, fonts, colors

---

### `lookin-cli search [--class CLASS] [--text TEXT] [--accessibility-label LABEL]`

Search for views matching criteria across the entire hierarchy.

**Options:**
- `--class CLASS` — Filter by class name (substring match, case-insensitive)
- `--text TEXT` — Filter by text content (UILabel text, UIButton title, UITextField text)
- `--accessibility-label LABEL` — Filter by accessibility label

**Output:**
```json
{
  "results": [
    {
      "class": "UIButton",
      "oid": "0x7ff12340010",
      "frame": {"x": 16, "y": 600, "width": 361, "height": 50},
      "title": "Submit Order",
      "isHidden": false,
      "isEnabled": true
    }
  ],
  "totalCount": 1
}
```

**When to use:**
- "Find the submit button" → `search --class UIButton --text Submit`
- "Find all labels with error text" → `search --text "error"`
- "Find the checkout button by accessibility" → `search --accessibility-label "checkout"`

---

### `lookin-cli screenshot <oid> --output <path>`

Capture a screenshot of a specific view and save it as a PNG file.

**Arguments:**
- `oid` — Object identifier of the view to capture

**Options:**
- `--output PATH` — Output file path (required)

**When to use:**
- To visually verify how a view looks
- To capture before/after states when making UI changes
- To show the user what the current UI looks like

---

### `lookin-cli modify <oid> --attr <property> --value <value>`

Modify a view attribute at runtime. Changes are immediate and visible in the simulator.

**Arguments:**
- `oid` — Object identifier of the view to modify
- `--attr` — Property name (e.g., `backgroundColor`, `alpha`, `isHidden`, `text`)
- `--value` — New value as JSON (e.g., `'"#FF0000"'`, `'0.5'`, `'true'`, `'"New Text"'`)

**Examples:**
```bash
# Hide a view
lookin-cli modify 0x7ff12340005 --attr isHidden --value true

# Change background color
lookin-cli modify 0x7ff12340005 --attr backgroundColor --value '"#FF0000"'

# Change label text
lookin-cli modify 0x7ff12340007 --attr text --value '"Updated Text"'

# Adjust alpha
lookin-cli modify 0x7ff12340005 --attr alpha --value 0.5
```

**When to use:**
- To verify a hypothesis ("what if I hide this view?")
- To test color/font changes before modifying code
- To confirm which view is causing a layout issue by hiding it

**Caution:** Changes are in-memory only and reset when the app restarts.

---

## Typical Workflows

### Workflow 1: Debug "button not visible"

```
1. lookin-cli ping                              → Confirm app is reachable
2. lookin-cli search --class UIButton --text "Submit"  → Find the button
3. lookin-cli inspect 0x7ff...                   → Check isHidden, alpha, frame
4. lookin-cli modify 0x7ff... --attr isHidden --value false  → Test fix
```

### Workflow 2: Understand screen structure

```
1. lookin-cli ping                    → Confirm connection
2. lookin-cli hierarchy               → Get full tree
3. lookin-cli inspect <target_oid>    → Deep-dive into specific view
```

### Workflow 3: Find layout constraint conflicts

```
1. lookin-cli hierarchy --flat --filter UIView   → Get all views
2. lookin-cli inspect <oid>                      → Check constraints for suspect views
3. Look for overlapping frames, zero-width/height, or ambiguous constraints
```

### Workflow 4: Verify code changes

```
1. User makes code change → rebuilds app in simulator
2. lookin-cli ping                              → Confirm app is running
3. lookin-cli inspect <oid> --screenshot        → Check if change took effect
```

## MCP Server Mode

For persistent AI agent integration, run as an MCP server:

```bash
lookin-cli mcp
```

This starts a stdio-based MCP server exposing the following tools:

| Tool Name | Maps to Command | Description |
|-----------|----------------|-------------|
| `lookin_ping` | `ping` | Discover connectable apps |
| `lookin_hierarchy` | `hierarchy` | Get view hierarchy tree |
| `lookin_inspect` | `inspect` | Get view details by oid |
| `lookin_search` | `search` | Search views by criteria |
| `lookin_screenshot` | `screenshot` | Capture view screenshot |
| `lookin_modify` | `modify` | Modify view attribute |

**Configuration** (`.claude/settings.json` or project `.claude/settings.json`):

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

## Important Notes

- **Simulator only** — Physical device connections via USB are not yet supported in the CLI
- **Runtime only** — The CLI inspects the live app state. It does not read source code or storyboards
- **Modifications are ephemeral** — `modify` changes are in-memory and lost on app restart
- **Performance** — Large view hierarchies may take a few seconds to retrieve. Use `--filter` to narrow results
- **Connection ports** — The tool scans ports 47164–47169 on localhost (standard LookinServer ports)
- **Version compatibility** — Requires LookinServer protocol version 7+
