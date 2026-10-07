# Kali-Style CPU & RAM Monitor for Omarchy

An ultra-lightweight, high-performance system resource panel widget for the **Omarchy 4.0** shell environment, styled after the classic top-right status layout in Kali Linux. 

Built natively using **QML (QtQuick)** and **Quickshell**, this plugin completely avoids heavy background bash cycles or spawning sub-processes by reading directly from the Linux `/proc/stat` and `/proc/meminfo` subsystems via highly optimized asynchronous file streams (`Quickshell.Io.FileView`).

---

## ⚡ Features
- **Dual Resource Tracking:** Displays real-time **CPU utilization** and **RAM allocation percentages** side-by-side.
- **Zero-Overhead Architecture:** Leverages C++ native file-readers to poll system ticks directly with near-zero CPU footprint.
- **Kali Linux Aesthetic:** High-contrast text layout utilizing FontAwesome system icons (``, ``) designed perfectly for modern bar layouts.
- **Dynamic Calculation:** Automatically recalculates core metrics and hardware deltas every 2000ms.

---

## 🛠️ Tech Stack
- **Language:** QML / JavaScript (Qt6 Ecosystem)
- **Framework:** Quickshell Core Engine
- **Development Environment:** Neovim (`nvim`) / Zed

---

## 🚀 Installation & Setup

1. **Clone this repository** directly into your local Omarchy configuration space:
   ```bash
   git clone https://github.com ~/.config/omarchy/plugins/kali-cpu-monitor
   ```

2. **Register and enable** the plugin using the Omarchy package tool:
   ```bash
   omarchy plugin add ~/.config/omarchy/plugins/kali-cpu-monitor --enable
   ```

3. **Inject the component** into your top bar layout. Open your configuration file (`~/.config/omarchy/shell.json`) and append your unique ID inside the `"right"` array block:
   ```json
   "right": [
       "omarchy.tray",
       "omarchy.audio",
       "omarchy.power",
       "com.daniel.kali-cpu-monitor"
   ]
   ```
   *(Note: Ensure you remove any conflicting stock `omarchy.monitor` objects from the panel array to prevent layout collisions).*

4. **Restart your desktop shell layout** to load the widget live:
   ```bash
   omarchy restart shell
   ```

---

## 📂 Project Structure
- `manifest.json` - Plugin capability metadata mapping and shell routing registration.
- `CpuWidget.qml` - Core QtQuick visual layouts and JavaScript data processing loops.
- `README.md` - Project documentation.
