FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libcanberra-gtk3-module \
    libtbb-dev \
    libdc1394-dev \
    gstreamer1.0-* \
    libgstreamer* \
    python3-dev \
    python3-pip \
    python3-numpy \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt

# Download OpenCV 4.9 source code
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/4.9.0.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/refs/tags/4.9.0.zip && \
    unzip opencv.zip && \
    unzip opencv_contrib.zip

# Create build directory for OpenCV
RUN mkdir -p /opt/opencv-4.9.0/build

# Build OpenCV with GStreamer backend
WORKDIR /opt/opencv-4.9.0/build
RUN cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-4.9.0/modules \
          -D WITH_GSTREAMER=ON \
          -D WITH_FFMPEG=ON \
          -D BUILD_EXAMPLES=OFF \
          -D WITH_V4L=ON \
          -D PYTHON3_EXECUTABLE=$(which python3) \
          -D BUILD_opencv_python3=ON \
          -D PYTHON3_INCLUDE_DIR=$(python3 -c "from sysconfig import get_paths as gp; print(gp()['include'])") \
          -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
	  -D CMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
          .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Verify OpenCV installation for Python
RUN python3 -c "import cv2; print(cv2.__version__)"

#RUN cmake -D CMAKE_BUILD_TYPE=Release \
#          -D CMAKE_INSTALL_PREFIX=/usr/local \
#          -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-4.9.0/modules \
#          -D WITH_GSTREAMER=ON \
#          -D WITH_FFMPEG=ON \
#          -D BUILD_EXAMPLES=OFF \
#          -D WITH_V4L=ON \
#          -D PYTHON3_EXECUTABLE=$(which python3) \
#          .. && \
#    make -j$(nproc) && \
#    make install && \
#    ldconfig

# Clean up unnecessary files after installation
WORKDIR /
RUN rm -rf /opt/opencv.zip /opt/opencv_contrib.zip /opt/opencv-4.9.0 /opt/opencv_contrib-4.9.0

WORKDIR /tmp
ADD linuxSDK_V2.1.0.36 linuxSDK_V2.1.0.36
WORKDIR linuxSDK_V2.1.0.36
RUN ./install.sh
RUN sed -i 's/=2/=0/g' /etc/sysctl.d/10-network-security.conf
# WORKDIR /tmp/linuxSDK_V2.1.0.36/demo/python_demo
WORKDIR /workspace
# Set up entrypoint to Python shell
ENTRYPOINT ["/usr/bin/python3"]

