#!/bin/bash

set -e

SHARE_DIR="$HOME/.local/share/nvim"
CACHE_DIR="$HOME/.cache/nvim"
STATE_DIR="$HOME/.local/state/nvim"

echo "Delete Neovim Cache & Logs"

# ~/.local/share/nvim
if [ -d "$SHARE_DIR" ]; then
  echo "DELETE $SHARE_DIR"
  rm -rf "$SHARE_DIR"
else
  echo "NOT FOUND $SHARE_DIR"
fi

# ~/.cache/nvim
if [ -d "$CACHE_DIR" ]; then
  echo "DELETE $CACHE_DIR"
  rm -rf "$CACHE_DIR"
else
  echo "NOT FOUND $CACHE_DIR"
fi

# ~/.local/state/nvim
if [ -d "$STATE_DIR" ]; then
  echo "DELETE $STATE_DIR"
  rm -rf "$STATE_DIR"
else
  echo "NOT FOUND $STATE_DIR"
fi

echo "COMPLETE"

