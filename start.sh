#!/bin/bash

docker-compose up -d

SERVICE_NAME="open-webui"
OLLAMA_BINARY="/Applications/Ollama.app/Contents/MacOS/Ollama"

# Graceful cleanup on script termination
cleanup_and_exit() {
  echo "[INFO] Caught interrupt. Shutting down container and Ollama..."
  docker-compose stop "$SERVICE_NAME" > /dev/null 2>&1
  stop_ollama
  exit 0
}

# Handle SIGINT and SIGTERM
trap cleanup_and_exit SIGINT SIGTERM

# Start Ollama if it's not running
start_ollama_if_needed() {
  if ! pgrep -f "$OLLAMA_BINARY" > /dev/null; then
    echo "[INFO] Starting Ollama.app..."
    open -a $OLLAMA_BINARY -jg
    sleep 3
    echo "[INFO] Ollama started."
  else
    echo "[INFO] Ollama already running."
  fi
}

# Kill Ollama and exit if it remains stopped
stop_ollama() {
  echo "[INFO] Verifying container remains stopped for 5 seconds before shutting down Ollama..."

  for i in {1..5}; do
    sleep 1
    CONTAINER_ID=$(docker-compose ps -q "$SERVICE_NAME")
    if [ -n "$CONTAINER_ID" ]; then
      IS_RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null)
      if [[ "$IS_RUNNING" == "true" ]]; then
        echo "[INFO] Container restarted during grace period. Aborting Ollama shutdown."
        return
      fi
    fi
  done

  if pgrep -f "$OLLAMA_BINARY" > /dev/null; then
    echo "[INFO] Stopping Ollama.app..."
    pkill -f "$OLLAMA_BINARY"
    sleep 3
  fi

  if ! pgrep -f "$OLLAMA_BINARY" > /dev/null; then
    echo "[INFO] Ollama stopped. Exiting script."
    exit 0
  else
    echo "[WARN] Ollama could not be stopped. Script will continue running."
  fi
}

echo "[INFO] Watching container '$SERVICE_NAME'..."

LAST_CONTAINER_ID=""
LAST_STATE="unknown"

while true; do
  CONTAINER_ID=$(docker-compose ps -q "$SERVICE_NAME")

  if [ -z "$CONTAINER_ID" ]; then
    if [ "$LAST_STATE" != "missing" ]; then
      echo "[INFO] Container '$SERVICE_NAME' is missing. Waiting..."
      stop_ollama
      LAST_STATE="missing"
    fi
    sleep 2
    continue
  fi

  if [ "$CONTAINER_ID" != "$LAST_CONTAINER_ID" ]; then
    echo "[INFO] Container recreated. New ID: $CONTAINER_ID"
    LAST_CONTAINER_ID="$CONTAINER_ID"
    LAST_STATE="unknown"
  fi

  IS_RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null)

  if [[ "$IS_RUNNING" == "true" && "$LAST_STATE" != "running" ]]; then
    echo "[INFO] Container is running (started or restarted)."
    start_ollama_if_needed
    LAST_STATE="running"
  elif [[ "$IS_RUNNING" != "true" && "$LAST_STATE" == "running" ]]; then
    echo "[INFO] Container stopped."
    stop_ollama
    LAST_STATE="stopped"
  fi

  sleep 2
done