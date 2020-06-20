#!/usr/bin/env bash

if [[ -d ${HOME}/.config/vsp ]]; then
    echo "Configuration directory already exists at ${HOME}/.config/vsp"
    echo "Remove directory ${HOME}/.config/vsp to reinstall vsp"
    echo "Installation aborted"
    exit 1
fi

mkdir ${HOME}/.config/vsp
curl -Ls "https://raw.githubusercontent.com/josebamartos/vsp/master/config.json" -o ${HOME}/.config/vsp/config.json
sudo curl -Ls "https://raw.githubusercontent.com/josebamartos/vsp/master/vsp.sh" -o /usr/local/bin/vsp
chmod +x /usr/local/bin/vsp
echo "Installation done"
