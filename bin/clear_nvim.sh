#!/bin/bash

SHARE_DIR="$HOME/.local/share/nvim"
CACHE_DIR="$HOME/.cache/nvim"

echo "Delete Neovim Cache"

# ~/.local/share/nvim
if [ -d "$SHARE_DIR" ]; then
  echo "DELETE $SHARE_DIR" 
  rm -rf "$SHARE_DIR"
else
  echo "NOT FOUND $SHARE_DIR"
fi
#
# ~/.cache/nvim の削除
if [ -d "$CACHE_DIR" ];then
  echo "DELETE $CACHE_DIR"
  rm -rf "$CACHE_DIR"
else
  echo "NOT FOUND $CACHE_DIR"
fi

echo "COMPLATE"
