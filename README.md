# Audio Stream Control Scripts

A collection of Bash scripts to control the audio volume of the active window on Linux using `xdotool`, `xprop`, and `pactl`. These scripts are designed to identify the active window's audio stream and either adjust its volume or switch its sink.

## Scripts

### 1. `lower_volume_active_window.sh`
Lowers the volume of the active window's audio stream by 10%.

#### Usage:
```bash
./lower_volume_active_window.sh
```

#### Features:
- Identifies the active window's audio stream.
- Decreases the volume by 10%.
- Logs all actions to `lower_volume_active_window.log`.

---

### 2. `raise_volume_active_window.sh`
Raises the volume of the active window's audio stream by 10%, with a maximum cap of 100%.

#### Usage:
```bash
./raise_volume_active_window.sh
```

#### Features:
- Identifies the active window's audio stream.
- Increases the volume by 10%, but never exceeds 100%.
- Caps the volume to 100% if it would otherwise exceed this value.
- Logs all actions to `raise_volume_active_window.log`.

---

### 3. `toggle_sink.sh`
Switches the audio output (sink) of the active window's audio stream. This script alternates the sink between two predefined outputs (e.g., a headset and an external speaker).

#### Usage:
```bash
./toggle_sink.sh
```

#### Features:
- Identifies the active window's audio stream.
- Switches the stream's audio sink between two predefined devices.
- Logs all actions to `toggle_sink.log`.

---

## StreamDeck Integration

These scripts can be easily integrated with an Elgato Stream Deck using the "System: Open" action. To set this up:

1. In the Stream Deck software, drag a "System: Open" action to your desired button
2. Set the action to point to the script's full path (e.g., `/home/user/audio-stream-control/lower_volume_active_window.sh`)
3. Optionally, customize the button's icon and title

This allows you to control your active window's audio with a single button press on your Stream Deck.

---

## Requirements

These scripts require the following tools to be installed:

- `xdotool`
- `xprop`
- `pactl` (PulseAudio or PipeWire)

To install these on most Linux distributions:
```bash
# On Debian/Ubuntu-based systems
sudo apt update && sudo apt install xdotool x11-utils pulseaudio-utils

# On Arch-based systems
sudo pacman -S xdotool xorg-xprop pulseaudio-ctl
```

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Klick3R-1/audio-stream-control.git
   cd audio-stream-control
   ```

2. Make the scripts executable:
   ```bash
   chmod +x lower_volume_active_window.sh
   chmod +x raise_volume_active_window.sh
   chmod +x toggle_sink.sh
   ```

---

## Logs

Each script has built-in logging functionality that is commented out by default. To enable logging:

1. Uncomment the `LOG_FILE` definition near the top of each script
2. Uncomment the `log()` function definition
3. Uncomment all `log` calls throughout the script
4. Restore the `tee` commands and log file redirections
5. Change error redirections from `/dev/null` back to `$LOG_FILE`
6. Uncomment debugging output sections

When enabled, each script will log to a separate file in the home directory:
- `lower_volume_active_window.log`
- `raise_volume_active_window.log`
- `toggle_sink.log`

These logs can help debug issues or understand the script's operation. By default, all logging, error output, and debugging sections are disabled to minimize disk writes and improve performance.

---

## Customization

- **Audio Sinks:** The `toggle_sink.sh` script uses predefined sink names. You can edit the script to replace these names with your audio devices:
  ```bash
  SINK_1="alsa_output.usb-Logitech_PRO_X_Wireless_Gaming_Headset-00.analog-stereo"
  SINK_2="alsa_output.usb-Solid_State_System_Co._Ltd._SPDIF_Device_24BIT_ALL_____000000000000-00.analog-stereo"
  ```

- **Volume Adjustment Limits:** In `raise_volume_active_window.sh`, you can change the maximum volume cap (default is 100%).

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve these scripts.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

