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
        PillContent {}
    }

    verticalBarPill: Component {
        PillContent {
            vertical: true
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
