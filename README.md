# 1、Install Docker Engine on Ubuntu
ref: https://docs.docker.com/engine/install/ubuntu/

# 2、Install the NVIDIA Container Toolkit
ref: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-apt

and https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#configuring-docker

# 3、Build docker image
```shell
sudo docker build -t noetic_dev:v1 .
```

# 4、Launch container
```shell
./launch.sh
```