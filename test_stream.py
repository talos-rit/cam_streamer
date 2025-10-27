#!/usr/bin/env python3

"""
Test script to verify cv2.VideoCapture can read from the FFmpeg RTSP stream
"""

import sys

import cv2


def test_rtsp_stream():
    """Test reading from the RTSP stream"""
    rtsp_url = "rtsp://localhost:8554/camera"
    
    print(f"Attempting to connect to: {rtsp_url}")
    
    # Create VideoCapture object
    cap = cv2.VideoCapture(rtsp_url)
    
    if not cap.isOpened():
        print("Error: Could not open RTSP stream")
        print("Make sure the camera-streamer service is running:")
        print("  sudo systemctl start camera-streamer")
        print("  sudo systemctl status camera-streamer")
        return False
    
    print("Successfully connected to RTSP stream!")
    print("Reading frames for 5 seconds...")
    
    frame_count = 0
    start_time = cv2.getTickCount()
    
    while True:
        ret, frame = cap.read()
        
        if not ret:
            print("Error: Could not read frame")
            break
            
        frame_count += 1
        
        # Show frame info every 30 frames
        if frame_count % 30 == 0:
            elapsed = (cv2.getTickCount() - start_time) / cv2.getTickFrequency()
            fps = frame_count / elapsed
            print(f"Frames: {frame_count}, FPS: {fps:.2f}")
        
        # Run for 5 seconds
        if frame_count > 150:  # Assuming ~30 FPS
            break
    
    cap.release()
    
    elapsed = (cv2.getTickCount() - start_time) / cv2.getTickFrequency()
    avg_fps = frame_count / elapsed
    
    print("\nTest completed!")
    print(f"Total frames: {frame_count}")
    print(f"Average FPS: {avg_fps:.2f}")
    print(f"Duration: {elapsed:.2f} seconds")
    
    return True

if __name__ == "__main__":
    success = test_rtsp_stream()
    sys.exit(0 if success else 1)
