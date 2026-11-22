import QtQuick
import qs.Common
import qs.DCommon.Widgets

Column {
    id: tv

    property string label: ""
    property int value: 0
    property string suffix: ""

    spacing: 2

    StyledText {
        text: tv.label
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
    }

    StyledText {
        text: tv.suffix ? tv.value + tv.suffix : ClightService.formatTimeout(tv.value)
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }
}
