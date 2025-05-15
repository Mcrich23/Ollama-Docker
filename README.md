# Ollama-Docker
A project to better run Ollama on Mac with all the optimizations.

## Installation
All you need to run this is ensure [Docker](https://docs.docker.com/desktop/setup/install/mac-install/), [tmux](https://tmuxcheatsheet.com/how-to-install-tmux/), and the [Ollama App](https://ollama.com/download) are already installed

## Running the Project

### Starting the Service
To run the project, just call `sh ./ollama-docker.sh up`.

### Stopping the Service
To stop the project, just call `sh ./ollama-docker.sh down`.


## How it Works

Ollama-Docker works by connecting the Ollama desktop service to a Open-WebUI docker container. The reason why we don't do it all in Docker is because docker unfortunately does not support metal acceleration. This causes Ollama to be very slow in docker.

The `start.sh` script starts these services and keeps them synced to automatically stop Ollama if the docker container stops, saving system resources.