import Foundation

struct PTFrame {
    let version: UInt32
    let type: UInt32
    let tag: UInt32
    let payloadSize: UInt32

    init(version: UInt32, type: UInt32, tag: UInt32, payloadSize: UInt32) {
        self.version = version
        self.type = type
        self.tag = tag
        self.payloadSize = payloadSize
    }

    /// Parse a 16-byte big-endian frame header
    init(data: Data) {
        precondition(data.count >= PT_FRAME_HEADER_SIZE)
        self.version = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 0, as: UInt32.self) }.bigEndian
        self.type = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 4, as: UInt32.self) }.bigEndian
        self.tag = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 8, as: UInt32.self) }.bigEndian
        self.payloadSize = data.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 12, as: UInt32.self) }.bigEndian
    }

    /// Serialize to 16-byte big-endian data
    var encoded: Data {
        var buf = Data(capacity: PT_FRAME_HEADER_SIZE)
        var v = version.bigEndian; buf.append(Data(bytes: &v, count: 4))
        var t = type.bigEndian; buf.append(Data(bytes: &t, count: 4))
        var g = tag.bigEndian; buf.append(Data(bytes: &g, count: 4))
        var p = payloadSize.bigEndian; buf.append(Data(bytes: &p, count: 4))
        return buf
    }
}

/// Read an exact number of bytes from a file descriptor
func readExact(fd: Int32, count: Int) throws -> Data {
    var data = Data(count: count)
    var remaining = count
    var offset = 0
    while remaining > 0 {
        let bytesRead = data.withUnsafeMutableBytes { ptr in
            Darwin.read(fd, ptr.baseAddress! + offset, remaining)
        }
        if bytesRead < 0 {
            throw LookinError.socketError(errno: errno)
        }
        if bytesRead == 0 {
            throw LookinError.connectionClosed
        }
        offset += bytesRead
        remaining -= bytesRead
    }
    return data
}

/// Write all data to a file descriptor
func writeAll(fd: Int32, data: Data) throws {
    var offset = 0
    while offset < data.count {
        let written = data.withUnsafeBytes { ptr in
            Darwin.write(fd, ptr.baseAddress! + offset, data.count - offset)
        }
        if written < 0 {
            throw LookinError.socketError(errno: errno)
        }
        offset += written
    }
}
