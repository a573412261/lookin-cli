import Foundation

struct USBDevice {
    let deviceID: Int
    let serialNumber: String
    let connectionType: String
}

/// Synchronous usbmuxd client. Each instance is single-use.
class USBMux {
    private static let socketPath = "/var/run/usbmuxd"
    private var fd: Int32 = -1
    private var nextTag: UInt32 = 1

    deinit {
        if fd >= 0 { close(fd) }
    }

    /// Returns attached USB iOS devices (excludes Wi-Fi/simulator entries).
    func listDevices() throws -> [USBDevice] {
        try openSocket()
        defer { close(fd); fd = -1 }

        let tag = nextTag; nextTag += 1
        try sendPlistRequest(["MessageType": "ListDevices", "ProgName": "lookin-cli", "ClientVersionString": "lookin-cli-0.1.0"], tag: tag)

        let response = try readPlistResponse()
        guard let deviceList = response["DeviceList"] as? [[String: Any]] else { return [] }

        return deviceList.compactMap { entry -> USBDevice? in
            guard let deviceID = entry["DeviceID"] as? Int,
                  let props = entry["Properties"] as? [String: Any] else { return nil }
            let serial = props["SerialNumber"] as? String ?? ""
            let connType = props["ConnectionType"] as? String ?? "USB"
            return USBDevice(deviceID: deviceID, serialNumber: serial, connectionType: connType)
        }
    }

    /// Establishes a TCP-over-USB tunnel. Returns the raw fd (caller owns it).
    func connect(deviceID: Int, port: Int) throws -> Int32 {
        try openSocket()

        // usbmuxd expects the port in network byte order but stored as little-endian integer
        let byteSwappedPort = ((port << 8) & 0xFF00) | (port >> 8)
        let tag = nextTag; nextTag += 1
        try sendPlistRequest([
            "MessageType": "Connect",
            "DeviceID": deviceID,
            "PortNumber": byteSwappedPort,
            "ProgName": "lookin-cli",
        ], tag: tag)

        let response = try readPlistResponse()
        guard let number = response["Number"] as? Int, number == 0 else {
            let errNum = response["Number"] as? Int ?? -1
            close(fd); fd = -1
            throw LookinError.connectionFailed("usbmuxd Connect failed (code \(errNum))")
        }

        let tunnelFd = fd
        fd = -1  // transfer ownership to caller
        return tunnelFd
    }

    // MARK: - Private

    private func openSocket() throws {
        fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else {
            throw LookinError.connectionFailed("Failed to create Unix socket: \(String(cString: strerror(errno)))")
        }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let path = USBMux.socketPath
        let maxPathLen = MemoryLayout.size(ofValue: addr.sun_path) - 1
        withUnsafeMutablePointer(to: &addr.sun_path) { dest in
            path.withCString { src in
                _ = strncpy(
                    UnsafeMutableRawPointer(dest).assumingMemoryBound(to: CChar.self),
                    src,
                    maxPathLen
                )
            }
        }

        let result = withUnsafePointer(to: &addr) { ptr in
            Darwin.connect(fd, UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self), socklen_t(MemoryLayout<sockaddr_un>.size))
        }
        if result != 0 {
            let err = errno; close(fd); fd = -1
            throw LookinError.connectionFailed("Cannot connect to usbmuxd at \(path): \(String(cString: strerror(err)))")
        }
    }

    private func sendPlistRequest(_ plist: [String: Any], tag: UInt32) throws {
        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let totalLength = UInt32(16 + plistData.count)

        // usbmuxd header is little-endian: length, version=1 (plist), type=8 (plist), tag
        var header = Data(capacity: 16)
        var len = totalLength.littleEndian; header.append(Data(bytes: &len, count: 4))
        var ver: UInt32 = 1; ver = ver.littleEndian; header.append(Data(bytes: &ver, count: 4))
        var typ: UInt32 = 8; typ = typ.littleEndian; header.append(Data(bytes: &typ, count: 4))
        var t = tag.littleEndian; header.append(Data(bytes: &t, count: 4))

        var packet = header
        packet.append(plistData)
        try writeAll(fd: fd, data: packet)
    }

    private func readPlistResponse() throws -> [String: Any] {
        let headerData = try readExact(fd: fd, count: 16)
        let totalLength = headerData.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 0, as: UInt32.self) }.littleEndian
        let payloadLength = Int(totalLength) - 16
        guard payloadLength > 0 else { return [:] }

        let plistData = try readExact(fd: fd, count: payloadLength)
        guard let result = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            throw LookinError.connectionFailed("Failed to parse usbmuxd plist response")
        }
        return result
    }
}
