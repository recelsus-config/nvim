#!/usr/bin/env bash

declare -A user_names=()
declare -A user_roles=()

add_user() {
  local id="$1"
  local name="$2"
  local roles="$3"

  user_names["$id"]="$name"
  user_roles["$id"]="$roles"
}

find_user_name() {
  local id="$1"
  printf '%s\n' "${user_names[$id]}"
}

find_user_roles() {
  local id="$1"
  printf '%s\n' "${user_roles[$id]}"
}

list_admin_ids() {
  local id
  for id in "${!user_roles[@]}"; do
    if [[ ",${user_roles[$id]}," == *",admin,"* ]]; then
      printf '%s\n' "$id"
    fi
  done
}
