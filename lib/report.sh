#!/usr/bin/env bash
# ==============================================================================
# lib/report.sh - Per-host orchestration, report generation, and alerting
# ==============================================================================

# Ensure common and check modules are loaded
if [[ -z "${_COMMON_SH_LOADED:-}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
fi

# Generate health report summary
generate_report() {
    local report_file="${1:-report.txt}"
    log_info "Generating system health report to ${report_file}..."

    {
        echo "=================================================="
        echo "           SYSTEM HEALTH REPORT                   "
        echo "           Date: $(date '+%Y-%m-%d %H:%M:%S')      "
        echo "=================================================="
        echo ""
        echo "--- Disk Usage ---"
        df -h
        echo ""
        echo "--- Memory Usage ---"
        free -h
        echo ""
        echo "--- System Load & Uptime ---"
        uptime
        echo ""
        echo "=================================================="
    } > "$report_file"

    log_info "Report successfully saved to ${report_file}."
}

# Run per-host check loop from config
run_fleet_orchestration() {
    local hosts_file="${1:-config/hosts.conf}"
    log_info "Starting fleet orchestration..."

    if [[ ! -f "$hosts_file" ]]; then
        log_warn "Hosts config $hosts_file not found."
        return 1
    fi

    while IFS='|' read -r name target services endpoints || [[ -n "$name" ]]; do
        # Ignore comments and empty lines
        [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue

        name=$(echo "$name" | xargs)
        target=$(echo "$target" | xargs)

        log_info "Orchestrating host: $name ($target)"
        if ping -c 1 -W 2 "$target" &>/dev/null; then
            log_info "[$name] Host is reachable."
        else
            log_error "[$name] Host is down or unreachable!"
        fi
    done < "$hosts_file"
}
