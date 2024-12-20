#!/bin/bash

# Define log file
LOG_FILE="$HOME/lower_volume_active_window.log"

# Log function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Script started."

# Get the active window's title and application name
active_window=$(xdotool getwindowfocus getwindowname 2>>"$LOG_FILE")
log "Active window title detected: $active_window"

application_name=$(xprop -id "$(xdotool getwindowfocus)" | grep "WM_CLASS" | awk -F '"' '{print $4}' 2>>"$LOG_FILE")
log "Application name from WM_CLASS: $application_name"

if [ -z "$active_window" ]; then
  log "Error: Could not determine the active window."
  exit 1
fi

if [ -z "$application_name" ]; then
  log "Error: Could not determine the application name for the active window."
  exit 1
fi

# Fetch and process sink input data
log "Fetching and processing sink input data..."
sink_inputs=$(pactl list sink-inputs)
log "Raw sink input data captured:"
echo "$sink_inputs" | tee -a "$LOG_FILE"

# Search for the audio stream matching the active window
log "Searching for audio stream with the following criteria:"
log "  - application.process.binary contains \"$application_name\""
log "  - media.name contains \"$active_window\""
log "  - application.name contains \"$application_name\""
log "  - Known browser binary match (brave, firefox, chrome, etc.)"

stream_index=$(echo "$sink_inputs" | awk -v app="$application_name" -v title="$active_window" '
    BEGIN {match_found=0}
    $0 ~ /Sink Input #/ {stream=$3}
    tolower($0) ~ "application.process.binary =.*" tolower(app) {match_found=1}
    tolower($0) ~ "media.name =.*" tolower(title) {match_found=1}
    tolower($0) ~ "application.name =.*" tolower(app) {match_found=1}
    tolower($0) ~ "application.name = \"brave\"" {match_found=1}
    tolower($0) ~ "application.process.binary = \"brave\"" {match_found=1}
    match_found {print stream; exit}
')
stream_index=$(echo "$stream_index" | tr -d '#') # Remove extraneous `#`
log "Sanitized stream index: $stream_index"

if [ -z "$stream_index" ]; then
  log "No audio stream found for active window or application: $active_window / $application_name"
  exit 1
fi

log "Found audio stream: #$stream_index for application or window: $active_window / $application_name"

# Adjust the volume for the identified stream (lower by 10%)
log "Lowering volume for stream #$stream_index by 10%..."
if pactl set-sink-input-volume "$stream_index" '-10%' 2>>"$LOG_FILE"; then
  log "Successfully lowered volume for stream #$stream_index by 10%."
else
  log "Error: Failed to lower volume for stream #$stream_index."
  exit 1
fi

log "Script completed successfully."
