import QtQuick
import Quickshell.Widgets
import qs.Common
import qs.DCommon.Widgets

Item {
    id: root

    property string deviceType: "phone"
    property string image: ""
    property bool reachable: true
    property real maximumWidth: Theme.buttonHeightM * 2
    property real maximumHeight: maximumWidth

    readonly property string imageSource: {
        const value = image.trim();
        if (value.startsWith("/"))
            return "file://" + value;
        return /^(file|https?):\/\//i.test(value) ? value : "";
    }
    readonly property bool hasImage: imageSource !== ""
    readonly property string form: {
        if (hasImage)
            return "phone";
        switch (deviceType) {
        case "tablet":
            return "tablet";
        case "laptop":
            return "laptop";
        case "desktop":
        case "computer":
        case "tv":
            return "monitor";
        default:
            return "phone";
        }
    }
    readonly property real aspect: {
        switch (form) {
        case "tablet":
            return 3 / 4;
        case "laptop":
            return 16 / 10;
        case "monitor":
            return 16 / 9;
        default:
            return 9 / 19;
        }
    }
    readonly property real standHeight: {
        switch (form) {
        case "laptop":
            return Theme.spacingS;
        case "monitor":
            return Theme.spacingL;
        default:
            return 0;
        }
    }
    readonly property real bezel: hasImage ? 0 : Theme.spacingXS
    readonly property real screenWidth: Math.round(Math.min(maximumWidth, (maximumHeight - standHeight) * aspect))
    readonly property color frameColor: Theme.scrimColor

    implicitWidth: screenWidth
    implicitHeight: Math.round(screenWidth / aspect) + standHeight

    Rectangle {
        id: frame
        width: parent.width
        height: parent.height - root.standHeight
        radius: root.standHeight > 0 ? Theme.cornerRadiusS : Theme.cornerRadiusL
        color: root.frameColor

        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: root.bezel
            radius: Math.max(0, frame.radius - root.bezel)
            color: Theme.surfaceContainerHighest

            Rectangle {
                anchors.fill: parent
                visible: root.reachable && !root.hasImage
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: Theme.primary
                    }
                    GradientStop {
                        position: 1
                        color: Theme.primaryContainer
                    }
                }
            }

            Image {
                anchors.fill: parent
                visible: root.reachable && root.hasImage
                source: root.imageSource
                sourceSize.width: root.width * 2
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            DIcon {
                anchors.centerIn: parent
                visible: !root.reachable
                name: "phonelink_off"
                size: Theme.iconSize
                color: Theme.onSurfaceVariant
            }

            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: Theme.spacingS
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.form === "phone" && !root.hasImage
                width: Theme.spacingS
                height: width
                radius: width / 2
                color: root.frameColor
            }
        }
    }

    Rectangle {
        anchors.top: frame.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.form === "monitor"
        width: Theme.spacingL
        height: root.standHeight
        color: root.frameColor
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.standHeight > 0
        width: root.form === "laptop" ? parent.width : parent.width / 3
        height: root.form === "laptop" ? root.standHeight : Theme.spacingXS
        radius: Theme.cornerRadiusXS
        color: root.frameColor
    }
}
