#!/bin/bash

set -euo pipefail

#set working directory
WORKDIR="$HOME/magnitude_temp"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

#update system
sudo pacman -Syu

ASCII=$(cat << "EOF"
 ███▄ ▄███▓ ▄▄▄        ▄████  ███▄    █  ██▓▄▄▄█████▓ █    ██ ▓█████▄ ▓█████ 
▓██▒▀█▀ ██▒▒████▄     ██▒ ▀█▒ ██ ▀█   █ ▓██▒▓  ██▒ ▓▒ ██  ▓██▒▒██▀ ██▌▓█   ▀ 
▓██    ▓██░▒██  ▀█▄  ▒██░▄▄▄░▓██  ▀█ ██▒▒██▒▒ ▓██░ ▒░▓██  ▒██░░██   █▌▒███   
▒██    ▒██ ░██▄▄▄▄██ ░▓█  ██▓▓██▒  ▐▌██▒░██░░ ▓██▓ ░ ▓▓█  ░██░░▓█▄   ▌▒▓█  ▄ 
▒██▒   ░██▒ ▓█   ▓██▒░▒▓███▀▒▒██░   ▓██░░██░  ▒██▒ ░ ▒▒█████▓ ░▒████▓ ░▒████▒
░ ▒░   ░  ░ ▒▒   ▓▒█░ ░▒   ▒ ░ ▒░   ▒ ▒ ░▓    ▒ ░░   ░▒▓▒ ▒ ▒  ▒▒▓  ▒ ░░ ▒░ ░
░  ░      ░  ▒   ▒▒ ░  ░   ░ ░ ░░   ░ ▒░ ▒ ░    ░    ░░▒░ ░ ░  ░ ▒  ▒  ░ ░  ░
░      ░     ░   ▒   ░ ░   ░    ░   ░ ░  ▒ ░  ░       ░░░ ░ ░  ░ ░  ░    ░   
       ░         ░  ░      ░          ░  ░              ░        ░       ░  ░
EOF
)

DESKTOPS=("KDE Plasma" "GNOME" "Budgie" "i3" "XFCE" "Cinnamon" "MATE" "LXQt" "Deepin" "Hyprland" "Wayfire" "Sway")

echo "$ASCII"
echo
echo "select a desktop environment."

for i in "${!DESKTOPS[@]}"; do
    echo "$((i+1))) ${DESKTOPS[i]}"
done

read -rp "enter your choice. [1-${#DESKTOPS[@]}]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#DESKTOPS[@]} )); then
    echo "invalid selection."
    exit 1
fi

CHOICE="${DESKTOPS[choice-1]}"
echo "installing $CHOICE..."

case "$CHOICE" in
    "KDE Plasma")
        sudo pacman -S --needed plasma kde-applications sddm --noconfirm
        sudo systemctl enable sddm --now
        ;;
    "GNOME")
        sudo pacman -S --needed gnome gdm --noconfirm
        sudo systemctl enable gdm --now
        ;;
    "Budgie")
        sudo pacman -S --needed budgie-desktop gdm --noconfirm
        sudo systemctl enable gdm --now
        ;;
    "i3")
        sudo pacman -S --needed i3-wm i3status dmenu --noconfirm
        ;;
    "XFCE")
        sudo pacman -S --needed xfce4 xfce4-goodies lightdm --noconfirm
        sudo systemctl enable lightdm --now
        ;;
    "Cinnamon")
        sudo pacman -S --needed cinnamon lightdm --noconfirm
        sudo systemctl enable lightdm --now
        ;;
    "MATE")
        sudo pacman -S --needed mate mate-extra lightdm --noconfirm
        sudo systemctl enable lightdm --now
        ;;
    "LXQt")
        sudo pacman -S --needed lxqt sddm --noconfirm
        sudo systemctl enable sddm --now
        ;;
    "Deepin")
        sudo pacman -S --needed deepin deepin-extra lightdm --noconfirm
        sudo systemctl enable lightdm --now
        ;;
    "Hyprland")
        sudo pacman -S --needed hyprland waybar --noconfirm
        ;;
    "Wayfire")
        sudo pacman -S --needed wayfire waybar --noconfirm
        ;;
    "Sway")
        sudo pacman -S --needed sway waybar --noconfirm
        ;;
esac

echo "$CHOICE installation complete."
#setup chaotic aur and cachyos
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo tee -a /etc/pacman.conf > /dev/null <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
sudo pacman -Syu


#get packages file
echo "downloading package file."
wget https://raw.githubusercontent.com/TriangleGuy6644/magnitude-postinstall/refs/heads/main/packages.txt
#install packages
PACKAGE_FILE="packages.txt"
echo "installing packages from, $PACKAGE_FILE..."
sudo pacman -S --needed - < "$PACKAGE_FILE" --noconfirm
echo "package installation complete."

#install flatpak things
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub io.github.zaedus.spider dev.geopjr.Calligraphy io.github.kolunmi.Bazaar org.vinegarhq.Sober

# setup fish shell
fish curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install pure-fish/pure
wget https://raw.githubusercontent.com/TriangleGuy6644/magnitude-postinstall/refs/heads/main/configfiles/config.fish && mv ./config.fish "$HOME/.config/fish/"

#setup kitty
wget https://raw.githubusercontent.com/TriangleGuy6644/magnitude-postinstall/refs/heads/main/configfiles/kitty.conf && mkdir -p "$HOME/.config/kitty" && mv ./kitty.conf "$HOME/.config/kitty/"


echo "Done!!"






#delete temp directory
cd "$HOME"
rm -rf "$WORKDIR"
