#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/lib.sh"

main() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: helm kubelinter [helm template args] -- [kubelinter flags]"
    exit 1
  fi

  # Split args: everything before `--` is for helm, after is for kube-linter
  HELM_ARGS=()
  KUBELINTER_ARGS=()
  PARSING_HELM_ARGS=true

  for arg in "$@"; do
    if $PARSING_HELM_ARGS; then
      if [[ "$arg" == "--" ]]; then
        PARSING_HELM_ARGS=false
      else
        HELM_ARGS+=("$arg")
      fi
    else
      KUBELINTER_ARGS+=("$arg")
    fi
  done

  # Generate Helm template
  TEMPLATE_FILE=$(mktemp /tmp/kubelinter-template-XXXXXX.yaml)

  echo "📦 Rendering chart using: $HELM_BIN template ${HELM_ARGS[*]}"
  if [[ "${HELM_NAMESPACE:-}" != "default" ]]; then
    HELM_ARGS+=("--namespace" "$HELM_NAMESPACE")
  fi
  "$HELM_BIN" template "${HELM_ARGS[@]}" > "$TEMPLATE_FILE"

  echo "🔍 Running KubeLinter with: ${KUBELINTER_ARGS[*]}"
  "$KUBELINTER_BIN" lint "$TEMPLATE_FILE" "${KUBELINTER_ARGS[@]}"

  rm -f "$TEMPLATE_FILE"
}

main "$@"
