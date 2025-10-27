# Camera Streamer

FFmpeg-based camera streaming service that provides RTSP video feed accessible via OpenCV.

## Installation

```bash
sudo ./install.sh
sudo systemctl start camera-streamer
```

## How It Works

The service uses FFmpeg to capture video from `/dev/video0` and streams it as an RTSP server on port 8554. The stream is encoded with H.264 for low latency and efficiency.

## Accessing the Feed

**RTSP URL**: `rtsp://localhost:8554/camera`

**With OpenCV**:
```python
import cv2
cap = cv2.VideoCapture('rtsp://localhost:8554/camera')
ret, frame = cap.read()
```

**Service Management**:
- Status: `sudo systemctl status camera-streamer`
- Logs: `sudo journalctl -u camera-streamer -f`
- Stop: `sudo systemctl stop camera-streamer`
