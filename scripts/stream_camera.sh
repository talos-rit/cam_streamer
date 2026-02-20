#!/bin/bash

# FFmpeg camera streaming script
# Streams camera feed to RTSP server that can be accessed by cv2.VideoCapture

CAMERA_DEVICE=${CAMERA_DEVICE:-/dev/video0}
RTSP_PORT=${RTSP_PORT:-8554}
STREAM_NAME=${STREAM_NAME:-camera}

# Check if camera device exists
if [ ! -e "$CAMERA_DEVICE" ]; then
    echo "Error: Camera device $CAMERA_DEVICE not found"
    exit 1
fi

# Start FFmpeg RTSP server
ffmpeg -f v4l2 -i "$CAMERA_DEVICE" \
    -vcodec h264_v4l2m2m -preset ultrafast -tune zerolatency \
    -f rtsp rtsp://localhost:$RTSP_PORT/$STREAM_NAME
