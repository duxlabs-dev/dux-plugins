import QtQuick
import qs.Common
import qs.DCommon.Widgets

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string value: ""
    property color valueColor: Theme.onSurface

    implicitHeight: Theme.buttonHeightXXS

    DIcon {
        id: glyph
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        size: Theme.iconSizeMedium
        color: Theme.primary
    }

    StyledText {
        anchors.left: glyph.right
        anchors.leftMargin: Theme.spacingS
        anchors.right: valueText.left
        anchors.rightMargin: Theme.spacingS
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.onSurfaceVariant
        elide: Text.ElideRight
    }

    StyledText {
        id: valueText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.value
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Theme.fontWeightMedium
        color: root.valueColor
    }
}
