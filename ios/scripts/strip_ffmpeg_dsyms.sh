#!/bin/bash

# Script to remove FFmpeg dSYMs that cause App Store upload issues
# Add this as a build phase in Xcode: "Run Script"

DSYM_DIR="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF"

if [ -d "$DSYM_DIR" ]; then
    echo "Removing FFmpeg dSYMs to prevent upload issues..."
    
    # Remove FFmpeg framework dSYMs
    rm -f "$DSYM_DIR/ffmpegkit"
    rm -f "$DSYM_DIR/libavcodec"
    rm -f "$DSYM_DIR/libavdevice"
    rm -f "$DSYM_DIR/libavfilter"
    rm -f "$DSYM_DIR/libavformat"
    rm -f "$DSYM_DIR/libavutil"
    rm -f "$DSYM_DIR/libswresample"
    rm -f "$DSYM_DIR/libswscale"
    
    echo "FFmpeg dSYMs removed successfully"
else
    echo "dSYM directory not found: $DSYM_DIR"
fi