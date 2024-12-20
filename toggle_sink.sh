#!/bin/bash

# Define log file
LOG_FILE="$HOME/toggle_sink.log"

# Define sink names
SPDIF_SINK="alsa_output.usb-Solid_State_System_Co._Ltd._SPDIF_Device_24BIT_ALL_____000000000000-00.analog-stereo"
LOGITECH_SINK="alsa_output.usb-Logitech_PRO_X_Wireless_Gaming_Headset-00.analog-stereo"

# Log function
log() {
  # echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
  :  # No-op
}

# log "Script started."

# Get the active window's title and application name
active_window=$(xdotool getwindowfocus getwindowname 2>/dev/null)
# log "Active window title detected: $active_window"

application_name=$(xprop -id "$(xdotool getwindowfocus)" | grep "WM_CLASS" | awk -F '"' '{print $4}' 2>/dev/null)
# log "Application name from WM_CLASS: $application_name"

if [ -z "$active_window" ]; then
  log "Error: Could not determine the active window."
  exit 1
fi

if [ -z "$application_name" ]; then
  log "Error: Could not determine the application name for the active window."
  exit 1
fi

# Normalize sink inputs for easier searching
# log "Fetching and processing sink input data..."
sink_inputs=$(pactl list sink-inputs)
# log "Raw sink input data captured:"
# echo "$sink_inputs" | tee -a "$LOG_FILE"

# Define matching criteria
# log "Searching for audio stream with the following criteria:"
# log "  - Exact matches for browser applications (e.g., Brave, Firefox, Chrome)"
# log "  - application.process.binary contains \"$application_name\""
# log "  - media.name contains \"$active_window\""
# log "  - application.name contains \"$application_name\""

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
# log "Sanitized stream index: $stream_index"

if [ -z "$stream_index" ]; then
  # log "No audio stream found for active window or application: $active_window / $application_name"
  exit 1
fi

# log "Found audio stream: #$stream_index for application or window: $active_window / $application_name"

# Extract the current sink ID for the stream
# log "Attempting to extract the current sink ID for stream #$stream_index..."
current_sink_id=$(echo "$sink_inputs" | awk -v stream="Sink Input #$stream_index" '
    $0 ~ stream {found=1}
    found && $0 ~ /Sink:/ {print $2; exit}
')
if [ -z "$current_sink_id" ]; then
  # log "Error: Could not determine the current sink for stream #$stream_index. Check the log for details."
  # log "Debugging: Stream details for stream #$stream_index:"
  # echo "$sink_inputs" | awk -v stream="Sink Input #$stream_index" '
  #     $0 ~ stream {found=1}
  #     found {print; if ($0 ~ /Properties:/) exit}
  # ' | tee -a "$LOG_FILE"
  exit 1
fi

# log "Extracted current sink ID: $current_sink_id"

# Map sink ID to sink name
# log "Mapping sink ID $current_sink_id to sink name..."
current_sink_name=$(pactl list sinks | awk '/Sink #'"$current_sink_id"'/ {found=1} found && /Name:/ {print $2; exit}')
# log "Mapped current sink name: $current_sink_name"

if [ -z "$current_sink_name" ]; then
  # log "Error: Could not map sink ID $current_sink_id to a sink name. Check the log for details."
  exit 1
fi

# Verify the target sink exists
# log "Verifying target sink exists..."
target_sink=""
if [ "$current_sink_name" = "$SPDIF_SINK" ]; then
  target_sink="$LOGITECH_SINK"
  # log "Switching from SPDIF to Logitech."
elif [ "$current_sink_name" = "$LOGITECH_SINK" ]; then
  target_sink="$SPDIF_SINK"
  # log "Switching from Logitech to SPDIF."
else
  # log "Stream is not currently assigned to either SPDIF or Logitech. Assigning to SPDIF."
  target_sink="$SPDIF_SINK"
fi

if ! pactl list sinks short | grep -q "$target_sink"; then
  # log "Error: Target sink $target_sink does not exist."
  exit 1
fi

# log "Target sink determined: $target_sink"

# Move the stream to the target sink
if pactl move-sink-input "$stream_index" "$target_sink" 2>/dev/null; then
  # log "Successfully moved stream #$stream_index to sink $target_sink."
else
  # log "Error: Failed to move stream #$stream_index to sink $target_sink."
  exit 1
fi

# log "Script completed successfully."
