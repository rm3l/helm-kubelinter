#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/lib.sh"

if [[ "${HELM_KUBELINTER_UPDATE:-}" == "true" ]]; then
  update_kubelinter
else
  install_kubelinter
fi
