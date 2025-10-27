#!/bin/bash

# Installation script for camera streamer service
set -e

echo "Installing Camera Streamer Service..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Create user and group for the service
if ! id "camera-streamer" &>/dev/null; then
    echo "Creating camera-streamer user..."
    useradd -r -s /bin/false camera-streamer
fi

# Create installation directory
INSTALL_DIR="/opt/camera-streamer"
echo "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR/scripts"

# Copy files
echo "Copying files..."
cp scripts/stream_camera.sh "$INSTALL_DIR/scripts/"
chmod +x "$INSTALL_DIR/scripts/stream_camera.sh"

# Set ownership
chown -R camera-streamer:camera-streamer "$INSTALL_DIR"

# Install service file
echo "Installing systemd service..."
cp camera-streamer.service /etc/systemd/system/

# Reload systemd and enable service
echo "Enabling service..."
systemctl daemon-reload
systemctl enable camera-streamer.service

echo "Installation complete!"
echo ""
echo "To start the service: sudo systemctl start camera-streamer"
echo "To check status: sudo systemctl status camera-streamer"
echo "To view logs: sudo journalctl -u camera-streamer -f"
echo ""
echo "The camera stream will be available at: rtsp://localhost:8554/camera"
echo "You can access it with cv2.VideoCapture('rtsp://localhost:8554/camera')"
