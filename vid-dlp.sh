#!/bin/bash

# Check if yt-dlp and kdialog are installed
if ! command -v yt-dlp &>/dev/null; then
    kdialog --error "yt-dlp is not installed.\n\nInstall it with:\n  sudo pacman -S yt-dlp  (Arch)\n  sudo apt install yt-dlp  (Debian/Ubuntu)"
    exit 1
fi

if ! command -v kdialog &>/dev/null; then
    echo "Error: kdialog is not installed."
    exit 1
fi

# Ask the user for the video URL
VIDEO_URL=$(kdialog --inputbox "Enter YouTube or video URL:")
if [ -z "$VIDEO_URL" ]; then
    kdialog --sorry "No URL provided. Exiting."
    exit 1
fi

# Ask the user where to save the file
SAVE_DIR=$(kdialog --getexistingdirectory "$HOME" "Select a folder to save the downloaded video")
if [ -z "$SAVE_DIR" ]; then
    kdialog --sorry "No destination selected. Exiting."
    exit 1
fi

# Confirm download
kdialog --yesno "Download video from:\n$VIDEO_URL\n\nSave to:\n$SAVE_DIR ?" --title "Confirm Download"
if [ $? -ne 0 ]; then
    kdialog --sorry "Download cancelled."
    exit 1
fi

# Run yt-dlp and show progress in konsole
konsole --noclose -e bash -c "
    echo 'Downloading...'
    yt-dlp -o \"$SAVE_DIR/%(title)s.%(ext)s\" \"$VIDEO_URL\"
    echo
    echo '✅ Download complete. File saved to:'
    echo '$SAVE_DIR'
    echo
    read -p 'Press Enter to close...' " &

exit 0
