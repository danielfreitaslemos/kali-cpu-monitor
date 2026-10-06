# Kali-Style CPU Monitor for Omarchy

An ultra-lightweight, high-performance CPU utilization monitor for the **Omarchy 4.0** shell environment, styled after the classic top-right status layout in Kali Linux. 

Built using **QML (QtQuick)** and **Quickshell**, this plugin avoids heavy background bash loops by reading directly from the Linux `/proc/stat` subsystem via native asynchronous file streams (`Quickshell.Io.FileView`).

## ⚡ Features
- **Zero-overhead performance:** Utilizes internal C++ file readers to pull CPU ticks instead of spawning sub-processes.
- **Kali Linux aesthetic:** High-contrast text layout with custom icon spacing designed for dark theme panels.
- **Dynamic delta intervals:** Re-calculates exact core delta usage metrics every 2000ms.

## 🚀 Installation

1. Clone this repository directly into your local Omarchy plugin directory:
   ```bash
   git clone https://github.com ~/.config/omarchy/plugins/kali-cpu-monitor
   ```

2. Register and enable the plugin with the Omarchy package manager:
   ```bash
   omarchy plugin add ~/.config/omarchy/plugins/kali-cpu-monitor --enable
   ```

3. Add the widget component ID to the `right` layout array inside your desktop configurations (`~/.config/omarchy/shell.json`):
   ```json
   "right": [
       "com.yourname.kali-cpu-monitor"
   ]
   ```

4. Restart your active workspace shell to push it live:
   ```bash
   omarchy restart shell
   ```

## 🛠️ Tech Stack
- **Language:** QML / JavaScript (Qt6 ecosystem)
- **Framework:** Quickshell Core Engine
- **Editor:** Neovim (`nvim`)

