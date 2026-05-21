import Foundation

/// High-level client that handles port scanning, connection, and request/response
class LookinClient {
    private var channel: (any LookinChannel)?
    private var currentTag: UInt32 = 0

    /// Scan simulator and USB ports; returns all reachable apps.
    func discoverPorts() -> [DiscoveredApp] {
        var apps: [DiscoveredApp] = []
        apps += discoverSimulatorPorts()
        apps += discoverUSBPorts()
        return apps
    }

    private func discoverSimulatorPorts() -> [DiscoveredApp] {
        var apps: [DiscoveredApp] = []
        for port in LOOKIN_SIMULATOR_PORT_START...LOOKIN_SIMULATOR_PORT_END {
            let ch = TCPChannel(port: port)
            do {
                try ch.connect()
                let response = try sendPing(channel: ch)
                if response.lookinServerVersion >= LOOKIN_SUPPORTED_SERVER_MIN
                    && response.lookinServerVersion <= LOOKIN_SUPPORTED_SERVER_MAX {
                    apps.append(DiscoveredApp(
                        port: port,
                        serverVersion: Int(response.lookinServerVersion),
                        deviceID: nil,
                        connectionType: "simulator"
                    ))
                }
                ch.disconnect()
            } catch {
                ch.disconnect()
            }
        }
        return apps
    }

    private func discoverUSBPorts() -> [DiscoveredApp] {
        var apps: [DiscoveredApp] = []
        let devices: [USBDevice]
        do {
            devices = try USBMux().listDevices()
        } catch {
            return []
        }

        for device in devices where device.connectionType == "USB" {
            for port in LOOKIN_USB_DEVICE_PORT_START...LOOKIN_USB_DEVICE_PORT_END {
                do {
                    let tunnelFd = try USBMux().connect(deviceID: device.deviceID, port: port)
                    let ch = USBChannel(fd: tunnelFd, deviceID: device.deviceID, port: port)
                    let response = try sendPing(channel: ch)
                    if response.lookinServerVersion >= LOOKIN_SUPPORTED_SERVER_MIN
                        && response.lookinServerVersion <= LOOKIN_SUPPORTED_SERVER_MAX {
                        apps.append(DiscoveredApp(
                            port: port,
                            serverVersion: Int(response.lookinServerVersion),
                            deviceID: device.deviceID,
                            connectionType: "usb"
                        ))
                    }
                    ch.disconnect()
                } catch {
                    // port not active on this device — continue
                }
            }
        }
        return apps
    }

    /// Connect to a specific discovered app.
    func connect(to app: DiscoveredApp) throws {
        if let deviceID = app.deviceID {
            let tunnelFd = try USBMux().connect(deviceID: deviceID, port: app.port)
            channel = USBChannel(fd: tunnelFd, deviceID: deviceID, port: app.port)
        } else {
            let ch = TCPChannel(port: app.port)
            try ch.connect()
            channel = ch
        }
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

        let attachment = LookinConnectionAttachment()
        attachment.data = data
        attachment.dataType = 0

        let payload = try NSKeyedArchiver.archivedData(withRootObject: attachment, requiringSecureCoding: true)

        currentTag = UInt32(Date().timeIntervalSince1970)
        let tag = currentTag

        try channel.sendFrame(type: type.rawValue, tag: tag, payload: payload)

        while true {
            let (frame, framePayload) = try channel.receiveFrame(timeout: timeout)

            guard frame.tag == tag else { continue }

            guard let payload = framePayload else { continue }

            let responseAttachment = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: LookinConnectionResponseAttachment.self,
                from: payload
            )

            guard let response = responseAttachment else {
                throw LookinError.serverError(code: -1, message: "Failed to decode response")
            }

            if let error = response.error {
                throw LookinError.serverError(code: error.code, message: error.localizedDescription)
            }

            if response.appIsInBackground {
                throw LookinError.appInBackground
            }

            if response.lookinServerVersion > 0 {
                if response.lookinServerVersion < LOOKIN_SUPPORTED_SERVER_MIN {
                    throw LookinError.unsupportedVersion(serverVersion: Int(response.lookinServerVersion))
                }
            }

            return response
        }
    }

    private func sendPing(channel: any LookinChannel) throws -> LookinConnectionResponseAttachment {
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

        _ = frame  // tag already matched implicitly in discovery
        return attachment
    }
}

struct DiscoveredApp {
    let port: Int
    let serverVersion: Int
    let deviceID: Int?       // nil = simulator
    let connectionType: String  // "simulator" or "usb"
}
