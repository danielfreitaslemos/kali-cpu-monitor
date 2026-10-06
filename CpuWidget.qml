import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

MouseArea {
    id: rootMouseArea
    implicitWidth: mainLayout.implicitWidth + 12
    Layout.fillHeight: true
    
    acceptedButtons: Qt.LeftButton
    onClicked: {
        infoPopup.visible = !infoPopup.visible
    }

    FileView { id: procStatReader; path: "/proc/stat" }
    FileView { id: procMemReader; path: "/proc/meminfo" }

    RowLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 12

        property color accentColor: "#81a1c1" 
        property color textColor: "#ffffff"   
        
        property var lastUser: 0; property var lastNice: 0; property var lastSystem: 0; property var lastIdle: 0
        property string cpuPercentage: "0%"
        property string ramPercentage: "0%"
        property string totalRamGb: "0.0"; property string usedRamGb: "0.0"

        RowLayout {
            spacing: 4
            Text { text: " CPU:"; font.bold: true; color: mainLayout.accentColor; font.pixelSize: 13 }
            Text { text: mainLayout.cpuPercentage; color: mainLayout.textColor; font.pixelSize: 13 }
        }

        RowLayout {
            spacing: 4
            Text { text: " RAM:"; font.bold: true; color: mainLayout.accentColor; font.pixelSize: 13 }
            Text { text: mainLayout.ramPercentage; color: mainLayout.textColor; font.pixelSize: 13 }
        }
    }

    Popup {
        id: infoPopup
        y: parent.height + 6
        anchors.horizontalCenter: parent.horizontalCenter
        width: 220
        height: 110
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        
        background: Rectangle {
            color: "#1e1e2e" 
            border.color: "#81a1c1"
            border.width: 1
            radius: 6
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            Text {
                text: "📊 System Metrics"
                color: "#81a1c1"
                font.bold: true
                font.pixelSize: 14
            }

            Text {
                text: "Memory Used: " + mainLayout.usedRamGb + " GB / " + mainLayout.totalRamGb + " GB"
                color: "#ffffff"
                font.pixelSize: 12
            }

            ProgressBar {
                id: ramBar
                Layout.fillWidth: true
                value: parseFloat(mainLayout.ramPercentage) / 100
                background: Rectangle { implicitHeight: 6; color: "#313244"; radius: 3 }
                contentItem: Item {
                    Rectangle {
                        width: ramBar.visualPosition * parent.width
                        height: parent.height
                        color: "#81a1c1"
                        radius: 3
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                text: "Launch Task Manager"
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 11
                }

                background: Rectangle {
                    color: parent.hovered ? "#313244" : "#181825"
                    border.color: "#81a1c1"
                    border.width: 1
                    radius: 4
                }

                onClicked: {
                    infoPopup.close()
                    // Fires a system daemon call. Adjust "alacritty" or "kitty" to match your terminal emulator!
                    Quickshell.execute(["alacritty", "-e", "btop"]) 
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            procStatReader.reload()
            procMemReader.reload()
            calculateCpu()
            calculateRam()
        }
    }

    function calculateCpu() {
        var data = procStatReader.text();
        if (!data || data.trim() === "") return; 
        var lines = data.split("\n");
        if (lines.length === 0) return;
        
        // Grab index 0 for the string line before running string manipulations!
        var parts = lines[0].trim().split(/\s+/);
        if (parts[0] !== "cpu") return;

        // Parse individual indexed elements out of our sliced data array
        var user = parseInt(parts[1]) || 0; 
        var nice = parseInt(parts[2]) || 0;
        var system = parseInt(parts[3]) || 0; 
        var idle = parseInt(parts[4]) || 0;

        var userDelta = user - mainLayout.lastUser; 
        var niceDelta = nice - mainLayout.lastNice;
        var systemDelta = system - mainLayout.lastSystem; 
        var idleDelta = idle - mainLayout.lastIdle;
        var totalDelta = userDelta + niceDelta + systemDelta + idleDelta;
        
        if (totalDelta > 0) {
            var usedDelta = userDelta + niceDelta + systemDelta;
            mainLayout.cpuPercentage = Math.round((usedDelta / totalDelta) * 100) + "%";
        }
        mainLayout.lastUser = user; mainLayout.lastNice = nice; mainLayout.lastSystem = system; mainLayout.lastIdle = idle;
    }

    function calculateRam() {
        var data = procMemReader.text();
        if (!data || data.trim() === "") return;
        var lines = data.split("\n");
        
        var memTotal = 0; var memAvailable = 0;
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].indexOf("MemTotal:") === 0) {
                memTotal = parseInt(lines[i].replace(/\D/g, ''));
            } else if (lines[i].indexOf("MemAvailable:") === 0) {
                memAvailable = parseInt(lines[i].replace(/\D/g, ''));
            }
        }

        if (memTotal > 0) {
            var memUsed = memTotal - memAvailable;
            var pct = Math.round((memUsed / memTotal) * 100);
            mainLayout.ramPercentage = pct + "%";
            mainLayout.totalRamGb = (memTotal / (1024 * 1024)).toFixed(1);
            mainLayout.usedRamGb = (memUsed / (1024 * 1024)).toFixed(1);
        }
    }
}

