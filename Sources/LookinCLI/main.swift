import Foundation

registerLookinClasses()

let args = Array(CommandLine.arguments.dropFirst())

guard let command = args.first else {
    printUsage()
    exit(0)
}

switch command {
case "ping":
    cmdPing()
case "hierarchy":
    let opts = parseOptions(args)
    let flat = opts["flat"] != nil
    let filter = opts["filter"]
    cmdHierarchy(flat: flat, filter: filter)
case "inspect":
    guard args.count >= 2 else {
        fputs("Error: oid required\n", stderr)
        exit(1)
    }
    let opts = parseOptions(args)
    let oid = args[1].hasPrefix("-") ? "" : args[1]
    let screenshot = opts["screenshot"] != nil
    cmdInspect(oid: oid, includeScreenshot: screenshot)
case "search":
    let opts = parseOptions(args)
    cmdSearch(
        classFilter: opts["class"],
        textFilter: opts["text"],
        accessibilityLabel: opts["accessibility-label"]
    )
case "modify":
    let opts = parseOptions(args)
    guard let oid = opts["oid"], let attr = opts["attr"], let value = opts["value"] else {
        fputs("Error: --oid, --attr, and --value required\n", stderr)
        exit(1)
    }
    cmdModify(oid: oid, attr: attr, value: value)
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
      ping                             Discover connectable iOS apps
      hierarchy [--flat] [--filter X]  Get view hierarchy (JSON)
      inspect <oid> [--screenshot]     Inspect a specific view
      search [--class X] [--text X]    Search views by criteria
      modify --oid X --attr X --value  Modify a view attribute
      mcp                              Start as MCP server (stdio)

    OPTIONS:
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
