pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.DCommon.Widgets
import "../services"

DCard {
    id: root

    required property string deviceId
    property bool switcherOpen: false

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property var device: PhoneConnectService.devices[deviceId] ?? null
    readonly property bool reachable: device?.isReachable ?? false
    readonly property real headingHeight: Theme.iconButtonSize
    readonly property real fullDetailsHeight: headingHeight + Theme.spacingM + Theme.buttonHeightXXS * 4 + Theme.spacingS * 3
    readonly property var info: {
        const rows = [];
        if (!device)
            return rows;
        if ((device.batteryCharge ?? -1) >= 0)
            rows.push({
                icon: PhoneConnectService.getBatteryIcon(device),
                label: I18n.trFor(pluginId, "Battery", "KDE Connect battery label"),
                value: device.batteryCharge + "%",
                accent: device.batteryCharging === true
            });
        if ((device.networkStrength ?? -1) >= 0)
            rows.push({
                icon: PhoneConnectService.getNetworkIcon(device),
                label: I18n.trFor(pluginId, "Signal Strength", "KDE Connect signal strength label"),
                value: PhoneConnectService.getNetworkStrengthLabel(device),
                accent: false
            });
        if (device.networkType)
            rows.push({
                icon: PhoneConnectService.getNetworkTypeIcon(device),
                label: I18n.trFor(pluginId, "Network Type", "KDE Connect network type label"),
                value: PhoneConnectService.getNetworkTypeLabel(device),
                accent: false
            });
        if (device.notificationCount !== undefined)
            rows.push({
                icon: "notifications",
                label: I18n.trFor(pluginId, "Notifications", "KDE Connect notifications label"),
                value: String(device.notificationCount),
                accent: false
            });
        return rows;
    }
    readonly property var actions: {
        const list = [
            {
                name: "ring",
                plugin: "findmyphone",
                icon: "phone_in_talk",
                label: I18n.trFor(pluginId, "Ring", "KDE Connect ring tooltip")
            },
            {
                name: "ping",
                plugin: "ping",
                icon: "notifications_active",
                label: I18n.trFor(pluginId, "Ping", "KDE Connect ping tooltip")
            },
            {
                name: "browse",
                plugin: "sftp",
                icon: "folder_open",
                label: I18n.trFor(pluginId, "Browse Files", "KDE Connect browse tooltip")
            },
            {
                name: "clipboard",
                plugin: "clipboard",
                icon: "content_paste_go",
                label: I18n.trFor(pluginId, "Send Clipboard", "KDE Connect send clipboard tooltip")
            },
            {
                name: "share",
                plugin: "share",
                icon: "share",
                label: I18n.trFor(pluginId, "Share", "KDE Connect share tooltip")
            },
            {
                name: "sms",
                plugin: "sms",
                icon: "sms",
                label: I18n.trFor(pluginId, "SMS", "KDE Connect SMS tooltip")
            }
        ];
        return PhoneConnectService.clipboardAction ? list : list.filter(action => action.name !== "clipboard");
    }

    signal switcherToggled
    signal actionTriggered(string name)

    restRadius: Theme.cornerRadiusL
    height: layout.implicitHeight + pad * 2

    Column {
        id: layout
        width: parent.width
        spacing: Theme.spacingM

        Row {
            id: body
            width: parent.width
            spacing: Theme.spacingM

            DeviceMock {
                id: mock
                visible: PhoneConnectService.showDevicePlaceholder
                maximumHeight: root.fullDetailsHeight
                deviceType: root.device?.type ?? "phone"
                image: PhoneConnectService.deviceImage(root.deviceId)
                reachable: root.reachable
            }

            Column {
                width: mock.visible ? body.width - mock.width - body.spacing : body.width
                spacing: Theme.spacingM

                Item {
                    width: parent.width
                    height: root.headingHeight

                    Column {
                        anchors.left: parent.left
                        anchors.right: switchButton.left
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXXS

                        StyledText {
                            width: parent.width
                            text: root.device?.name ?? root.deviceId
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Theme.fontWeightMedium
                            color: Theme.onSurface
                            elide: Text.ElideRight
                        }

                        StyledText {
                            width: parent.width
                            text: PhoneConnectService.statusText(root.device)
                            font.pixelSize: Theme.fontSizeSmall
                            color: root.reachable ? Theme.primary : Theme.onSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }

                    DActionButton {
                        id: switchButton
                        anchors.right: parent.right
                        anchors.rightMargin: -(width - iconSize) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        buttonSize: root.headingHeight
                        iconName: root.switcherOpen ? "unfold_less" : "unfold_more"
                        tooltipText: I18n.trFor(root.pluginId, "Devices", "Phone Connect device list toggle tooltip")
                        onClicked: root.switcherToggled()
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingS
                    visible: root.info.length > 0

                    Repeater {
                        model: root.info

                        InfoRow {
                            required property var modelData
                            width: parent.width
                            icon: modelData.icon
                            label: modelData.label
                            value: modelData.value
                            valueColor: modelData.accent ? Theme.primary : Theme.onSurface
                        }
                    }
                }
            }
        }

        Row {
            id: actionRow
            width: parent.width
            spacing: Theme.spacingXS

            Repeater {
                model: root.actions

                DIconButton {
                    required property var modelData
                    width: (actionRow.width - actionRow.spacing * (root.actions.length - 1)) / root.actions.length
                    variant: "tonal"
                    iconName: modelData.icon
                    tooltipText: modelData.label
                    enabled: PhoneConnectService.canUse(root.deviceId, modelData.plugin)
                    onClicked: root.actionTriggered(modelData.name)
                }
            }
        }
    }
}
