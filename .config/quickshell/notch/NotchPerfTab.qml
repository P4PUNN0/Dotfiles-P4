import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root

    implicitWidth: 688
    implicitHeight: 330

    readonly property color accentColor: Theme.accentSolid
    readonly property color cardBg: Theme.alpha(Theme.bgCard, 0.88)
    readonly property color cardBorder: Theme.borderAccent

    StatsSubscription {
        active: true
        keys: ["cpu", "mem", "gpu", "temp", "net", "info"]
        fast: true
    }

    property string diskUsedStr: "..."
    property string diskTotalStr: "..."
    property int diskPct: 0
    property string battPctStr: "100%"
    property bool battCharging: false

    FileView {
        id: batCapFile
        path: "/sys/class/power_supply/BAT0/capacity"
        onLoaded: {
            const t = batCapFile.text();
            if (t) root.battPctStr = t.trim() + "%";
        }
    }

    FileView {
        id: batStatFile
        path: "/sys/class/power_supply/BAT0/status"
        onLoaded: {
            const t = batStatFile.text();
            if (t) root.battCharging = (t.trim() === "Charging");
        }
    }

    Process {
        id: dfProc
        command: ["sh", "-c", "df -h -l --total -x tmpfs -x devtmpfs -x efivarfs -x overlay -x squashfs 2>/dev/null | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim();
                if (line.length > 0) {
                    const parts = line.replace(/\s+/g, " ").split(" ");
                    if (parts.length >= 5) {
                        root.diskTotalStr = parts[1];
                        root.diskUsedStr = parts[2];
                        root.diskPct = parseInt(parts[4]) || 0;
                    }
                }
            }
        }
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!dfProc.running) dfProc.running = true;
            batCapFile.reload();
            batStatFile.reload();
        }
    }

    function formatSpeed(bytesPerSec) {
        if (!bytesPerSec || bytesPerSec <= 0) return "0.0 B/s";
        if (bytesPerSec < 1024) return bytesPerSec.toFixed(1) + " B/s";
        if (bytesPerSec < 1048576) return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        return (bytesPerSec / 1048576).toFixed(1) + " MB/s";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // ==========================================
        // TOP ROW: CPU Card & GPU Card (Height: 105px)
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 105
            spacing: 12

            // CPU Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰻠  CPU"
                            font.family: Theme.iconFont
                            font.pixelSize: 12
                            font.bold: true
                            color: root.accentColor
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Math.round(SystemStats.cpuUsage) + "%"
                            font.family: Theme.fontFamily
                            font.pixelSize: 16
                            font.bold: true
                            color: Theme.text
                        }
                    }

                    Text {
                        text: SystemStats.cpuName || "Intel Core Processor"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: "#a0a4b0"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: (SystemStats.cpuTemp > 0 ? SystemStats.cpuTemp : 45) + "°C"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: root.accentColor
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 5
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.1)

                            Rectangle {
                                height: parent.height
                                radius: parent.radius
                                color: root.accentColor
                                width: parent.width * Math.min(1.0, Math.max(0.0, (SystemStats.cpuTemp > 0 ? SystemStats.cpuTemp : 45) / 100))
                            }
                        }
                    }
                }
            }

            // GPU Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰢮  GPU"
                            font.family: Theme.iconFont
                            font.pixelSize: 12
                            font.bold: true
                            color: "#bd93f9"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Math.round(SystemStats.gpuUsage) + "%"
                            font.family: Theme.fontFamily
                            font.pixelSize: 16
                            font.bold: true
                            color: Theme.text
                        }
                    }

                    Text {
                        text: SystemStats.gpuName || "Intel HD Graphics"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: "#a0a4b0"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: (SystemStats.gpuTemp > 0 ? SystemStats.gpuTemp : (SystemStats.cpuTemp > 0 ? SystemStats.cpuTemp : 45)) + "°C"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: "#bd93f9"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 5
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.1)

                            Rectangle {
                                height: parent.height
                                radius: parent.radius
                                color: "#bd93f9"
                                width: parent.width * Math.min(1.0, Math.max(0.0, (SystemStats.gpuTemp > 0 ? SystemStats.gpuTemp : 45) / 100))
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // BOTTOM ROW: Battery & Storage, Network, Memory (Height: 160px)
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            spacing: 12

            // Battery & Storage Card
            Rectangle {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        spacing: 10
                        Text {
                            text: root.battCharging ? "󰂄" : "󰁹"
                            font.family: Theme.iconFont
                            font.pixelSize: 20
                            color: root.accentColor
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: root.battPctStr + (root.battCharging ? " (Cargando)" : "")
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: Theme.text
                            }
                            Text {
                                text: "Batería"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.textDim
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.06) }

                    RowLayout {
                        spacing: 10
                        Text {
                            text: "󰋊"
                            font.family: Theme.iconFont
                            font.pixelSize: 20
                            color: "#50fa7b"
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: root.diskUsedStr + " / " + root.diskTotalStr
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: Theme.text
                            }
                            Text {
                                text: "Disco (" + root.diskPct + "%)"
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                color: Theme.textDim
                            }
                        }
                    }
                }
            }

            // Network Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰛳  Network"
                            font.family: Theme.iconFont
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.text
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "󰇚 " + root.formatSpeed(SystemStats.netDown)
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: root.accentColor
                        }
                        Text {
                            text: "󰕒 " + root.formatSpeed(SystemStats.netUp)
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: "#ff79c6"
                        }
                    }

                    Canvas {
                        id: netCanvas
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            const hist = SystemStats.netDownHistory;
                            if (!hist || hist.length < 2) return;

                            ctx.lineWidth = 2;
                            ctx.strokeStyle = root.accentColor;
                            ctx.beginPath();

                            const step = width / (hist.length - 1);
                            let maxVal = 10240;
                            for (let i = 0; i < hist.length; i++) {
                                if (hist[i] > maxVal) maxVal = hist[i];
                            }

                            for (let i = 0; i < hist.length; i++) {
                                const x = i * step;
                                const y = height - (hist[i] / maxVal) * (height - 6) - 3;
                                if (i === 0) ctx.moveTo(x, y);
                                else ctx.lineTo(x, y);
                            }
                            ctx.stroke();
                        }

                        Connections {
                            target: SystemStats
                            function onNetDownChanged() { netCanvas.requestPaint(); }
                        }
                    }
                }
            }

            // Memory Card
            Rectangle {
                Layout.preferredWidth: 170
                Layout.fillHeight: true
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 56
                        height: 56
                        radius: 28
                        color: Qt.rgba(0, 0, 0, 0.3)
                        border.width: 3
                        border.color: root.accentColor
                        Layout.alignment: Qt.AlignHCenter

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                text: Math.round(SystemStats.memPercent) + "%"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: "USED"
                                font.family: Theme.fontFamily
                                font.pixelSize: 7
                                color: root.accentColor
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Text {
                        text: "󰍛  Memory"
                        font.family: Theme.iconFont
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.text
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: (SystemStats.memUsedG ? SystemStats.memUsedG.toFixed(1) : "0.0") + " / " + (SystemStats.memTotalG ? SystemStats.memTotalG.toFixed(1) : "0.0") + " GiB"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        color: Theme.textDim
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
