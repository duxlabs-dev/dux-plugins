import QtQuick
import qs.Common
import qs.DCommon.Widgets

DCard {
    id: root

    property string iconName: ""
    property string heading: ""
    property string hint: ""

    restRadius: Theme.cornerRadiusL
    height: layout.implicitHeight + pad * 2

    Column {
        id: layout
        width: parent.width
        spacing: Theme.spacingS

        DIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: root.iconName
            size: Theme.iconSizeLarge
            color: Theme.onSurfaceVariant
        }

        StyledText {
            width: parent.width
            text: root.heading
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Theme.fontWeightMedium
            color: Theme.onSurface
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        StyledText {
            width: parent.width
            text: root.hint
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
