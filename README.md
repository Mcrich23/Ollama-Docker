# Ollama-Docker
A project to better run Ollama on Mac with all the optimizations.

## Installation
All you need to run this is ensure [Docker](https://docs.docker.com/desktop/setup/install/mac-install/), [tmux](https://tmuxcheatsheet.com/how-to-install-tmux/), and the [Ollama App](https://ollama.com/download) are already installed

## Running the Project
You can absolutely run this project just by cd-ing into this folder and following the instructions below, but I personally recommend adding the following line to your `.zprofile` to make it callable from anywhere: 
```sh
alias ollama-docker='/path/to/ollama-docker/ollama-docker.sh'
```

After adding it, make sure to run `source ~/.zprofile` to make it available to your current terminal session.

### Starting the Service
To run ollama-docker, just run `sh ./ollama-docker.sh up`.

### Stopping the Service
To stop ollama-docker, just run `sh ./ollama-docker.sh down`.

### Checking to See if the Service is Running
To see the status of ollama-docker, just run `sh ./ollama-docker.sh status`.

## How it Works

Ollama-Docker works by connecting the Ollama desktop service to a Open-WebUI docker container. The reason why we don't do it all in Docker is because docker unfortunately does not support metal acceleration. This causes Ollama to be very slow in docker.

The `start.sh` script starts these services and keeps them synced to automatically stop Ollama if the docker container stops, saving system resources.