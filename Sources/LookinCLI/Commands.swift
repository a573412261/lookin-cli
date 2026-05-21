import Foundation

// MARK: - JSON Output Helpers

func jsonOutput(_ dict: [String: Any]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys, .prettyPrinted]) else {
        return "{\"error\":\"JSON serialization failed\"}"
    }
    return String(data: data, encoding: .utf8) ?? "{}"
}

func jsonOutput(_ array: [[String: Any]]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: array, options: [.sortedKeys, .prettyPrinted]) else {
        return "{\"error\":\"JSON serialization failed\"}"
    }
    return String(data: data, encoding: .utf8) ?? "[]"
}

extension LookinAppInfo {
    func toJSON() -> [String: Any] {
        var result: [String: Any] = [:]
        result["appName"] = appName ?? ""
        result["bundleId"] = appBundleIdentifier ?? ""
        result["device"] = deviceDescription ?? ""
        result["os"] = osDescription ?? ""
        result["serverVersion"] = Int(serverVersion)
        result["screenWidth"] = screenWidth
        result["screenHeight"] = screenHeight
        result["screenScale"] = screenScale
        return result
    }
}

extension LookinObject {
    func toJSON() -> [String: Any] {
        var result: [String: Any] = [:]
        result["oid"] = String(format: "0x%lx", oid)
        result["memoryAddress"] = memoryAddress ?? ""
        result["classChain"] = classChainList ?? []
        return result
    }
}

extension LookinDisplayItem {
    func toJSON(flat: Bool = false, includeChildren: Bool = true) -> [String: Any] {
        var result: [String: Any] = [:]

        // Class info
        if let viewObj = viewObject, let chain = viewObj.classChainList, !chain.isEmpty {
            result["class"] = chain[0]
        }
        if let title = customDisplayTitle {
            result["title"] = title
        }

        // OID
        if let viewObj = viewObject {
            result["oid"] = String(format: "0x%lx", viewObj.oid)
        }

        // Geometry
        result["frame"] = rectToJSON(frame)
        result["isHidden"] = isHidden
        result["alpha"] = alpha

        // Children
        if includeChildren, let subitems = subitems, !subitems.isEmpty {
            if flat {
                result["childrenCount"] = subitems.count
            } else {
                result["children"] = subitems.map { $0.toJSON(flat: flat, includeChildren: includeChildren) }
            }
        }

        return result
    }

    /// Flatten the entire hierarchy into a flat array
    func flatten() -> [[String: Any]] {
        var result: [LookinDisplayItem] = []
        collectFlat(into: &result)
        return result.map { $0.toJSON(includeChildren: false) }
    }

    func collectFlat(into array: inout [LookinDisplayItem]) {
        array.append(self)
        subitems?.forEach { $0.collectFlat(into: &array) }
    }
}

private func rectToJSON(_ rect: CGRect) -> [String: Any] {
    return [
        "x": rect.origin.x,
        "y": rect.origin.y,
        "width": rect.size.width,
        "height": rect.size.height,
    ]
}

// MARK: - Command Implementations

func cmdPing() {
    let client = LookinClient()
    let apps = client.discoverPorts()

    if apps.isEmpty {
        print(jsonOutput(["apps": []]))
        return
    }

    let appsJson = apps.map { app -> [String: Any] in
        return [
            "port": app.port,
            "serverVersion": app.serverVersion,
        ]
    }
    print(jsonOutput(["apps": appsJson]))
}

func cmdHierarchy(flat: Bool, filter: String?) {
    let client = LookinClient()

    // First discover
    let apps = client.discoverPorts()
    guard let app = apps.first else {
        print(jsonOutput(["error": "No LookinServer-enabled app found"]))
        return
    }

    do {
        try client.connect(port: app.port)
        let response = try client.sendRequest(type: .hierarchy)

        guard let hierarchyInfo = response.data as? LookinHierarchyInfo else {
            print(jsonOutput(["error": "Failed to decode hierarchy data"]))
            return
        }

        guard let items = hierarchyInfo.displayItems else {
            print(jsonOutput(["error": "No display items in response"]))
            return
        }

        // Apply filter
        var filteredItems = items
        if let filter = filter, !filter.isEmpty {
            filteredItems = filterItems(items, filter: filter)
        }

        if flat {
            let flatList = filteredItems.flatMap { $0.flatten() }
            print(jsonOutput(["items": flatList]))
        } else {
            let tree = filteredItems.map { $0.toJSON() }
            print(jsonOutput(["items": tree]))
        }

        client.disconnect()
    } catch {
        print(jsonOutput(["error": error.localizedDescription]))
        client.disconnect()
    }
}

func cmdInspect(oid: String, includeScreenshot: Bool) {
    let client = LookinClient()

    let apps = client.discoverPorts()
    guard let app = apps.first else {
        print(jsonOutput(["error": "No app found"]))
        return
    }

    do {
        try client.connect(port: app.port)

        // First get hierarchy to find the item
        let hierarchyResponse = try client.sendRequest(type: .hierarchy)
        guard let hierarchyInfo = hierarchyResponse.data as? LookinHierarchyInfo,
              let items = hierarchyInfo.displayItems else {
            print(jsonOutput(["error": "Failed to get hierarchy"]))
            return
        }

        // Find the item with matching OID
        guard let targetItem = findItem(items, oid: oid) else {
            print(jsonOutput(["error": "View with oid \(oid) not found"]))
            return
        }

        var result = targetItem.toJSON(includeChildren: false)

        // Add view/layer object details
        if let viewObj = targetItem.viewObject {
            result["viewObject"] = viewObj.toJSON()
            result["class"] = viewObj.classChainList?.first ?? "Unknown"
        }
        if let layerObj = targetItem.layerObject {
            result["layerObject"] = layerObj.toJSON()
        }
        if let vcObj = targetItem.hostViewControllerObject {
            result["hostViewController"] = vcObj.toJSON()
            result["hostViewControllerClass"] = vcObj.classChainList?.first ?? ""
        }

        // Add attributes
        if let attrGroups = targetItem.attributesGroupList {
            var attrs: [[String: Any]] = []
            for group in attrGroups {
                if let groupDict = group as? LookinAttribute {
                    attrs.append([
                        "title": groupDict.displayTitle ?? "",
                        "identifier": groupDict.identifier ?? "",
                        "value": groupDict.value ?? NSNull(),
                    ])
                }
            }
            result["attributes"] = attrs
        }

        // Add background color if available
        if let bgColor = targetItem.backgroundColor, bgColor.count >= 4 {
            result["backgroundColor"] = [
                "r": bgColor[0],
                "g": bgColor[1],
                "b": bgColor[2],
                "a": bgColor[3],
            ]
        }

        if includeScreenshot {
            result["hasScreenshot"] = targetItem.soloScreenshot != nil
        }

        print(jsonOutput(result))
        client.disconnect()
    } catch {
        print(jsonOutput(["error": error.localizedDescription]))
        client.disconnect()
    }
}

func cmdSearch(classFilter: String?, textFilter: String?, accessibilityLabel: String?) {
    let client = LookinClient()

    let apps = client.discoverPorts()
    guard let app = apps.first else {
        print(jsonOutput(["error": "No app found"]))
        return
    }

    do {
        try client.connect(port: app.port)
        let response = try client.sendRequest(type: .hierarchy)

        guard let hierarchyInfo = response.data as? LookinHierarchyInfo,
              let items = hierarchyInfo.displayItems else {
            print(jsonOutput(["error": "Failed to get hierarchy"]))
            return
        }

        var allItems: [LookinDisplayItem] = []
        for item in items {
            item.collectFlat(into: &allItems)
        }

        var results = allItems.compactMap { item -> [String: Any]? in
            let className = item.viewObject?.classChainList?.first ?? ""
            let title = item.customDisplayTitle ?? ""

            if let cf = classFilter, !className.localizedCaseInsensitiveContains(cf) {
                return nil
            }
            if let tf = textFilter, !title.localizedCaseInsensitiveContains(tf) {
                return nil
            }

            return item.toJSON(includeChildren: false)
        }

        print(jsonOutput([
            "results": results,
            "totalCount": results.count,
        ]))
        client.disconnect()
    } catch {
        print(jsonOutput(["error": error.localizedDescription]))
        client.disconnect()
    }
}

func cmdScreenshot(oid: String, outputPath: String) {
    let client = LookinClient()

    let apps = client.discoverPorts()
    guard let app = apps.first else {
        print(jsonOutput(["error": "No app found"]))
        return
    }

    do {
        try client.connect(port: app.port)

        // Get hierarchy first to find the item
        let hierarchyResponse = try client.sendRequest(type: .hierarchy)
        guard let hierarchyInfo = hierarchyResponse.data as? LookinHierarchyInfo,
              let items = hierarchyInfo.displayItems else {
            print(jsonOutput(["error": "Failed to get hierarchy"]))
            return
        }

        guard let targetItem = findItem(items, oid: oid) else {
            print(jsonOutput(["error": "View with oid \(oid) not found"]))
            return
        }

        if let screenshotData = targetItem.soloScreenshot {
            let url = URL(fileURLWithPath: outputPath)
            try screenshotData.write(to: url)
            print(jsonOutput(["success": true, "path": outputPath, "size": screenshotData.count]))
        } else {
            // Try fetching the image via dedicated request
            // For now, report no screenshot available
            print(jsonOutput(["error": "No screenshot data available for this view"]))
        }

        client.disconnect()
    } catch {
        print(jsonOutput(["error": error.localizedDescription]))
        client.disconnect()
    }
}

func cmdModify(oid: String, attr: String, value: String) {
    print(jsonOutput([
        "error": "Modify command requires LookinServer protocol details for \(attr)",
        "oid": oid,
        "note": "This command needs the LookinAttributeModification model implementation",
    ]))
}

// MARK: - Helper Functions

private func filterItems(_ items: [LookinDisplayItem], filter: String) -> [LookinDisplayItem] {
    return items.compactMap { item -> LookinDisplayItem? in
        let className = item.viewObject?.classChainList?.first ?? ""
        let matches = className.localizedCaseInsensitiveContains(filter)

        let filteredChildren = item.subitems.map { filterItems($0, filter: filter) } ?? []

        if matches || !filteredChildren.isEmpty {
            return item
        }
        return nil
    }
}

private func findItem(_ items: [LookinDisplayItem], oid: String) -> LookinDisplayItem? {
    for item in items {
        if let viewObj = item.viewObject {
            let itemOid = String(format: "0x%lx", viewObj.oid)
            if itemOid == oid { return item }
        }
        if let subitems = item.subitems {
            for sub in subitems {
                if let found = findItem([sub], oid: oid) {
                    return found
                }
            }
        }
    }
    return nil
}
