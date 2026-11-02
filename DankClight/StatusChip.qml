import QtQuick
import qs.Common
import qs.Widgets
import qs.DCommon.Widgets

StyledRect {
    id: chip

    property string icon: ""
    property string text: ""
    property bool active: true
    property bool warning: false

    width: chipRow.implicitWidth + Theme.spacingS * 2
    height: 24
    radius: 12
    color: warning ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.2) : active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : Theme.surfaceContainerHigh

    Row {
        id: chipRow
        anchors.centerIn: parent
        spacing: 4

        DIcon {
            name: chip.icon
            size: 14
            color: chip.warning ? Theme.warning : chip.active ? Theme.primary : Theme.surfaceVariantText
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: chip.text
            font.pixelSize: 10
            font.weight: Font.Medium
            color: chip.warning ? Theme.warning : chip.active ? Theme.primary : Theme.surfaceVariantText
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
