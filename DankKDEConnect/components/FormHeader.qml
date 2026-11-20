import QtQuick
import qs.Common
import qs.DCommon.Widgets

Item {
    id: root

    property string title: ""

    signal closeRequested

    width: parent?.width ?? 0
    height: closeButton.height

    StyledText {
        anchors.left: parent.left
        anchors.right: closeButton.left
        anchors.rightMargin: Theme.spacingS
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Theme.fontWeightMedium
        color: Theme.primary
        elide: Text.ElideRight
    }

    DActionButton {
        id: closeButton
        anchors.right: parent.right
        anchors.rightMargin: -(width - iconSize) / 2
        iconName: "close"
        Accessible.name: I18n.tr("Close")
        onClicked: root.closeRequested()
    }
}
