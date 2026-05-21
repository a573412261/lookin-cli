import Foundation

registerLookinClasses()

let args = Array(CommandLine.arguments.dropFirst())

guard let command = args.first else {
    printUsage()
    exit(0)
}

switch command {
case "ping":
    let opts = parseOptions(args)
    let deviceID = opts["device"].flatMap { Int($0) }
    cmdPing(deviceID: deviceID)
case "hierarchy":
    let opts = parseOptions(args)
    let flat = opts["flat"] != nil
    let filter = opts["filter"]
    let deviceID = opts["device"].flatMap { Int($0) }
    cmdHierarchy(flat: flat, filter: filter, deviceID: deviceID)
case "inspect":
    guard args.count >= 2 else {
        fputs("Error: oid required\n", stderr)
        exit(1)
    }
    let opts = parseOptions(args)
    let oid = args[1].hasPrefix("-") ? "" : args[1]
    let screenshot = opts["screenshot"] != nil
    let deviceID = opts["device"].flatMap { Int($0) }
    cmdInspect(oid: oid, includeScreenshot: screenshot, deviceID: deviceID)
case "search":
    let opts = parseOptions(args)
    let deviceID = opts["device"].flatMap { Int($0) }
    cmdSearch(
        classFilter: opts["class"],
        textFilter: opts["text"],
        accessibilityLabel: opts["accessibility-label"],
        deviceID: deviceID
    )
case "modify":
    let opts = parseOptions(args)
    guard let oid = opts["oid"], let attr = opts["attr"], let value = opts["value"] else {
        fputs("Error: --oid, --attr, and --value required\n", stderr)
        exit(1)
    }
    let deviceID = opts["device"].flatMap { Int($0) }
    cmdModify(oid: oid, attr: attr, value: value, deviceID: deviceID)
case "mcp":
    MCPServer().run()
case "--help", "-h":
    printUsage()
case "--version":
    print("lookin-cli 0.1.0")
default:
    fputs("Unknown command: \(command)\n", stderr)
    printUsage()
    exit(1)
}

func printUsage() {
    print("""
    lookin-cli — iOS UI inspector for AI agents

    USAGE:
      lookin-cli <command> [options]

    COMMANDS:
      ping                             Discover connectable iOS apps (simulator + USB)
      hierarchy [--flat] [--filter X]  Get view hierarchy (JSON)
      inspect <oid> [--screenshot]     Inspect a specific view
      search [--class X] [--text X]    Search views by criteria
      modify --oid X --attr X --value  Modify a view attribute
      mcp                              Start as MCP server (stdio)

    OPTIONS:
      --device <id>  Target a specific USB device by its usbmuxd device ID
      -h, --help     Show this help message
      --version      Show version
    """)
}

func parseOptions(_ args: [String]) -> [String: String] {
    var opts: [String: String] = [:]
    var i = 0
    while i < args.count {
        if args[i].hasPrefix("--") {
            let key = String(args[i].dropFirst(2))
            if i + 1 < args.count && !args[i + 1].hasPrefix("--") {
                opts[key] = args[i + 1]
                i += 2
            } else {
                opts[key] = "true"
                i += 1
            }
        } else {
            i += 1
        }
    }
    return opts
}
