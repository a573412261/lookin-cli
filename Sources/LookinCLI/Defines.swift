import Foundation

enum LookinRequestType: UInt32 {
    case ping = 200
    case app = 201
    case hierarchy = 202
    case hierarchyDetails = 203
    case inbuiltAttrModification = 204
    case attrModificationPatch = 205
    case invokeMethod = 206
    case fetchObject = 207
    case fetchImageViewImage = 208
    case modifyRecognizerEnable = 209
    case allAttrGroups = 210
    case allSelectorNames = 213
    case customAttrModification = 214
}

enum LookinPushType: UInt32 {
    case bringForwardScreenshotTask = 303
    case cancelHierarchyDetails = 304
}

enum LookinErrorCode: Int {
    case `default` = -400
    case inner = -401
    case peerTalk = -402
    case noConnect = -403
    case pingFailForTimeout = -404
    case timeout = -405
    case discard = -406
    case pingFailForBackground = -407
    case objectNotFound = -500
    case modifyValueTypeInvalid = -501
    case exception = -502
    case serverVersionTooHigh = -600
    case serverVersionTooLow = -601
}

enum LookinCodingValueType: Int {
    case none = 0
}

let LOOKIN_SIMULATOR_PORT_START = 47164
let LOOKIN_SIMULATOR_PORT_END = 47169
let LOOKIN_USB_DEVICE_PORT_START = 47175
let LOOKIN_USB_DEVICE_PORT_END = 47179
let LOOKIN_PROTOCOL_VERSION: UInt32 = 1
let LOOKIN_SUPPORTED_SERVER_MIN = 7
let LOOKIN_SUPPORTED_SERVER_MAX = 7
let LOOKIN_REQUEST_TIMEOUT: TimeInterval = 5.0
let LOOKIN_PING_TIMEOUT: TimeInterval = 2.0
let PT_FRAME_HEADER_SIZE = 16
let PT_FRAME_NO_TAG: UInt32 = 0
