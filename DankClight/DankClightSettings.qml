import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.DCommon.Widgets

PluginSettings {
    id: root
    pluginId: "dankClight"

    StyledText {
        text: "Clight"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    Row {
        spacing: Theme.spacingS

        DIcon {
            name: ClightService.available ? "check_circle" : "error"
            size: Theme.iconSize
            color: ClightService.available ? Theme.success : Theme.error
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: ClightService.available ? "Daemon running" : "Daemon not running"
            font.pixelSize: Theme.fontSizeSmall
            color: ClightService.available ? Theme.success : Theme.error
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: Theme.spacingM
            height: 1
        }

        DButton {
            visible: ClightService.available
            text: "Refresh"
            iconName: "refresh"
            onClicked: ClightService.refresh()
        }
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    SettingsSection {
        title: "Backlight"

        DToggle {
            width: parent.width
            text: "Auto Calibrate"
            description: "Automatically adjust brightness based on ambient light"
            checked: !ClightService.blNoAutoCalib
            enabled: ClightService.available && ClightService.sensorAvailable
            onToggled: isChecked => ClightService.setBacklightProp("NoAutoCalib", !isChecked)
        }

        DToggle {
            width: parent.width
            text: "Smooth Transitions"
            description: "Gradual brightness changes instead of instant"
            checked: !ClightService.blNoSmooth
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setBacklightProp("NoSmooth", !isChecked)
        }

        DToggle {
            width: parent.width
            text: "Inhibit on Lid Closed"
            description: "Stop adjusting brightness when laptop lid is closed"
            checked: ClightService.blInhibitOnLidClosed
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setBacklightProp("InhibitOnLidClosed", isChecked)
        }

        DToggle {
            width: parent.width
            text: "Capture on Lid Opened"
            description: "Take a brightness reading when laptop lid is opened"
            checked: ClightService.blCaptureOnLidOpened
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setBacklightProp("CaptureOnLidOpened", isChecked)
        }
    }

    SettingsSection {
        title: "Capture Timeouts"
        visible: ClightService.available

        StyledText {
            text: "Time between automatic brightness captures"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
        }

        Grid {
            columns: 3
            columnSpacing: Theme.spacingL
            rowSpacing: Theme.spacingS

            TimeoutValue {
                label: "AC Day"
                value: ClightService.blAcDayTimeout
            }
            TimeoutValue {
                label: "AC Night"
                value: ClightService.blAcNightTimeout
            }
            TimeoutValue {
                label: "AC Event"
                value: ClightService.blAcEventTimeout
            }
            TimeoutValue {
                label: "Batt Day"
                value: ClightService.blBattDayTimeout
            }
            TimeoutValue {
                label: "Batt Night"
                value: ClightService.blBattNightTimeout
            }
            TimeoutValue {
                label: "Batt Event"
                value: ClightService.blBattEventTimeout
            }
        }
    }

    SettingsSection {
        title: "Dimmer"

        DToggle {
            width: parent.width
            text: "Smooth Dimming"
            description: "Gradual transition when dimming screen"
            checked: !ClightService.dimNoSmoothEnter
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setDimmerProp("NoSmoothEnter", !isChecked)
        }

        DToggle {
            width: parent.width
            text: "Smooth Undimming"
            description: "Gradual transition when undimming screen"
            checked: !ClightService.dimNoSmoothExit
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setDimmerProp("NoSmoothExit", !isChecked)
        }

        Row {
            visible: ClightService.available
            spacing: Theme.spacingL

            TimeoutValue {
                label: "AC Timeout"
                value: ClightService.dimAcTimeout
            }
            TimeoutValue {
                label: "Batt Timeout"
                value: ClightService.dimBattTimeout
            }
            TimeoutValue {
                label: "Dim Level"
                value: Math.round(ClightService.dimmedPct * 100)
                suffix: "%"
            }
        }
    }

    SettingsSection {
        title: "DPMS (Screen Off)"

        Row {
            visible: ClightService.available
            spacing: Theme.spacingL

            TimeoutValue {
                label: "AC Timeout"
                value: ClightService.dpmsAcTimeout
            }
            TimeoutValue {
                label: "Batt Timeout"
                value: ClightService.dpmsBattTimeout
            }
        }
    }

    SettingsSection {
        title: "Keyboard Backlight"

        Row {
            visible: ClightService.available
            spacing: Theme.spacingL

            TimeoutValue {
                label: "AC Timeout"
                value: ClightService.kbdAcTimeout
            }
            TimeoutValue {
                label: "Batt Timeout"
                value: ClightService.kbdBattTimeout
            }
        }
    }

    SettingsSection {
        title: "Daytime"

        Row {
            visible: ClightService.available
            spacing: Theme.spacingL

            Column {
                spacing: 2

                StyledText {
                    text: "Sunrise"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
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

                StyledText {
                    text: "Sunset"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
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

                StyledText {
                    text: "Location"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                StyledText {
                    text: ClightService.locationText
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }

            Column {
                spacing: 2

                StyledText {
                    text: "Event Duration"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                StyledText {
                    text: Math.round(ClightService.daytimeEventDuration / 60) + " min"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
            }
        }
    }

    SettingsSection {
        title: "Inhibition"

        DToggle {
            width: parent.width
            text: "Inhibit When Docked"
            description: "Stop auto-brightness when laptop is docked"
            checked: ClightService.inhibitDocked
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setInhibitProp("InhibitDocked", isChecked)
        }

        DToggle {
            width: parent.width
            text: "Auto-Inhibit PM"
            description: "Inhibit power management when Clight is inhibited"
            checked: ClightService.inhibitPM
            enabled: ClightService.available
            onToggled: isChecked => ClightService.setInhibitProp("InhibitPM", isChecked)
        }
    }

    SettingsSection {
        title: "Displays"
        visible: ClightService.available && ClightService.backlights.length > 0

        Column {
            width: parent.width
            spacing: Theme.spacingS

            Repeater {
                model: ClightService.backlights

                delegate: Row {
                    required property var modelData
                    width: parent.width
                    spacing: Theme.spacingS

                    DIcon {
                        name: ClightService.getBacklightTypeIcon(modelData)
                        size: 18
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        spacing: 0
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: modelData.name
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            elide: Text.ElideMiddle
                            width: parent.width
                        }

                        StyledText {
                            text: modelData.ddc ? "DDC" : (modelData.internal ? "Internal" : "External")
                            font.pixelSize: 10
                            color: Theme.surfaceVariantText
                        }
                    }

                    StyledRect {
                        width: parent.width - 180
                        height: 8
                        radius: 4
                        color: Theme.surfaceVariant
                        anchors.verticalCenter: parent.verticalCenter

                        StyledRect {
                            width: parent.width * modelData.brightness
                            height: parent.height
                            radius: 4
                            color: Theme.primary
                        }
                    }

                    StyledText {
                        text: modelData.percent + "%"
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.Bold
                        color: Theme.primary
                        width: 45
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Row {
        visible: ClightService.available
        spacing: Theme.spacingS

        DButton {
            text: "Capture"
            iconName: "photo_camera"
            enabled: ClightService.sensorAvailable
            onClicked: ClightService.capture(true, false)
        }

        DButton {
            text: ClightService.suspended ? "Resume" : "Pause"
            iconName: ClightService.suspended ? "play_arrow" : "pause"
            onClicked: ClightService.setPaused(!ClightService.suspended)
        }

        DButton {
            text: ClightService.inhibited ? "Uninhibit" : "Inhibit"
            iconName: ClightService.inhibited ? "lock_open" : "lock"
            onClicked: ClightService.setInhibit(!ClightService.inhibited)
        }
    }
}
