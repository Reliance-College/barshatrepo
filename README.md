# barshatrepo

# Final Project: Infrastructure Operations & System Monitor

A modular Bash-based system administration and monitoring toolkit
 designed to track system metrics, manage server fleets, analyze
 reports, and automate maintenance routines.

## Project Structure

```
final-project-ops/
├── README.md         # Project documentation
├── monitor.sh        # Main CLI entry point
├── config/           # System and fleet configuration files
│   ├── monitor.conf  # Thresholds and log settings
│   └── hosts.conf    # Server fleet target list
└── lib/              # Sourced library modules
    ├── common.sh     # Configuration loader and logging helpers
    ├── checks.sh     # Health, reachability, and service checks
    ├── report.sh     # Multi-host reporting and alerts
    └── maintenance.sh# Backup creation, retention, and log rotation
