pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.Common
import qs.Modules.Plugins
import qs.DCommon.Widgets
import "./components"
import "./services"

PluginComponent {
    id: root

    readonly property string phonePluginId: PhoneConnectService.pluginId
    readonly property var device: PhoneConnectService.selectedDevice
    readonly property bool reachable: PhoneConnectService.selectedReachable
    readonly property int batteryCharge: reachable ? (device.batteryCharge ?? -1) : -1
    readonly property bool charging: reachable && device.batteryCharging === true
    readonly property color chargeColor: {
        if (batteryCharge <= 20)
            return Theme.error;
        if (batteryCharge <= 50)
            return Theme.warning;
        return Theme.success;
    }
    property real detailContentHeight: maximumDetailHeight
    readonly property real maximumDetailHeight: Theme.listItemHeight * 8

    ccWidgetIcon: reachable ? "phonelink" : "phonelink_off"
    ccWidgetPrimaryText: PhoneConnectService.backendName
    ccWidgetSecondaryText: {
        if (!PhoneConnectService.available)
            return I18n.trFor(phonePluginId, "Unavailable", "Phone Connect unavailable status");
        if (!device)
            return I18n.trFor(phonePluginId, "No devices", "Phone Connect no devices status");
        if (!reachable)
            return device.name + " (" + I18n.trFor(phonePluginId, "Offline", "Phone Connect offline status") + ")";
        return batteryCharge >= 0 ? device.name + " • " + batteryCharge + "%" : device.name;
    }
    ccWidgetIsActive: reachable
    ccDetailHeight: Math.min(maximumDetailHeight, detailContentHeight)

    component PillContent: Item {
        id: pill

        property bool vertical: false
        readonly property Item basePill: {
            let p = parent;
            while (p && p.visualWidth === undefined)
                p = p.parent;
            return p;
        }

        implicitWidth: pillGrid.implicitWidth
        implicitHeight: pillGrid.implicitHeight

        ClippingRectangle {
            anchors.centerIn: parent
            width: pill.basePill?.visualWidth ?? 0
            height: pill.basePill?.visualHeight ?? 0
            visible: PhoneConnectService.chargingFill && root.charging
            radius: (root.barConfig?.noBackground ?? false) ? 0 : Theme.cornerRadius
            color: "transparent"

            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: pill.vertical ? parent.width : parent.width * root.batteryCharge / 100
                height: pill.vertical ? parent.height * root.batteryCharge / 100 : parent.height
                color: Theme.withAlpha(root.chargeColor, Theme.stateLayerFocus)
            }
        }

        Grid {
            id: pillGrid
            anchors.centerIn: parent
            columns: pill.vertical ? 1 : 2
            spacing: Theme.spacingXXS
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter

            DIcon {
                id: pillIcon
                name: root.reachable ? "smartphone" : "phonelink_off"
                size: pill.vertical ? root.iconSizeLarge : root.iconSize
                color: root.charging ? Theme.primary : Theme.widgetIconColor

                DIcon {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -Theme.spacingXXS
                    visible: root.charging
                    name: "bolt"
                    size: pillIcon.size / 2
                    color: Theme.primary
                }
            }

            StyledText {
                visible: root.batteryCharge >= 0
                text: pill.vertical ? String(root.batteryCharge) : root.batteryCharge + "%"
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
            }
        }
    }

    horizontalBarPill: Component {
<<<<<<< HEAD
        Item {
            id: horizWrapper
            implicitWidth: horizRow.implicitWidth
            implicitHeight: horizRow.implicitHeight
            DropArea {
                id: horizDropArea
                anchors.fill: parent
                anchors.margins: -15

                property bool isDragActive: false

                onEntered: drag => {
                    if (drag.hasUrls && root.hasDevice && root.selectedDevice?.isReachable) {
                        isDragActive = true;
                        drag.accept();
                    } else {
                        isDragActive = false;
                        drag.ignore();
                    }
                }
                onExited: {
                    isDragActive = false;
                }
                onDropped: drop => {
                    isDragActive = false;
                    if (drop.hasUrls && root.hasDevice && root.selectedDevice?.isReachable) {
                        for (let i = 0; i < drop.urls.length; ++i) {
                            PhoneConnectService.shareFile(root.selectedDeviceId, drop.urls[i], function(response) {
                                if (response && response.error) {
                                    ToastService.showError(I18n.tr("Failed to send file", "Phone Connect error"), response.error);
                                } else {
                                    ToastService.showInfo(I18n.tr("Sending file to %1...", "Phone Connect share action").arg(root.selectedDevice?.name || "device"));
                                }
                            });
                        }
                        drop.accept();
                    }
                }
            }

            Item {
                id: hWaveContainer
                readonly property var basePill: {
                    let p = parent;
                    while (p && p.visualWidth === undefined) {
                        p = p.parent;
                    }
                    return p;
                }
                width: basePill ? basePill.visualWidth : 0
                height: basePill ? basePill.visualHeight : 0
                anchors.centerIn: parent
                visible: root.enableChargingAnimation && root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharging ?? false)

                Rectangle {
                    id: hWaveMask
                    anchors.fill: parent
                    radius: (root.barConfig?.noBackground ?? false) ? 0 : Theme.cornerRadius
                    visible: false
                    layer.enabled: true
                }

                Rectangle {
                    id: hChargeFill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * ((root.selectedDevice?.batteryCharge ?? 0) / 100.0)
                    color: {
                        const charge = root.selectedDevice?.batteryCharge ?? 0;
                        if (charge <= 20)
                            return Theme.withAlpha(Theme.error, 0.15);
                        if (charge <= 50)
                            return Theme.withAlpha(Theme.warning, 0.15);
                        return Theme.withAlpha(Theme.success, 0.15);
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.standardEasing
                        }
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: hWaveMask
                }
            }

            Row {
                id: horizRow
                anchors.centerIn: parent
                spacing: (root.barConfig?.noBackground ?? false) ? 1 : 2

                Item {
                    width: phoneIcon.width
                    height: phoneIcon.height
                    anchors.verticalCenter: parent.verticalCenter

                    DIcon {
                        id: phoneIcon
                        name: horizDropArea.isDragActive ? "share" : (root.hasDevice && root.selectedDevice.isReachable ? "smartphone" : "phonelink_off")
                        size: Theme.barIconSize(root.barThickness, -4)
                        color: {
                            if (!PhoneConnectService.available)
                                return Theme.widgetIconColor;
                            if (horizDropArea.isDragActive || (root.hasDevice && root.selectedDevice?.isReachable && root.selectedDevice?.batteryCharging))
                                return Theme.primary;
                            return Theme.widgetIconColor;
                        }
                    }

                    DIcon {
                        visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharging ?? false) && !horizDropArea.isDragActive
                        name: "bolt"
                        size: phoneIcon.size * 0.45
                        color: Theme.primary
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -2
                        anchors.bottomMargin: -1
                    }
                }

                StyledText {
                    visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharge ?? -1) >= 0
                    text: (root.selectedDevice?.batteryCharge ?? 0) + "%"
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                    color: Theme.widgetTextColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    visible: !PhoneConnectService.available
                    text: "N/A"
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                    color: Theme.widgetTextColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            id: vertWrapper
            implicitWidth: vertCol.implicitWidth
            implicitHeight: vertCol.implicitHeight
            DropArea {
                id: vertDropArea
                anchors.fill: parent
                anchors.margins: -15

                property bool isDragActive: false

                onEntered: drag => {
                    if (drag.hasUrls && root.hasDevice && root.selectedDevice?.isReachable) {
                        isDragActive = true;
                        drag.accept();
                    } else {
                        isDragActive = false;
                        drag.ignore();
                    }
                }
                onExited: {
                    isDragActive = false;
                }
                onDropped: drop => {
                    isDragActive = false;
                    if (drop.hasUrls && root.hasDevice && root.selectedDevice?.isReachable) {
                        for (let i = 0; i < drop.urls.length; ++i) {
                            PhoneConnectService.shareFile(root.selectedDeviceId, drop.urls[i], function(response) {
                                if (response && response.error) {
                                    ToastService.showError(I18n.tr("Failed to send file", "Phone Connect error"), response.error);
                                } else {
                                    ToastService.showInfo(I18n.tr("Sending file to %1...", "Phone Connect share action").arg(root.selectedDevice?.name || "device"));
                                }
                            });
                        }
                        drop.accept();
                    }
                }
            }

            Item {
                id: vWaveContainer
                readonly property var basePill: {
                    let p = parent;
                    while (p && p.visualWidth === undefined) {
                        p = p.parent;
                    }
                    return p;
                }
                width: basePill ? basePill.visualWidth : 0
                height: basePill ? basePill.visualHeight : 0
                anchors.centerIn: parent
                visible: root.enableChargingAnimation && root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharging ?? false)

                Rectangle {
                    id: vWaveMask
                    anchors.fill: parent
                    radius: (root.barConfig?.noBackground ?? false) ? 0 : Theme.cornerRadius
                    visible: false
                    layer.enabled: true
                }

                Rectangle {
                    id: vChargeFill
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * ((root.selectedDevice?.batteryCharge ?? 0) / 100.0)
                    color: {
                        const charge = root.selectedDevice?.batteryCharge ?? 0;
                        if (charge <= 20)
                            return Theme.withAlpha(Theme.error, 0.15);
                        if (charge <= 50)
                            return Theme.withAlpha(Theme.warning, 0.15);
                        return Theme.withAlpha(Theme.success, 0.15);
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.mediumDuration
                            easing.type: Theme.standardEasing
                        }
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: vWaveMask
                }
            }

            Column {
                id: vertCol
                anchors.centerIn: parent
                spacing: 1

                Item {
                    width: phoneIconV.width
                    height: phoneIconV.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    DIcon {
                        id: phoneIconV
                        name: vertDropArea.isDragActive ? "share" : (root.hasDevice && root.selectedDevice.isReachable ? "smartphone" : "phonelink_off")
                        size: Theme.barIconSize(root.barThickness)
                        color: {
                            if (!PhoneConnectService.available)
                                return Theme.widgetIconColor;
                            if (vertDropArea.isDragActive || (root.hasDevice && root.selectedDevice?.isReachable && root.selectedDevice?.batteryCharging))
                                return Theme.primary;
                            return Theme.widgetIconColor;
                        }
                    }

                    DIcon {
                        visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharging ?? false) && !vertDropArea.isDragActive
                        name: "bolt"
                        size: phoneIconV.size * 0.45
                        color: Theme.primary
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -2
                        anchors.bottomMargin: -1
                    }
                }

                StyledText {
                    visible: root.hasDevice && root.selectedDevice?.isReachable && (root.selectedDevice?.batteryCharge ?? -1) >= 0
                    text: (root.selectedDevice?.batteryCharge ?? 0).toString()
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                    color: Theme.widgetTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
=======
        PillContent {}
    }

    verticalBarPill: Component {
        PillContent {
            vertical: true
>>>>>>> origin/master
        }
    }

    popoutContent: Component {
        Item {
            id: popoutFrame

            property var parentPopout: null
            readonly property real bodyHeight: parentPopout ? parentPopout.renderedAlignedHeight - PopoutMetrics.contentPadding * 2 : implicitHeight
            readonly property bool bodyGrowing: bodyHeight < implicitHeight - 1

            implicitHeight: popoutPanel.implicitHeight
            height: bodyGrowing ? Math.max(0, bodyHeight) : implicitHeight
            clip: bodyGrowing

            PhoneConnectPanel {
                id: popoutPanel
                width: parent.width
                parentPopout: popoutFrame.parentPopout
                shortcuts: true
                onCloseRequested: root.closePopout()
            }
        }
    }

    ccDetailContent: Component {
        DFlickable {
            anchors.fill: parent
            contentHeight: detailPanel.implicitHeight
            clip: true

            PhoneConnectPanel {
                id: detailPanel
                width: parent.width
                inset: Theme.spacingL
                onImplicitHeightChanged: root.detailContentHeight = implicitHeight
            }
        }
    }
}
