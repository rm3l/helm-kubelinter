#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/stackrox/kube-linter"

KUBELINTER_VERSION="0.7.4"
KUBELINTER_BIN="${HELM_PLUGIN_DIR}/bin/kube-linter"

OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH_SUFFIX=$(uname -m)
case "$ARCH_SUFFIX" in
  x86_64) ARCH_SUFFIX="" ;;
  aarch64 | arm64) ARCH_SUFFIX="_arm64" ;;
  *) echo "Unsupported architecture: $ARCH_SUFFIX" >&2; exit 1 ;;
esac

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- | grep -v stable | grep -v v0.0.1 |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# By default we simply list the tag names from GitHub releases.
	# Change this function if kubeshark has other means of determining installable versions.
	list_github_tags
}

install_kubelinter() {
  if [[ "${HELM_KUBELINTER_UPDATE:-}" == "true" ]] || [[ ! -f "$KUBELINTER_BIN" ]]; then
    kubelinter_version="${1:-$KUBELINTER_VERSION}"
    echo "🔧 Installing KubeLinter $kubelinter_version..."
    mkdir -p "$(dirname "$KUBELINTER_BIN")"
    curl -fsSL -o "${KUBELINTER_BIN}.tar.gz" \
        "https://github.com/stackrox/kube-linter/releases/download/v${kubelinter_version}/kube-linter-${OS}${ARCH_SUFFIX}.tar.gz"
    tar -xzf "${KUBELINTER_BIN}.tar.gz" -C "$(dirname "$KUBELINTER_BIN")" kube-linter
    chmod +x "$KUBELINTER_BIN"
    rm -f "${KUBELINTER_BIN}.tar.gz"
  fi
}

update_kubelinter() {
  install_latest="false"
  if [[ -x "$KUBELINTER_BIN" ]]; then
    # Check if the installed version is older than the latest available version
    installed_version=$("$KUBELINTER_BIN" version)
  else
    install_latest="true"
  fi
  # curl of REPO/releases/latest is expected to be a 302 to another URL
  # when no releases redirect_url="REPO/releases"
  # when there are releases redirect_url="REPO/releases/tag/v<VERSION>"
  redirect_url=$(curl -sI -A "rm3l/helm-kubelinter" "$GH_REPO/releases/latest" | sed -n -e "s|^location: *||p" | sed -n -e "s|\r||p")
  local latest_version
  if [[ "$redirect_url" == "$GH_REPO/releases" ]]; then
    latest_version="$(list_all_versions | sort_versions | tail -n1 | xargs echo)"
  else
    latest_version="$(printf "%s\n" "$redirect_url" | sed 's|.*/tag/v\{0,1\}||')"
  fi
  if [[ -z "$latest_version" ]]; then
    echo "Error: Unable to determine the latest version of KubeLinter." >&2
    exit 1
  fi

  if [[ -n "$installed_version" ]]; then
    if [[ "$installed_version" != "$latest_version" ]]; then
      echo "Current version: $installed_version, Latest version: $latest_version"
      install_latest="true"
    # else
    #   echo "KubeLinter is already up-to-date (version: $installed_version)"
    fi
  fi

  if [[ "$install_latest" = "true" ]]; then
    echo "🔄 Updating KubeLinter..."
    install_kubelinter "$latest_version"
  fi
}
