#!/bin/bash

# --- Dependency Checks ---
if ! command -v yt-dlp &>/dev/null; then
    kdialog --error "yt-dlp is not installed.\n\nInstall it using:\n  sudo pacman -S yt-dlp  (Arch)\n  sudo apt install yt-dlp  (Debian/Ubuntu)"
    exit 1
fi

if ! command -v kdialog &>/dev/null; then
    echo "Error: kdialog is not installed."
    exit 1
fi

# --- Ask for video URL ---
VIDEO_URL=$(kdialog --inputbox "Enter YouTube or video URL:")
if [ -z "$VIDEO_URL" ]; then
    kdialog --sorry "No URL provided. Exiting."
    exit 1
fi

# --- Ask for save directory ---
SAVE_DIR=$(kdialog --getexistingdirectory "$HOME" "Select a folder to save the downloaded video")
if [ -z "$SAVE_DIR" ]; then
    kdialog --sorry "No destination selected. Exiting."
    exit 1
fi

# --- Confirm download ---
kdialog --yesno "Download video from:\n$VIDEO_URL\n\nSave to:\n$SAVE_DIR ?" --title "Confirm Download"
if [ $? -ne 0 ]; then
    kdialog --sorry "Download cancelled."
    exit 1
fi

# --- Prepare temp name preview ---
VIDEO_TITLE=$(yt-dlp --get-title "$VIDEO_URL" 2>/dev/null | head -n 1)
OUTPUT_FILE="$SAVE_DIR/${VIDEO_TITLE}.mp4"

# --- Check for invalid characters ---
if [[ "$OUTPUT_FILE" =~ [\/:\*\?\"\<\>\|] ]]; then
    kdialog --warning "The video title contains characters that are invalid for filenames.\n\nA sanitized name will be used instead."
    USE_RESTRICT="--restrict-filenames"
else
    USE_RESTRICT=""
fi

# --- Run yt-dlp inside Konsole ---
konsole --noclose -e bash -c "
    echo 'Downloading...'
    yt-dlp -o \"$SAVE_DIR/%(title)s.%(ext)s\" $USE_RESTRICT \"$VIDEO_URL\"
    EXIT_CODE=\$?
    if [ \$EXIT_CODE -eq 0 ]; then
        echo
        echo '✅ Download complete. File saved to:'
        echo '$SAVE_DIR'
    else
        echo
        echo '❌ Download failed. Please check your connection or URL.'
    fi
    echo
    read -p 'Press Enter to close...' " &
