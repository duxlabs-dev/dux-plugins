import QtQuick
import qs.Common
import qs.DCommon.Widgets

Column {
    property string title: ""

    width: parent.width
    spacing: Theme.spacingS

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: title
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }
}
