#!/usr/bin/python3
import cv2
import numpy as np

# Replace with the RTMP URL of your server
rtmp_url = "rtmp://172.31.1.7:1935/htv"

# Define the GStreamer pipeline with appsrc, encoding, and streaming to RTMP
gst_pipeline = (
    "appsrc ! videoconvert ! x264enc speed-preset=ultrafast tune=zerolatency ! "
    "flvmux streamable=true ! rtmpsink location=" + rtmp_url
)

# Initialize VideoWriter with GStreamer pipeline
fps = 30
frame_width = 640
frame_height = 480
out = cv2.VideoWriter(gst_pipeline, cv2.CAP_GSTREAMER, 0, fps, (frame_width, frame_height), True)

# Check if VideoWriter is successfully opened
if not out.isOpened():
    print("Failed to open VideoWriter with GStreamer pipeline")
    exit(1)

# Generate a white frame
white_frame = np.ones((frame_height, frame_width, 3), dtype=np.uint8) * 255  # White frame

while True:
    print('.', end='')
    # Write white frame to the RTMP stream using VideoWriter
    out.write(white_frame)

    # Optionally, show the frame in a window for local preview
    #cv2.imshow("Stream Preview", white_frame)

    # Break the loop on 'q' key press
    #if cv2.waitKey(1) & 0xFF == ord('q'):
    #    break

# Release resources
out.release()

