#!/bin/bash

# Run this script after creating an archive but before uploading to App Store
# Usage: ./archive_post_process.sh /path/to/your.xcarchive

ARCHIVE_PATH="$1"

if [ -z "$ARCHIVE_PATH" ]; then
    echo "Usage: $0 /path/to/your.xcarchive"
    exit 1
fi

DSYMS_PATH="$ARCHIVE_PATH/dSYMs"

if [ -d "$DSYMS_PATH" ]; then
    echo "Processing dSYMs in: $DSYMS_PATH"
    
    # Remove FFmpeg dSYM files
    find "$DSYMS_PATH" -name "*ffmpegkit*" -type d -exec rm -rf {} + 2>/dev/null
    find "$DSYMS_PATH" -name "*libav*" -type d -exec rm -rf {} + 2>/dev/null
    find "$DSYMS_PATH" -name "*libsw*" -type d -exec rm -rf {} + 2>/dev/null
    
    echo "FFmpeg dSYMs removed from archive"
    echo "Archive is ready for App Store upload"
else
    echo "dSYMs directory not found in archive"
fi