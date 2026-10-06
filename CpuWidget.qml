import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Quickshell 1.0

RowLayout {
    id: rootCpuWidget
    
    implicitWidth: cpuLabel.implicitWidth + cpuValue.implicitWidth + spacing
    Layout.fillHeight: true
    spacing: 6

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
        if (!data || data.trim() === "") return; // Safety check for asynchronous empty reads

        var lines = data.split("\n");
        if (lines.length === 0) return;
        
        // Safely extract the cumulative total CPU line
        var firstLine = lines[0].trim();
        var parts = firstLine.split(/\s+/);
        if (parts[0] !== "cpu") return;

        // Cumulative CPU stats logic
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
