import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.DCommon.Widgets

PluginComponent {
    id: root

    ccWidgetIcon: ClightService.available ? ClightService.getBacklightIcon() : "brightness_auto"
    ccWidgetPrimaryText: "Clight"
    ccWidgetSecondaryText: {
        if (!ClightService.available)
            return "Unavailable";
        if (ClightService.suspended)
            return "Paused";
        let parts = [ClightService.blPercent + "% brightness"];
        if (ClightService.sensorAvailable)
            parts.push(ClightService.ambientPercent + "% ambient");
        return parts.join(" • ");
    }
    ccWidgetIsActive: ClightService.available && !ClightService.suspended && !ClightService.inhibited

    ccDetailContent: Component {
        Column {
            width: parent.width
            spacing: Theme.spacingS

            Flow {
                width: parent.width
                spacing: Theme.spacingXS

                StatusChip {
                    icon: ClightService.getDayTimeIcon()
                    text: ClightService.dayTimeText
                    active: true
                }

                StatusChip {
                    icon: ClightService.onBattery ? "battery_std" : "power"
                    text: ClightService.acStateText
                    active: !ClightService.onBattery
                }

                StatusChip {
                    visible: ClightService.sensorAvailable
                    icon: "sensors"
                    text: ClightService.ambientPercent + "% ambient"
                    active: true
                }

                StatusChip {
                    visible: ClightService.suspended
                    icon: "pause"
                    text: "Paused"
                    active: false
                    warning: true
                }

                StatusChip {
                    visible: ClightService.inhibited
                    icon: "block"
                    text: "Inhibited"
                    active: false
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                Repeater {
                    model: ClightService.backlights

                    delegate: Row {
                        required property var modelData
                        width: parent.width
                        spacing: Theme.spacingS

                        DIcon {
                            name: ClightService.getBacklightTypeIcon(modelData)
                            size: 16
                            color: Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: modelData.name
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            width: 80
                            elide: Text.ElideMiddle
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledRect {
                            width: parent.width - 140
                            height: 6
                            radius: 3
                            color: Theme.surfaceVariant
                            anchors.verticalCenter: parent.verticalCenter

                            StyledRect {
                                width: parent.width * modelData.brightness
                                height: parent.height
                                radius: 3
                                color: Theme.primary

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }
                        }

                        StyledText {
                            text: modelData.percent + "%"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            width: 35
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacingS

                DButton {
                    text: "Capture"
                    iconName: "photo_camera"
                    enabled: ClightService.available && ClightService.sensorAvailable
                    onClicked: ClightService.capture(true, false)
                }

                DButton {
                    text: ClightService.suspended ? "Resume" : "Pause"
                    iconName: ClightService.suspended ? "play_arrow" : "pause"
                    enabled: ClightService.available
                    onClicked: ClightService.setPaused(!ClightService.suspended)
                }

                DButton {
                    text: ClightService.inhibited ? "Uninhibit" : "Inhibit"
                    iconName: ClightService.inhibited ? "lock_open" : "lock"
                    enabled: ClightService.available
                    onClicked: ClightService.setInhibit(!ClightService.inhibited)
                }
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: (root.barConfig?.noBackground ?? false) ? 1 : 2

            DIcon {
                name: ClightService.available ? ClightService.getBacklightIcon() : "brightness_auto"
                size: Theme.barIconSize(root.barThickness, -4)
                color: {
                    if (!ClightService.available)
                        return Theme.widgetIconColor;
                    if (ClightService.suspended || ClightService.inhibited)
                        return Theme.surfaceVariantText;
                    return Theme.widgetIconColor;
                }
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: ClightService.available
                text: ClightService.blPercent + "%"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: (ClightService.suspended || ClightService.inhibited) ? Theme.surfaceVariantText : Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: !ClightService.available
                text: "N/A"
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DIcon {
                name: ClightService.available ? ClightService.getBacklightIcon() : "brightness_auto"
                size: Theme.barIconSize(root.barThickness)
                color: {
                    if (!ClightService.available)
                        return Theme.widgetIconColor;
                    if (ClightService.suspended || ClightService.inhibited)
                        return Theme.surfaceVariantText;
                    return Theme.widgetIconColor;
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: ClightService.available
                text: ClightService.blPercent.toString()
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: (ClightService.suspended || ClightService.inhibited) ? Theme.surfaceVariantText : Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "Clight"
            detailsText: {
                if (!ClightService.available)
                    return "Daemon not running";
                let parts = [ClightService.dayTimeText, ClightService.acStateText];
                if (ClightService.sensorAvailable)
                    parts.push(ClightService.ambientPercent + "% ambient");
                return parts.join(" • ");
            }
            showCloseButton: true

            headerActions: Component {
                Row {
                    spacing: 4

                    DActionButton {
                        iconName: "refresh"
                        iconColor: Theme.surfaceVariantText
                        buttonSize: 28
                        tooltipText: "Refresh"
                        tooltipSide: "bottom"
                        onClicked: ClightService.refresh()
                    }

                    DActionButton {
                        iconName: "photo_camera"
                        iconColor: Theme.surfaceVariantText
                        buttonSize: 28
                        enabled: ClightService.available && ClightService.sensorAvailable
                        tooltipText: "Capture now"
                        tooltipSide: "bottom"
                        onClicked: ClightService.capture(true, false)
                    }

                    DActionButton {
                        iconName: ClightService.suspended ? "play_arrow" : "pause"
                        iconColor: ClightService.suspended ? Theme.warning : Theme.surfaceVariantText
                        buttonSize: 28
                        enabled: ClightService.available
                        tooltipText: ClightService.suspended ? "Resume" : "Pause"
                        tooltipSide: "bottom"
                        onClicked: ClightService.setPaused(!ClightService.suspended)
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM

                StyledRect {
                    visible: !ClightService.available
                    width: parent.width
                    height: unavailableContent.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15)

                    Column {
                        id: unavailableContent
                        anchors.centerIn: parent
                        width: parent.width - Theme.spacingL * 2
                        spacing: Theme.spacingS

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: Theme.spacingS

                            DIcon {
                                name: "error"
                                size: Theme.iconSize
                                color: Theme.error
                            }

                            StyledText {
                                text: "Clight daemon not running"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.error
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: "Start clight service or install clight"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.error
                            opacity: 0.8
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Column {
                    visible: ClightService.available
                    width: parent.width
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        StatusChip {
                            icon: ClightService.getDayTimeIcon()
                            text: ClightService.dayTimeText
                            active: true
                        }

                        StatusChip {
                            icon: ClightService.onBattery ? "battery_std" : "power"
                            text: ClightService.acStateText
                            active: !ClightService.onBattery
                        }

                        StatusChip {
                            visible: ClightService.sensorAvailable
                            icon: "sensors"
                            text: "Sensor"
                            active: true
                        }

                        StatusChip {
                            visible: ClightService.suspended
                            icon: "pause"
                            text: "Paused"
                            active: false
                            warning: true
                        }

                        StatusChip {
                            visible: ClightService.inhibited
                            icon: "block"
                            text: "Inhibited"
                            active: false
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: backlightsCol.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh

                        Column {
                            id: backlightsCol
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Displays"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceVariantText
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.spacingS

                                Repeater {
                                    model: ClightService.backlights

                                    delegate: Column {
                                        required property var modelData
                                        required property int index
                                        width: parent.width
                                        spacing: 4

                                        Item {
                                            width: parent.width
                                            height: displayNameRow.implicitHeight

                                            Row {
                                                id: displayNameRow
                                                anchors.left: parent.left
                                                anchors.right: displayPercentText.left
                                                anchors.rightMargin: Theme.spacingS
                                                spacing: Theme.spacingS

                                                DIcon {
                                                    name: ClightService.getBacklightTypeIcon(modelData)
                                                    size: 18
                                                    color: Theme.primary
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Column {
                                                    spacing: 0
                                                    anchors.verticalCenter: parent.verticalCenter

                                                    StyledText {
                                                        text: modelData.name
                                                        font.pixelSize: Theme.fontSizeSmall
                                                        font.weight: Font.Medium
                                                        color: Theme.surfaceText
                                                    }

                                                    StyledText {
                                                        text: modelData.ddc ? "DDC" : (modelData.internal ? "Internal" : "External")
                                                        font.pixelSize: 10
                                                        color: Theme.surfaceVariantText
                                                    }
                                                }
                                            }

                                            StyledText {
                                                id: displayPercentText
                                                text: modelData.percent + "%"
                                                font.pixelSize: Theme.fontSizeLarge
                                                font.weight: Font.Bold
                                                color: Theme.primary
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        StyledRect {
                                            width: parent.width
                                            height: 8
                                            radius: 4
                                            color: Theme.surfaceVariant

                                            StyledRect {
                                                width: parent.width * modelData.brightness
                                                height: parent.height
                                                radius: 4
                                                color: Theme.primary

                                                Behavior on width {
                                                    NumberAnimation {
                                                        duration: 150
                                                        easing.type: Easing.OutQuad
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                StyledText {
                                    visible: ClightService.backlights.length === 0
                                    text: "No displays detected"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    font.italic: true
                                }
                            }
                        }
                    }

                    StyledRect {
                        visible: ClightService.sensorAvailable
                        width: parent.width
                        height: sensorCol.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh

                        Column {
                            id: sensorCol
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            Row {
                                width: parent.width

                                StyledText {
                                    text: "Ambient Light"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceVariantText
                                }

                                Item {
                                    width: parent.width - 140
                                    height: 1
                                }

                                StyledText {
                                    text: ClightService.ambientPercent + "%"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                }
                            }

                            StyledRect {
                                width: parent.width
                                height: 8
                                radius: 4
                                color: Theme.surfaceVariant

                                StyledRect {
                                    width: parent.width * ClightService.ambientBr
                                    height: parent.height
                                    radius: 4
                                    color: Theme.secondary

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }
                            }

                            Row {
                                visible: ClightService.screenBr > 0
                                width: parent.width
                                spacing: Theme.spacingXS

                                StyledText {
                                    text: "Screen compensation:"
                                    font.pixelSize: 10
                                    color: Theme.surfaceVariantText
                                }

                                StyledText {
                                    text: Math.round(ClightService.screenBr * 100) + "%"
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: daytimeCol.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh

                        Column {
                            id: daytimeCol
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Daytime"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceVariantText
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingL

                                Column {
                                    spacing: 2

                                    Row {
                                        spacing: Theme.spacingXS

                                        DIcon {
                                            name: "wb_sunny"
                                            size: 14
                                            color: Theme.warning
                                        }

                                        StyledText {
                                            text: "Sunrise"
                                            font.pixelSize: 10
                                            color: Theme.surfaceVariantText
                                        }
                                    }

                                    StyledText {
                                        text: ClightService.sunrise ? Qt.formatTime(ClightService.sunrise, "hh:mm") : "—"
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Row {
                                        spacing: Theme.spacingXS

                                        DIcon {
                                            name: "nightlight"
                                            size: 14
                                            color: Theme.secondary
                                        }

                                        StyledText {
                                            text: "Sunset"
                                            font.pixelSize: 10
                                            color: Theme.surfaceVariantText
                                        }
                                    }

                                    StyledText {
                                        text: ClightService.sunset ? Qt.formatTime(ClightService.sunset, "hh:mm") : "—"
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }
                                }

                                Column {
                                    spacing: 2

                                    Row {
                                        spacing: Theme.spacingXS

                                        DIcon {
                                            name: "location_on"
                                            size: 14
                                            color: Theme.surfaceVariantText
                                        }

                                        StyledText {
                                            text: "Location"
                                            font.pixelSize: 10
                                            color: Theme.surfaceVariantText
                                        }
                                    }

                                    StyledText {
                                        text: ClightService.locationText
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Font.Medium
                                        color: Theme.surfaceText
                                    }
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: timeoutsCol.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh

                        Column {
                            id: timeoutsCol
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Current Timeouts (" + ClightService.acStateText + " / " + ClightService.dayTimeText + ")"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceVariantText
                            }

                            Row {
                                width: parent.width
                                spacing: Theme.spacingM

                                TimeoutDisplay {
                                    icon: "photo_camera"
                                    label: "Capture"
                                    value: ClightService.formatTimeout(ClightService.currentCaptureTimeout)
                                }

                                TimeoutDisplay {
                                    icon: "brightness_low"
                                    label: "Dimmer"
                                    value: ClightService.formatTimeout(ClightService.currentDimTimeout)
                                }

                                TimeoutDisplay {
                                    icon: "monitor"
                                    label: "DPMS"
                                    value: ClightService.formatTimeout(ClightService.currentDpmsTimeout)
                                }

                                TimeoutDisplay {
                                    icon: "keyboard"
                                    label: "Keyboard"
                                    value: ClightService.formatTimeout(ClightService.currentKbdTimeout)
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingS

                        DToggle {
                            width: (parent.width - parent.spacing) / 2
                            text: "Auto Calibrate"
                            checked: !ClightService.blNoAutoCalib
                            enabled: ClightService.sensorAvailable
                            onToggled: isChecked => ClightService.setBacklightProp("NoAutoCalib", !isChecked)
                        }

                        DToggle {
                            width: (parent.width - parent.spacing) / 2
                            text: "Smooth"
                            checked: !ClightService.blNoSmooth
                            onToggled: isChecked => ClightService.setBacklightProp("NoSmooth", !isChecked)
                        }
                    }

                    DToggle {
                        width: parent.width
                        text: "Inhibit Brightness Control"
                        description: "Prevent automatic brightness adjustments"
                        checked: ClightService.inhibited
                        onToggled: isChecked => ClightService.setInhibit(isChecked)
                    }
                }
            }
        }
    }

}
