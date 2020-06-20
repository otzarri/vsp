#!/usr/bin/env bash

dt=$(date +'%s')

git@github.com:josebamartos/vsp.git /tmp/vsp-${dt}
mkdir ${HOME}/.config/vsp
mv /tmp/vsp-${dt}/config.json ${HOME}/.config/vsp
mv /tmp/vsp-${dt}/vsp.sh /usr/local/bin/vsp
chmod +x /usr/local/bin/vsp
rm -rf /tmp/vsp-${dt}