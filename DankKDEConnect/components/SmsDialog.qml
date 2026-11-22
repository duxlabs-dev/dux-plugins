import QtQuick
import qs.Common
import qs.DCommon.Widgets
import "../services"

DCard {
    id: root

    required property string deviceId

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property bool complete: phoneInput.text !== "" && messageInput.text !== ""
    readonly property real buttonWidth: (buttons.width - buttons.spacing) / 2

    signal closeRequested

    function send() {
        if (!complete)
            return;
        PhoneConnectService.sendSms(deviceId, phoneInput.text, messageInput.text);
        closeRequested();
    }

    restRadius: Theme.cornerRadiusL
    height: layout.implicitHeight + pad * 2
    Component.onCompleted: phoneInput.forceActiveFocus()
    Keys.onEscapePressed: event => {
        closeRequested();
        event.accepted = true;
    }

    Column {
        id: layout
        width: parent.width
        spacing: Theme.spacingS

        FormHeader {
            title: I18n.trFor(root.pluginId, "Send SMS", "KDE Connect SMS dialog title")
            onCloseRequested: root.closeRequested()
        }

        DTextField {
            id: phoneInput
            width: parent.width
            placeholderText: I18n.trFor(root.pluginId, "Phone number", "KDE Connect SMS phone input placeholder")
            onAccepted: messageInput.forceActiveFocus()
        }

        DTextField {
            id: messageInput
            width: parent.width
            placeholderText: I18n.trFor(root.pluginId, "Message", "KDE Connect SMS message input placeholder")
            onAccepted: root.send()
        }

        Row {
            id: buttons
            width: parent.width
            spacing: Theme.spacingXS

            DButton {
                width: root.buttonWidth
                iconName: "send"
                text: I18n.trFor(root.pluginId, "Send", "KDE Connect SMS send button")
                enabled: root.complete
                onClicked: root.send()
            }

            DButton {
                width: root.buttonWidth
                variant: "tonal"
                iconName: "open_in_new"
                text: I18n.trFor(root.pluginId, "Open App", "KDE Connect open SMS app button")
                onClicked: {
                    PhoneConnectService.launchSmsApp(root.deviceId);
                    root.closeRequested();
                }
            }
        }
    }
}
