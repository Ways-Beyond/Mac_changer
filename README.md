# 🖥️ MAC Address Manager

A colorful, menu‑driven Bash script for managing MAC addresses on Linux systems.  
It provides a dashboard‑style interface with logging, search, backup, and real‑time monitoring.  
**Made by ELMAN404**

---

## ✨ Features
- **List Interfaces** – see all available network interfaces.
- **Real‑Time Status Panel** – table view of interfaces, MACs, and status (✅ Active / ❌ Down).
- **Change MAC** – set a custom or random MAC address.
- **Restore MAC** – revert to the original saved MAC.
- **View Current MAC** – check the MAC of a specific interface.
- **Log History** – view, search, clear, or backup logs with timestamps.
- **Auto‑Refresh Mode** – continuously monitor interface states every few seconds.
- **Summary Line** – shows counts of active vs down interfaces.
- **Signature Logging** – every log entry is tagged with `(Made by ELMAN404)`.

---

## ⚙️ Installation
Clone the repository and make the script executable:

```bash
git clone https://github.com/Ways-Bigvai/mac_changer.sh
cd mac-manager
chmod +x mac_manager.sh

🚀 Usage
./mac_manager.sh

You’ll see a menu like this:
┌───────────────────────────────────────────────┐
│         MAC Address Manager Dashboard         │
└───────────────────────────────────────────────┘
1) List Interfaces
2) Real-Time Status Panel
3) Change MAC
4) Restore MAC
5) View Current MAC
6) View Log History
7) Search Log History
8) Clear Log History
9) Backup Log History
10) Exit

📂 Logs

    Logs are stored in /var/log/mac_manager.log.
    Backups are saved in /var/log/mac_manager_backups/ with timestamped filenames.

⚠️ Disclaimer

This tool is for educational and administrative use.
Changing MAC addresses may affect your network connectivity. Use responsibly.
chmod +x mac_manager.sh

