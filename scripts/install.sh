#!/bin/sh

set -ex

if [ -n "${HELM_PUSH_PLUGIN_NO_INSTALL_HOOK}" ]; then
    echo "Development mode: not downloading versioned release."
    exit 0
fi

cd "$HELM_PLUGIN_DIR" || exit 1
version="$(grep "version" plugin.yaml | cut -d '"' -f 2)"
echo "Installing helm-kubelinter ${version} ..."

# Find correct archive name
unameOut="$(uname -s)"

case "${unameOut}" in
    Linux*)             os=Linux;;
    Darwin*)            os=Darwin;;
    CYGWIN*)            os=Cygwin;;
    MINGW*|MSYS_NT*)    os=windows;;
    *)                  os="UNKNOWN:${unameOut}"
esac

arch=$(uname -m)

if echo "$os" | grep -qe '.*UNKNOWN.*'
then
    echo "Unsupported OS / architecture: ${os}_${arch}"
    exit 1
fi

url="https://github.com/rm3l/helm-kubelinter/releases/download/${version}/helm-kubelinter_${version}_${os}_${arch}.tar.gz"
filename=$(echo "${url}" | sed -e "s/^.*\///g")

# Download archive
if [ -n "$(command -v curl)" ]
then
    curl -sSL -O "$url"
elif [ -n "$(command -v wget)" ]
then
    wget -q "$url"
else
    echo "Need curl or wget"
    exit 1
fi

# Install bin
mkdir -p bin
tar xvf "$filename" -C bin > /dev/null && rm -f "$filename"

echo "helm-kubelinter ${version} has been installed correctly."
echo
echo "Lint a Helm Chart:"
echo "  helm kubelinter lint <my_chart> [--format {sarif,plain,json}] [--values /path/to/my/values.yaml]"
echo
