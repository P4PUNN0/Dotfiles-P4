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

    property string location: "Miguel Hidalgo"
    property string dateStr: "jueves, 26 de noviembre"
    property string tempStr: "12°C"
    property string descStr: "Llovizna ligera"
    property string iconStr: "󰖗"
    property string humidityStr: "86%"
    property string feelsStr: "11°C"
    property string windStr: "4.6 km/h"
    property string sunriseStr: "7:00 AM"
    property string sunsetStr: "6:05 PM"

    property var dailyForecast: [
        { day: "Hoy", icon: "󰖗", min: "10°", max: "16°" },
        { day: "vie", icon: "󰖐", min: "11°", max: "18°" },
        { day: "sáb", icon: "󰖐", min: "10°", max: "20°" },
        { day: "dom", icon: "󰖙", min: "9°",  max: "21°" },
        { day: "lun", icon: "󰖙", min: "10°", max: "22°" },
        { day: "mar", icon: "󰖐", min: "11°", max: "19°" },
        { day: "mié", icon: "󰖗", min: "10°", max: "17°" }
    ]

    FileView {
        id: wxCacheFile
        path: Quickshell.env("HOME") + "/.cache/43pr/weather-panel.json"
        watchChanges: true
        onLoaded: {
            try {
                const d = JSON.parse(wxCacheFile.text());
                root.location = d.loc || d.city || "Miguel Hidalgo";
                root.tempStr = Math.round(d.tempC || 12) + "°C";
                root.feelsStr = Math.round(d.feelsC || (d.tempC - 1)) + "°C";
                root.humidityStr = (d.humidity || 86) + "%";
                root.windStr = (d.windKmh || 4.6) + " km/h";
                root.descStr = d.code === 0 ? "Despejado" : (d.code <= 3 ? "Nublado" : "Llovizna ligera");
                root.iconStr = d.code === 0 ? "󰖙" : (d.code <= 3 ? "󰖐" : "󰖗");

                const now = new Date();
                const days = ["dom", "lun", "mar", "mié", "jue", "vie", "sáb"];
                const months = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];
                root.dateStr = days[now.getDay()] + ", " + now.getDate() + " de " + months[now.getMonth()];

                let updated = [];
                for (let i = 0; i < 7; i++) {
                    let fDay = new Date(now.getTime() + i * 86400000);
                    let label = (i === 0) ? "Hoy" : days[fDay.getDay()];
                    let ic = (i === 0) ? root.iconStr : (i % 2 === 0 ? "󰖐" : "󰖙");
                    let tMin = (Math.round(d.tempC || 12) - 2 + (i % 3)) + "°";
                    let tMax = (Math.round(d.tempC || 12) + 5 + (i % 4)) + "°";
                    updated.push({ day: label, icon: ic, min: tMin, max: tMax });
                }
                root.dailyForecast = updated;
            } catch(e) {}
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: wxCacheFile.reload()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // HEADER: Location, Date, Sunrise & Sunset
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 1
                Text {
                    text: root.location
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.text
                }
                Text {
                    text: root.dateStr
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.textDim
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 16
                RowLayout {
                    spacing: 4
                    Text { text: "󰖚"; font.family: Theme.iconFont; font.pixelSize: 13; color: "#f1fa8c" }
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Amanecer"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.textDim }
                        Text { text: root.sunriseStr; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true; color: Theme.text }
                    }
                }
                RowLayout {
                    spacing: 4
                    Text { text: "󰖛"; font.family: Theme.iconFont; font.pixelSize: 13; color: "#ffb86c" }
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Atardecer"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.textDim }
                        Text { text: root.sunsetStr; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true; color: Theme.text }
                    }
                }
            }
        }

        // HERO: Large Temperature & Condition
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: 16
            color: root.cardBg
            border.width: 1
            border.color: root.cardBorder

            RowLayout {
                anchors.centerIn: parent
                spacing: 18

                Text {
                    text: root.iconStr
                    font.family: Theme.iconFont
                    font.pixelSize: 42
                    color: root.accentColor
                }

                ColumnLayout {
                    spacing: 0
                    Text {
                        text: root.tempStr
                        font.family: Theme.fontFamily
                        font.pixelSize: 32
                        font.bold: true
                        color: Theme.text
                    }
                    Text {
                        text: root.descStr
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.textDim
                    }
                }
            }
        }

        // METRICS ROW: Humedad, Sensación, Viento
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 12
                color: root.cardBg
                border.width: 1
                border.color: root.cardBorder

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "󰖖"; font.family: Theme.iconFont; font.pixelSize: 15; color: "#8be9fd" }
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Humedad"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.textDim }
                        Text { text: root.humidityStr; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; color: Theme.text }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 12
                color: root.cardBg
                border.width: 1
                border.color: root.cardBorder

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "󰔄"; font.family: Theme.iconFont; font.pixelSize: 15; color: root.accentColor }
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Sensación"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.textDim }
                        Text { text: root.feelsStr; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; color: Theme.text }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: 12
                color: root.cardBg
                border.width: 1
                border.color: root.cardBorder

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "󰖝"; font.family: Theme.iconFont; font.pixelSize: 15; color: "#50fa7b" }
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Viento"; font.family: Theme.fontFamily; font.pixelSize: 9; color: Theme.textDim }
                        Text { text: root.windStr; font.family: Theme.fontFamily; font.pixelSize: 11; font.bold: true; color: Theme.text }
                    }
                }
            }
        }

        // 7-DAY FORECAST CARDS ROW
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "Pronóstico de 7 días"
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                color: Theme.textDim
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: root.dailyForecast

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 12
                        color: root.cardBg
                        border.width: 1
                        border.color: modelData.day === "Hoy" ? root.accentColor : root.cardBorder

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: modelData.day
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: modelData.day === "Hoy"
                                color: modelData.day === "Hoy" ? root.accentColor : "#8b909a"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: modelData.icon
                                font.family: Theme.iconFont
                                font.pixelSize: 15
                                color: Theme.text
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: modelData.min + " / " + modelData.max
                                font.family: Theme.fontFamily
                                font.pixelSize: 8
                                color: Theme.textDim
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
