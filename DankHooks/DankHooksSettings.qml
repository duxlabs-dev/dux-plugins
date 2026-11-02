import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "dankHooks"

    StyledText {
        text: "System Event Hooks"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        text: "Execute custom scripts when system events occur. Scripts receive two arguments: hook name (e.g., 'onBatteryLevelChanged') and event value."
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
        text: "Appearance & Theme"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "wallpaperPath"
        label: "Wallpaper Changed"
        description: "Hook: onWallpaperChanged | Value: wallpaper file path"
        placeholder: "/path/to/wallpaper-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "monitorWallpaper"
        label: "Per-Monitor Wallpapers Changed"
        description: "Hook: onMonitorWallpapersChanged | Value: JSON object with all monitors (e.g., '{\"eDP-1\":\"/path1.jpg\",\"DP-2\":\"/path2.jpg\"}')"
        placeholder: "/path/to/monitor-wallpaper-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "lightMode"
        label: "Light/Dark Mode Changed"
        description: "Hook: onLightModeChanged | Value: 'light' or 'dark'"
        placeholder: "/path/to/mode-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "theme"
        label: "Theme Changed"
        description: "Hook: onThemeChanged | Value: theme name (e.g., 'blue', 'red', 'dynamic')"
        placeholder: "/path/to/theme-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "matugenCompleted"
        label: "Matugen Generation Completed"
        description: "Hook: onMatugenCompleted | Value: '<mode>:<result>' (e.g., 'dark:success', 'light:no-changes')"
        placeholder: "/path/to/matugen-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "nightMode"
        label: "Night Mode Changed"
        description: "Hook: onNightModeChanged | Value: 'enabled' or 'disabled'"
        placeholder: "/path/to/nightmode-hook.sh"
        defaultValue: ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Power & Battery"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "batteryLevel"
        label: "Battery Level Changed"
        description: "Hook: onBatteryLevelChanged | Value: percentage (0-100)"
        placeholder: "/path/to/battery-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "batteryCharging"
        label: "Battery Charging State Changed"
        description: "Hook: onBatteryChargingChanged | Value: 'charging' or 'not-charging'"
        placeholder: "/path/to/charging-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "batteryPluggedIn"
        label: "Power Adapter Changed"
        description: "Hook: onBatteryPluggedInChanged | Value: 'plugged-in' or 'on-battery'"
        placeholder: "/path/to/power-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "hookPowerRequestLock"
        label: "Lock Screen Event Triggered"
        description: "Hook: onLockRequested | Value: empty"
        placeholder: "/path/to/sessionlock-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "sessionLocked"
        label: "Session Locked"
        description: "Hook: onSessionLocked | Value: 'locked'"
        placeholder: "/path/to/session-locked-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "sessionUnlocked"
        label: "Session Unlocked"
        description: "Hook: onSessionUnlocked | Value: 'unlocked'"
        placeholder: "/path/to/session-unlocked-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "hookPowerMonitorOff"
        label: "Monitor Off Event Triggered"
        description: "Hook: onRequestMonitorOff | Value: empty"
        placeholder: "/path/to/monitoroff-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "hookPowerMonitorOn"
        label: "Monitor On Event Triggered"
        description: "Hook: onRequestMonitorOn | Value: empty"
        placeholder: "/path/to/monitoron-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "hookPowerSuspend"
        label: "Suspend Event Triggered"
        description: "Hook: onRequestSuspend | Value: empty"
        placeholder: "/path/to/suspend-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "hookResumeFromSleep"
        label: "Resume From Sleep Event Triggered"
        description: "Hook: onResumeFromSleep | Value: empty"
        placeholder: "/path/to/resumeFromSleep-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "idleInhibit"
        label: "Idle Inhibitor Changed"
        description: "Hook: onInhibitorChanged | Value: 'inhibited' or 'not-inhibited'"
        placeholder: "/path/to/inhibitor-hook.sh"
        defaultValue: ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Network"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "wifiConnected"
        label: "WiFi Connection Changed"
        description: "Hook: onWifiConnectedChanged | Value: 'connected' or 'disconnected'"
        placeholder: "/path/to/wifi-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "wifiSSID"
        label: "WiFi Network Changed"
        description: "Hook: onWifiSSIDChanged | Value: SSID name or 'none'"
        placeholder: "/path/to/ssid-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "ethernetConnected"
        label: "Ethernet Connection Changed"
        description: "Hook: onEthernetConnectedChanged | Value: 'connected' or 'disconnected'"
        placeholder: "/path/to/ethernet-hook.sh"
        defaultValue: ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Audio"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "audioVolume"
        label: "Audio Volume Changed"
        description: "Hook: onAudioVolumeChanged | Value: percentage (0-100)"
        placeholder: "/path/to/volume-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "audioMute"
        label: "Audio Mute Changed"
        description: "Hook: onAudioMuteChanged | Value: 'muted' or 'unmuted'"
        placeholder: "/path/to/mute-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "micMute"
        label: "Microphone Mute Changed"
        description: "Hook: onMicMuteChanged | Value: 'muted' or 'unmuted'"
        placeholder: "/path/to/mic-hook.sh"
        defaultValue: ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Display & Media"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "brightness"
        label: "Brightness Changed"
        description: "Hook: onBrightnessChanged | Value: percentage (0-100)"
        placeholder: "/path/to/brightness-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "mediaPlaying"
        label: "Media Playback Changed"
        description: "Hook: onMediaPlayingChanged | Value: 'playing' or 'paused'"
        placeholder: "/path/to/media-hook.sh"
        defaultValue: ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "System"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "dankHooksStarted"
        label: "Dank Hooks Started"
        description: "Hook: onDankHooksStarted | Value: 'started' or 'restarted'"
        placeholder: "/path/to/dankhooks-hook.sh"
        defaultValue: ""
    }

    StringSetting {
        settingKey: "doNotDisturb"
        label: "Do Not Disturb Changed"
        description: "Hook: onDoNotDisturbChanged | Value: 'enabled' or 'disabled'"
        placeholder: "/path/to/dnd-hook.sh"
        defaultValue: ""
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }

    StyledText {
        text: "Hook Script Examples"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }

    StyledText {
        text: "Example hook script:"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
    }

    StyledRect {
        width: parent.width
        height: exampleCode.height + 16
        color: Theme.surface
        radius: Theme.cornerRadius

        StyledText {
            id: exampleCode
            anchors.centerIn: parent
            anchors.margins: 8
            width: parent.width - 16
            text: '#!/bin/bash\n# Save as ~/.config/scripts/hook.sh\n# Make executable: chmod +x ~/.config/scripts/hook.sh\n\nHOOK_NAME="$1"  # e.g., "onWallpaperChanged"\nHOOK_VALUE="$2" # e.g., "/path/to/wallpaper.jpg"\n\necho "Hook: $HOOK_NAME, Value: $HOOK_VALUE"\ndms notify "$HOOK_NAME" "$HOOK_VALUE"'
            font.pixelSize: Theme.fontSizeSmall
            font.family: "monospace"
            color: Theme.surfaceText
            wrapMode: Text.WordWrap
        }
    }

    StyledText {
        text: "All hooks pass two arguments: $1 = hook name (e.g., 'onBatteryLevelChanged'), $2 = event value. See descriptions above for each hook's values."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
