pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Mpris
import qs.Common
import qs.Services
import qs.Widgets
import qs.DCommon.Widgets
import "../services"

DCard {
    id: root

    required property string deviceId

    readonly property string pluginId: PhoneConnectService.pluginId
    readonly property var device: PhoneConnectService.devices[deviceId] ?? null
    readonly property MprisPlayer player: {
        const deviceName = normalized(device?.name);
        if (deviceName === "")
            return null;
        const matches = MprisController.availablePlayers.filter(p => (p.dbusName ?? "").startsWith("org.mpris.MediaPlayer2.kdeconnect") && normalized(p.identity).includes(deviceName));
        return matches.find(p => p.playbackState === MprisPlaybackState.Playing) ?? matches[0] ?? null;
    }
    readonly property string trackTitle: player ? player.trackTitle : (device?.mediaTitle ?? "")
    readonly property string trackArtist: player ? player.trackArtist : (device?.mediaArtist ?? "")
    readonly property string trackAlbum: player ? player.trackAlbum : (device?.mediaAlbum ?? "")
    readonly property string source: (player ? (player.identity ?? "").split(" - ")[0] : device?.mediaPlayer) || I18n.trFor(pluginId, "Media Player")
    readonly property bool active: trackTitle !== ""
    readonly property bool playing: player ? player.playbackState === MprisPlaybackState.Playing : (device?.mediaIsPlaying ?? false)
    readonly property bool seekable: (player?.canSeek ?? false) && player.length > 0
    readonly property string artUrl: player ? TrackArtService.getArtworkUrl(player) : ""

    function normalized(text) {
        return (text ?? "").toLowerCase().replace(/[^a-z0-9]/g, "");
    }

    function seekBy(seconds) {
        player.position = Math.max(0, Math.min(player.length, player.position + seconds));
    }

    function previous() {
        if (player)
            player.previous();
        else
            PhoneConnectService.mediaAction(deviceId, "previous");
    }

    function next() {
        if (player)
            player.next();
        else
            PhoneConnectService.mediaAction(deviceId, "next");
    }

    function togglePlaying() {
        if (player)
            player.togglePlaying();
        else
            PhoneConnectService.mediaAction(deviceId, "PlayPause");
    }

    restRadius: Theme.cornerRadiusL
    height: layout.implicitHeight + pad * 2

    Timer {
        interval: 1000
        repeat: true
        running: root.visible && root.seekable && root.playing
        onTriggered: root.player.positionChanged()
    }

    Column {
        id: layout
        width: parent.width
        spacing: Theme.spacingM

        Row {
            width: parent.width
            spacing: Theme.spacingM

            DCircularImage {
                id: art
                width: Theme.buttonHeightM
                height: width
                imageSource: root.artUrl
                fallbackIcon: "material:music_note"
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - art.width - parent.spacing
                spacing: Theme.spacingXXS

                StyledText {
                    width: parent.width
                    text: root.source
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Theme.fontWeightMedium
                    color: Theme.primary
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width
                    text: root.trackTitle
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Theme.fontWeightMedium
                    color: Theme.onSurface
                    elide: Text.ElideRight
                }

                StyledText {
                    width: parent.width
                    text: [root.trackArtist, root.trackAlbum].filter(part => part !== "").join(" • ")
                    visible: text !== ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.onSurfaceVariant
                    elide: Text.ElideRight
                }
            }
        }

        DSeekbar {
            width: parent.width
            height: Theme.spacingL
            visible: root.seekable
            activePlayer: root.player
            stableLength: root.player?.length ?? 0
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingXS

            DIconButton {
                iconName: "skip_previous"
                Accessible.name: I18n.trFor(root.pluginId, "Previous", "Media previous tooltip")
                onClicked: root.previous()
            }

            DIconButton {
                visible: root.seekable
                iconName: "replay_10"
                Accessible.name: I18n.trFor(root.pluginId, "Rewind 10s", "Media rewind tooltip")
                onClicked: root.seekBy(-10)
            }

            DIconButton {
                variant: "filled"
                widthMode: "wide"
                iconName: root.playing ? "pause" : "play_arrow"
                Accessible.name: root.playing ? I18n.trFor(root.pluginId, "Pause", "Media pause tooltip") : I18n.trFor(root.pluginId, "Play", "Media play tooltip")
                onClicked: root.togglePlaying()
            }

            DIconButton {
                visible: root.seekable
                iconName: "forward_10"
                Accessible.name: I18n.trFor(root.pluginId, "Forward 10s", "Media forward tooltip")
                onClicked: root.seekBy(10)
            }

            DIconButton {
                iconName: "skip_next"
                Accessible.name: I18n.trFor(root.pluginId, "Next", "Media next tooltip")
                onClicked: root.next()
            }
        }
    }
}
