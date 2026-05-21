import Foundation

// MARK: - Entry Point

@main
struct LookinCLI {
    static func main() async {
        let args = CommandLine.arguments.dropFirst()

        guard let command = args.first else {
            printUsage()
            return
        }

        switch command {
        case "ping":
            await PingCommand().run()
        case "hierarchy":
            await HierarchyCommand(options: parseOptions(Array(args.dropFirst()))).run()
        case "inspect":
            await InspectCommand(args: Array(args.dropFirst())).run()
        case "search":
            await SearchCommand(options: parseOptions(Array(args.dropFirst()))).run()
        case "screenshot":
            await ScreenshotCommand(args: Array(args.dropFirst())).run()
        case "modify":
            await ModifyCommand(args: Array(args.dropFirst())).run()
        case "mcp":
            await MCPServer().run()
        case "--help", "-h":
            printUsage()
        case "--version":
            print("lookin-cli 0.1.0")
        default:
            print("Unknown command: \(command)")
            printUsage()
        }
    }

    static func printUsage() {
        print("""
        lookin-cli — iOS UI inspector for AI agents

        USAGE:
          lookin-cli <command> [options]

        COMMANDS:
          ping                           Discover connectable iOS apps
          hierarchy [--flat] [--filter]  Get view hierarchy (JSON)
          inspect <oid> [--screenshot]   Inspect a specific view
          search [--class] [--text]      Search views by criteria
          screenshot <oid> -o <path>     Capture view screenshot
          modify <oid> --attr --value    Modify a view attribute
          mcp                            Start as MCP server

        OPTIONS:
          -h, --help     Show this help message
          --version      Show version
        """)
    }

    static func parseOptions(_ args: [String]) -> [String: String] {
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
}

// MARK: - Connection

struct LookinConnection {
    static let simulatorPorts: [Int] = Array(47164...47169)

    /// Scan simulator ports and return the first responsive app info
    static func discoverApps() async -> [[String: Any]] {
        var apps: [[String: Any]] = []
        // TODO: Implement TCP port scanning and ping protocol
        return apps
    }

    /// Send a request to LookinServer and return the response data
    static func sendRequest(type: UInt32, data: Data?, port: Int) async -> Data? {
        // TODO: Implement frame-based protocol (PeerTalk compatible)
        return nil
    }
}

// MARK: - Commands (Stubs)

struct PingCommand {
    func run() async {
        print("{\"apps\":[]}")
        // TODO: Implement port scanning + ping
    }
}

struct HierarchyCommand {
    let options: [String: String]
    func run() async {
        // TODO: Send LookinRequestTypeHierarchy (202), decode response
        print("{\"class\":\"UIWindow\",\"children\":[]}")
    }
}

struct InspectCommand {
    let args: [String]
    func run() async {
        guard let oid = args.first else {
            fputs("Error: oid required\n", stderr)
            return
        }
        // TODO: Send LookinRequestTypeHierarchyDetails (203)
        print("{\"oid\":\"\(oid)\"}")
    }
}

struct SearchCommand {
    let options: [String: String]
    func run() async {
        // TODO: Get hierarchy then filter locally
        print("{\"results\":[],\"totalCount\":0}")
    }
}

struct ScreenshotCommand {
    let args: [String]
    func run() async {
        // TODO: Send LookinRequestTypeFetchImageViewImage (208)
        print("{\"error\":\"not implemented\"}")
    }
}

struct ModifyCommand {
    let args: [String]
    func run() async {
        // TODO: Send LookinRequestTypeInbuiltAttrModification (204)
        print("{\"error\":\"not implemented\"}")
    }
}

struct MCPServer {
    func run() async {
        // TODO: Implement MCP stdio protocol
        fputs("MCP server mode not yet implemented\n", stderr)
    }
}
