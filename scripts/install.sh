#!/bin/sh

cd $HELM_PLUGIN_DIR
version="$(cat plugin.yaml | grep "version" | cut -d '"' -f 2)"
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

arch=`uname -m`

if echo "$os" | grep -qe '.*UNKNOWN.*'
then
    echo "Unsupported OS / architecture: ${os}_${arch}"
    exit 1
fi

url="https://github.com/rm3l/helm-kubelinter/releases/download/${version}/helm-kubelinter_${version}_${os}_${arch}.tar.gz"

filename=`echo ${url} | sed -e "s/^.*\///g"`

# Download archive
if [ -n "$(command -v curl)" ]
then
    curl -sSL -O $url
elif [ -n "$(command -v wget)" ]
then
    wget -q $url
else
    echo "Need curl or wget"
    exit -1
fi

# Install bin
rm -rf bin && mkdir bin && tar xvf $filename -C bin > /dev/null && rm -f $filename

echo "helm-kubelinter ${version} is correctly installed."
echo

echo "Lint a Helm Chart:"
echo "  helm kubelinter lint /path/to/my/Chart [--format {sarif,plain,json}] [--values /path/to/my/values.yaml]"
echo
