import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 1.0

Row {
    id: cpuRoot
    spacing: 6
    padding: 4

    // Colors mapping to active Omarchy system styles
    property color textColor: "#ffffff"
    property color accentColor: "#81a1c1" // Light blue accents reminiscent of Kali

    property var lastUser: 0
    property var lastNice: 0
    property var lastSystem: 0
    property var lastIdle: 0
    property string cpuPercentage: "0%"

    // Text display for the layout bar
    Text {
        text: " CPU:"
        font.bold: true
        color: cpuRoot.accentColor
        font.pixelSize: 13
    }

    Text {
        text: cpuRoot.cpuPercentage
        color: cpuRoot.textColor
        font.pixelSize: 13
    }

    // Timer that fires based on manifest definitions to process /proc/stat
    Timer {
        interval: 2000 // Refreshes every 2 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: calculateCpu()
    }

    function calculateCpu() {
        // Read native Linux stats directly via FileView or Quickshell bindings
        var data = Quickshell.readFile("/proc/stat");
        if (!data) return;

        var firstLine = data.split("\n")[0];
        var parts = firstLine.split(/\s+/);
        
        // /proc/stat layout: cpu  user nice system idle ...
        var user = parseInt(parts[1]) || 0;
        var nice = parseInt(parts[2]) || 0;
        var system = parseInt(parts[3]) || 0;
        var idle = parseInt(parts[4]) || 0;

        var userDelta = user - cpuRoot.lastUser;
        var niceDelta = nice - cpuRoot.lastNice;
        var systemDelta = system - cpuRoot.lastSystem;
        var idleDelta = idle - cpuRoot.lastIdle;

        var totalDelta = userDelta + niceDelta + systemDelta + idleDelta;
        
        if (totalDelta > 0) {
            var usedDelta = userDelta + niceDelta + systemDelta;
            var percent = Math.round((usedDelta / totalDelta) * 100);
            cpuRoot.cpuPercentage = percent + "%";
        }

        // Store baseline state for the next calculation loop
        cpuRoot.lastUser = user;
        cpuRoot.lastNice = nice;
        cpuRoot.lastSystem = system;
        cpuRoot.lastIdle = idle;
    }
}

