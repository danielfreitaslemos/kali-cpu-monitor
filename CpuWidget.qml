import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: rootCpuWidget
    
    // Broadcast the children dimensions upstream to the main layout panel
    implicitWidth: mainLayoutRow.implicitWidth + 12
    Layout.fillHeight: true
    spacing: 0

    // Native readers for system tracking files
    FileView { id: procStatReader; path: "/proc/stat" }
    FileView { id: procMemReader; path: "/proc/meminfo" }

    RowLayout {
        id: mainLayoutRow
        spacing: 12
        Layout.fillHeight: true

        property color accentColor: "#81a1c1" // Light blue accent
        property color textColor: "#ffffff"   // Clean white text
        
        property var lastUser: 0; property var lastNice: 0; property var lastSystem: 0; property var lastIdle: 0
        property string cpuPercentage: "0%"
        property string ramPercentage: "0%"

        // --- CPU Text Segment ---
        RowLayout {
            spacing: 4
            Layout.fillHeight: true
            Text {
                text: " CPU:"
                font.bold: true
                color: mainLayoutRow.accentColor
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                text: mainLayoutRow.cpuPercentage
                color: mainLayoutRow.textColor
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
            }
        }

        // --- RAM Text Segment ---
        RowLayout {
            spacing: 4
            Layout.fillHeight: true
            Text {
                text: " RAM:"
                font.bold: true
                color: mainLayoutRow.accentColor
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                text: mainLayoutRow.ramPercentage
                color: mainLayoutRow.textColor
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
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
        
        var firstLine = lines[0].trim();
        var parts = firstLine.split(/\s+/);
        if (parts[0] !== "cpu") return;

        var user = parseInt(parts[1]) || 0;
        var nice = parseInt(parts[2]) || 0;
        var system = parseInt(parts[3]) || 0;
        var idle = parseInt(parts[4]) || 0;

        var userDelta = user - mainLayoutRow.lastUser;
        var niceDelta = nice - mainLayoutRow.lastNice;
        var systemDelta = system - mainLayoutRow.lastSystem;
        var idleDelta = idle - mainLayoutRow.lastIdle;

        var totalDelta = userDelta + niceDelta + systemDelta + idleDelta;
        
        if (totalDelta > 0) {
            var usedDelta = userDelta + niceDelta + systemDelta;
            var percent = Math.round((usedDelta / totalDelta) * 100);
            mainLayoutRow.cpuPercentage = percent + "%";
        }

        mainLayoutRow.lastUser = user;
        mainLayoutRow.lastNice = nice;
        mainLayoutRow.lastSystem = system;
        mainLayoutRow.lastIdle = idle;
    }

    function calculateRam() {
        var data = procMemReader.text();
        if (!data || data.trim() === "") return;

        var lines = data.split("\n");
        var memTotal = 0;
        var memAvailable = 0;

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
            mainLayoutRow.ramPercentage = pct + "%";
        }
    }
}
