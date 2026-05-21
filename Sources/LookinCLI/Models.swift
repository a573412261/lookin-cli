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
        data = coder.decodeObject(of: [LookinHierarchyInfo.self, LookinAppInfo.self, LookinDisplayItem.self, LookinObject.self, LookinAttribute.self, NSArray.self, NSDictionary.self, NSString.self, NSNumber.self, NSData.self], forKey: "0")
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
        classChainList = coder.decodeObject(of: [NSArray.self, NSString.self], forKey: "classChainList") as? [String]
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
    @objc var customInfo: LookinCustomDisplayItemInfo?
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
        customInfo = coder.decodeObject(of: LookinCustomDisplayItemInfo.self, forKey: "customInfo")
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

        attributesGroupList = coder.decodeObject(of: [NSArray.self, LookinAttributesGroup.self], forKey: "attributesGroupList") as? [Any]
        customAttrGroupList = coder.decodeObject(of: [NSArray.self, LookinAttributesGroup.self], forKey: "customAttrGroupList") as? [Any]
        eventHandlers = coder.decodeObject(of: [NSArray.self, LookinEventHandler.self], forKey: "eventHandlers") as? [Any]
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

// MARK: LookinStringTwoTuple

@objc(LookinStringTwoTuple)
class LookinStringTwoTuple: NSObject, NSSecureCoding {
    @objc var first: String?
    @objc var second: String?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        first = coder.decodeObject(of: NSString.self, forKey: "first") as? String
        second = coder.decodeObject(of: NSString.self, forKey: "second") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(first, forKey: "first")
        coder.encode(second, forKey: "second")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinEventHandler

@objc(LookinEventHandler)
class LookinEventHandler: NSObject, NSSecureCoding {
    @objc var handlerType: Int = 0
    @objc var eventName: String?
    @objc var targetActions: [LookinStringTwoTuple]?
    @objc var inheritedRecognizerName: String?
    @objc var gestureRecognizerIsEnabled: Bool = false
    @objc var gestureRecognizerDelegator: String?
    @objc var recognizerIvarTraces: [String]?
    @objc var recognizerOid: UInt = 0

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        handlerType = coder.decodeInteger(forKey: "handlerType")
        eventName = coder.decodeObject(of: NSString.self, forKey: "eventName") as? String
        targetActions = coder.decodeObject(of: [NSArray.self, LookinStringTwoTuple.self], forKey: "targetActions") as? [LookinStringTwoTuple]
        inheritedRecognizerName = coder.decodeObject(of: NSString.self, forKey: "inheritedRecognizerName") as? String
        gestureRecognizerIsEnabled = coder.decodeBool(forKey: "gestureRecognizerIsEnabled")
        gestureRecognizerDelegator = coder.decodeObject(of: NSString.self, forKey: "gestureRecognizerDelegator") as? String
        recognizerIvarTraces = coder.decodeObject(of: [NSArray.self, NSString.self], forKey: "recognizerIvarTraces") as? [String]
        recognizerOid = (coder.decodeObject(of: NSNumber.self, forKey: "recognizerOid") as? NSNumber)?.uintValue ?? 0
    }

    func encode(with coder: NSCoder) {
        coder.encode(handlerType, forKey: "handlerType")
        coder.encode(eventName, forKey: "eventName")
        coder.encode(targetActions, forKey: "targetActions")
        coder.encode(inheritedRecognizerName, forKey: "inheritedRecognizerName")
        coder.encode(gestureRecognizerIsEnabled, forKey: "gestureRecognizerIsEnabled")
        coder.encode(gestureRecognizerDelegator, forKey: "gestureRecognizerDelegator")
        coder.encode(recognizerIvarTraces, forKey: "recognizerIvarTraces")
        coder.encode(NSNumber(value: recognizerOid), forKey: "recognizerOid")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinAttributesSection

@objc(LookinAttributesSection)
class LookinAttributesSection: NSObject, NSSecureCoding {
    @objc var identifier: String?
    @objc var attributes: [LookinAttribute]?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        identifier = coder.decodeObject(of: NSString.self, forKey: "identifier") as? String
        attributes = coder.decodeObject(of: [NSArray.self, LookinAttribute.self], forKey: "attributes") as? [LookinAttribute]
    }

    func encode(with coder: NSCoder) {
        coder.encode(identifier, forKey: "identifier")
        coder.encode(attributes, forKey: "attributes")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinAttributesGroup

@objc(LookinAttributesGroup)
class LookinAttributesGroup: NSObject, NSSecureCoding {
    @objc var userCustomTitle: String?
    @objc var identifier: String?
    @objc var attrSections: [LookinAttributesSection]?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        userCustomTitle = coder.decodeObject(of: NSString.self, forKey: "userCustomTitle") as? String
        identifier = coder.decodeObject(of: NSString.self, forKey: "identifier") as? String
        attrSections = coder.decodeObject(of: [NSArray.self, LookinAttributesSection.self], forKey: "attrSections") as? [LookinAttributesSection]
    }

    func encode(with coder: NSCoder) {
        coder.encode(userCustomTitle, forKey: "userCustomTitle")
        coder.encode(identifier, forKey: "identifier")
        coder.encode(attrSections, forKey: "attrSections")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinIvarTrace

@objc(LookinIvarTrace)
class LookinIvarTrace: NSObject, NSSecureCoding {
    @objc var relation: String?
    @objc var hostClassName: String?
    @objc var ivarName: String?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        relation = coder.decodeObject(of: NSString.self, forKey: "relation") as? String
        hostClassName = coder.decodeObject(of: NSString.self, forKey: "hostClassName") as? String
        ivarName = coder.decodeObject(of: NSString.self, forKey: "ivarName") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(relation, forKey: "relation")
        coder.encode(hostClassName, forKey: "hostClassName")
        coder.encode(ivarName, forKey: "ivarName")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinCustomDisplayItemInfo

@objc(LookinCustomDisplayItemInfo)
class LookinCustomDisplayItemInfo: NSObject, NSSecureCoding {
    @objc var title: String?
    @objc var subtitle: String?
    @objc var danceuiSource: String?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        title = coder.decodeObject(of: NSString.self, forKey: "title") as? String
        subtitle = coder.decodeObject(of: NSString.self, forKey: "subtitle") as? String
        danceuiSource = coder.decodeObject(of: NSString.self, forKey: "danceuiSource") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(subtitle, forKey: "subtitle")
        coder.encode(danceuiSource, forKey: "danceuiSource")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinAutoLayoutConstraint

@objc(LookinAutoLayoutConstraint)
class LookinAutoLayoutConstraint: NSObject, NSSecureCoding {
    @objc var effective: Bool = false
    @objc var active: Bool = false
    @objc var shouldBeArchived: Bool = false
    @objc var firstItem: LookinObject?
    @objc var firstItemType: Int = 0
    @objc var firstAttribute: Int = 0
    @objc var relation: Int = 0
    @objc var secondItem: LookinObject?
    @objc var secondItemType: Int = 0
    @objc var secondAttribute: Int = 0
    @objc var multiplier: Double = 1.0
    @objc var constant: Double = 0
    @objc var priority: Double = 1000
    @objc var identifier: String?

    override init() { super.init() }

    required init?(coder: NSCoder) {
        super.init()
        effective = coder.decodeBool(forKey: "effective")
        active = coder.decodeBool(forKey: "active")
        shouldBeArchived = coder.decodeBool(forKey: "shouldBeArchived")
        firstItem = coder.decodeObject(of: LookinObject.self, forKey: "firstItem")
        firstItemType = coder.decodeInteger(forKey: "firstItemType")
        firstAttribute = coder.decodeInteger(forKey: "firstAttribute")
        relation = coder.decodeInteger(forKey: "relation")
        secondItem = coder.decodeObject(of: LookinObject.self, forKey: "secondItem")
        secondItemType = coder.decodeInteger(forKey: "secondItemType")
        secondAttribute = coder.decodeInteger(forKey: "secondAttribute")
        multiplier = coder.decodeDouble(forKey: "multiplier")
        constant = coder.decodeDouble(forKey: "constant")
        priority = coder.decodeDouble(forKey: "priority")
        identifier = coder.decodeObject(of: NSString.self, forKey: "identifier") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(effective, forKey: "effective")
        coder.encode(active, forKey: "active")
        coder.encode(shouldBeArchived, forKey: "shouldBeArchived")
        coder.encode(firstItem, forKey: "firstItem")
        coder.encode(firstItemType, forKey: "firstItemType")
        coder.encode(firstAttribute, forKey: "firstAttribute")
        coder.encode(relation, forKey: "relation")
        coder.encode(secondItem, forKey: "secondItem")
        coder.encode(secondItemType, forKey: "secondItemType")
        coder.encode(secondAttribute, forKey: "secondAttribute")
        coder.encode(multiplier, forKey: "multiplier")
        coder.encode(constant, forKey: "constant")
        coder.encode(priority, forKey: "priority")
        coder.encode(identifier, forKey: "identifier")
    }

    static var supportsSecureCoding: Bool { true }
}

// MARK: LookinDashboardBlueprint

@objc(LookinDashboardBlueprint)
class LookinDashboardBlueprint: NSObject, NSSecureCoding {
    override init() { super.init() }
    required init?(coder: NSCoder) { super.init() }
    func encode(with coder: NSCoder) {}
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
    NSKeyedUnarchiver.setClass(LookinEventHandler.self, forClassName: "LookinEventHandler")
    NSKeyedUnarchiver.setClass(LookinStringTwoTuple.self, forClassName: "LookinStringTwoTuple")
    NSKeyedUnarchiver.setClass(LookinAttributesGroup.self, forClassName: "LookinAttributesGroup")
    NSKeyedUnarchiver.setClass(LookinAttributesSection.self, forClassName: "LookinAttributesSection")
    NSKeyedUnarchiver.setClass(LookinIvarTrace.self, forClassName: "LookinIvarTrace")
    NSKeyedUnarchiver.setClass(LookinCustomDisplayItemInfo.self, forClassName: "LookinCustomDisplayItemInfo")
    NSKeyedUnarchiver.setClass(LookinAutoLayoutConstraint.self, forClassName: "LookinAutoLayoutConstraint")
    NSKeyedUnarchiver.setClass(LookinDashboardBlueprint.self, forClassName: "LookinDashboardBlueprint")
}
