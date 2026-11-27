import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

Scope {
    id: root

    property bool open: false
    property int currentTab: 0

    readonly property color accentColor: Theme.accentSolid

    IpcHandler {
        target: "notch"
        function toggle(): void { root.open = !root.open }
        function open(): void { root.open = true }
        function close(): void { root.open = false }
        function tab(idx: int): void { root.currentTab = idx; root.open = true }
    }

    Timer {
        id: closeTimer
        interval: 700
        repeat: false
        onTriggered: {
            if (!cardHover.hovered && !triggerHover.hovered) {
                root.open = false;
            }
        }
    }

    PanelWindow {
        id: win
        screen: Quickshell.screens[0]

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "notch-dashboard"

        mask: Region {
            Region { item: triggerZone }
            Region { item: root.open ? panelCard : null }
        }

        // ==========================================
        // TOP TRIGGER ZONE (Camera / Notch Area)
        // ==========================================
        Rectangle {
            id: triggerZone
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 240
            height: 6
            color: "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 70
                height: 3
                radius: 2
                color: root.open ? root.accentColor : (triggerHover.hovered ? root.accentColor : Qt.rgba(1, 1, 1, 0.18))
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            HoverHandler {
                id: triggerHover
                onHoveredChanged: {
                    if (hovered) {
                        closeTimer.stop();
                        root.open = true;
                    } else if (root.open) {
                        closeTimer.restart();
                    }
                }
            }
        }

        // ==========================================
        // FLOATING NOTCH BENTO PANEL
        // ==========================================
        Rectangle {
            id: panelCard
            anchors.horizontalCenter: parent.horizontalCenter
            width: 820
            height: 464
            radius: 20

            y: root.open ? 10 : -height - 40
            opacity: root.open ? 1.0 : 0.0

            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            color: Theme.alpha(Theme.bgPanel, 0.95)
            border.width: 1
            border.color: Theme.borderAccent

            HoverHandler {
                id: cardHover
                onHoveredChanged: {
                    if (hovered) {
                        closeTimer.stop();
                    } else if (root.open) {
                        closeTimer.restart();
                    }
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // ------------------------------------------
                // TAB BAR HEADER
                // ------------------------------------------
                RowLayout {
                    width: parent.width
                    height: 34

                    Rectangle {
                        Layout.preferredHeight: 34
                        Layout.preferredWidth: tabsRow.implicitWidth + 8
                        radius: 17
                        color: Theme.alpha(Theme.bgCard, 0.9)
                        border.width: 1
                        border.color: Theme.border

                        RowLayout {
                            id: tabsRow
                            anchors.centerIn: parent
                            spacing: 4

                            // Tab 0: Dashboard
                            Rectangle {
                                width: t0Text.implicitWidth + 24
                                height: 26
                                radius: 13
                                color: root.currentTab === 0 ? root.accentColor : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    id: t0Text
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰕮"
                                        font.family: Theme.iconFont
                                        font.pixelSize: 12
                                        color: root.currentTab === 0 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.textDim
                                    }
                                    Text {
                                        text: "Dashboard"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: root.currentTab === 0
                                        color: root.currentTab === 0 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.text
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentTab = 0
                                }
                            }

                            // Tab 1: Media
                            Rectangle {
                                width: t1Text.implicitWidth + 24
                                height: 26
                                radius: 13
                                color: root.currentTab === 1 ? root.accentColor : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    id: t1Text
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰝚"
                                        font.family: Theme.iconFont
                                        font.pixelSize: 12
                                        color: root.currentTab === 1 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.textDim
                                    }
                                    Text {
                                        text: "Media"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: root.currentTab === 1
                                        color: root.currentTab === 1 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.text
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentTab = 1
                                }
                            }

                            // Tab 2: Performance
                            Rectangle {
                                width: t2Text.implicitWidth + 24
                                height: 26
                                radius: 13
                                color: root.currentTab === 2 ? root.accentColor : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    id: t2Text
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰓅"
                                        font.family: Theme.iconFont
                                        font.pixelSize: 12
                                        color: root.currentTab === 2 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.textDim
                                    }
                                    Text {
                                        text: "Performance"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: root.currentTab === 2
                                        color: root.currentTab === 2 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.text
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentTab = 2
                                }
                            }

                            // Tab 3: Clima
                            Rectangle {
                                width: t3Text.implicitWidth + 24
                                height: 26
                                radius: 13
                                color: root.currentTab === 3 ? root.accentColor : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    id: t3Text
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "󰖐"
                                        font.family: Theme.iconFont
                                        font.pixelSize: 12
                                        color: root.currentTab === 3 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.textDim
                                    }
                                    Text {
                                        text: "Clima"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: root.currentTab === 3
                                        color: root.currentTab === 3 ? (Theme.accentSolid.hslLightness > 0.6 ? "#0a0a0f" : "#ffffff") : Theme.text
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentTab = 3
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Close Button
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: closeBtnHover.hovered ? Theme.alpha(Theme.accentSolid, 0.2) : Theme.alpha(Theme.text, 0.08)
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: Theme.iconFont
                            font.pixelSize: 13
                            color: closeBtnHover.hovered ? root.accentColor : Theme.text
                        }

                        HoverHandler { id: closeBtnHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.open = false
                        }
                    }
                }

                // ------------------------------------------
                // TAB CONTENT (390px)
                // ------------------------------------------
                Item {
                    width: parent.width
                    height: 390

                    NotchDashTab {
                        anchors.fill: parent
                        visible: root.currentTab === 0
                    }

                    NotchMediaTab {
                        anchors.fill: parent
                        visible: root.currentTab === 1
                    }

                    NotchPerfTab {
                        anchors.fill: parent
                        visible: root.currentTab === 2
                    }

                    NotchWeatherTab {
                        anchors.fill: parent
                        visible: root.currentTab === 3
                    }
                }
            }
        }
    }
}
