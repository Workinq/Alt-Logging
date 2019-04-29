#!/bin/bash
# Alt logging script made by Kieraaaan.
# If you have any issues, my Discord is: Kieraaaan#6612

config=alt_config.cfg
alts=$1
lsb_dist="$(. /etc/os-release && echo "$ID")"
dist_version="$(. /etc/os-release && echo "$VERSION_ID")"

output() {
    echo -e '\e[32m'$1'\e[0m';
}

warn() {
    echo -e '\e[31m'$1'\e[0m';
}

info() {
    echo -e '\e[36m'$1'\e[0m';
}

credits() {
    info "Linux alt script made by Kieraaaan."
    info "MCM: https://www.mc-market.org/members/33627/"
    info "Discord: Kieraaaan#6612"
    info "If you need help, PM on one of the above sites."
    output ""
    config_check
}

config_check() {
    output "Checking configuration file."
    if [[ ! -f "$config" ]]; then
        warn "Could not find configuration file, creating a new one."
        bash -c 'cat > alt_config.cfg' <<-'EOF'
# This is the speed at which alts will be logged, set to 0 for fast launch.
logging_speed=5
EOF
    fi
    source "$config"
    output "Loaded configuration file."
    output ""
    dependency_check
}

dependency_check() {
    output "Detected $lsb_dist $dist_version, installing all necessary dependencies."
    if [[ "$lsb_dist" == "ubuntu" ]]; then
        if [[ "$dist_version" == "18.04" ]]; then
            apt -y install gnupg ca-certificates
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
            echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list
            apt -y update
        elif [[ "$dist_version" == "16.04" ]]; then
            apt -y install apt-transport-https ca-certificates
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
            echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | tee /etc/apt/sources.list.d/mono-official-stable.list
            apt -y update
		else
		    warn "Unsupported version, this script only supports Ubuntu 18.04 and ubuntu 16.04."
			exit 1
		fi
		apt -y install mono-complete
		apt -y install screen
		apt -y install wget
    elif [[ "$lsb_dist" == "debian" ]]; then
        if [[ "$dist_version" == "9" ]]; then
            apt -y install apt-transport-https dirmngr gnupg ca-certificates
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
            echo "deb https://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list
            apt -y update
		else
		    warn "Unsupported version, this script only supports Debian 9."
			exit 1
		fi
		apt -y install mono-complete
		apt -y install screen
		apt -y install wget
    elif [[ "$lsb_dist" == "fedora" ]]; then
        if [[ "$dist_version" == "29" ]]; then
            rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
            su -c 'curl https://download.mono-project.com/repo/centos8-stable.repo | tee /etc/yum.repos.d/mono-centos8-stable.repo'
            dnf -y update
        else
            warn "Unsupported version, this script only supports Fedora 29."
            exit 1
        fi
        dnf -y install mono-devel
        dnf -y install screen
        dnf -y install wget
    elif [[ "$lsb_dist" == "centos" ]]; then
        if [[ "$dist_version" == "7" ]]; then
            rpm --import "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
            su -c 'curl https://download.mono-project.com/repo/centos7-stable.repo | tee /etc/yum.repos.d/mono-centos7-stable.repo'
		else
		    warn "Unsupported version, this script only supports CentOS 7."
		    exit 1
		fi
		yum -y install mono-devel
		yum -y install screen
		yum -y install wget
    fi
    output "Dependency check complete."
    output ""
    file_check
}

file_check() {
    output "Checking for necessary files."
    if [[ ! -f "$alts" ]]; then
        warn "The alt file you specified doesn't exist."
        exit 1
    fi
    if [[ ! -f "MinecraftClient.exe" ]]; then
        output "Couldn't locate MinecraftClient.exe, would you like to download it? (y|n)"
        output "Downloading latest artifact for MinecraftClient."
        wget -qO MinecraftClient.exe "https://ci.appveyor.com/api/buildjobs/7tkk3jqmfqm8o9fm/artifacts/MinecraftClient%2Fbin%2FRelease%2FMinecraftClient.exe"
        output "Finished downloading MinecraftClient."
    fi
    export TERM=xterm
    if [[ "$TERM" != "xterm" ]]; then
        warn "Failed to set TERM. Search: 'Mono Bug : Magic number is wrong: 542'"
        exit 1
    fi
    output "Finished file check."
    output ""
    print_info
}

print_info() {
    output "Logging speed is: ${logging_speed}s."
    output ""
    launch_alts
}

launch_alts() {
    y=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
	    output "Starting alt number $y."
	    cmd="screen -dmS alt$y bash -c 'exec $line; exec bash'"
	    eval ${cmd}
	    sleep ${logging_speed}
	    y=$(( $y + 1 ))
    done < "$alts" && output "" && post_launch
}

post_launch() {
    info "Finished alt launch, here is some important information."
    info ""
    info "To go to the console for an alt, type:"
    info "screen -r alt<number> where <number> is the number of the alt."
    info "To see a list of all the active alts, type screen -r."
    info ""
    info "If your alts start disconnecting then it means your server"
    info "can't handle the amount of alts you're trying to log."
    info ""
    info "If you go to the console for an alt and you can't get the"
    info "account to execute commands or chat then reboot your server"
    info "or destroy some instances to free up some RAM."
    info ""
    info "To destroy a screen instance, type: screen -S <name> -X quit"
    info "where <name> is the name of the screen when typing screen -r."
    info ""
    exit 0
}

[[ $# -eq 0 ]] && { warn "ERROR: You must specify an alt file."; exit 1; }
output ""
credits
