#!/bin/bash
#
# https://github.com/david-janssen/kmonad
#

kmVersion="0.4.1"
kmDownloadUrl="https://github.com/david-janssen/kmonad/releases/download/$kmVersion/kmonad-$kmVersion-linux"

kmExe="$HOME/.cache/kmonad"
kmHome="$(dirname $(readlink $0))"

if [ ! -f $kmExe ]; then
    mkdir -p $(dirname $kmExe)
    echo "Downloading $kmDownloadUrl ..."
    curl -Lo $kmExe $kmDownloadUrl
    chmod +x $kmExe
fi

exec sudo $kmExe $kmHome/layout.kbd -l error 
