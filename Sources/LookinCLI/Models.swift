import Foundation

// MARK: - NSSecureCoding Model Stubs
// These Swift classes replicate the ObjC LookinShared NSSecureCoding format
// so we can decode archives from LookinServer.

// MARK: LookinConnectionAttachment

@objc(LookinConnectionAttachment)
class LookinConnectionAttachment: NSObject, NSSecureCoding {
    @objc var dataType: Int = 0
    @objc var data: Any?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        dataType = coder.decodeInteger(forKey: "1")
        data = coder.decodeObject(forKey: "0")
    }

    func encode(with coder: NSCoder) {
        coder.encode(data, forKey: "0")
        coder.encode(dataType, forKey: "1")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinConnectionResponseAttachment

@objc(LookinConnectionResponseAttachment)
class LookinConnectionResponseAttachment: NSObject, NSSecureCoding {
    @objc var lookinServerVersion: Int32 = 0
    @objc var error: NSError?
    @objc var dataTotalCount: Int = 0
    @objc var currentDataCount: Int = 0
    @objc var appIsInBackground: Bool = false
    @objc var data: Any?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        lookinServerVersion = coder.decodeInt32(forKey: "lookinServerVersion")
        error = coder.decodeObject(of: NSError.self, forKey: "error") as? NSError
        dataTotalCount = (coder.decodeObject(of: NSNumber.self, forKey: "dataTotalCount") as? NSNumber)?.intValue ?? 0
        currentDataCount = (coder.decodeObject(of: NSNumber.self, forKey: "currentDataCount") as? NSNumber)?.intValue ?? 0
        appIsInBackground = coder.decodeBool(forKey: "appIsInBackground")
        data = coder.decodeObject(forKey: "0")
    }

    func encode(with coder: NSCoder) {
        coder.encode(lookinServerVersion, forKey: "lookinServerVersion")
        coder.encode(error, forKey: "error")
        coder.encode(NSNumber(value: dataTotalCount), forKey: "dataTotalCount")
        coder.encode(NSNumber(value: currentDataCount), forKey: "currentDataCount")
        coder.encode(appIsInBackground, forKey: "appIsInBackground")
        coder.encode(data as? Any, forKey: "0")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinAppInfo

@objc(LookinAppInfo)
class LookinAppInfo: NSObject, NSSecureCoding {
    @objc var serverVersion: Int32 = 0
    @objc var serverReadableVersion: String?
    @objc var appName: String?
    @objc var appBundleIdentifier: String?
    @objc var deviceDescription: String?
    @objc var osDescription: String?
    @objc var screenWidth: Double = 0
    @objc var screenHeight: Double = 0
    @objc var screenScale: Double = 0
    @objc var deviceType: Int = 0
    @objc var appInfoIdentifier: Int = 0
    @objc var shouldUseCache: Bool = false
    @objc var appIcon: Data?
    @objc var screenshot: Data?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        serverVersion = coder.decodeInt32(forKey: "serverVersion")
        serverReadableVersion = coder.decodeObject(of: NSString.self, forKey: "serverReadableVersion") as? String
        appName = coder.decodeObject(of: NSString.self, forKey: "5") as? String
        appBundleIdentifier = coder.decodeObject(of: NSString.self, forKey: "appBundleIdentifier") as? String
        deviceDescription = coder.decodeObject(of: NSString.self, forKey: "3") as? String
        osDescription = coder.decodeObject(of: NSString.self, forKey: "4") as? String
        screenWidth = coder.decodeDouble(forKey: "6")
        screenHeight = coder.decodeDouble(forKey: "7")
        screenScale = coder.decodeDouble(forKey: "screenScale")
        deviceType = coder.decodeInteger(forKey: "8")
        appInfoIdentifier = coder.decodeInteger(forKey: "appInfoIdentifier")
        shouldUseCache = coder.decodeBool(forKey: "shouldUseCache")
        appIcon = coder.decodeObject(of: NSData.self, forKey: "1") as? Data
        screenshot = coder.decodeObject(of: NSData.self, forKey: "2") as? Data
    }

    func encode(with coder: NSCoder) {
        coder.encode(serverVersion, forKey: "serverVersion")
        coder.encode(serverReadableVersion, forKey: "serverReadableVersion")
        coder.encode(appName, forKey: "5")
        coder.encode(appBundleIdentifier, forKey: "appBundleIdentifier")
        coder.encode(deviceDescription, forKey: "3")
        coder.encode(osDescription, forKey: "4")
        coder.encode(screenWidth, forKey: "6")
        coder.encode(screenHeight, forKey: "7")
        coder.encode(screenScale, forKey: "screenScale")
        coder.encode(deviceType, forKey: "8")
        coder.encode(appInfoIdentifier, forKey: "appInfoIdentifier")
        coder.encode(shouldUseCache, forKey: "shouldUseCache")
        coder.encode(appIcon, forKey: "1")
        coder.encode(screenshot, forKey: "2")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinObject

@objc(LookinObject)
class LookinObject: NSObject, NSSecureCoding {
    @objc var oid: UInt = 0
    @objc var memoryAddress: String?
    @objc var classChainList: [String]?
    @objc var specialTrace: String?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        oid = (coder.decodeObject(of: NSNumber.self, forKey: "oid") as? NSNumber)?.uintValue ?? 0
        memoryAddress = coder.decodeObject(of: NSString.self, forKey: "memoryAddress") as? String
        classChainList = coder.decodeObject(of: [NSString.self], forKey: "classChainList") as? [String]
        specialTrace = coder.decodeObject(of: NSString.self, forKey: "specialTrace") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(NSNumber(value: oid), forKey: "oid")
        coder.encode(memoryAddress, forKey: "memoryAddress")
        coder.encode(classChainList, forKey: "classChainList")
        coder.encode(specialTrace, forKey: "specialTrace")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinDisplayItem

@objc(LookinDisplayItem)
class LookinDisplayItem: NSObject, NSSecureCoding {
    @objc var viewObject: LookinObject?
    @objc var layerObject: LookinObject?
    @objc var hostViewControllerObject: LookinObject?
    @objc var subitems: [LookinDisplayItem]?
    @objc var isHidden: Bool = false
    @objc var alpha: Float = 1.0
    @objc var frame: CGRect = CGRect()
    @objc var bounds: CGRect = CGRect()
    @objc var attributesGroupList: [Any]?
    @objc var customAttrGroupList: [Any]?
    @objc var eventHandlers: [Any]?
    @objc var customDisplayTitle: String?
    @objc var shouldCaptureImage: Bool = false
    @objc var soloScreenshot: Data?
    @objc var groupScreenshot: Data?
    @objc var backgroundColor: [Float]?
    @objc var representedAsKeyWindow: Bool = false

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        viewObject = coder.decodeObject(of: LookinObject.self, forKey: "viewObject")
        layerObject = coder.decodeObject(of: LookinObject.self, forKey: "layerObject")
        hostViewControllerObject = coder.decodeObject(of: LookinObject.self, forKey: "hostViewControllerObject")
        subitems = coder.decodeObject(of: [NSArray.self, LookinDisplayItem.self], forKey: "subitems") as? [LookinDisplayItem]
        isHidden = coder.decodeBool(forKey: "hidden")
        alpha = coder.decodeFloat(forKey: "alpha")

        // CGRect encoded as NSString "CGRect" by NSKeyedArchiver
        if coder.containsValue(forKey: "frame") {
            let frameStr = coder.decodeObject(of: NSString.self, forKey: "frame") as? String
            frame = Self.parseCGRect(frameStr) ?? CGRect()
        }
        if coder.containsValue(forKey: "bounds") {
            let boundsStr = coder.decodeObject(of: NSString.self, forKey: "bounds") as? String
            bounds = Self.parseCGRect(boundsStr) ?? CGRect()
        }

        attributesGroupList = coder.decodeObject(of: [NSArray.self], forKey: "attributesGroupList") as? [Any]
        customAttrGroupList = coder.decodeObject(of: [NSArray.self], forKey: "customAttrGroupList") as? [Any]
        eventHandlers = coder.decodeObject(of: [NSArray.self], forKey: "eventHandlers") as? [Any]
        customDisplayTitle = coder.decodeObject(of: NSString.self, forKey: "customDisplayTitle") as? String

        if coder.containsValue(forKey: "shouldCaptureImage") {
            shouldCaptureImage = coder.decodeBool(forKey: "shouldCaptureImage")
        }

        soloScreenshot = coder.decodeObject(of: NSData.self, forKey: "soloScreenshot") as? Data
        groupScreenshot = coder.decodeObject(of: NSData.self, forKey: "groupScreenshot") as? Data

        backgroundColor = coder.decodeObject(of: [NSArray.self, NSNumber.self], forKey: "backgroundColor") as? [Float]
        representedAsKeyWindow = coder.decodeBool(forKey: "representedAsKeyWindow")
    }

    func encode(with coder: NSCoder) {
        coder.encode(viewObject, forKey: "viewObject")
        coder.encode(layerObject, forKey: "layerObject")
        coder.encode(hostViewControllerObject, forKey: "hostViewControllerObject")
        coder.encode(subitems, forKey: "subitems")
        coder.encode(isHidden, forKey: "hidden")
        coder.encode(alpha, forKey: "alpha")
        coder.encode(NSStringFromRect(NSRectFromCGRect(frame)), forKey: "frame")
        coder.encode(NSStringFromRect(NSRectFromCGRect(bounds)), forKey: "bounds")
        coder.encode(attributesGroupList, forKey: "attributesGroupList")
        coder.encode(customAttrGroupList, forKey: "customAttrGroupList")
        coder.encode(eventHandlers, forKey: "eventHandlers")
        coder.encode(customDisplayTitle, forKey: "customDisplayTitle")
        coder.encode(shouldCaptureImage, forKey: "shouldCaptureImage")
        coder.encode(soloScreenshot, forKey: "soloScreenshot")
        coder.encode(groupScreenshot, forKey: "groupScreenshot")
        coder.encode(backgroundColor, forKey: "backgroundColor")
        coder.encode(representedAsKeyWindow, forKey: "representedAsKeyWindow")
    }

    static var supportsSecureCoding: Bool { true }

    private static func parseCGRect(_ str: String?) -> CGRect? {
        guard let str = str else { return nil }
        // Format: "{{x, y}, {w, h}}"
        let cleaned = str
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: " ", with: "")
        let parts = cleaned.split(separator: ",").compactMap { Double($0) }
        guard parts.count == 4 else { return nil }
        return CGRect(origin: CGPoint(x: parts[0], y: parts[1]),
                      size: CGSize(width: parts[2], height: parts[3]))
    }
}

// MARK: LookinHierarchyInfo

@objc(LookinHierarchyInfo)
class LookinHierarchyInfo: NSObject, NSSecureCoding {
    @objc var displayItems: [LookinDisplayItem]?
    @objc var appInfo: LookinAppInfo?
    @objc var colorAlias: [AnyHashable: Any]?
    @objc var collapsedClassList: [String]?
    @objc var serverVersion: Int32 = 0

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        displayItems = coder.decodeObject(of: [NSArray.self, LookinDisplayItem.self], forKey: "1") as? [LookinDisplayItem]
        appInfo = coder.decodeObject(of: LookinAppInfo.self, forKey: "2")
        colorAlias = coder.decodeObject(of: [NSDictionary.self], forKey: "3") as? [AnyHashable: Any]
        collapsedClassList = coder.decodeObject(of: [NSArray.self, NSString.self], forKey: "4") as? [String]
        serverVersion = coder.decodeInt32(forKey: "serverVersion")
    }

    func encode(with coder: NSCoder) {
        coder.encode(displayItems, forKey: "1")
        coder.encode(appInfo, forKey: "2")
        coder.encode(colorAlias, forKey: "3")
        coder.encode(collapsedClassList, forKey: "4")
        coder.encode(serverVersion, forKey: "serverVersion")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinAttribute

@objc(LookinAttribute)
class LookinAttribute: NSObject, NSSecureCoding {
    @objc var displayTitle: String?
    @objc var identifier: String?
    @objc var attrType: Int = 0
    @objc var value: Any?
    @objc var extraValue: Any?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        displayTitle = coder.decodeObject(of: NSString.self, forKey: "displayTitle") as? String
        identifier = coder.decodeObject(of: NSString.self, forKey: "identifier") as? String
        attrType = coder.decodeInteger(forKey: "attrType")
        value = coder.decodeObject(forKey: "value")
        extraValue = coder.decodeObject(forKey: "extraValue")
    }

    func encode(with coder: NSCoder) {
        coder.encode(displayTitle, forKey: "displayTitle")
        coder.encode(identifier, forKey: "identifier")
        coder.encode(attrType, forKey: "attrType")
        coder.encode(value as? Any, forKey: "value")
        coder.encode(extraValue as? Any, forKey: "extraValue")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: - Register all model classes for NSKeyedUnarchiver

func registerLookinClasses() {
    NSKeyedUnarchiver.setClass(LookinConnectionAttachment.self, forClassName: "LookinConnectionAttachment")
    NSKeyedUnarchiver.setClass(LookinConnectionResponseAttachment.self, forClassName: "LookinConnectionResponseAttachment")
    NSKeyedUnarchiver.setClass(LookinAppInfo.self, forClassName: "LookinAppInfo")
    NSKeyedUnarchiver.setClass(LookinObject.self, forClassName: "LookinObject")
    NSKeyedUnarchiver.setClass(LookinDisplayItem.self, forClassName: "LookinDisplayItem")
    NSKeyedUnarchiver.setClass(LookinHierarchyInfo.self, forClassName: "LookinHierarchyInfo")
    NSKeyedUnarchiver.setClass(LookinAttribute.self, forClassName: "LookinAttribute")
}
