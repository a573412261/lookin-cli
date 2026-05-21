import Foundation

protocol LookinChannel {
    var isConnected: Bool { get }
    func sendFrame(type: UInt32, tag: UInt32, payload: Data?) throws
    func receiveFrame(timeout: TimeInterval) throws -> (frame: PTFrame, payload: Data?)
    func disconnect()
}

enum LookinError: Error, LocalizedError {
    case connectionFailed(String)
    case connectionClosed
    case socketError(errno: Int32)
    case timeout
    case unsupportedVersion(serverVersion: Int)
    case appInBackground
    case serverError(code: Int, message: String)
    case noAppFound

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let msg): return "Connection failed: \(msg)"
        case .connectionClosed: return "Connection closed by peer"
        case .socketError(let err): return "Socket error: \(strerror(err))"
        case .timeout: return "Request timed out"
        case .unsupportedVersion(let v): return "Unsupported server version: \(v)"
        case .appInBackground: return "App is in background"
        case .serverError(let code, let msg): return "Server error (\(code)): \(msg)"
        case .noAppFound: return "No LookinServer-enabled app found (simulator or USB device)"
        }
    }
}

class TCPChannel: LookinChannel {
    private var fd: Int32 = -1
    let port: Int
    let queue = DispatchQueue(label: "lookin.tcp", qos: .userInitiated)

    init(port: Int) {
        self.port = port
    }

    deinit {
        disconnect()
    }

    var isConnected: Bool { fd >= 0 }

    func connect() throws {
        fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else {
            throw LookinError.socketError(errno: errno)
        }

        // Non-blocking connect with timeout
        var addr = sockaddr_in()
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(port).bigEndian
        addr.sin_addr.s_addr = in_addr_t(INADDR_LOOPBACK).bigEndian

        let result = withUnsafePointer(to: &addr) { ptr in
            Darwin.connect(fd, UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self), socklen_t(MemoryLayout<sockaddr_in>.size))
        }

        if result != 0 {
            let err = errno
            close(fd)
            fd = -1
            throw LookinError.connectionFailed("connect() failed: \(strerror(err))")
        }
    }

    func disconnect() {
        if fd >= 0 {
            close(fd)
            fd = -1
        }
    }

    /// Send a frame with optional payload
    func sendFrame(type: UInt32, tag: UInt32, payload: Data?) throws {
        guard fd >= 0 else { throw LookinError.connectionClosed }

        let payloadSize = UInt32(payload?.count ?? 0)
        let header = PTFrame(
            version: LOOKIN_PROTOCOL_VERSION,
            type: type,
            tag: tag,
            payloadSize: payloadSize
        )

        var frameData = header.encoded
        if let payload = payload {
            frameData.append(payload)
        }

        try writeAll(fd: fd, data: frameData)
    }

    /// Read a single frame (header + payload)
    func receiveFrame(timeout: TimeInterval = LOOKIN_REQUEST_TIMEOUT) throws -> (frame: PTFrame, payload: Data?) {
        guard fd >= 0 else { throw LookinError.connectionClosed }

        // Set socket read timeout
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
}
