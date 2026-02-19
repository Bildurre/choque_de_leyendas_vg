#!/bin/bash
PROJECT_DIR="$(dirname "$(realpath "$0")")"

if [ "$1" = "--editor" ]; then
  flatpak run org.godotengine.Godot --editor --path "$PROJECT_DIR"
else
  flatpak run org.godotengine.Godot --path "$PROJECT_DIR"
fi
