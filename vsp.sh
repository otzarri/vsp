#! /usr/bin/env bash
#
# vsp is a program to manage profiles for Visual Studio Code/Codium in GNU/Linux

dir="${HOME}/.config/vsp"
conf="${dir}/config.json"

if [[ ! -f ${conf} ]]; then echo "Missing config file ${conf}"; exit 1; fi

action="${1}"
profile="${2}"
bin=$(cat ${conf} | jq -r .bin)

function get_settings {
cat <<EOF
{
  "telemetry.enableCrashReporter": false,
  "telemetry.enableTelemetry": false,
  "workbench.colorTheme": "GitHub Dark",
  "git.autofetch": true,
}
EOF
}

del() {
    if [[ -z ${profile} ]]; then echo "Profile missing"; fi
    if [[ ! -d ${dir}/${profile} ]]; then                                                                                                                         
        echo "Profile \"${profile}\" missing"                                                                                                                     
        echo ""                                                                                                                                                   
        list                                                                                                                                                      
        exit 1
    else
	read -p "Remove profile \"${profile}\"? (y/N): " res
        if [[ ! "${res}" =~ ^[yY]$ ]]; then exit 1; fi
        rm -rf ${dir}/${profile}
        echo "Profile \"${profile}\" removed"
    fi
}

ext() {
    if [[ ! -d ${dir}/${profile} ]]; then
        echo "Profile \"${profile}\" missing"                                                                                                                     
        echo ""                                                                                                                                                   
        list
        exit 1
    else
        cur_extensions=$(ls -1 ${dir}/${profile}/extensions | wc -l)
        if [[ "${cur_extensions}" -lt 1 ]]; then
            echo "No extensions"
        else
            extensions=($(                                        \
	        code                                              \
                    --user-data-dir ${dir}/${profile}/data        \
                    --extensions-dir=${dir}/${profile}/extensions \
                    --list-extensions
	    ))
            echo "${cur_extensions} extension(s) in profile \"${profile}\":"
	    for item in "${extensions[@]}"; do echo "  * ${item}"; done
        fi
    fi
}

list() {
    cur_profiles=$(ls -1 ${dir} | grep -v config.json | wc -l)
    if [[ "${cur_profiles}" -lt 1 ]]; then
        echo "No profiles"
    else
        echo "${cur_profiles} profile(s):"
        profiles=($(ls ${dir} | grep -v config.json))
	for item in "${profiles[@]}"; do echo "  * ${item}"; done
    fi
}

new() {
    if [[ -d ${dir}/${profile} ]]; then
        echo "Profile \"${profile}\" already exists"
	exit 1
    else
        read -p "Do you want to create profile \"${profile}\"? (y/N): " res
        if [[ ! "${res}" =~ ^[yY]$ ]]; then exit 1; fi
	mkdir -p ${dir}/${profile}/data/User
	mkdir -p ${dir}/${profile}/extensions
	echo "$(get_settings)" > ${dir}/${profile}/data/User/settings.json
        echo "Profile \"${profile}\" created"

	extensions=($(cat ${dir}/config.json | jq -r '.extensions.'${profile}' | join(" ")' 2> /dev/null))
	if [[ -n $extensions ]]; then
            for item in ${extensions[@]}; do
                ${bin}                                            \
                    --user-data-dir ${dir}/${profile}/data        \
                    --extensions-dir=${dir}/${profile}/extensions \
                    --install-extension ${item}
	    done	
	fi

	read -p "Run \"${bin}\" with profile \"${profile}\"? (y/N): " res
        if [[ ! "${res}" =~ ^[yY]$ ]]; then exit 0; fi
    fi
    run
}

run() {
    if [[ ! -d ${dir}/${profile} ]]; then
        echo "Profile \"${profile}\" missing"
	echo ""
	list
	exit 1
    else
        echo "Running \"${bin}\" with profile \"${profile}\""
        ${bin}                                            \
            --user-data-dir ${dir}/${profile}/data        \
            --extensions-dir=${dir}/${profile}/extensions
    fi
}

settings() {
    if [[ ! -d ${dir}/${profile} ]]; then
        echo "Profile \"${profile}\" missing"
        echo ""
        list
        exit 1
    else
        cat ${dir}/${profile}/data/User/settings.json
    fi
}

usage() {
    echo "Profile dir: ${dir}"
    echo "Usage:"
    echo "  * Create a profile: ${0} new <profile-name>"
    echo "  * List profiles: ${0} ls"
    echo "  * List extensions: ${0} ext <profile-name>"
    echo "  * Print settings.json: ${0} settings <profile-name>"
    echo "  * Run with a profile: ${0} run <profile-name>"
    echo "  * Remove a profile: ${0} rm <profile-name>"
}

case $action in
    ext) ext           ;;
    ls) list           ;;
    new) new           ;;
    rm) del            ;;
    run) run           ;;
    settings) settings ;;
    *)   usage
esac 
