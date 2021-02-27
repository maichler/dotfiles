#!/bin/sh
#
# Install script for kmonad
#

cd $(dirname $0)

rm -f ~/.config/kmonad
ln -sf . ~/.config/kmonad
ln -sf kmonad.sh ~/bin/kmonad.sh
