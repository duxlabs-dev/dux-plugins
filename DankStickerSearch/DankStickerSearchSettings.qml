import QtQuick
import qs.Common
import qs.DCommon.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "dankStickerSearch"

    StyledText {
        width: parent.width
        text: "Sticker Search"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Search and browse stickers powered by Klipy."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    StringSetting {
        settingKey: "trigger"
        label: "Trigger"
        description: "Prefix to activate sticker search (default: :s)"
        placeholder: ":s"
        defaultValue: ":s"
    }

    ToggleSetting {
        settingKey: "pasteUrlOnly"
        label: "Paste URL Only"
        description: "When enabled, Shift+Enter pastes the image URL instead of downloading the content"
        defaultValue: false
    }

    SelectionSetting {
        settingKey: "preferredFormat"
        label: "Preferred Format"
        description: "Format to use for default copy and Shift+Enter paste"
        options: [
            {
                label: "WebP",
                value: "webp"
            },
            {
                label: "GIF",
                value: "gif"
            }
        ]
        defaultValue: "webp"
    }
}
