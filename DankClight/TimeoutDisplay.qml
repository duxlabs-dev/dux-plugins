import QtQuick
import qs.Common
import qs.Widgets
import qs.DCommon.Widgets

Column {
    id: display

    property string icon: ""
    property string label: ""
    property string value: ""

    spacing: 2

    Row {
        spacing: 4

        DIcon {
            name: display.icon
            size: 12
            color: Theme.surfaceVariantText
        }

        StyledText {
            text: display.label
            font.pixelSize: 10
            color: Theme.surfaceVariantText
        }
    }

    StyledText {
        text: display.value
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.Medium
        color: Theme.surfaceText
    }
}
