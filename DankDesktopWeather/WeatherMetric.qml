import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.DCommon.Widgets

RowLayout {
    id: metric

    property string icon: ""
    property string label: ""
    property string value: ""
    property color accentColor: Theme.primary
    property color textColor: Theme.surfaceText
    property color dimColor: Theme.surfaceVariantText
    property bool compact: false
    property real iconSize: Theme.iconSizeSmall
    property real fontSize: Theme.fontSizeSmall

    spacing: 2

    DIcon {
        name: metric.icon
        size: metric.compact ? metric.iconSize - 2 : metric.iconSize
        color: metric.accentColor
    }

    ColumnLayout {
        spacing: 0
        visible: !metric.compact

        StyledText {
            visible: metric.label.length > 0
            text: metric.label
            font.pixelSize: metric.fontSize - 2
            color: metric.dimColor
        }

        StyledText {
            text: metric.value
            font.pixelSize: metric.fontSize
            color: metric.textColor
        }
    }

    StyledText {
        visible: metric.compact
        text: metric.value
        font.pixelSize: metric.fontSize
        color: metric.textColor
    }
}
