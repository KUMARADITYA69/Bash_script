#!/bin/bash

# ============================
# System Health Monitoring Script
# ============================

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80
LOG_FILE="/var/log/system_health.log"

# Function to log alerts
log_alert() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ALERT: $message" | tee -a "$LOG_FILE"
}

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU_USAGE_INT=${CPU_USAGE%.*}

if [ "$CPU_USAGE_INT" -gt "$CPU_THRESHOLD" ]; then
    log_alert "High CPU usage detected: ${CPU_USAGE_INT}% (Threshold: ${CPU_THRESHOLD}%)"
fi

# Memory usage
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
MEM_USAGE_INT=${MEM_USAGE%.*}

if [ "$MEM_USAGE_INT" -gt "$MEM_THRESHOLD" ]; then
    log_alert "High Memory usage detected: ${MEM_USAGE_INT}% (Threshold: ${MEM_THRESHOLD}%)"
fi

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    log_alert "High Disk usage detected: ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)"
fi

# Running processes
PROC_COUNT=$(ps -e --no-headers | wc -l)
MAX_PROC=300   # set a limit for processes
if [ "$PROC_COUNT" -gt "$MAX_PROC" ]; then
    log_alert "High number of running processes detected: ${PROC_COUNT} (Threshold: ${MAX_PROC})"
fi

echo "✅ System health check completed at $(date)" | tee -a "$LOG_FILE"

