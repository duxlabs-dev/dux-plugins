import QtQuick
import qs.Common
import qs.DCommon.Widgets
import "../services"

DListItem {
    id: root

    required property string deviceId
    property real inset: Theme.spacingM

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property var device: PhoneConnectService.devices[deviceId] ?? null
    readonly property bool reachable: device?.isReachable ?? false
    readonly property bool paired: device?.isPaired ?? false
    readonly property bool incomingRequest: device?.isPairRequestedByPeer ?? false
    readonly property bool outgoingRequest: device?.isPairRequested ?? false
    readonly property string status: {
        const parts = [PhoneConnectService.statusText(device)];
        if (incomingRequest && device.verificationKey)
            parts.push(device.verificationKey);
        if (reachable && paired && (device.batteryCharge ?? -1) >= 0)
            parts.push(device.batteryCharge + "%");
        return parts.join(" • ");
    }

    isSelected: PhoneConnectService.selectedDeviceId === deviceId
    Accessible.name: device?.name ?? deviceId
    onClicked: PhoneConnectService.selectDevice(deviceId)

    DIcon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: root.inset
        anchors.verticalCenter: parent.verticalCenter
        name: PhoneConnectService.getDeviceIcon(root.device)
        size: Theme.iconSize
        color: root.reachable ? root.contentColor : root.supportingContentColor
    }

    Column {
        anchors.left: glyph.right
        anchors.leftMargin: Theme.spacingM
        anchors.right: trailing.left
        anchors.rightMargin: Theme.spacingS
        anchors.verticalCenter: parent.verticalCenter

        StyledText {
            width: parent.width
            text: root.device?.name ?? root.deviceId
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Theme.fontWeightMedium
            color: root.contentColor
            elide: Text.ElideRight
        }

        StyledText {
            width: parent.width
            text: root.status
            font.pixelSize: Theme.fontSizeSmall
            color: root.supportingContentColor
            elide: Text.ElideRight
        }
    }

    Row {
        id: trailing
        anchors.right: parent.right
        anchors.rightMargin: root.inset - (Theme.iconButtonSize - Theme.iconSizeMedium) / 2
        anchors.verticalCenter: parent.verticalCenter

        DActionButton {
            visible: root.incomingRequest
            buttonSize: Theme.iconButtonSize
            iconName: "check"
            iconColor: root.contentColor
            tooltipText: I18n.trFor(root.pluginId, "Accept", "KDE Connect accept pairing button")
            onClicked: PhoneConnectService.acceptPairing(root.deviceId)
        }

        DActionButton {
            visible: root.incomingRequest
            buttonSize: Theme.iconButtonSize
            iconName: "close"
            iconColor: root.contentColor
            tooltipText: I18n.trFor(root.pluginId, "Reject", "KDE Connect reject pairing button")
            onClicked: PhoneConnectService.rejectPairing(root.deviceId)
        }

        DActionButton {
            visible: root.reachable && !root.paired && !root.incomingRequest && !root.outgoingRequest
            buttonSize: Theme.iconButtonSize
            iconName: "link"
            iconColor: root.contentColor
            tooltipText: I18n.trFor(root.pluginId, "Request Pairing", "KDE Connect request pairing button")
            onClicked: PhoneConnectService.requestPairing(root.deviceId)
        }

        DActionButton {
            visible: root.paired
            buttonSize: Theme.iconButtonSize
            iconName: "link_off"
            iconColor: root.contentColor
            tooltipText: I18n.trFor(root.pluginId, "Unpair", "KDE Connect unpair tooltip")
            onClicked: PhoneConnectService.unpair(root.deviceId)
        }
    }
}
