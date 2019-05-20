#!/bin/bash
# Alt logging script made by Kieraaaan.
# If you have any issues, my Discord is: Kieraaaan#6612

config=alt_config.cfg
alts=$1
lsb_dist="$(. /etc/os-release && echo "$ID")"
dist_version="$(. /etc/os-release && echo "$VERSION_ID")"

log() {
    if [[ "$1" == "error" ]]; then
        echo -e '\e[31m'"$2"'\e[0m';
    elif [[ "$1" == "log" ]]; then
        echo -e '\e[32m'"$2"'\e[0m';
    elif [[ "$1" == "info" ]]; then
        echo -e '\e[36m'"$2"'\e[0m';
    fi
}

credits() {
    log "info" "Linux alt script made by Kieraaaan."
    log "info" "MCM: https://www.mc-market.org/members/33627/"
    log "info" "Discord: Kieraaaan#6612"
    log "info" "If you need help, PM me on one of the above sites."
    log "log" ""
    config_check
}

config_check() {
    log "log" "Checking configuration file."
    if [[ ! -f "$config" ]]; then
        log "error" "Could not find configuration file, creating a new one."
        bash -c 'cat > alt_config.cfg' <<-'EOF'
# This is the speed at which alts will be logged, set to 0 for fast launch.
logging_speed=5
# This determines whether or not there should be output when fetching updates or installing dependencies.
silence_output=false
EOF
    fi
    source "$config"
    log "log" "Loaded configuration file."
    log "log" ""
    dependency_check
}

dependency_check() {
    log "log" "Detected $lsb_dist $dist_version."
    log "log" "Fetching updates and installing all necessary dependencies."
    if [[ "$lsb_dist" == "ubuntu" ]] || [[ "$lsb_dist" == "debian" ]]; then
        if [[ "$silence_output" == "true" ]]; then
            apt -y update >/dev/null 2>&1 && apt -y upgrade >/dev/null 2>&1 && apt -y autoremove >/dev/null 2>&1
            apt -y install gnupg ca-certificates >/dev/null 2>&1
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF >/dev/null 2>&1
        else
            apt -y update && apt -y upgrade && apt -y autoremove
            apt -y install gnupg ca-certificates
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
        fi
        if [[ "$lsb_dist" == "ubuntu" ]]; then
            if [[ "$dist_version" == "19.04" ]] || [[ "$dist_version" == "18.04" ]]; then
                echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" > /etc/apt/sources.list.d/mono-official-stable.list
            elif [[ "$dist_version" == "16.04" ]]; then
                echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" > /etc/apt/sources.list.d/mono-official-stable.list
		    else
		        log "error" "Unsupported version, this script only supports Ubuntu 19.04, 18.04 and 16.04."
			    exit 1
		    fi
		else
		    if [[ "$dist_version" == "9" ]]; then
		        echo "deb https://download.mono-project.com/repo/debian stable-stretch main" > /etc/apt/sources.list.d/mono-official-stable.list
		    else
		        log "error" "Unsupported version, this script only supports Debian 9."
			    exit 1
		    fi
		fi
		if [[ "$silence_output" == "true" ]]; then
		    apt -y update >/dev/null 2>&1
		    apt -y install mono-complete screen wget >/dev/null 2>&1
		else
		    apt -y update
		    apt -y install mono-complete screen wget
		fi
    elif [[ "$lsb_dist" == "fedora" ]] || [[ "$lsb_dist" == "centos" ]]; then
        if [[ "$silence_output" == "true" ]]; then
            yum -y update >/dev/null 2>&1
            rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" >/dev/null 2>&1
        else
            yum -y update
            rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
        fi
        if [[ "$lsb_dist" == "fedora" ]]; then
            if [[ "$dist_version" == "29" ]]; then
                su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo' >/dev/null 2>&1
            else
                log "error" "Unsupported version, this script only supports Fedora 29."
                exit 1
            fi
        elif [[ "$lsb_dist" == "centos" ]]; then
            if [[ "$dist_version" == "7" ]]; then
                su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo' >/dev/null 2>&1
		    else
		        log "error" "Unsupported version, this script only supports CentOS 7."
		        exit 1
		    fi
        fi
        if [[ "$silence_output" == "true" ]]; then
            yum -y update >/dev/null 2>&1
            yum -y install mono-complete >/dev/null 2>&1
            yum -y install screen >/dev/null 2>&1
            yum -y install wget >/dev/null 2>&1
        else
            yum -y update
		    yum -y install mono-complete
		    yum -y install screen
		    yum -y install wget
        fi
    fi
    log "log" "Dependency check complete."
    log "log" ""
    file_check
}

file_check() {
    log "log" "Checking for necessary files."
    if [[ ! -f "$alts" ]]; then
        log "error" "The alt file you specified doesn't exist."
        exit 1
    fi
    if [[ ! -f "MinecraftClient.exe" ]]; then
        log "error" "Couldn't find MinecraftClient.exe, downloading it now."
        wget -qO MinecraftClient.exe "https://ci.appveyor.com/api/buildjobs/7tkk3jqmfqm8o9fm/artifacts/MinecraftClient%2Fbin%2FRelease%2FMinecraftClient.exe"
        log "log" "Finished downloading MinecraftClient."
    fi
    export TERM=xterm
    if [[ "$TERM" != "xterm" ]]; then
        log "error" "Failed to set TERM. Search: 'Mono Bug : Magic number is wrong: 542'"
        exit 1
    fi
    log "log" "Finished file check."
    log "log" ""
    print_info
}

print_info() {
    clear
    log "log" "Logging speed is: ${logging_speed}s."
    log "log" ""
    launch_alts
}

launch_alts() {
    y=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
	    log "log" "Starting alt number $y."
	    cmd="screen -dmS alt$y bash -c 'exec $line; exec bash'"
	    eval "${cmd}"
	    sleep "${logging_speed}"
	    y=$(( y + 1 ))
    done < "$alts" && log "" && post_launch
}

post_launch() {
    log "info" "Finished alt launch, here is some important information."
    log "info" ""
    log "info" "To go to the console for an alt, type:"
    log "info" "screen -r alt<number> where <number> is the number of the alt."
    log "info" "To see a list of all the active alts, type screen -r."
    log "info" ""
    log "info" "If your alts start disconnecting then it means your server"
    log "info" "can't handle the amount of alts you're trying to log."
    log "info" ""
    log "info" "If you go to the console for an alt and you can't get the"
    log "info" "account to execute commands or chat then reboot your server"
    log "info" "or destroy some screen instances to free up some RAM."
    log "info" ""
    log "info" "To destroy a screen instance, type: screen -S <name> -X quit"
    log "info" "where <name> is the name of the screen when typing screen -r."
    log "info" ""
    exit 0
}

[[ $# -eq 0 ]] && { log "error" "ERROR: You must specify an alt file."; exit 1; }
log ""
credits
