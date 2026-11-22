pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.DCommon.Widgets
import "../services"

Column {
    id: root

    property var parentPopout: null
    property bool shortcuts: false
    property real inset: Theme.spacingM
    property bool switcherOpen: false
    property string openForm: ""

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property string deviceId: PhoneConnectService.selectedDeviceId
    readonly property var deviceIds: PhoneConnectService.deviceIds
    readonly property bool devicePaired: PhoneConnectService.selectedDevice?.isPaired ?? false
    readonly property bool incomingRequest: deviceIds.some(id => PhoneConnectService.devices[id]?.isPairRequestedByPeer)
    readonly property bool listShown: deviceIds.length > 0 && (switcherOpen || !devicePaired || incomingRequest)
    readonly property bool showsImages: visible && devicePaired && PhoneConnectService.recentImagesPath !== "" && PhoneConnectService.hasPlugin(deviceId, "sftp")
    readonly property bool typing: {
        const item = Window.activeFocusItem;
        return item instanceof TextInput || item instanceof TextEdit;
    }
    property bool imagesHeld: false

    signal closeRequested

    function runAction(name) {
        switch (name) {
        case "ring":
            PhoneConnectService.ring(deviceId);
            return;
        case "ping":
            PhoneConnectService.ping(deviceId);
            return;
        case "clipboard":
            PhoneConnectService.sendClipboard(deviceId);
            return;
        case "browse":
            closeRequested();
            PhoneConnectService.browse(deviceId);
            return;
        case "share":
        case "sms":
            openForm = openForm === name ? "" : name;
            return;
        }
    }

    function holdImages(wanted) {
        if (wanted === imagesHeld)
            return;
        imagesHeld = wanted;
        PhoneConnectService.imageViewers += wanted ? 1 : -1;
    }

    spacing: PopoutMetrics.contentGap
    onDeviceIdChanged: {
        openForm = "";
        switcherOpen = false;
    }
    onShowsImagesChanged: holdImages(showsImages)
    onVisibleChanged: {
        if (visible)
            PhoneConnectService.refreshDevices();
    }
    Component.onCompleted: holdImages(showsImages)
    Component.onDestruction: holdImages(false)

    Shortcut {
        sequence: "Ctrl+Tab"
        enabled: root.shortcuts && root.visible
        onActivated: PhoneConnectService.selectRelative(1)
    }

    Shortcut {
        sequence: "Ctrl+Shift+Tab"
        enabled: root.shortcuts && root.visible
        onActivated: PhoneConnectService.selectRelative(-1)
    }

    Shortcut {
        sequence: "S"
        enabled: root.shortcuts && root.visible && !root.typing && PhoneConnectService.canUse(root.deviceId, "share")
        onActivated: root.runAction("share")
    }

    Repeater {
        model: Math.min(root.deviceIds.length, 9)

        Item {
            id: slot
            required property int index

            Shortcut {
                sequence: "Alt+" + (slot.index + 1)
                enabled: root.shortcuts && root.visible
                onActivated: PhoneConnectService.selectDevice(root.deviceIds[slot.index])
            }
        }
    }

    PanelMessage {
        width: parent.width
        visible: !PhoneConnectService.available
        pad: root.inset
        iconName: "phonelink_off"
        heading: I18n.trFor(root.pluginId, "Phone Connect Not Available", "Phone Connect unavailable error title")
        hint: I18n.trFor(root.pluginId, "Start Dux Connect, KDE Connect, or Valent to use this plugin", "Phone Connect daemon hint")
    }

    PanelMessage {
        width: parent.width
        visible: PhoneConnectService.available && root.deviceIds.length === 0
        pad: root.inset
        iconName: "devices"
        heading: I18n.trFor(root.pluginId, "No devices found", "KDE Connect no devices message")
        hint: I18n.trFor(root.pluginId, "Make sure KDE Connect or Valent is running on your other devices", "Phone Connect hint message")
    }

    DeviceCard {
        width: parent.width
        visible: root.devicePaired
        pad: root.inset
        deviceId: root.deviceId
        switcherOpen: root.listShown
        onSwitcherToggled: root.switcherOpen = !root.switcherOpen
        onActionTriggered: name => root.runAction(name)
    }

    Column {
        width: parent.width
        spacing: Theme.groupedListGap
        visible: root.listShown

        Repeater {
            model: root.deviceIds

            DeviceListRow {
                required property string modelData
                required property int index
                width: parent.width
                deviceId: modelData
                inset: root.inset
                firstInGroup: index === 0
                lastInGroup: index === root.deviceIds.length - 1
            }
        }
    }

    Loader {
        width: parent.width
        active: root.openForm === "share"
        visible: active
        sourceComponent: ShareDialog {
            pad: root.inset
            deviceId: root.deviceId
            parentPopout: root.parentPopout
            onCloseRequested: root.openForm = ""
        }
    }

    Loader {
        width: parent.width
        active: root.openForm === "sms"
        visible: active
        sourceComponent: SmsDialog {
            pad: root.inset
            deviceId: root.deviceId
            onCloseRequested: root.openForm = ""
        }
    }

    MediaCard {
        width: parent.width
        visible: root.devicePaired && PhoneConnectService.showOngoingMedia && active
        pad: root.inset
        deviceId: root.deviceId
    }

    RecentImagesCard {
        width: parent.width
        visible: root.showsImages
        pad: root.inset
        onCloseRequested: root.closeRequested()
    }
}
