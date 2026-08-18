#!/usr/bin/env bash
# ==============================================================================
# lib/checks.sh - Health checks for disk, memory, CPU load, services & network
# ==============================================================================

# Ensure common library is loaded
if [[ -z "${_COMMON_SH_LOADED:-}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
fi

# 1. Disk Usage Check
check_disk_usage() {
    local threshold="${DISK_THRESHOLD:-80}"
    log_info "Checking disk usage (Threshold: ${threshold}%)..."
    
    # Get highest usage percentage on mounted drives
    local max_usage
    max_usage=$(df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | awk '{ print $1 }' | cut -d'%' -f1 | sort -nr | head -n1)

    if [[ "$max_usage" -ge "$threshold" ]]; then
        log_warn "Disk usage high: ${max_usage}% exceeds threshold (${threshold}%)"
        return 1
    else
        log_info "Disk usage normal: ${max_usage}%"
        return 0
    fi
}

# 2. Memory Usage Check
check_memory_usage() {
    local threshold="${MEMORY_THRESHOLD:-85}"
    log_info "Checking memory usage (Threshold: ${threshold}%)..."

    local total_mem used_mem usage
    total_mem=$(free | awk '/^Mem:/ {print $2}')
    used_mem=$(free | awk '/^Mem:/ {print $3}')
    
    if [[ "$total_mem" -gt 0 ]]; then
        usage=$(( used_mem * 100 / total_mem ))
        if [[ "$usage" -ge "$threshold" ]]; then
            log_warn "Memory usage high: ${usage}% exceeds threshold (${threshold}%)"
            return 1
        else
            log_info "Memory usage normal: ${usage}%"
            return 0
        fi
    fi
}

# 3. System Load Average Check
check_system_load() {
    log_info "Checking CPU load average..."
    local load
    load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | xargs)
    log_info "Current 1-min load average: ${load}"
}

# 4. Service Status Check
check_service_status() {
    local service_name="$1"
    if systemctl is-active --quiet "$service_name"; then
        log_info "Service '${service_name}' is running."
        return 0
    else
        log_warn "Service '${service_name}' is NOT running."
        return 1
    fi
}

# 5. Network Reachability Check
check_host_reachability() {
    local host="$1"
    if ping -c 1 -W 2 "$host" &>/dev/null; then
        log_info "Host '${host}' is reachable."
        return 0
    else
        log_error "Host '${host}' is unreachable!"
        return 1
    fi
}
