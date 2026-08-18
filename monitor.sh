#!/usr/bin/env bash
# ==============================================================================
# monitor.sh - Main entry point: option parsing, dispatch, menu & execution
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all lib modules
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/checks.sh"
source "${SCRIPT_DIR}/lib/report.sh"
source "${SCRIPT_DIR}/lib/maintenance.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -c, --check       Run system health checks (disk, memory, load, network)
  -r, --report      Generate health report & run fleet orchestration
  -m, --maintenance Run system maintenance and cleanup tasks
  -a, --all         Run checks, generate report, and perform maintenance
  -h, --help        Display this help message and exit

EOF
}

run_all_checks() {
    log_info "=== Starting System Health Checks ==="
    check_disk_usage
    check_memory_usage
    check_system_load
    check_service_status "ssh" || check_service_status "sshd"
    check_host_reachability "8.8.8.8"
}

run_all_maintenance() {
    log_info "=== Starting System Maintenance ==="
    clean_tmp_files
    clean_package_cache
    archive_logs
}

main() {
    load_config "${SCRIPT_DIR}/config/monitor.conf"

    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--check)
                run_all_checks
                shift
                ;;
            -r|--report)
                generate_report "health_report.txt"
                run_fleet_orchestration "${SCRIPT_DIR}/config/hosts.conf"
                shift
                ;;
            -m|--maintenance)
                run_all_maintenance
                shift
                ;;
            -a|--all)
                run_all_checks
                echo ""
                generate_report "health_report.txt"
                run_fleet_orchestration "${SCRIPT_DIR}/config/hosts.conf"
                echo ""
                run_all_maintenance
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

main "$@"
