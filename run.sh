#!/bin/bash

# Exit immediately if a command fails
set -e

DIR_NAME=$(dirname "$0")

# Path to your start script
START_SCRIPT="./start.sh"

# Name of your docker-compose service
SERVICE_NAME="open-webui"

# Tmux session name
SESSION_NAME="ollama-docker"

# Handle command argument
case "$1" in
  up)
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      echo "[INFO] Services are already running"
      exit 0
    fi

    echo "[INFO] Starting services..."
    tmux new-session -d -s $SESSION_NAME "cd $DIR_NAME && sh $START_SCRIPT && exit" &
    ;;
  down)
    # Check if the tmux session exists
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      echo "[INFO] No services are running"
      exit 1
    fi

    echo "[INFO] Stopping services..."
    # Stop the docker container
    docker stop "$SERVICE_NAME" > /dev/null 2>&1

    # Kill Ollama
    ollama=$(pgrep -f "/Applications/Ollama.app/Contents/MacOS/Ollama")
    kill $ollama > /dev/null 2>&1

    # Kill tmux session
    tmux kill-session -t "$SESSION_NAME" &
    ;;
  *)
    echo "Usage: $0 {up | down}"
    exit 1
    ;;
esac
