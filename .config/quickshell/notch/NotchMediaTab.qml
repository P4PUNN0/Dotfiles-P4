import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root

    implicitWidth: 788
    implicitHeight: 390

    readonly property color accentColor: Theme.accentSolid
    readonly property color cardBg: Theme.alpha(Theme.bgCard, 0.88)
    readonly property color cardBorder: Theme.borderAccent

    property string title: ""
    property string artist: ""
    property string album: ""
    property string status: "Stopped"
    property string artUrl: ""
    property string playerName: "spotify"
    property real positionSec: 0
    property real lengthSec: 0

    readonly property bool hasMedia: status === "Playing" || (title !== "" && title !== "No hay música")

    Process {
        id: mediaProc
        command: ["playerctl", "metadata", "--format", "{{playerName}}\t{{status}}\t{{title}}\t{{artist}}\t{{album}}\t{{position}}\t{{mpris:length}}\t{{mpris:artUrl}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line) {
                    const p = line.split("\t");
                    root.playerName = p[0] || "spotify";
                    root.status = p[1] || "Stopped";
                    root.title = p[2] || "";
                    root.artist = p[3] || "";
                    root.album = p[4] || "";
                    root.positionSec = (parseFloat(p[5]) || 0) / 1000000;
                    root.lengthSec = (parseFloat(p[6]) || 0) / 1000000;
                    root.artUrl = p[7] || "";
                } else {
                    root.status = "Stopped";
                    root.title = "";
                    root.artist = "";
                    root.album = "";
                    root.positionSec = 0;
                    root.lengthSec = 0;
                    root.artUrl = "";
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!mediaProc.running) mediaProc.running = true;
        }
    }

    function formatTime(s) {
        if (!s || s <= 0) return "0:00";
        const m = Math.floor(s / 60);
        const sec = Math.floor(s % 60);
        return m + ":" + (sec < 10 ? "0" : "") + sec;
    }

    // ==========================================
    // 1. EMPTY STATE (When no music is active)
    // ==========================================
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 16
        color: root.cardBg
        border.width: 1
        border.color: root.cardBorder
        visible: !root.hasMedia

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 72
                height: 72
                radius: 36
                color: Theme.alpha(root.accentColor, 0.12)
                border.width: 1
                border.color: Theme.alpha(root.accentColor, 0.3)

                Text {
                    anchors.centerIn: parent
                    text: "󰓇"
                    font.family: Theme.iconFont
                    font.pixelSize: 34
                    color: root.accentColor
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Sin reproducción activa"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Inicia Spotify para ver la portada, controles y progreso aquí"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.textDim
                }
            }

            AnimatedImage {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                width: 130
                height: 85
                source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/imgs/bongocat.gif"
                fillMode: Image.PreserveAspectFit
                playing: false
                opacity: 0.8
            }
        }
    }

    // ==========================================
    // 2. ACTIVE MEDIA STATE
    // ==========================================
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 16
        color: root.cardBg
        border.width: 1
        border.color: root.cardBorder
        visible: root.hasMedia

        RowLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 28

            // Album Artwork (Rounded Square)
            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignVCenter
                radius: 16
                color: Theme.alpha(Theme.bgPanel, 0.9)
                border.width: 1
                border.color: root.cardBorder
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.artUrl !== "" ? root.artUrl : "file://" + Quickshell.env("HOME") + "/.config/hypr/assets/spotify-fallback.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰓇"
                    font.family: Theme.iconFont
                    font.pixelSize: 52
                    color: root.accentColor
                    visible: root.artUrl === ""
                }
            }

            // Controls & Track Details
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 14

                // Header badge
                Rectangle {
                    Layout.preferredHeight: 22
                    Layout.preferredWidth: badgeRow.implicitWidth + 14
                    radius: 11
                    color: Theme.alpha(root.accentColor, 0.15)
                    border.width: 1
                    border.color: Theme.alpha(root.accentColor, 0.35)

                    RowLayout {
                        id: badgeRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: root.playerName === "spotify" ? "󰓇" : "󰝚"
                            font.family: Theme.iconFont
                            font.pixelSize: 12
                            color: root.accentColor
                        }

                        Text {
                            text: root.playerName.toUpperCase() + (root.status === "Playing" ? " · REPRODUCIENDO" : " · EN PAUSA")
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            font.bold: true
                            color: Theme.text
                        }
                    }
                }

                // Title & Artist
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.title !== "" ? root.title : "Sin título"
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        font.bold: true
                        color: Theme.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: (root.artist !== "" ? root.artist : "Artista desconocido") + (root.album ? "  ·  " + root.album : "")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.textDim
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Progress Bar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Theme.alpha(Theme.text, 0.12)

                        Rectangle {
                            height: parent.height
                            radius: parent.radius
                            color: root.accentColor
                            width: root.lengthSec > 0 ? parent.width * Math.min(1.0, Math.max(0.0, root.positionSec / root.lengthSec)) : 0
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.formatTime(root.positionSec)
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.textDim
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.formatTime(root.lengthSec)
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.textDim
                        }
                    }
                }

                // Playback Buttons & Bongo Cat
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20

                    RowLayout {
                        spacing: 20

                        Text {
                            text: "󰒮"
                            font.family: Theme.iconFont
                            font.pixelSize: 24
                            color: prevHover.hovered ? root.accentColor : Theme.text
                            HoverHandler { id: prevHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["playerctl", "previous"])
                            }
                        }

                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: root.accentColor

                            Text {
                                anchors.centerIn: parent
                                text: root.status === "Playing" ? "󰏤" : "󰐊"
                                font.family: Theme.iconFont
                                font.pixelSize: 22
                                color: Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
                            }
                        }

                        Text {
                            text: "󰒭"
                            font.family: Theme.iconFont
                            font.pixelSize: 24
                            color: nextHover.hovered ? root.accentColor : Theme.text
                            HoverHandler { id: nextHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["playerctl", "next"])
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    AnimatedImage {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 70
                        source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/imgs/bongocat.gif"
                        fillMode: Image.PreserveAspectFit
                        playing: root.status === "Playing"
                    }
                }
            }
        }
    }
}
