---
name: lookin
description: Inspect iOS app UI hierarchy and view properties via LookinServer. Use when debugging layout issues, finding UI elements, or verifying UI changes in an iOS simulator.
---

You have access to `lookin-cli`, a command-line tool that inspects the live UI of iOS apps running in the simulator via LookinServer.

## Prerequisites

The user's iOS project must have [LookinServer](https://github.com/QMUI/LookinServer) integrated and the app must be running in the iOS Simulator.

CocoaPods: `pod 'LookinServer', :configurations => ['Debug']`
SPM: Add `https://github.com/QMUI/LookinServer.git`

## When to Use

Trigger this skill when the user mentions:
- UI layout problems ("button is off-screen", "spacing looks wrong", "view not showing")
- Finding UI elements ("where is the login button", "what's on this screen")
- Inspecting properties ("what color is this", "what font", "what frame")
- Verifying UI changes after code modifications
- Debugging accessibility or Auto Layout constraints

## Commands

### `lookin-cli ping`
Discover connectable apps. Always run this first to confirm the app is reachable.

### `lookin-cli hierarchy [--flat] [--filter CLASS]`
Get the view hierarchy as JSON. `--flat` returns a list; `--filter UIButton` filters by class name.

### `lookin-cli inspect <oid>`
Get detailed attributes of a specific view (class chain, frame, host view controller, etc.).

### `lookin-cli search [--class CLASS] [--text TEXT]`
Search views by class name or text content.

### `lookin-cli screenshot --oid <oid> --output <path>`
Save a view's screenshot to a PNG file.

### `lookin-cli modify --oid <oid> --attr <property> --value <value>`
Modify a view property at runtime. Changes are in-memory only and lost on app restart.

## Workflow

1. `lookin-cli ping` — verify app is reachable
2. `lookin-cli search` or `lookin-cli hierarchy` — locate the relevant view
3. `lookin-cli inspect <oid>` — get detailed properties
4. Analyze the output and relate it back to the user's code

## Notes

- All output is JSON to stdout
- Simulator only (no USB device support)
- oid values like `0x1ed` come from the hierarchy/search output
- View frames are in points (not pixels)
