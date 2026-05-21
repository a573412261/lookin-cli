import Foundation

/// Minimal MCP (Model Context Protocol) server implementation over stdio
class MCPServer {
    private let client = LookinClient()
    private let input = FileHandle.standardInput
    private let output = FileHandle.standardOutput
    private var running = true

    func run() {
        registerLookinClasses()

        let reader = InputStreamReader(fileHandle: input)

        while running {
            guard let line = reader.readLine() else { break }
            guard let data = line.data(using: .utf8) else { continue }

            guard let message = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }

            handleMessage(message)
        }
    }

    private func handleMessage(_ message: [String: Any]) {
        guard let method = message["method"] as? String else { return }
        let id = message["id"]
        let params = message["params"] as? [String: Any] ?? [:]

        switch method {
        case "initialize":
            sendResult(id: id, result: [
                "protocolVersion": "2024-11-05",
                "capabilities": ["tools": ["listChanged": false]],
                "serverInfo": ["name": "lookin-cli", "version": "0.1.0"],
            ])

        case "notifications/initialized":
            // No response needed for notifications
            break

        case "tools/list":
            sendResult(id: id, result: ["tools": toolDefinitions()])

        case "tools/call":
            guard let toolName = params["name"] as? String else {
                sendError(id: id, code: -32602, message: "Missing tool name")
                return
            }
            let arguments = params["arguments"] as? [String: Any] ?? [:]
            handleToolCall(id: id, name: toolName, arguments: arguments)

        default:
            sendError(id: id, code: -32601, message: "Method not found: \(method)")
        }
    }

    private func toolDefinitions() -> [[String: Any]] {
        let deviceProp: [String: Any] = ["type": "integer", "description": "usbmuxd device ID for real device (omit for simulator)"]
        return [
            [
                "name": "lookin_ping",
                "description": "Discover iOS apps running LookinServer in the simulator or on USB-connected real devices",
                "inputSchema": [
                    "type": "object",
                    "properties": ["device": deviceProp],
                    "required": [],
                ],
            ],
            [
                "name": "lookin_hierarchy",
                "description": "Get the view hierarchy of the frontmost app window as JSON",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "flat": ["type": "boolean", "description": "Return flat list instead of tree"],
                        "filter": ["type": "string", "description": "Filter views by class name"],
                        "device": deviceProp,
                    ],
                    "required": [],
                ],
            ],
            [
                "name": "lookin_inspect",
                "description": "Get detailed attributes of a specific view by its object ID",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "oid": ["type": "string", "description": "Object ID (e.g. 0x7ff12340000)"],
                        "screenshot": ["type": "boolean", "description": "Include screenshot info"],
                        "device": deviceProp,
                    ],
                    "required": ["oid"],
                ],
            ],
            [
                "name": "lookin_search",
                "description": "Search views by class name, text, or accessibility label",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "class": ["type": "string", "description": "Filter by class name"],
                        "text": ["type": "string", "description": "Filter by text content"],
                        "accessibilityLabel": ["type": "string", "description": "Filter by accessibility label"],
                        "device": deviceProp,
                    ],
                    "required": [],
                ],
            ],
            [
                "name": "lookin_modify",
                "description": "Modify a view attribute at runtime (changes are in-memory only)",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "oid": ["type": "string", "description": "Object ID"],
                        "attr": ["type": "string", "description": "Attribute name"],
                        "value": ["type": "string", "description": "New value as JSON"],
                        "device": deviceProp,
                    ],
                    "required": ["oid", "attr", "value"],
                ],
            ],
        ]
    }

    private func handleToolCall(id: Any?, name: String, arguments: [String: Any]) {
        var result: String
        let deviceID = arguments["device"] as? Int

        switch name {
        case "lookin_ping":
            result = captureOutput { cmdPing(deviceID: deviceID) }

        case "lookin_hierarchy":
            let flat = arguments["flat"] as? Bool ?? false
            let filter = arguments["filter"] as? String
            result = captureOutput { cmdHierarchy(flat: flat, filter: filter, deviceID: deviceID) }

        case "lookin_inspect":
            guard let oid = arguments["oid"] as? String else {
                sendError(id: id, code: -32602, message: "Missing required parameter: oid")
                return
            }
            let screenshot = arguments["screenshot"] as? Bool ?? false
            result = captureOutput { cmdInspect(oid: oid, includeScreenshot: screenshot, deviceID: deviceID) }

        case "lookin_search":
            let classFilter = arguments["class"] as? String
            let textFilter = arguments["text"] as? String
            let accLabel = arguments["accessibilityLabel"] as? String
            result = captureOutput { cmdSearch(classFilter: classFilter, textFilter: textFilter, accessibilityLabel: accLabel, deviceID: deviceID) }

        case "lookin_modify":
            guard let oid = arguments["oid"] as? String,
                  let attr = arguments["attr"] as? String,
                  let value = arguments["value"] as? String else {
                sendError(id: id, code: -32602, message: "Missing required parameters: oid, attr, value")
                return
            }
            result = captureOutput { cmdModify(oid: oid, attr: attr, value: value, deviceID: deviceID) }

        default:
            sendError(id: id, code: -32602, message: "Unknown tool: \(name)")
            return
        }

        sendResult(id: id, result: [
            "content": [["type": "text", "text": result]],
        ])
    }

    // MARK: - JSON-RPC Helpers

    private func sendResult(id: Any?, result: [String: Any]) {
        var response: [String: Any] = ["jsonrpc": "2.0", "result": result]
        if let id = id { response["id"] = id }
        sendJSON(response)
    }

    private func sendError(id: Any?, code: Int, message: String) {
        let response: [String: Any] = [
            "jsonrpc": "2.0",
            "id": id ?? NSNull(),
            "error": ["code": code, "message": message],
        ]
        sendJSON(response)
    }

    private func sendJSON(_ dict: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]) else { return }
        output.write(data)
        output.write(Data("\n".utf8))
    }

    /// Capture print() output from a closure
    private func captureOutput(_ block: () -> Void) -> String {
        let pipe = Pipe()
        let original = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        block()

        fflush(stdout)
        dup2(original, STDOUT_FILENO)
        close(original)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - Line Reader

class InputStreamReader {
    private let handle: FileHandle
    private var buffer = Data()

    init(fileHandle: FileHandle) {
        self.handle = fileHandle
    }

    func readLine() -> String? {
        while true {
            // Check if we have a newline in buffer
            if let newline = buffer.firstIndex(of: UInt8(ascii: "\n")) {
                let lineData = buffer[..<newline]
                buffer = buffer[(newline + 1)...]
                return String(data: lineData, encoding: .utf8)
            }

            // Read more data
            let chunk = handle.availableData
            if chunk.isEmpty { return nil }
            buffer.append(chunk)
        }
    }
}
