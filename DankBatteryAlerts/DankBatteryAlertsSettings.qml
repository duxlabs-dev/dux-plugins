import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "dankBatteryAlerts"

    StyledText {
        text: "Battery Alerts"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        text: "Get notified when battery reaches critical or warning levels while on battery power"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        width: parent.width
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Critical Alert"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "enableCriticalAlert"
        label: "Enable Critical Alert"
        description: "Show urgent notification when battery reaches critical level"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "criticalThreshold"
        label: "Critical Threshold"
        description: "Battery percentage to trigger critical alert"
        defaultValue: 10
        minimum: 1
        maximum: 30
        unit: "%"
        rightIcon: "battery_alert"
    }

    StringSetting {
        settingKey: "criticalTitle"
        label: "Critical Title"
        description: "Notification title for critical alerts"
        placeholder: "Critical Battery Level"
        defaultValue: "Critical Battery Level"
    }

    StringSetting {
        settingKey: "criticalMessage"
        label: "Critical Message"
        description: "Use ${level} for battery percentage"
        placeholder: "Battery at ${level}% - Connect charger immediately!"
        defaultValue: "Battery at ${level}% - Connect charger immediately!"
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Warning Alert"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "enableWarningAlert"
        label: "Enable Warning Alert"
        description: "Show notification when battery reaches warning level"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "warningThreshold"
        label: "Warning Threshold"
        description: "Battery percentage to trigger warning alert"
        defaultValue: 20
        minimum: 5
        maximum: 50
        unit: "%"
        rightIcon: "battery_std"
    }

    StringSetting {
        settingKey: "warningTitle"
        label: "Warning Title"
        description: "Notification title for warning alerts"
        placeholder: "Low Battery"
        defaultValue: "Low Battery"
    }

    StringSetting {
        settingKey: "warningMessage"
        label: "Warning Message"
        description: "Use ${level} for battery percentage"
        placeholder: "Battery at ${level}% - Consider charging soon"
        defaultValue: "Battery at ${level}% - Consider charging soon"
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Alert Behavior"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StyledText {
        text: "• Critical alerts use urgent priority and persist longer\n• Alerts reset when battery is charging or rises above threshold\n• Only one alert per threshold per battery discharge cycle"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
