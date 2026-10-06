import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 1.0

Item {
    id: rootItem
    // Explicitly set sizing so the bar parent container knows how much room to give it
    implicitWidth: cpuLayoutRow.width + 12
    implicitHeight: 30 

    Row {
        id: cpuLayoutRow
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 6

        // Style variables mirroring Kali Linux topbar look
        property color accentColor: "#81a1c1" // Light blue accent
        property color textColor: "#ffffff"   // Clean white text
        
        property var lastUser: 0
        property var lastNice: 0
        property var lastSystem: 0
        property var lastIdle: 0
        property string cpuPercentage: "0%"

        Text {
            text: " CPU:"
            font.bold: true
            color: cpuLayoutRow.accentColor
            font.pixelSize: 13
        }

        Text {
            text: cpuLayoutRow.cpuPercentage
            color: cpuLayoutRow.textColor
            font.pixelSize: 13
        }

        Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: calculateCpu()
        }

        function calculateCpu() {
            var data = Quickshell.readFile("/proc/stat");
            if (!data) return;

            var lines = data.split("\n");
            if (lines.length === 0) return;
            
            var parts = lines[0].split(/\s+/);
            // parts[0] is "cpu", parts[1] is user, parts[2] is nice, etc.
            var user = parseInt(parts[1]) || 0;
            var nice = parseInt(parts[2]) || 0;
            var system = parseInt(parts[3]) || 0;
            var idle = parseInt(parts[4]) || 0;

            var userDelta = user - cpuLayoutRow.lastUser;
            var niceDelta = nice - cpuLayoutRow.lastNice;
            var systemDelta = system - cpuLayoutRow.lastSystem;
            var idleDelta = idle - cpuLayoutRow.lastIdle;

            var totalDelta = userDelta + niceDelta + systemDelta + idleDelta;
            
            if (totalDelta > 0) {
                var usedDelta = userDelta + niceDelta + systemDelta;
                var percent = Math.round((usedDelta / totalDelta) * 100);
                cpuLayoutRow.cpuPercentage = percent + "%";
            }

            cpuLayoutRow.lastUser = user;
            cpuLayoutRow.lastNice = nice;
            cpuLayoutRow.lastSystem = system;
            cpuLayoutRow.lastIdle = idle;
        }
    }
}
