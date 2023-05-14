# Remove the Docker image named "data-integrator"
docker rmi data-integrator 

# Remove unused builder resources
docker builder prune

# Build a new Docker image named "data-integrator" using the current directory as the build context
docker build -t data-integrator .

# Start a new container from the "data-integrator" image and access the container's shell
docker run --rm -it data-integrator bash

# Start a new container from the "data-integrator" image, mount local directories and a file, and run the data-integrator application
docker run --rm -v ${PWD}/data:/app/data -v ${PWD}/config:/app/config:ro -v ${PWD}/log:/app/log data-integrator

# Set the $PWD environment variable to the current directory path
# $env:PWD = (Get-Location).Path  #PowerShell
export PWD=$(pwd) #bash
echo $PWD

# Start the Docker Compose services, building necessary images, removing any orphaned containers, and running the containers
docker-compose up --build --remove-orphans

# To stop the container and then remove it
docker stop "containerID" && docker rm "containerID"

# To remove dangling images in Docker
docker image prune

#To list running containers:
docker ps

#To list all containers (including stopped containers):
docker ps -a

#To list services in a Docker Compose stack:
docker-compose ps
