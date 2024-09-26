FROM nvidia/cuda:12.2.2-devel-ubuntu20.04

ENV ROSDISTRO_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/rosdistro/index-v4.yaml
ENV TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6;8.7;8.9;9.0+PTX"

RUN rm /etc/apt/apt.conf.d/docker-clean \
 && echo 'deb https://mirror.iscas.ac.cn/ubuntu/ focal main restricted universe multiverse' > /etc/apt/sources.list \
 && echo 'deb https://mirror.iscas.ac.cn/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb https://mirror.iscas.ac.cn/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb https://mirror.iscas.ac.cn/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list \
 && echo 'deb https://mirror.iscas.ac.cn/ros/ubuntu/ focal main' > /etc/apt/sources.list.d/ros-latest.list \
 && echo 'Acquire::http::Proxy "false";' > /etc/apt/apt.conf.d/no-proxy \
 && echo 'Acquire::https::Proxy "false";' >> /etc/apt/apt.conf.d/no-proxy \
 && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
        apt-transport-https \
        bash-completion \
        ccache \
        clangd-12 \
        command-not-found \
        curl \
        gdb \
        git \
        jq \
        libceres-dev \
        libgmock-dev \
        liblua5.2-dev \
        ninja-build \
        python-is-python3 \
        python3-catkin-tools \
        python3-dev \
        python3-pcl \
        python3-pip \
        python3-progressbar \
        python3-rosdep \
        python3-scipy \
        ros-noetic-desktop-full \
        ros-noetic-geodesy \
        ros-noetic-lms1xx \
        ros-noetic-moveit \
        ros-noetic-navigation \
        ros-noetic-nmea-msgs \
        ros-noetic-pointcloud-to-laserscan \
        ros-noetic-serial \
        ros-noetic-trac-ik \
        tzdata \
        vim \
        wget \
 && cp /etc/skel/.bashrc /root/.bashrc \
 && sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc \
 && echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc

RUN rosdep init \
 && rosdep update

RUN mkdir -p ~/miniconda3 \
 && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh \
 && bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 \
 && rm ~/miniconda3/miniconda.sh \
 && ~/miniconda3/bin/conda init bash \
 && ~/miniconda3/bin/conda config --set auto_activate_base false

RUN pip install -U pip \
 && pip install torch torchvision torchaudio

RUN mkdir -p /root/workspace/interbotix_ws \
 && curl 'https://raw.githubusercontent.com/Interbotix/interbotix_ros_rovers/main/interbotix_ros_xslocobots/install/xslocobot_remote_install.sh' > xslocobot_remote_install.sh \
 && chmod +x xslocobot_remote_install.sh \
 && ./xslocobot_remote_install.sh -d noetic -p /root/workspace/interbotix_ws -b kobuki -r locobot -i 192.168.1.36 -n \
 && rm xslocobot_remote_install.sh \
 && sed -i 's|export ROS_MASTER_URI=http://locobot.local:11311|#&|' ~/.bashrc \
 && sed -i 's|source /root/workspace/interbotix_ws/devel/setup.bash|#&|' ~/.bashrc 

RUN mkdir -p /etc/apt/keyrings \
 && curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo tee /etc/apt/keyrings/librealsense.pgp > /dev/null \
 && echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | tee /etc/apt/sources.list.d/librealsense.list \
 && apt-get update \
 && apt-get install -y librealsense2-dkms librealsense2-utils librealsense2-dev \
 && mkdir -p /root/workspace/dev_ws/src \
 && cd /root/workspace/dev_ws \
 && catkin init \
 && cd src \
 && git clone https://github.com/IntelRealSense/realsense-ros.git -b ros1-legacy \
 && cd .. \
 && catkin config --extend /opt/ros/noetic \
 && catkin build