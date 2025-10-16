#!/usr/bin/env python

from flask import Flask, Response
import cv2

app = Flask(__name__)

cap = cv2.VideoCapture(0)

def generate():
    global cap
    while True:
        success, frame = cap.read()
        if not success:
            break
        # Encode frame to JPEG
        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()
        # HTTP MJPEG streaming protocol
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

# Run server on all interfaces at port 5000
app.run(host='0.0.0.0', port=5000, threaded=True)
