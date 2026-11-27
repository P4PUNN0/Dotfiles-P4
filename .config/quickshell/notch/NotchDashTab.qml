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

    // Weather data
    property string wxCity: "Miguel Hidalgo"
    property string wxTemp: "12°C"
    property string wxDesc: "Llovizna ligera"
    property string wxIcon: "󰖗"
    property string wxHumidity: "86%"
    property string wxWind: "4.6 km/h"

    // Media data
    property string mediaTitle: "No hay música"
    property string mediaArtist: "Spotify en pausa"
    property string mediaStatus: "Stopped"
    property string mediaArt: ""

    // System uptime
    property string uptimeStr: "up 2h, 29m"

    // Calendar & Clock
    property var currDate: new Date()
    readonly property int currentYear: currDate.getFullYear()
    readonly property int currentMonth: currDate.getMonth()
    readonly property int currentDay: currDate.getDate()

    readonly property var monthNames: [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]
    readonly property var dayHeaders: ["L", "M", "M", "J", "V", "S", "D"]

    readonly property var monthDays: {
        const year = currentYear;
        const month = currentMonth;
        const firstDayIndex = (new Date(year, month, 1).getDay() + 6) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const daysInPrevMonth = new Date(year, month, 0).getDate();
        
        let days = [];
        for (let i = firstDayIndex - 1; i >= 0; i--) {
            days.push({ day: daysInPrevMonth - i, isCurrent: false, isToday: false });
        }
        for (let d = 1; d <= daysInMonth; d++) {
            days.push({ day: d, isCurrent: true, isToday: d === currentDay });
        }
        while (days.length < 35) {
            days.push({ day: days.length - (firstDayIndex + daysInMonth) + 1, isCurrent: false, isToday: false });
        }
        return days;
    }

    FileView {
        id: wxCache
        path: Quickshell.env("HOME") + "/.cache/43pr/weather-panel.json"
        watchChanges: true
        onLoaded: {
            try {
                const d = JSON.parse(wxCache.text());
                root.wxCity = d.loc || d.city || "Miguel Hidalgo";
                root.wxTemp = Math.round(d.tempC || 12) + "°C";
                root.wxDesc = d.code === 0 ? "Despejado" : (d.code <= 3 ? "Nublado" : "Llovizna");
                root.wxIcon = d.code === 0 ? "󰖙" : (d.code <= 3 ? "󰖐" : "󰖗");
                root.wxHumidity = (d.humidity || 86) + "%";
                root.wxWind = (d.windKmh || 4.6) + " km/h";
            } catch(e) {}
        }
    }

    FileView {
        id: upFile
        path: "/proc/uptime"
        onLoaded: {
            try {
                const secs = parseFloat(upFile.text().split(" ")[0]);
                const h = Math.floor(secs / 3600);
                const m = Math.floor((secs % 3600) / 60);
                root.uptimeStr = "up " + h + "h, " + m + "m";
            } catch(e) {}
        }
    }

    property real mediaPos: 0
    property real mediaLen: 0
    readonly property bool hasMedia: mediaStatus === "Playing" || (mediaTitle !== "" && mediaTitle !== "No hay música")

    Process {
        id: mediaProc
        command: ["playerctl", "-a", "metadata", "--format", "{{playerName}}\t{{title}}\t{{artist}}\t{{status}}\t{{mpris:artUrl}}\t{{position}}\t{{mpris:length}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const textVal = text.trim();
                if (textVal) {
                    const lines = textVal.split("\n");
                    let chosen = null;
                    for (let i = 0; i < lines.length; i++) {
                        const parts = lines[i].split("\t");
                        if (parts.length >= 4) {
                            if (parts[3] === "Playing") {
                                chosen = parts;
                                if (parts[0].toLowerCase().indexOf("spotify") >= 0) break;
                            } else if (!chosen && parts[0].toLowerCase().indexOf("spotify") >= 0) {
                                chosen = parts;
                            }
                        }
                    }
                    if (!chosen && lines.length > 0) {
                        const p0 = lines[0].split("\t");
                        if (p0.length >= 4) chosen = p0;
                    }

                    if (chosen) {
                        root.mediaTitle = chosen[1] || "";
                        root.mediaArtist = chosen[2] || "";
                        root.mediaStatus = chosen[3] || "Stopped";
                        root.mediaArt = chosen[4] || "";
                        root.mediaPos = (parseFloat(chosen[5]) || 0) / 1000000;
                        root.mediaLen = (parseFloat(chosen[6]) || 0) / 1000000;
                    } else {
                        root.mediaTitle = "";
                        root.mediaArtist = "";
                        root.mediaStatus = "Stopped";
                        root.mediaArt = "";
                        root.mediaPos = 0;
                        root.mediaLen = 0;
                    }
                } else {
                    root.mediaTitle = "";
                    root.mediaArtist = "";
                    root.mediaStatus = "Stopped";
                    root.mediaArt = "";
                    root.mediaPos = 0;
                    root.mediaLen = 0;
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!mediaProc.running) mediaProc.running = true;
            upFile.reload();
            root.currDate = new Date();
        }
    }

    StatsSubscription {
        active: true
        keys: ["cpu", "mem", "temp"]
    }

    Column {
        anchors.fill: parent
        spacing: 12

        // ==========================================
        // ROW 0 (Height: 180px): Weather, User, Resources
        // ==========================================
        Row {
            width: parent.width
            height: 180
            spacing: 12

            // Card 1: Weather (250px x 180px)
            Rectangle {
                width: 250
                height: 180
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    RowLayout {
                        spacing: 14
                        Text {
                            text: root.wxIcon
                            font.family: Theme.iconFont
                            font.pixelSize: 44
                            color: root.accentColor
                        }

                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: root.wxTemp
                                font.family: Theme.fontFamily
                                font.pixelSize: 26
                                font.bold: true
                                color: Theme.text
                            }
                            Text {
                                text: root.wxDesc
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                color: "#a0a4b0"
                            }
                        }
                    }

                    Text {
                        text: "📍 " + root.wxCity
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: root.accentColor
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            radius: 8
                            color: Qt.rgba(0.05, 0.06, 0.09, 0.8)
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "󰖖"; font.family: Theme.iconFont; font.pixelSize: 11; color: "#8be9fd" }
                                Text { text: root.wxHumidity; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.text }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            radius: 8
                            color: Qt.rgba(0.05, 0.06, 0.09, 0.8)
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "󰖝"; font.family: Theme.iconFont; font.pixelSize: 11; color: "#50fa7b" }
                                Text { text: root.wxWind; font.family: Theme.fontFamily; font.pixelSize: 10; color: Theme.text }
                            }
                        }
                    }
                }
            }

            // Card 2: User Profile (270px x 180px)
            Rectangle {
                width: 270
                height: 180
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        spacing: 14
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            width: 58
                            height: 58
                            radius: 29
                            color: Qt.rgba(0.05, 0.06, 0.09, 0.9)
                            border.width: 2
                            border.color: root.accentColor
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/imgs/pfp3.png"
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }
                        }

                        ColumnLayout {
                            spacing: 3
                            Text {
                                text: "rodrigo"
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                                font.bold: true
                                color: Theme.text
                            }
                            Text {
                                text: "󰣇 Arch Linux"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                color: root.accentColor
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "󱄅 Hyprland Wayland"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: "#a0a4b0"
                        }
                        Text {
                            text: "󰔚 " + root.uptimeStr
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: root.accentColor
                        }
                    }
                }
            }

            // Card 3: Resources (244px x 180px)
            Rectangle {
                width: 244
                height: 180
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    // CPU Gauge
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 28
                            color: Qt.rgba(0.05, 0.06, 0.09, 0.8)
                            border.width: 3
                            border.color: root.accentColor
                            Layout.alignment: Qt.AlignHCenter

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 0
                                Text {
                                    text: Math.round(SystemStats.cpuUsage) + "%"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Theme.text
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: "󰻠"
                                    font.family: Theme.iconFont
                                    font.pixelSize: 10
                                    color: root.accentColor
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        Text {
                            text: "CPU"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.textDim
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // RAM Gauge
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 28
                            color: Qt.rgba(0.05, 0.06, 0.09, 0.8)
                            border.width: 3
                            border.color: "#8be9fd"
                            Layout.alignment: Qt.AlignHCenter

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 0
                                Text {
                                    text: Math.round(SystemStats.memPercent) + "%"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Theme.text
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: "󰍛"
                                    font.family: Theme.iconFont
                                    font.pixelSize: 10
                                    color: "#8be9fd"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        Text {
                            text: "RAM"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.textDim
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Temp Gauge
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 28
                            color: Qt.rgba(0.05, 0.06, 0.09, 0.8)
                            border.width: 3
                            border.color: "#ff79c6"
                            Layout.alignment: Qt.AlignHCenter

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 0
                                Text {
                                    text: (SystemStats.cpuTemp > 0 ? SystemStats.cpuTemp : 45) + "°"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: Theme.text
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: "󰔄"
                                    font.family: Theme.iconFont
                                    font.pixelSize: 10
                                    color: "#ff79c6"
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }

                        Text {
                            text: "TEMP"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.textDim
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ==========================================
        // ROW 1 (Height: 198px): Clock, Calendar, Spotify
        // ==========================================
        Row {
            width: parent.width
            height: 198
            spacing: 12

            // Card 4: Clock & Date (170px x 198px)
            Rectangle {
                width: 170
                height: 198
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: Qt.formatDateTime(root.currDate, "hh:mm")
                        font.family: Theme.fontFamily
                        font.pixelSize: 34
                        font.bold: true
                        color: Theme.text
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width: 40
                        height: 2
                        radius: 1
                        color: root.accentColor
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: Qt.formatDateTime(root.currDate, "dddd").toUpperCase()
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: root.accentColor
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: Qt.formatDateTime(root.currDate, "d 'de' MMMM")
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.textDim
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Card 5: Calendar (310px x 198px)
            Rectangle {
                width: 310
                height: 198
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
                            text: root.monthNames[root.currentMonth] + " " + root.currentYear
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.text
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "󰸗"
                            font.family: Theme.iconFont
                            font.pixelSize: 13
                            color: root.accentColor
                        }
                    }

                    // Headers (L M M J V S D)
                    RowLayout {
                        Layout.fillWidth: true
                        Repeater {
                            model: root.dayHeaders
                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                color: root.accentColor
                            }
                        }
                    }

                    // Days grid
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rowSpacing: 2
                        columnSpacing: 2

                        Repeater {
                            model: root.monthDays
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: Boolean(modelData.isToday) ? root.accentColor : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.day
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    font.bold: Boolean(modelData.isToday)
                                    color: Boolean(modelData.isToday) ? "#0a0a0f" : (modelData.isCurrent ? "#ffffff" : Qt.rgba(1, 1, 1, 0.22))
                                }
                            }
                        }
                    }
                }
            }

            // Card 6: Spotify Horizontal Card (284px x 198px)
            Rectangle {
                width: 284
                height: 198
                color: root.cardBg
                radius: 16
                border.width: 1
                border.color: root.cardBorder
                clip: true

                // ==========================================
                // 1. EMPTY STATE (When no track is playing)
                // ==========================================
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8
                    visible: !root.hasMedia

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰓇  Spotify"
                            font.family: Theme.iconFont
                            font.pixelSize: 11
                            font.bold: true
                            color: "#1DB954"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "En reposo"
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: Theme.textDim
                        }
                    }

                    Item { Layout.fillHeight: true }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 38
                            height: 38
                            radius: 19
                            color: Theme.alpha(root.accentColor, 0.12)
                            border.width: 1
                            border.color: Theme.alpha(root.accentColor, 0.3)

                            Text {
                                anchors.centerIn: parent
                                text: "󰓇"
                                font.family: Theme.iconFont
                                font.pixelSize: 18
                                color: root.accentColor
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Sin reproducción"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            color: Theme.text
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Clic para abrir Spotify"
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: Theme.textDim
                        }
                    }

                    Item { Layout.fillHeight: true }

                    AnimatedImage {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 36
                        Layout.maximumWidth: 54
                        Layout.maximumHeight: 36
                        source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/imgs/bongocat.gif"
                        fillMode: Image.PreserveAspectFit
                        playing: false
                        opacity: 0.75
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !root.hasMedia
                    onClicked: Quickshell.execDetached(["spotify"])
                }

                // ==========================================
                // 2. ACTIVE MEDIA STATE
                // ==========================================
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10
                    visible: root.hasMedia

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "󰓇  Spotify"
                            font.family: Theme.iconFont
                            font.pixelSize: 11
                            font.bold: true
                            color: "#1DB954"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.mediaStatus === "Playing" ? "Reproduciendo" : "En pausa"
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: Theme.textDim
                        }
                    }

                    // Main track row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: 60
                            height: 60
                            radius: 10
                            color: Theme.alpha(Theme.bgPanel, 0.9)
                            border.width: 1
                            border.color: root.accentColor
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: root.mediaArt !== "" ? root.mediaArt : "file://" + Quickshell.env("HOME") + "/.config/hypr/assets/spotify-fallback.png"
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰓇"
                                font.family: Theme.iconFont
                                font.pixelSize: 24
                                color: root.accentColor
                                visible: root.mediaArt === ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: root.mediaTitle !== "" ? root.mediaTitle : "Sin título"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                color: Theme.text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.mediaArtist !== "" ? root.mediaArtist : "Desconocido"
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.textDim
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Progress bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: Theme.alpha(Theme.text, 0.12)

                                Rectangle {
                                    height: parent.height
                                    radius: parent.radius
                                    color: root.accentColor
                                    width: root.mediaLen > 0 ? parent.width * Math.min(1.0, root.mediaPos / root.mediaLen) : 0
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Controls + Bongo Cat bottom row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        RowLayout {
                            spacing: 12

                            Text {
                                text: "󰒮"
                                font.family: Theme.iconFont
                                font.pixelSize: 16
                                color: prevH.hovered ? root.accentColor : Theme.text
                                HoverHandler { id: prevH }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["playerctl", "previous"])
                                }
                            }

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 14
                                color: root.accentColor

                                Text {
                                    anchors.centerIn: parent
                                    text: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                                    font.family: Theme.iconFont
                                    font.pixelSize: 14
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
                                font.pixelSize: 16
                                color: nextH.hovered ? root.accentColor : Theme.text
                                HoverHandler { id: nextH }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["playerctl", "next"])
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        AnimatedImage {
                            Layout.preferredWidth: 54
                            Layout.preferredHeight: 36
                            Layout.maximumWidth: 54
                            Layout.maximumHeight: 36
                            source: "file://" + Quickshell.env("HOME") + "/.config/quickshell/imgs/bongocat.gif"
                            fillMode: Image.PreserveAspectFit
                            playing: root.mediaStatus === "Playing"
                        }
                    }
                }
            }
        }
    }
}
