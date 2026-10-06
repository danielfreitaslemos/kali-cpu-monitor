import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell 1.0

// Use RowLayout as the root to broadcast structural widths correctly to Omarchy's bar
RowLayout {
    id: rootCpuWidget
    
    // Broadcast the children dimensions upstream to the main layout panel
    implicitWidth: cpuLabel.implicitWidth + cpuValue.implicitWidth + spacing
    Layout.fillHeight: true
    spacing: 6

    // Styling metrics inspired by Kali Linux status text
    property color accentColor: "#81a1c1" 
    property color textColor: "#ffffff"   

    property var lastUser: 0
    property var lastNice: 0
    property var lastSystem: 0
    property var lastIdle: 0
    property string cpuPercentage: "0%"

    Text {
        id: cpuLabel
        text: " CPU:"
        font.bold: true
        color: rootCpuWidget.accentColor
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
        Layout.fillHeight: true
    }

    Text {
        id: cpuValue
        text: rootCpuWidget.cpuPercentage
        color: rootCpuWidget.textColor
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
        Layout.fillHeight: true
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
        
        // Split strings gracefully matching native proc layouts
        var parts = lines[0].split(/\s+/);
        if (parts[0] !== "cpu") return;

        var user = parseInt(parts[1]) || 0;
        var nice = parseInt(parts[2]) || 0;
        var system = parseInt(parts[3]) || 0;
        var idle = parseInt(parts[4]) || 0;

        var userDelta = user - rootCpuWidget.lastUser;
        var niceDelta = nice - rootCpuWidget.lastNice;
        var systemDelta = system - rootCpuWidget.lastSystem;
        var idleDelta = idle - rootCpuWidget.lastIdle;

        var totalDelta = userDelta + niceDelta + systemDelta + idleDelta;
        
        if (totalDelta > 0) {
            var usedDelta = userDelta + niceDelta + systemDelta;
            var percent = Math.round((usedDelta / totalDelta) * 100);
            rootCpuWidget.cpuPercentage = percent + "%";
        }

        rootCpuWidget.lastUser = user;
        rootCpuWidget.lastNice = nice;
        rootCpuWidget.lastSystem = system;
        rootCpuWidget.lastIdle = idle;
    }
}
