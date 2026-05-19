#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/model.sh"

create_directory() {
  add_user "u-001" "Ada" "admin,developer"
  add_user "u-002" "Grace" "developer"
  add_user "u-003" "Linus" "reviewer"
}

format_user_label() {
  local id="$1"
  local name
  local roles

  name="$(find_user_name "$id")"
  roles="$(find_user_roles "$id")"
  printf '%s (%s)\n' "$name" "${roles//,/, }"
}

require_user() {
  local id="$1"
  if [[ -z "$(find_user_name "$id")" ]]; then
    printf 'User not found: %s\n' "$id" >&2
    return 1
  fi
}
