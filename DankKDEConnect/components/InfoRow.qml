import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.DCommon.Widgets

RowLayout {
    id: root
    
    property string icon: ""
    property string label: ""
    property string value: ""
    property color valueColor: Theme.surfaceText

    spacing: Theme.spacingM
    Layout.fillWidth: true

    DIcon {
        name: root.icon
        size: 28
        color: Theme.primary
        Layout.alignment: Qt.AlignVCenter
    }

    Column {
        spacing: 0
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter

        StyledText {
            width: parent.width
            text: root.label
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            font.weight: Font.Medium
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

        StyledText {
            width: parent.width
            text: root.value
            font.pixelSize: Theme.fontSizeMedium
            color: root.valueColor
            font.weight: Font.Medium
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }
    }
}
