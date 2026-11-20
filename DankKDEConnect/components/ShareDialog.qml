import QtQuick
import qs.Common
import qs.Modals.FileBrowser
import qs.DCommon.Widgets
import "../services"

DCard {
    id: root

    required property string deviceId
    property var parentPopout: null

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property string trimmed: input.text.trim()
    readonly property bool contentIsUri: /^[A-Za-z][A-Za-z0-9+.-]*:\S+$/.test(trimmed)
    readonly property real buttonWidth: (buttons.width - buttons.spacing * 2) / 3

    signal closeRequested

    function share(asUri) {
        if (trimmed === "" || (asUri && !contentIsUri))
            return;
        PhoneConnectService.shareContent(deviceId, asUri ? trimmed : input.text, asUri);
        closeRequested();
    }

    restRadius: Theme.cornerRadiusL
    height: layout.implicitHeight + pad * 2
    Component.onCompleted: input.forceActiveFocus()
    Keys.onEscapePressed: event => {
        closeRequested();
        event.accepted = true;
    }

    Column {
        id: layout
        width: parent.width
        spacing: Theme.spacingS

        FormHeader {
            title: I18n.trFor(root.pluginId, "Share", "KDE Connect share dialog title")
            onCloseRequested: root.closeRequested()
        }

        DTextField {
            id: input
            width: parent.width
            placeholderText: I18n.trFor(root.pluginId, "Enter URI or text to share", "KDE Connect share input placeholder")
            onAccepted: root.share(root.contentIsUri)
        }

        Row {
            id: buttons
            width: parent.width
            spacing: Theme.spacingXS

            DButton {
                width: root.buttonWidth
                variant: "tonal"
                iconName: "link"
                text: I18n.trFor(root.pluginId, "URI", "KDE Connect share URI button")
                enabled: root.contentIsUri
                onClicked: root.share(true)
            }

            DButton {
                width: root.buttonWidth
                variant: "tonal"
                iconName: "notes"
                text: I18n.trFor(root.pluginId, "Text", "KDE Connect share text button")
                enabled: root.trimmed !== ""
                onClicked: root.share(false)
            }

            DButton {
                width: root.buttonWidth
                variant: "tonal"
                iconName: "upload_file"
                text: I18n.trFor(root.pluginId, "File", "KDE Connect send file button")
                onClicked: fileBrowser.open()
            }
        }
    }

    FileBrowserSurfaceModal {
        id: fileBrowser

        browserTitle: I18n.trFor(root.pluginId, "Select File to Send", "KDE Connect file browser title")
        browserType: "generic"
        showHiddenFiles: false
        fileExtensions: ["*"]
        parentPopout: root.parentPopout

        onFileSelected: function (path) {
            PhoneConnectService.shareFile(root.deviceId, path);
            close();
            root.closeRequested();
        }
    }
}
