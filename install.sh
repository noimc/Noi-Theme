#!/bin/bash

# Kiểm tra quyền root
if (( EUID != 0 )); then
    echo "Please run as root"
    exit 1
fi

clear

installTheme() {
    cd /var/www/ || exit
    echo "Creating backup..."
    tar -czvf Pterodactyl_Nightcore_Themebackup.tar.gz pterodactyl

    echo "Installing theme..."
    cd /var/www/pterodactyl || exit
    rm -rf Pterodactyl_Nightcore_Theme
    git clone https://github.com/NoPro200/Pterodactyl_Nightcore_Theme.git

    cd Pterodactyl_Nightcore_Theme || exit
    rm -f /var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css
    rm -f /var/www/pterodactyl/resources/scripts/index.tsx

    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv Pterodactyl_Nightcore_Theme.css /var/www/pterodactyl/resources/scripts/Pterodactyl_Nightcore_Theme.css

    echo "Installing Node.js 18 and dependencies..."
    curl -sL https://deb.nodesource.com/setup_18.x | bash -
    apt update
    apt install -y nodejs

    npm install -g yarn
    yarn install

    echo "Building panel..."
    yarn build:production
    php artisan optimize:clear
}

installThemeQuestion() {
    while true; do
        read -rp "Are you sure that you want to install the theme [y/n]? " yn
        case $yn in
            [Yy]* ) installTheme; break ;;
            [Nn]* ) exit ;;
            * ) echo "Please answer y or n." ;;
        esac
    done
}

repair() {
    bash <(curl -s https://raw.githubusercontent.com/NoPro200/Pterodactyl_Nightcore_Theme/main/repair.sh)
}

restoreBackUp() {
    echo "Restoring backup..."
    cd /var/www/ || exit
    tar -xzvf Pterodactyl_Nightcore_Themebackup.tar.gz
    rm -f Pterodactyl_Nightcore_Themebackup.tar.gz

    cd /var/www/pterodactyl || exit
    yarn install
    yarn build:production
    php artisan optimize:clear
}

# Menu
echo "============================================"
echo "  Pterodactyl Noi Theme Installer"
echo "  (c) 2025 NoiMC"
echo "============================================"
echo "[1] Install theme"
echo "[2] Restore backup"
echo "[3] Repair panel"
echo "[4] Exit"
echo "--------------------------------------------"

read -rp "Please enter a number: " choice
case $choice in
    1) installThemeQuestion ;;
    2) restoreBackUp ;;
    3) repair ;;
    4) exit ;;
    *) echo "Invalid option!" ;;
esac
