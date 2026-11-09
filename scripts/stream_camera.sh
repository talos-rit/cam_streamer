#!/bin/bash

# FFmpeg camera streaming script
# Streams camera feed to RTSP server that can be accessed by cv2.VideoCapture

CAMERA_DEVICE=${CAMERA_DEVICE:-/dev/video0}
RTSP_PORT=${RTSP_PORT:-8554}
STREAM_NAME=${STREAM_NAME:-camera}
VIDEO_SIZE=${VIDEO_SIZE:-640x480}
VIDEO_FPS=${VIDEO_FPS:-30}
INPUT_FORMAT=${INPUT_FORMAT:-yuyv422}
VIDEO_ENCODER=${VIDEO_ENCODER:-h264_v4l2m2m}
VIDEO_BITRATE=${VIDEO_BITRATE:-3M}
# Optional: publish at a lower frame rate than the camera captures. Useful because many webcams
# only deliver 720p at 30 fps as MJPEG, while we want a 10 fps stream: capture MJPEG at 30, drop
# frames to 10 before encoding. Unset = publish at VIDEO_FPS.
OUTPUT_FPS=${OUTPUT_FPS:-}
# Keyframe every N encoded frames; defaults to one per second of output.
KEYFRAME_INTERVAL=${KEYFRAME_INTERVAL:-${OUTPUT_FPS:-$VIDEO_FPS}}

# Check if camera device exists
if [ ! -e "$CAMERA_DEVICE" ]; then
    echo "Error: Camera device $CAMERA_DEVICE not found"
    exit 1
fi

# Start FFmpeg RTSP server
encoder_options=()
if [ "$VIDEO_ENCODER" = "libx264" ]; then
    encoder_options=(-preset ultrafast -tune zerolatency)
fi

filter_options=()
if [ -n "$OUTPUT_FPS" ]; then
    filter_options=(-vf "fps=$OUTPUT_FPS")
fi

exec ffmpeg -hide_banner -nostats -f v4l2 \
    -threads 1 -filter_threads 1 \
    -input_format "$INPUT_FORMAT" -video_size "$VIDEO_SIZE" -framerate "$VIDEO_FPS" \
    -i "$CAMERA_DEVICE" "${filter_options[@]}" -pix_fmt yuv420p -c:v "$VIDEO_ENCODER" \
    "${encoder_options[@]}" -b:v "$VIDEO_BITRATE" -g "$KEYFRAME_INTERVAL" -bf 0 \
    -f rtsp -rtsp_transport tcp "rtsp://localhost:$RTSP_PORT/$STREAM_NAME"
