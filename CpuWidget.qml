    function calculateCpu() {
        var data = Quickshell.readFile("/proc/stat");
        if (!data) return;

        var lines = data.split("\n");
        if (lines.length === 0) return;
        
        // Target index 0 which contains the overall global "cpu user nice system..."
        var parts = lines[0].trim().split(/\s+/);
        if (parts[0] !== "cpu") return;

        // parts[0] is "cpu", values start at index 1
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
