#!/usr/bin/env bash
# ==============================================================================
# lib/common.sh - Shared utilities, logging, color formatting, and config loader
# ==============================================================================

# Prevent double-sourcing
if [[ -n "${_COMMON_SH_LOADED:-}" ]]; then
    return 0
fi
_COMMON_SH_LOADED=1

# --- Color Formatting ---
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# --- Helper Functions ---

# Load configuration file
load_config() {
    local config_file="${1:-config/monitor.conf}"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    else
        log_warn "Configuration file $config_file not found. Using defaults."
    fi
}

# Timestamped logging helper
log_msg() {
    local level="$1"
    local color="$2"
    shift 2
    local message="$*"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    echo -e "${color}[${timestamp}] [${level}] ${message}${NC}"

    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    fi
}

log_info()  { log_msg "INFO"  "$GREEN"  "$@"; }
log_warn()  { log_msg "WARN"  "$YELLOW" "$@"; }
log_error() { log_msg "ERROR" "$RED"    "$@"; }

die() {
    log_error "$@"
    exit 1
}

require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        die "Required command '$cmd' is not installed or not in PATH."
    fi
}
