import Foundation

/// High-level client that handles port scanning, connection, and request/response
class LookinClient {
    private var channel: TCPChannel?
    private var currentTag: UInt32 = 0

    /// Scan simulator ports and try to connect to an app
    func discoverPorts() -> [DiscoveredApp] {
        var apps: [DiscoveredApp] = []

        for port in LOOKIN_SIMULATOR_PORT_START...LOOKIN_SIMULATOR_PORT_END {
            let ch = TCPChannel(port: port)
            do {
                try ch.connect()
                // Try ping to verify it's a LookinServer
                let response = try sendPing(channel: ch)
                if response.lookinServerVersion >= LOOKIN_SUPPORTED_SERVER_MIN
                    && response.lookinServerVersion <= LOOKIN_SUPPORTED_SERVER_MAX {
                    apps.append(DiscoveredApp(port: port, serverVersion: Int(response.lookinServerVersion)))
                }
                ch.disconnect()
            } catch {
                ch.disconnect()
            }
        }

        return apps
    }

    /// Connect to a specific port
    func connect(port: Int) throws {
        channel = TCPChannel(port: port)
        try channel!.connect()
    }

    func disconnect() {
        channel?.disconnect()
        channel = nil
    }

    /// Send a request and wait for the response
    func sendRequest(type: LookinRequestType, data: Any? = nil, timeout: TimeInterval = LOOKIN_REQUEST_TIMEOUT) throws -> LookinConnectionResponseAttachment {
        guard let channel = channel else {
            throw LookinError.noAppFound
        }

        // Create attachment
        let attachment = LookinConnectionAttachment()
        attachment.data = data
        attachment.dataType = 0

        // Archive payload
        let payload = try NSKeyedArchiver.archivedData(withRootObject: attachment, requiringSecureCoding: true)

        // Generate tag
        currentTag = UInt32(Date().timeIntervalSince1970)
        let tag = currentTag

        // Send frame
        try channel.sendFrame(type: type.rawValue, tag: tag, payload: payload)

        // Read response(s)
        while true {
            let (frame, framePayload) = try channel.receiveFrame(timeout: timeout)

            // Check if this is a response to our request
            guard frame.tag == tag else { continue }

            guard let payload = framePayload else {
                // Empty response (e.g., push message) — skip
                continue
            }

            // Decode the response attachment
            let responseAttachment = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: LookinConnectionResponseAttachment.self,
                from: payload
            )

            guard let response = responseAttachment else {
                throw LookinError.serverError(code: -1, message: "Failed to decode response")
            }

            // Check for errors
            if let error = response.error {
                throw LookinError.serverError(code: error.code, message: error.localizedDescription)
            }

            if response.appIsInBackground {
                throw LookinError.appInBackground
            }

            // Version check
            if response.lookinServerVersion > 0 {
                if response.lookinServerVersion < LOOKIN_SUPPORTED_SERVER_MIN {
                    throw LookinError.unsupportedVersion(serverVersion: Int(response.lookinServerVersion))
                }
            }

            // Multi-part response handling
            if response.dataTotalCount > 1 {
                // This is a chunked response, data is partial
                // For now, just return the first part
                // TODO: Implement full multi-part assembly
                return response
            }

            return response
        }
    }

    /// Quick ping on a channel without storing state
    private func sendPing(channel: TCPChannel) throws -> LookinConnectionResponseAttachment {
        let attachment = LookinConnectionAttachment()
        attachment.data = nil
        attachment.dataType = 0

        let payload = try NSKeyedArchiver.archivedData(withRootObject: attachment, requiringSecureCoding: true)
        let tag = UInt32(Date().timeIntervalSince1970)

        try channel.sendFrame(type: LookinRequestType.ping.rawValue, tag: tag, payload: payload)

        let (frame, framePayload) = try channel.receiveFrame(timeout: LOOKIN_PING_TIMEOUT)

        guard let payloadData = framePayload else {
            throw LookinError.connectionClosed
        }

        let response = try NSKeyedUnarchiver.unarchivedObject(
            ofClass: LookinConnectionResponseAttachment.self,
            from: payloadData
        )

        guard let attachment = response else {
            throw LookinError.serverError(code: -1, message: "Failed to decode ping response")
        }

        return attachment
    }
}

struct DiscoveredApp {
    let port: Int
    let serverVersion: Int
}
