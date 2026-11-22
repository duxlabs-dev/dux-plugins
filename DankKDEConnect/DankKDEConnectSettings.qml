pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Services
import qs.Modals.FileBrowser
import qs.Modules.Plugins
import qs.DCommon.Widgets
import "./services"

PluginSettings {
    id: root

    pluginId: PhoneConnectService.pluginId

    readonly property var deviceTypes: ["phone", "tablet", "laptop", "desktop", "tv"]
    readonly property var deviceTypeLabels: [I18n.trFor(pluginId, "Phone", "Phone Connect device type"), I18n.trFor(pluginId, "Tablet", "Phone Connect device type"), I18n.trFor(pluginId, "Laptop", "Phone Connect device type"), I18n.trFor(pluginId, "Desktop", "Phone Connect device type"), I18n.trFor(pluginId, "TV", "Phone Connect device type")]

    function typeIndex(device) {
        switch (device?.type) {
        case "tablet":
            return 1;
        case "laptop":
            return 2;
        case "desktop":
        case "computer":
            return 3;
        case "tv":
            return 4;
        default:
            return 0;
        }
    }

    function saveRemotePath(deviceId, path, setting) {
        PhoneConnectService.getSftpMountPoint(deviceId, function (mountPoint) {
            if (path === "" || mountPoint === "" || path.startsWith(mountPoint)) {
                PhoneConnectService.setRecentImagesPath(deviceId, path);
                return;
            }
            ToastService.showError(I18n.trFor(root.pluginId, "Invalid Path", "Phone Connect settings error"), I18n.trFor(root.pluginId, "Path must be located on the remote device.", "Phone Connect settings error"));
            setting.revert();
        });
    }

    component SettingLabel: Column {
        id: label

        property string title: ""
        property string description: ""

        width: parent.width
        spacing: Theme.spacingXS

<<<<<<< HEAD
        function loadValue(key, def) {
            return PluginService.loadPluginData(root.pluginId, key, def);
        }

        function saveValue(key, val) {
            PluginService.savePluginData(root.pluginId, key, val);
            PluginService.setGlobalVar(root.pluginId, key, val);
        }

        function backendName(backend) {
            switch (backend) {
            case PhoneConnectService.Backend.Valent:
                return "Valent";
            case PhoneConnectService.Backend.DuxConnect:
                return "Dux Connect";
            default:
                return "KDE Connect";
            }
        }

        function setPreferredBackend(name, persist) {
            switch (name) {
            case "Valent":
                PhoneConnectService.preferredBackend = PhoneConnectService.Backend.Valent;
                break;
            case "Dux Connect":
            case "DankConnect": // value saved by pre-rebrand alpha builds
                PhoneConnectService.preferredBackend = PhoneConnectService.Backend.DuxConnect;
                break;
            default:
                PhoneConnectService.preferredBackend = PhoneConnectService.Backend.KDEConnect;
            }
            if (persist)
                saveValue("preferredBackend", name);
        }

        readonly property string selectedDeviceId: loadValue("selectedDeviceId", "")
        readonly property string targetDeviceId: selectedDeviceId || (PhoneConnectService.deviceIds.length > 0 ? PhoneConnectService.deviceIds[0] : "")
        readonly property var targetDevice: PhoneConnectService.getDevice(targetDeviceId)
        readonly property string targetDeviceName: targetDevice ? targetDevice.name : "Device 1"

        property var deviceTypeMap: ({})
        property var deviceImageMap: ({})
        property bool hasDeviceImageMapSetting: false

        function refreshDeviceTypeMap() {
            const rawMap = loadValue("deviceTypeMap", "");
            if (rawMap) {
                try {
                    deviceTypeMap = JSON.parse(rawMap);
                    return;
                } catch (e) {}
            }
            deviceTypeMap = {};
        }

        function refreshDeviceImageMap() {
            const rawMap = loadValue("deviceImageMap", "");
            hasDeviceImageMapSetting = rawMap !== undefined && rawMap !== null && rawMap !== "";
            if (rawMap) {
                try {
                    deviceImageMap = JSON.parse(rawMap);
                    return;
                } catch (e) {}
            }
            deviceImageMap = {};
        }

        Component.onCompleted: {
            refreshDeviceTypeMap();
            refreshDeviceImageMap();
            setPreferredBackend(loadValue("preferredBackend", "KDE Connect"), false);
        }

        Connections {
            target: PluginService
            ignoreUnknownSignals: true
            function onGlobalVarChanged(pluginId, varName) {
                if (pluginId === root.pluginId) {
                    if (varName === "deviceTypeMap") {
                        mainSettingsCol.refreshDeviceTypeMap();
                    } else if (varName === "deviceImageMap") {
                        mainSettingsCol.refreshDeviceImageMap();
                    } else if (varName === "preferredBackend") {
                        mainSettingsCol.setPreferredBackend(mainSettingsCol.loadValue("preferredBackend", "KDE Connect"), false);
                    }
                }
            }
            function onPluginDataChanged(pluginId) {
                if (pluginId === root.pluginId) {
                    mainSettingsCol.refreshDeviceTypeMap();
                    mainSettingsCol.refreshDeviceImageMap();
                    mainSettingsCol.setPreferredBackend(mainSettingsCol.loadValue("preferredBackend", "KDE Connect"), false);
                }
            }
        }

        function getDeviceImage(deviceId) {
            if (!deviceId)
                return "";
            if (deviceImageMap[deviceId])
                return deviceImageMap[deviceId];
            // Fallback to legacy single image if it's the first device
            if (!hasDeviceImageMapSetting && PhoneConnectService.deviceIds.length > 0 && deviceId === PhoneConnectService.deviceIds[0]) {
                return loadValue("customPhoneImage", "");
            }
            return "";
        }

        function saveDeviceImage(deviceId, path) {
            if (!deviceId)
                return;
            let newMap = Object.assign({}, deviceImageMap);
            if (path === "" || path === null) {
                delete newMap[deviceId];
            } else {
                newMap[deviceId] = path;
            }
            deviceImageMap = newMap;
            hasDeviceImageMapSetting = true;
            saveValue("deviceImageMap", JSON.stringify(newMap));
        }

        function getDeviceRecentImagesPath(deviceId) {
            if (!deviceId)
                return "";
            const rawMap = loadValue("deviceRecentImagesPathMap", "");
            if (rawMap) {
                try {
                    const map = JSON.parse(rawMap);
                    if (map[deviceId])
                        return map[deviceId];
                } catch (e) {}
            }
            // Fallback to legacy single recentImagesPath if it's the first device
            if (PhoneConnectService.deviceIds.length > 0 && deviceId === PhoneConnectService.deviceIds[0]) {
                return loadValue("recentImagesPath", "");
            }
            return "";
        }

        function saveDeviceRecentImagesPath(deviceId, path) {
            if (!deviceId)
                return;
            let map = {};
            const rawMap = loadValue("deviceRecentImagesPathMap", "");
            if (rawMap) {
                try {
                    map = JSON.parse(rawMap);
                } catch (e) {}
            }
            if (path === "" || path === null) {
                delete map[deviceId];
            } else {
                map[deviceId] = path;
            }
            const serialized = JSON.stringify(map);
            saveValue("deviceRecentImagesPathMap", serialized);
        }

        function getDeviceType(deviceId) {
            if (!deviceId)
                return "Phone";
            if (deviceTypeMap[deviceId]) {
                switch (deviceTypeMap[deviceId]) {
                case "phone":
                    return "Phone";
                case "tablet":
                    return "Tablet";
                case "laptop":
                    return "Laptop";
                case "desktop":
                    return "PC";
                }
            }
            // Fallback to real device type from service
            const dev = PhoneConnectService.getDevice(deviceId);
            if (dev && dev.type) {
                switch (dev.type) {
                case "phone":
                case "smartphone":
                    return "Phone";
                case "tablet":
                    return "Tablet";
                case "laptop":
                    return "Laptop";
                case "desktop":
                case "computer":
                    return "PC";
                }
            }
            return "Phone";
        }

        function saveDeviceType(deviceId, typeStr) {
            if (!deviceId)
                return;
            let typeVal = "";
            switch (typeStr) {
            case "Phone":
                typeVal = "phone";
                break;
            case "Tablet":
                typeVal = "tablet";
                break;
            case "Laptop":
                typeVal = "laptop";
                break;
            case "PC":
                typeVal = "desktop";
                break;
            }

            let newMap = Object.assign({}, deviceTypeMap);
            if (typeVal === "") {
                delete newMap[deviceId];
            } else {
                newMap[deviceId] = typeVal;
            }
            deviceTypeMap = newMap;
            saveValue("deviceTypeMap", JSON.stringify(newMap));
        }

        // 1. Connection Status Card
        Rectangle {
            width: parent.width
            height: statusCol.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            Column {
                id: statusCol
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                RowLayout {
                    width: parent.width
                    spacing: Theme.spacingM
                    DIcon {
                        name: PhoneConnectService.available ? "check_circle" : "error"
                        size: 22
                        color: PhoneConnectService.available ? Theme.success : Theme.error
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: Theme.spacingXXS
                        StyledText {
                            text: PhoneConnectService.available ? (serviceName + " Running") : "No Backend Running"
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }
                        StyledText {
                            text: PhoneConnectService.available ? ("Announced as: " + PhoneConnectService.announcedName + " (" + PhoneConnectService.selfId + ")") : "Please start Dux Connect, kdeconnectd, or Valent"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                    DButton {
                        text: "Refresh"
                        iconName: "refresh"
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: PhoneConnectService.available ? PhoneConnectService.refreshDevices() : PhoneConnectService.detectBackend()
                    }
                }

                RowLayout {
                    width: parent.width
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Preferred Backend"
                        color: Theme.surfaceText
                        Layout.fillWidth: true
                    }

                    DankDropdown {
                        compactMode: true
                        dropdownWidth: 180
                        currentValue: mainSettingsCol.backendName(PhoneConnectService.preferredBackend)
                        options: ["KDE Connect", "Valent", "Dux Connect"]
                        optionIcons: ["devices", "devices", "phonelink"]
                        onValueChanged: function(value) {
                            if (value !== mainSettingsCol.backendName(PhoneConnectService.preferredBackend))
                                mainSettingsCol.setPreferredBackend(value, true);
                        }
                    }
                }

                // Device List inside status card
                Column {
                    width: parent.width
                    spacing: Theme.spacingS
                    visible: PhoneConnectService.available && PhoneConnectService.deviceIds.length > 0

                    StyledText {
                        text: "Paired Devices"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                        color: Theme.surfaceText
                    }

                    Repeater {
                        model: PhoneConnectService.deviceIds

                        Rectangle {
                            required property string modelData
                            readonly property var device: PhoneConnectService.getDevice(modelData)

                            width: parent.width
                            height: deviceRow.implicitHeight + Theme.spacingS * 2
                            radius: Theme.cornerRadius
                            color: Theme.surfaceContainerHigh
                            border.color: Theme.withAlpha(Theme.outline, 0.15)
                            border.width: 1

                            Row {
                                id: deviceRow
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Theme.spacingS
                                spacing: Theme.spacingS

                                DIcon {
                                    name: PhoneConnectService.getDeviceIcon(device)
                                    size: Theme.iconSize
                                    color: device?.isReachable ? Theme.primary : Theme.surfaceVariantText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacingXXS

                                    StyledText {
                                        text: device?.name || modelData
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: device?.isReachable ? "Connected" : (device?.isPaired ? "Offline" : "Not paired")
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: device?.isReachable ? Theme.success : Theme.surfaceVariantText
                                    }
                                }
                            }

                            Row {
                                visible: device && (device.batteryCharge ?? -1) >= 0
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: Theme.spacingS
                                spacing: Theme.spacingXS

                                DIcon {
                                    name: PhoneConnectService.getBatteryIcon(device)
                                    size: Theme.iconSize - 4
                                    color: device?.batteryCharging ? Theme.success : Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: (device?.batteryCharge ?? 0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                }
                            }
                        }
                    }
                }

                StyledText {
                    visible: PhoneConnectService.available && PhoneConnectService.deviceIds.length === 0
                    text: "No devices found. Pair a device using KDE Connect settings."
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
=======
        StyledText {
            width: parent.width
            text: label.title
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Theme.fontWeightMedium
            color: Theme.surfaceText
            wrapMode: Text.WordWrap
>>>>>>> origin/master
        }

        StyledText {
            width: parent.width
            text: label.description
            visible: text !== ""
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
        }
    }

    component PathSetting: Column {
        id: setting

        property alias title: pathLabel.title
        property alias description: pathLabel.description
        property alias placeholder: pathField.placeholderText
        property string value: ""

        signal edited(string path)
        signal browseRequested

        function revert() {
            pathField.text = value;
        }

        width: parent.width
        spacing: Theme.spacingS
        onValueChanged: revert()

        SettingLabel {
            id: pathLabel
        }

        Row {
            width: parent.width
            spacing: Theme.spacingS

            DTextField {
                id: pathField
                width: parent.width - browseButton.width - parent.spacing
                onEditingFinished: {
                    if (text !== setting.value)
                        setting.edited(text);
                }
            }

            DActionButton {
                id: browseButton
                anchors.verticalCenter: parent.verticalCenter
                buttonSize: Theme.iconButtonSize
                iconName: "folder_open"
                tooltipText: I18n.trFor(root.pluginId, "Browse", "Phone Connect browse for path button")
                onClicked: setting.browseRequested()
            }
        }
    }

    component SectionTitle: Column {
        id: section

        property string text: ""
        property string iconName: ""
        property string detail: ""

        width: parent.width
        spacing: Theme.spacingM

        StyledRect {
            width: parent.width
            height: Theme.dividerWidth
            radius: 0
            color: Theme.outlineVariant
        }

        Row {
            width: parent.width
            spacing: Theme.spacingS

            DIcon {
                id: sectionIcon
                anchors.verticalCenter: parent.verticalCenter
                visible: section.iconName !== ""
                name: section.iconName
                size: Theme.iconSizeMedium
                color: Theme.primary
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - (sectionIcon.visible ? sectionIcon.width + parent.spacing : 0) - (sectionDetail.visible ? sectionDetail.width + parent.spacing : 0)
                text: section.text
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Theme.fontWeightMedium
                color: Theme.primary
                elide: Text.ElideRight
            }

            StyledText {
                id: sectionDetail
                anchors.verticalCenter: parent.verticalCenter
                visible: text !== ""
                text: section.detail
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }
    }

    Row {
        width: parent.width
        spacing: Theme.spacingM

        DIcon {
            id: statusIcon
            anchors.verticalCenter: parent.verticalCenter
            name: PhoneConnectService.available ? "check_circle" : "error"
            size: Theme.iconSize
            color: PhoneConnectService.available ? Theme.success : Theme.error
        }

        SettingLabel {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - statusIcon.width - statusRefresh.width - parent.spacing * 2
            title: PhoneConnectService.available ? PhoneConnectService.backendName : I18n.trFor(root.pluginId, "Phone Connect Not Available", "Phone Connect unavailable error title")
            description: PhoneConnectService.available ? PhoneConnectService.announcedName : I18n.trFor(root.pluginId, "Start KDE Connect or Valent to use this plugin", "Phone Connect daemon hint")
        }

        DRefreshButton {
            id: statusRefresh
            anchors.verticalCenter: parent.verticalCenter
            buttonSize: Theme.iconButtonSize
            busy: PhoneConnectService.isRefreshing
            onClicked: PhoneConnectService.refreshDevices()
        }
    }

    Repeater {
        model: PhoneConnectService.deviceIds

        Column {
            id: deviceSection

            required property string modelData
            readonly property string deviceId: modelData
            readonly property var device: PhoneConnectService.devices[deviceId] ?? null

            width: parent.width
            spacing: Theme.spacingM

            SectionTitle {
                iconName: PhoneConnectService.getDeviceIcon(deviceSection.device)
                text: deviceSection.device?.name ?? deviceSection.deviceId
                detail: PhoneConnectService.statusText(deviceSection.device)
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM

                SettingLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - preferredToggle.width - parent.spacing
                    title: I18n.trFor(root.pluginId, "Preferred Device", "Phone Connect preferred device setting")
                    description: I18n.trFor(root.pluginId, "Select this device whenever it connects.", "Phone Connect preferred device setting description")
                }

                DToggle {
                    id: preferredToggle
                    anchors.verticalCenter: parent.verticalCenter
                    checked: PhoneConnectService.preferredDeviceId === deviceSection.deviceId
                    onToggled: isChecked => PhoneConnectService.saveSetting("preferredDeviceId", isChecked ? deviceSection.deviceId : "")
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM

                SettingLabel {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - typeDropdown.width - parent.spacing
                    title: I18n.trFor(root.pluginId, "Device Type", "Phone Connect device type setting")
                    description: I18n.trFor(root.pluginId, "Sets the icon and illustration.", "Phone Connect device type setting description")
                }

                DDropdown {
                    id: typeDropdown
                    anchors.verticalCenter: parent.verticalCenter
                    compactMode: true
                    alignPopupRight: true
                    currentValue: root.deviceTypeLabels[root.typeIndex(deviceSection.device)]
                    options: root.deviceTypeLabels
                    optionIcons: ["smartphone", "tablet", "laptop", "desktop_windows", "tv"]
                    onValueChanged: value => PhoneConnectService.setDeviceType(deviceSection.deviceId, root.deviceTypes[root.deviceTypeLabels.indexOf(value)])
                }
            }

            PathSetting {
                title: I18n.trFor(root.pluginId, "Custom Image", "Phone Connect custom device image setting")
                description: I18n.trFor(root.pluginId, "Shown in place of the device illustration.", "Phone Connect custom device image setting description")
                placeholder: I18n.trFor(root.pluginId, "Absolute path or URL", "Phone Connect custom device image placeholder")
                value: PhoneConnectService.deviceImage(deviceSection.deviceId).replace(/^file:\/\//, "")
                onEdited: path => PhoneConnectService.setDeviceImage(deviceSection.deviceId, path)
                onBrowseRequested: {
                    imageBrowser.deviceId = deviceSection.deviceId;
                    imageBrowser.open();
                }
            }

            PathSetting {
                id: folderSetting
                title: I18n.trFor(root.pluginId, "Recent Images Folder", "Phone Connect recent images folder setting")
                description: I18n.trFor(root.pluginId, "A folder on the device, listed in the popout.", "Phone Connect recent images folder setting description")
                value: PhoneConnectService.recentImagesPathFor(deviceSection.deviceId)
                onEdited: path => root.saveRemotePath(deviceSection.deviceId, path, folderSetting)
                onBrowseRequested: PhoneConnectService.mountAndWait(deviceSection.deviceId, function () {
                    PhoneConnectService.getSftpMountPoint(deviceSection.deviceId, function (mountPoint) {
                        folderBrowser.deviceId = deviceSection.deviceId;
                        folderBrowser.setting = folderSetting;
                        folderBrowser.revealPath = mountPoint;
                        folderBrowser.open();
                    });
                })
            }
        }
    }

    SectionTitle {
        text: I18n.trFor(root.pluginId, "Display", "Phone Connect settings section")
    }

    ToggleSetting {
        settingKey: "hideUnpairedDevices"
        label: I18n.trFor(root.pluginId, "Hide Unpaired Devices", "Phone Connect hide unpaired devices setting")
        description: I18n.trFor(root.pluginId, "Only list paired devices and pairing requests.", "Phone Connect hide unpaired devices setting description")
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "showDevicePlaceholder"
        label: I18n.trFor(root.pluginId, "Show Device Illustration", "Phone Connect device illustration setting")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showOngoingMedia"
        label: I18n.trFor(root.pluginId, "Show Ongoing Media", "Phone Connect ongoing media setting")
        description: I18n.trFor(root.pluginId, "Media playing on the device, with playback controls.", "Phone Connect ongoing media setting description")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "enableClipboardAction"
        label: I18n.trFor(root.pluginId, "Show Clipboard Action", "Phone Connect clipboard action setting")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "enableChargingAnimation"
        label: I18n.trFor(root.pluginId, "Show Charging Fill", "Phone Connect charging fill setting")
        description: I18n.trFor(root.pluginId, "Fill the bar widget to the battery level while the device charges.", "Phone Connect charging fill setting description")
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "scanSubdirectories"
        label: I18n.trFor(root.pluginId, "Scan Subfolders for Images", "Phone Connect scan subfolders setting")
        defaultValue: false
    }

    SliderSetting {
        settingKey: "maxRecentImages"
        label: I18n.trFor(root.pluginId, "Recent Images Shown", "Phone Connect recent images count setting")
        defaultValue: 4
        minimum: 1
        maximum: 12
    }

    SliderSetting {
        settingKey: "stateUpdateInterval"
        label: I18n.trFor(root.pluginId, "Refresh Interval", "Phone Connect refresh interval setting")
        description: I18n.trFor(root.pluginId, "Seconds between device state refreshes. 0 turns polling off.", "Phone Connect refresh interval setting description")
        defaultValue: 30
        minimum: 0
        maximum: 300
    }

    FileBrowserSurfaceModal {
        id: imageBrowser

        property string deviceId: ""

        browserTitle: I18n.trFor(root.pluginId, "Select Device Image", "Phone Connect image browser title")
        browserType: "generic"
        showHiddenFiles: false
        fileExtensions: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        onFileSelected: path => PhoneConnectService.setDeviceImage(deviceId, path)
    }

    FileBrowserSurfaceModal {
        id: folderBrowser

        property string deviceId: ""
        property var setting: null

        browserTitle: I18n.trFor(root.pluginId, "Select Recent Images Folder", "Phone Connect folder browser title")
        browserType: "generic"
        folderMode: true
        onFileSelected: path => root.saveRemotePath(deviceId, path, setting)
    }
}
