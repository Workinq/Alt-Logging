#!/bin/bash
# Alt logging script made by Kieraaaan.
# If you have any issues, my Discord is: Kieraaaan#6612

config=alt_config.cfg
alts=$1
lsb_dist="$(. /etc/os-release && echo "$ID")"

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
    output "Checking dependencies, this may take a while."
    if [[ "$lsb_dist" == "ubuntu" ]] || [[ "$lsb_dist" == "debian" ]]; then
        if ! dpkg --get-selections | grep -q "^mono-complete[[:space:]]*install$" >/dev/null; then
            output "Mono is not installed, would you like to install it? (y|n)"
            read -p "" mono_install
            if [[ "$mono_install" == "y" ]]; then
                output "Installing mono-complete, this may take a while."
                apt-get -y install mono-complete > /dev/null
                output "Finished installing mono-complete."
            else
                warn "Exiting due to missing dependency: mono-complete"
                exit 1
            fi
        fi
        if ! dpkg --get-selections | grep -q "^screen[[:space:]]*install$" >/dev/null; then
            output "Screen is not installed, would you like to install it? (y|n)"
            read -p "" screen_install
            if [[ "$screen_install" == "y" ]]; then
                output "Installing screen, this may take a while."
                apt-get -y install screen > /dev/null
                output "Finished installing screen."
            else
                warn "Exiting due to missing dependency: screen"
                exit 1
            fi
        fi
    elif [[ "$lsb_dist" == "fedora" ]]; then
        if ! yum list installed "mono-devel" >/dev/null 2>&1; then
            output "Mono is not installed, would you like to install it? (y|n)"
            read -p "" mono_install
            if [[ "$mono_install" == "y" ]]; then
                output "Installing mono-complete, this may take a while."
                dnf -yq install mono-devel
                output "Finished installing mono-complete."
            else
                warn "Exiting due to missing dependency: mono-complete"
                exit 1
            fi
        fi
        if ! yum list installed "screen" >/dev/null 2>&1; then
            output "Screen is not installed, would you like to install it? (y|n)"
            read -p "" screen_install
            if [[ "screen_install" == "y" ]]; then
                output "Installing screen, this may take a while."
                dnf -yq install screen
                output "Finished installing screen."
            else
                warn "Exiting due to missing dependency: screen"
                exit 1
            fi
        fi
        if ! yum list installed "wget" >/dev/null 2>&1; then
            output "Wget is not installed, would you like to install it? (y|n)"
            read -p "" wget_install
            if [[ "wget_install" == "y" ]]; then
                output "Installing wget, this may take a while."
                dnf -yq install wget
                output "Finished installing wget."
            else
                warn "Exiting due to missing dependency: wget"
                exit 1
            fi
        fi
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
        read -p "" download
        if [[ "$download" == "y" ]]; then
            output "Downloading latest artifact for MinecraftClient."
            wget -qO MinecraftClient.exe "https://ci.appveyor.com/api/buildjobs/7tkk3jqmfqm8o9fm/artifacts/MinecraftClient%2Fbin%2FRelease%2FMinecraftClient.exe"
            output "Finished downloading MinecraftClient."
        else
            warn "Exiting due to missing file: MinecraftClient.exe"
            exit 1
        fi
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
