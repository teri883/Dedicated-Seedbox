#!/bin/sh

tput sgr0; clear

## Check Root Privilege
if [ "$(id -u)" -ne 0 ]; then 
    echo "This script needs root permission to run"
    exit 1 
fi

## Load text color settings from URL
wget -qO /tmp/tput.sh https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Miscellaneous/tput.sh
source /tmp/tput.sh
rm -f /tmp/tput.sh  # Remove the temporary file after sourcing

## Check Linux Distro
distro_codename="$(source /etc/os-release && printf "%s" "${VERSION_CODENAME}")"
if [ "$distro_codename" != "buster" ] && [ "$distro_codename" != "bullseye" ] && [ "$distro_codename" != "bookworm" ]; then
    echo "Only Debian 10/11/12 is supported"
    exit 1

fi

while true; do
    source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/tweaking.sh)
    normal_3; options=("Deluge Tuning" "Tweaked BBR Install" "System Tuning" "Configure Boot Script")
    select opt in "${options[@]}"
    do
        case $opt in
            "Deluge Tuning")
                need_input; read -p "Enter the username of your Deluge: " username
                read -p "Cache Size (unit: MiB): " cache
                Cache_de=$((cache * 64))
                Deluge_libtorrent
                break
                ;;
            "Tweaked BBR Install")
                apt-get -qqy install sudo
                Tweaked_BBR
                normal_1; echo "Reboot for Tweaked BBR to take effect"
                break
                ;;
            "System Tuning")
                CPU_Tweaking
                NIC_Tweaking
                Network_Other_Tweaking
                Scheduler_Tweaking
                kernel_Tweaking
                break
                ;;
            "Configure Boot Script")
                normal_1; echo "Start Configuring Boot Script"
                wget https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/Miscellaneous/.boot-script.sh && chmod +x .boot-script.sh
                cat << EOF > /etc/systemd/system/boot-script.service
[Unit]
Description=boot-script
After=network.target

[Service]
Type=simple
ExecStart=/root/.boot-script.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
                systemctl enable boot-script.service
                break
                ;;
            *) warn_1; echo "Please choose a valid action";;
        esac
    done
done
