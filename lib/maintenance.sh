#!/usr/bin/env bash
# ==============================================================================
# lib/maintenance.sh - Automated cleanup, log rotation, and maintenance
# ==============================================================================

# Ensure common library is loaded
if [[ -z "${_COMMON_SH_LOADED:-}" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
fi

# 1. Clean /tmp directory files older than 7 days
clean_tmp_files() {
    log_info "Cleaning up /tmp files older than 7 days..."
    if find /tmp -type f -atime +7 -delete 2>/dev/null; then
        log_info "Temporary files cleaned successfully."
    else
        log_warn "Some files in /tmp could not be deleted (permission denied)."
    fi
}

# 2. Clear package manager cache (apt/yum/dnf)
clean_package_cache() {
    log_info "Clearing package manager cache..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get clean &>/dev/null && log_info "APT cache cleared."
    elif command -v dnf &>/dev/null; then
        sudo dnf clean all &>/dev/null && log_info "DNF cache cleared."
    elif command -v yum &>/dev/null; then
        sudo yum clean all &>/dev/null && log_info "YUM cache cleared."
    else
        log_warn "No supported package manager found to clean cache."
    fi
}

# 3. Archive/Rotate old logs
archive_logs() {
    local log_dir="${1:-/var/log}"
    local archive_dir="${2:-/var/log/archive}"
    
    log_info "Archiving logs older than 30 days from ${log_dir}..."
    mkdir -p "$archive_dir"

    find "$log_dir" -maxdepth 1 -name "*.log" -mtime +30 -exec gzip {} \; 2>/dev/null
    find "$log_dir" -maxdepth 1 -name "*.log.gz" -exec mv {} "$archive_dir/" \; 2>/dev/null

    log_info "Log archival complete."
}
