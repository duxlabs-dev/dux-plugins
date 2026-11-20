pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Common
import qs.DCommon.Widgets
import "../services"

DCard {
    id: root

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property var images: PhoneConnectService.recentImages
    readonly property bool loading: PhoneConnectService.loadingImages && images.length === 0
    readonly property int placeholders: loading ? PhoneConnectService.maxRecentImages : 0
    readonly property int tileCount: Math.max(images.length, placeholders)
    readonly property int columns: tileCount <= 2 ? Math.max(1, tileCount) : Math.ceil(tileCount / 2)
    readonly property bool leadSpans: tileCount > 2 && tileCount % 2 === 1
    readonly property real tileWidth: (tiles.width - tiles.spacing * (columns - 1)) / columns
    readonly property real tileHeight: tileCount <= 2 ? Theme.buttonHeightM * 2 : Theme.buttonHeightM + Theme.spacingL
    readonly property int dragThreshold: Theme.spacingM

    signal closeRequested

    function widthFor(index) {
        return leadSpans && index === 0 ? tileWidth * 2 + tiles.spacing : tileWidth;
    }

    function openImage(path) {
        Quickshell.execDetached(["xdg-open", path]);
        closeRequested();
    }

    function dragImage(path) {
        fileDragger.running = false;
        fileDragger.command = ["sh", "-c", "pkill -x ripdrag; pkill -x xdragon; pkill -x dragon; if command -v ripdrag >/dev/null 2>&1; then ripdrag --and-exit --icons-only --icon-size 64 --content-width 90 --content-height 64 \"$1\"; elif command -v xdragon >/dev/null 2>&1; then xdragon --and-exit --small \"$1\"; elif command -v dragon >/dev/null 2>&1; then dragon --and-exit --small \"$1\"; fi", "sh", path];
        fileDragger.running = true;
        closeRequested();
    }

    restRadius: Theme.cornerRadiusL
    height: layout.implicitHeight + pad * 2

    Process {
        id: fileDragger
    }

    Column {
        id: layout
        width: parent.width
        spacing: Theme.spacingS

        StyledText {
            width: parent.width
            text: I18n.trFor(root.pluginId, "Recent Images", "Recent Images title")
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Theme.fontWeightMedium
            color: Theme.primary
        }

        StyledText {
            width: parent.width
            visible: root.tileCount === 0
            text: I18n.trFor(root.pluginId, "No images found", "No recent images found message")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurfaceVariant
        }

        Flow {
            id: tiles
            width: parent.width
            spacing: Theme.groupedListGap
            visible: root.tileCount > 0

            Repeater {
                model: root.placeholders

                StyledRect {
                    required property int index
                    width: root.widthFor(index)
                    height: root.tileHeight
                    radius: Theme.cornerRadiusS
                    color: Theme.foregroundColor(Theme.chipSurface)
                }
            }

            Repeater {
                model: root.images

                ClippingRectangle {
                    id: tile
                    required property string modelData
                    required property int index

                    width: root.widthFor(index)
                    height: root.tileHeight
                    radius: Theme.cornerRadiusS
                    color: Theme.foregroundColor(Theme.chipSurface)

                    Image {
                        anchors.fill: parent
                        source: "file://" + tile.modelData
                        sourceSize.width: tile.width * 2
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    StateLayer {
                        id: tileLayer
                        property point pressPoint
                        property bool dragged: false

                        cornerRadius: tile.radius
                        stateColor: Theme.primary
                        onPressed: mouse => {
                            pressPoint = Qt.point(mouse.x, mouse.y);
                            dragged = false;
                        }
                        onPositionChanged: mouse => {
                            if (!pressed || dragged)
                                return;
                            if (Math.hypot(mouse.x - pressPoint.x, mouse.y - pressPoint.y) < root.dragThreshold)
                                return;
                            dragged = true;
                            root.dragImage(tile.modelData);
                        }
                        onClicked: {
                            if (!dragged)
                                root.openImage(tile.modelData);
                        }
                    }
                }
            }
        }
    }
}
