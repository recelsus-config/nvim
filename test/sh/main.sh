#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/service.sh"

main() {
  create_directory
  require_user "u-001"

  format_user_label "u-001"
  while IFS= read -r admin_id; do
    printf 'admin: '
    format_user_label "$admin_id"
  done < <(list_admin_ids)
}

main "$@"
