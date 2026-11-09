# Camera Streamer

FFmpeg publishes the webcam to MediaMTX, which serves an RTSP feed that OpenCV can open.

## Installation

`install.sh` only installs the FFmpeg publisher. MediaMTX is the process that listens on port 8554, so install that first. Both downloads need a network connection. On macOS you can share internet to the Pi by connecting an Ethernet cable directly from the computer to the Pi (needed for downloads; not sure about other OSes).

`install-mediamtx.sh` downloads the arm64 build (`uname -m` must be `aarch64`), installs the binary and `mediamtx.yml`, and enables the service.

```bash
sudo apt-get update
sudo apt-get install -y ffmpeg
sudo ./install-mediamtx.sh
sudo ./install.sh
sudo systemctl start camera-streamer
```

`sudo ss -ltnp | grep 8554` should show `mediamtx` before you start `camera-streamer`.

## How It Works

`camera-streamer` runs FFmpeg against `/dev/video0` and publishes H.264 to `rtsp://localhost:8554/camera`. MediaMTX, configured by `mediamtx.yml`, is the RTSP server on port 8554. FFmpeg does not listen on that port itself. Start MediaMTX before `camera-streamer`.

## Accessing the Feed

**RTSP URL**: `rtsp://localhost:8554/camera`

From another machine, use the Pi's hostname or address, for example `rtsp://raspberrypi.local:8554/camera`.

You can view it in the [Commander](https://github.com/talos-rit/commander) GUI, create a source for it in OBS (guide [here](https://github.com/talos-rit/commander#setting-up-the-virtual-camera)) or use a media player like [mpv](https://mpv.io/).

**With OpenCV**:

```python
import cv2
cap = cv2.VideoCapture('rtsp://localhost:8554/camera')
ret, frame = cap.read()
```

**Configuration** (environment variables read by `scripts/stream_camera.sh`):

| Variable | Default | Meaning |
|---|---|---|
| `CAMERA_DEVICE` | `/dev/video0` | V4L2 device to capture from |
| `RTSP_PORT` | `8554` | MediaMTX RTSP port on this host |
| `STREAM_NAME` | `camera` | RTSP path: `rtsp://<host>:8554/<STREAM_NAME>` |
| `INPUT_FORMAT` | `yuyv422` | Capture pixel format (`mjpeg` allows 720p at 30 fps on most webcams) |
| `VIDEO_SIZE` | `640x480` | Capture resolution |
| `VIDEO_FPS` | `30` | Capture frame rate |
| `OUTPUT_FPS` | *(unset)* | Publish at a lower rate than captured, e.g. `10` (drops frames before encoding) |
| `KEYFRAME_INTERVAL` | output fps | Frames between keyframes (`-g`) |
| `VIDEO_ENCODER` | `h264_v4l2m2m` | `h264_v4l2m2m` (Pi hardware) or `libx264` (software) |
| `VIDEO_BITRATE` | `3M` | Target bitrate |

The Talos container stack (Gaia) runs this script with
`INPUT_FORMAT=mjpeg VIDEO_SIZE=1280x720 VIDEO_FPS=30 OUTPUT_FPS=10`.

**Service Management**:

- MediaMTX status: `sudo systemctl status mediamtx`
- Publisher status: `sudo systemctl status camera-streamer`
- Publisher logs: `sudo journalctl -u camera-streamer -f`
- Stop the publisher: `sudo systemctl stop camera-streamer`
