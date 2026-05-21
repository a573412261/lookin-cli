import Foundation

/// LookinChannel backed by a TCP-over-USB tunnel fd from USBMux.
/// Frame I/O is identical to TCPChannel — only the connection setup differs.
class USBChannel: LookinChannel {
    private var fd: Int32
    let deviceID: Int
    let port: Int

    init(fd: Int32, deviceID: Int, port: Int) {
        self.fd = fd
        self.deviceID = deviceID
        self.port = port
    }

    deinit { disconnect() }

    var isConnected: Bool { fd >= 0 }

    func sendFrame(type: UInt32, tag: UInt32, payload: Data?) throws {
        guard fd >= 0 else { throw LookinError.connectionClosed }
        let payloadSize = UInt32(payload?.count ?? 0)
        let header = PTFrame(version: LOOKIN_PROTOCOL_VERSION, type: type, tag: tag, payloadSize: payloadSize)
        var frameData = header.encoded
        if let payload { frameData.append(payload) }
        try writeAll(fd: fd, data: frameData)
    }

    func receiveFrame(timeout: TimeInterval) throws -> (frame: PTFrame, payload: Data?) {
        guard fd >= 0 else { throw LookinError.connectionClosed }
        var tv = timeval(tv_sec: Int(timeout), tv_usec: Int32((timeout.truncatingRemainder(dividingBy: 1)) * 1_000_000))
        setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))

        let headerData = try readExact(fd: fd, count: PT_FRAME_HEADER_SIZE)
        let frame = PTFrame(data: headerData)
        guard frame.version == LOOKIN_PROTOCOL_VERSION else {
            throw LookinError.connectionFailed("Unsupported protocol version: \(frame.version)")
        }

        var payload: Data?
        if frame.payloadSize > 0 && frame.payloadSize < 50_000_000 {
            payload = try readExact(fd: fd, count: Int(frame.payloadSize))
        }
        return (frame, payload)
    }

    func disconnect() {
        if fd >= 0 { close(fd); fd = -1 }
    }
}
