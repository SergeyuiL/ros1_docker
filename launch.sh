#!/bin/bash

CONTAINER_NAME="noetic"
IMAGE_NAME="noetic_dev:v1" 

EXISTING_CONTAINER=$(docker ps -q -f name=$CONTAINER_NAME)
EXISTING_CONTAINER_ALL=$(docker ps -aq -f name=$CONTAINER_NAME)

if [ -z "$DISPLAY" ]; then
	echo "DISPLAY env variable not set. Ensure X11 is configured."
	exit 1
fi

xhost +local:root

if [ ! -z "$EXISTING_CONTAINER" ]; then
	echo "Execing running container..."
	docker exec -it $CONTAINER_NAME bash
elif [ ! -z "$EXISTING_CONTAINER_ALL" ]; then
	echo "Starting existed container..."
	docker start $CONTAINER_NAME
	docker exec -it $CONTAINER_NAME bash
else
	echo "Creating new container..."
	docker run -it --name $CONTAINER_NAME \
        	--gpus=all \
        	--net=host \
        	--ipc=host \
        	--privileged \
        	--runtime=nvidia \
        	-e NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display \
        	-v /tmp/.X11-unix:/tmp/.X11-unix \
        	-v /dev:/dev \
        	-e DISPLAY=$DISPLAY \
		-e QT_X11_NO_MITSHM=1 \
        	$IMAGE_NAME bash
fi

xhost -local:root
