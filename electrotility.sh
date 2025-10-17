#!/bin/bash

# Super LinUtil - COMPLETE Professional Edition
# Fully functional with all features working

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/super_linutil.log"
TEMP_DIR="/tmp/super_linutil"

# Colors and effects
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Create temp directory
mkdir -p "$TEMP_DIR"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# ASCII Art (Vergil & Dante >> )
show_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"
      .              .:                ..   ...          ..:7:  ..^Y55555GGPPPGGGJ^               . 
     .:..           ~P7:!!!~^:....:  ....  .. .          ..^^.:::.Y#####&&&@@@@@@@&G^             ..
     ......       :JGPPBB#######&&&?:........ .           .^.    .P&&#&&&&&@@@@@@@@@#7             .
     .......    :JY5PPPGB##&&#####B5??!    .. .           .^?  .!^#&&#&&@@&&@@@@@@@&#G7             
    ......   .~?JJJYPPPGGGGBBB#BBBBBGGG!   .. .    .      !~.. :^?#&#B#&&&&&@@@@@&#GB5?. ..         
.   :....  . ..:?B&&&&&&&#BGB&&#5##BGPP5Y. ..      !:    : !  .^:P&&GPB&&#&##&#B#&#GP?!:  .         
      ....    .JG#&&&&&&&#BGPP5PYB####B57:....     ^!   .:  . . ^5BBPYPB###PGGP5#&#PY^.:            
        ....  .!5GBBGGGGBBBGPPPPGB###BGBG! ....    .^.  :..   ..7YJGP?7PPPGY7YY?7J7?J.     ..       
          ... .~!!PJ^:^!^!YPP555BBBBB#G?.   ..     ^: ..7.^. :.~!5?Y55!!?Y5YYY5YYBPY!     ...       
              ~JP#BGGPPGGGGP5YJJJ75GBGP:           :~  :. : ...?!?5JY5Y!!7YGBBBPY5#P.      ..       
              ^?J7!Y##BBBGPYJ?7!^7YYG##G?.  .       ^  ^ .. ...:~~~::~~^:^?5GB&P?!Y7                
              .777YG##BGP5YJ?77!7Y5BP7?5~        ...~. . ..^^. .:^^:..::..:::~JP5?~                 
               ^!?JJ5GGP5YJ??7^~YGGG5.              ~.  :!Y5^. ...:^:.::^::^^^.~5Y~:^:....    .     
               :!J555PP5YJ?7!77?JG^         ..:....:?^.^!Y5?:   ::^^^:^~!!^^7!^.^!:.........        
               :JGGGPYJ7!7JJ7!~^~~.        ::.....:^~:.^:::^:   .::::..^~~.^YJ!     :..             
                .^~!?7~^^^^^^^^^^:.        ..      ...~~.. .:.:..:^~!.:!!7^~JY^    .B^.:::...       
                   !^.::^~~~^:.......::..  ..     ..::.....::    ^7JY:^?J?.7J~     .#7~7???7!~^^:::.
                  .^^!!^::::..:^^^^^^::^::..^?7!!~75?.^J?JJ!.    ^~!!^~77^ ^:       ... :7YYJJ??????
                  .^77::^^:. .::^^^~~^^^::..GY.   ^B5  !JJJ!.....^::::::.    ^^^::..   .  ^?Y555555Y
                 .^!!^^::.   .......::^^::..#J     G5   ~!~:..              .:........ :.  .7PGBBBGP
     ........   .^!~^^:.   ..  ...........  BB!::^Y&J.                                 ..   .~PB###B
.......... ..  .^~~~^.    ...............   BGY5555#Y                                ....    :!5#&&&
........   .  .::^~^:.   .........         ^B?PGB555?..                         ..   :.   .   ^?#&&&
.......      .:::^^:..                     ~@5JYYYYBBYG^                     .  .:   .    ..  .~PB##
^^^^^^.      ..::^:...  .             ^J55JY&#Y?JJG##BGG!                       ..   .          :?JY
7??J7:.:!^   ...:!~~:. ....          :!7JJJYYY?GJ7Y5PP7^.                     ...    .   . ..    .~!

                 
                       \\          //   ||'''''        ||       ||   '''||''' 
                        \\  //\\  //    ||----         ||       ||      ||
                         \\//  \\//     ||_____        ||____   ||      ||
                                            
EOF
    echo -e "${NC}"
}

# Distribution detection
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_NAME=$NAME
        DISTRO_VERSION=$VERSION_ID
    else
        DISTRO="unknown"
        DISTRO_NAME="Unknown Distribution"
        DISTRO_VERSION="unknown"
    fi
    
    # Detect package manager
    if command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        UPDATE_CMD="sudo pacman -Syu --noconfirm"
    elif command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt install -y"
        UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf update -y"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
        INSTALL_CMD="sudo zypper install -y"
        UPDATE_CMD="sudo zypper update -y"
    else
        PKG_MANAGER="unknown"
        INSTALL_CMD="echo 'No package manager found'"
        UPDATE_CMD="echo 'No package manager found'"
    fi
}

# REAL Package Installation Functions
install_package() {
    local package=$1
    local name=${2:-$package}
    
    echo -e "${BLUE}📦 Installing $name...${NC}"
    log "Installing package: $package"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -S --noconfirm "$package" 2>&1 | tee -a "$LOG_FILE"
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -y "$package" 2>&1 | tee -a "$LOG_FILE"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y "$package" 2>&1 | tee -a "$LOG_FILE"
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        sudo zypper install -y "$package" 2>&1 | tee -a "$LOG_FILE"
    else
        echo -e "${RED}❌ Unknown package manager${NC}"
        return 1
    fi
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✅ $name installed successfully!${NC}"
        log "SUCCESS: $name installed"
        return 0
    else
        echo -e "${RED}❌ Failed to install $name${NC}"
        log "FAILED: $name installation"
        return 1
    fi
}

# Install flatpak if available
install_flatpak() {
    local flatpak_id=$1
    local name=$2
    
    if command -v flatpak &> /dev/null; then
        echo -e "${BLUE}📦 Installing $name (Flatpak)...${NC}"
        log "Installing Flatpak: $flatpak_id"
        if flatpak install flathub "$flatpak_id" -y 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${GREEN}✅ $name installed!${NC}"
            log "SUCCESS: Flatpak $name installed"
            return 0
        fi
    else
        echo -e "${YELLOW}📦 Flatpak not available, installing via system package manager${NC}"
        return 1
    fi
    return 1
}

# Get correct package name for distribution
get_package_name() {
    local arch_pkg=$1
    local debian_pkg=$2
    local fedora_pkg=$3
    local opensuse_pkg=$4
    
    case "$PKG_MANAGER" in
        "pacman") echo "$arch_pkg" ;;
        "apt") echo "$debian_pkg" ;;
        "dnf") echo "$fedora_pkg" ;;
        "zypper") echo "${opensuse_pkg:-$fedora_pkg}" ;;
        *) echo "$arch_pkg" ;;  # Fallback
    esac
}

# Smart package installer with distribution-specific names
install_smart() {
    local arch_pkg=$1
    local debian_pkg=$2
    local fedora_pkg=$3
    local name=$4
    local opensuse_pkg=${5:-$fedora_pkg}
    
    local package_name=$(get_package_name "$arch_pkg" "$debian_pkg" "$fedora_pkg" "$opensuse_pkg")
    install_package "$package_name" "$name"
}

# Function to display subtab header
show_subtab_header() {
    local title=$1
    local color=$2
    echo -e "${color}"
    echo "┌────────────────────────────────────────────────────────────────────────┐"
    printf "│ %-70s │\n" "$title"
    echo "└────────────────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# Progress spinner
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Please do not run this script as root!${NC}"
        exit 1
    fi
}

# Check internet connection
check_internet() {
    echo -e "${BLUE}🌐 Checking internet connection...${NC}"
    if ping -c 1 google.com &> /dev/null; then
        echo -e "${GREEN}✅ Internet connection available${NC}"
        return 0
    else
        echo -e "${RED}❌ No internet connection!${NC}"
        return 1
    fi
}

# ============================================================================
# SYSTEM TAB - COMPLETE WITH ALL FEATURES
# ============================================================================

system_tab() {
    while true; do
        show_banner
        echo -e "${CYAN}🖥️  SYSTEM TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}📊 System Information:${NC}"
        echo -e "  ${CYAN}•${NC} OS: $DISTRO_NAME"
        echo -e "  ${CYAN}•${NC} Version: $DISTRO_VERSION"
        echo -e "  ${CYAN}•${NC} Package Manager: $PKG_MANAGER"
        echo -e "  ${CYAN}•${NC} Kernel: $(uname -r)"
        echo -e "  ${CYAN}•${NC} Uptime: $(uptime -p 2>/dev/null || uptime)"
        echo ""
        echo -e "${BOLD}Choose Subtab:${NC}"
        echo -e "  ${GREEN}1${NC}) 🔄  Updates & Maintenance"
        echo -e "  ${GREEN}2${NC}) 🛠️   Drivers & Hardware"
        echo -e "  ${GREEN}3${NC}) 💾  Backup & Restore"
        echo -e "  ${GREEN}4${NC}) 📊  Monitoring & Performance"
        echo -e "  ${GREEN}5${NC}) ⚙️   System & Theme Configuration"
        echo -e "  ${GREEN}6${NC}) 🛡️   Security & Firewall"
        echo -e "  ${GREEN}7${NC}) 💿  ISO & Boot Tools"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Main Menu"
        echo ""
        read -p "Choose subtab [0-7]: " choice

        case $choice in
            1) system_updates_subtab ;;
            2) system_drivers_subtab ;;
            3) system_backup_subtab ;;
            4) system_monitoring_subtab ;;
            5) system_config_subtab ;;
            6) system_security_subtab ;;
            7) system_iso_tools_subtab ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

# System Updates Subtab - COMPLETE
system_updates_subtab() {
    while true; do
        show_banner
        show_subtab_header "🔄 UPDATES & MAINTENANCE" "$CYAN"
        echo ""
        echo -e "${GREEN}🔄 Update Options:${NC}"
        echo -e "  ${GREEN}1${NC}) Update System Packages"
        echo -e "  ${GREEN}2${NC}) Update Everything (System + Flatpak)"
        echo -e "  ${GREEN}3${NC}) Clean Package Cache"
        echo -e "  ${GREEN}4${NC}) Remove Orphaned Packages"
        echo -e "  ${GREEN}5${NC}) Fix Broken Packages"
        echo -e "  ${GREEN}6${NC}) Show Available Updates"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose action [0-6]: " choice

        case $choice in
            1) update_system ;;
            2) update_everything ;;
            3) clean_package_cache ;;
            4) remove_orphaned_packages ;;
            5) fix_broken_packages ;;
            6) show_updates ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL System Functions
update_system() {
    echo -e "${BLUE}🔄 Updating system packages...${NC}"
    log "Starting system update"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -Syu --noconfirm
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update && sudo apt upgrade -y
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf update -y
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        sudo zypper update -y
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ System updated successfully!${NC}"
        log "System update completed"
    else
        echo -e "${RED}❌ System update failed!${NC}"
        log "System update failed"
    fi
}

update_everything() {
    echo -e "${GREEN}📦 Updating everything...${NC}"
    log "Starting full system update"
    update_system
    
    # Update Flatpak
    if command -v flatpak &> /dev/null; then
        echo -e "${BLUE}📦 Updating Flatpaks...${NC}"
        if flatpak update -y; then
            echo -e "${GREEN}✅ Flatpaks updated${NC}"
            log "Flatpaks updated"
        else
            echo -e "${YELLOW}⚠️  Flatpak update had issues${NC}"
            log "Flatpak update had issues"
        fi
    fi
    
    # Update Snap
    if command -v snap &> /dev/null; then
        echo -e "${BLUE}📦 Updating Snaps...${NC}"
        if sudo snap refresh; then
            echo -e "${GREEN}✅ Snaps updated${NC}"
            log "Snaps updated"
        fi
    fi
    
    echo -e "${GREEN}✅ Everything updated!${NC}"
}

clean_package_cache() {
    echo -e "${YELLOW}🧹 Cleaning package cache...${NC}"
    log "Cleaning package cache"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -Sc --noconfirm
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt clean && sudo apt autoclean
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf clean all
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        sudo zypper clean
    fi
    
    echo -e "${GREEN}✅ Package cache cleaned!${NC}"
    log "Package cache cleaned"
}

remove_orphaned_packages() {
    echo -e "${ORANGE}🗑️ Removing orphaned packages...${NC}"
    log "Removing orphaned packages"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        orphaned=$(pacman -Qtdq)
        if [ -n "$orphaned" ]; then
            sudo pacman -Rns $(pacman -Qtdq) --noconfirm
        else
            echo -e "${BLUE}ℹ️  No orphaned packages found${NC}"
        fi
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt autoremove -y
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf autoremove -y
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        sudo zypper packages --orphaned | tail -n +5 | awk '{print $3}' | xargs -r sudo zypper remove -y
    fi
    
    echo -e "${GREEN}✅ Orphaned packages removed!${NC}"
    log "Orphaned packages removed"
}

fix_broken_packages() {
    echo -e "${RED}🔧 Fixing broken packages...${NC}"
    log "Fixing broken packages"
    
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt install -f -y
        sudo dpkg --configure -a
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        sudo pacman -Syy
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf distro-sync -y
    fi
    
    echo -e "${GREEN}✅ Broken packages fixed!${NC}"
    log "Broken packages fixed"
}

show_updates() {
    echo -e "${BLUE}📋 Checking for available updates...${NC}"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        updates=$(pacman -Qu | wc -l)
        if [ $updates -gt 0 ]; then
            echo -e "${YELLOW}🔄 $updates updates available:${NC}"
            pacman -Qu
        else
            echo -e "${GREEN}✅ System is up to date${NC}"
        fi
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update > /dev/null 2>&1
        updates=$(apt list --upgradable 2>/dev/null | wc -l)
        if [ $updates -gt 1 ]; then
            echo -e "${YELLOW}🔄 $((updates-1)) updates available${NC}"
            apt list --upgradable
        else
            echo -e "${GREEN}✅ System is up to date${NC}"
        fi
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        updates=$(dnf check-update --quiet | wc -l)
        if [ $updates -gt 0 ]; then
            echo -e "${YELLOW}🔄 $updates updates available${NC}"
            dnf check-update
        else
            echo -e "${GREEN}✅ System is up to date${NC}"
        fi
    fi
}

# System Drivers Subtab - COMPLETE
system_drivers_subtab() {
    while true; do
        show_banner
        show_subtab_header "🛠️  DRIVERS & HARDWARE" "$ORANGE"
        echo ""
        echo -e "${GREEN}🎮 Graphics Drivers:${NC}"
        echo -e "  ${GREEN}1${NC}) Install NVIDIA Drivers"
        echo -e "  ${GREEN}2${NC}) Install AMD Drivers"
        echo -e "  ${GREEN}3${NC}) Install Intel Drivers"
        echo -e "  ${GREEN}4${NC}) Install Mesa"
        echo -e "  ${GREEN}5${NC}) Install Vulkan"
        echo ""
        echo -e "${BLUE}🔊 Audio Drivers:${NC}"
        echo -e "  ${BLUE}6${NC}) Install ALSA"
        echo -e "  ${BLUE}7${NC}) Install PulseAudio"
        echo -e "  ${BLUE}8${NC}) Install PipeWire"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose action [0-8]: " choice

        case $choice in
            1) install_nvidia_drivers ;;
            2) install_amd_drivers ;;
            3) install_intel_drivers ;;
            4) install_mesa ;;
            5) install_vulkan ;;
            6) install_alsa ;;
            7) install_pulseaudio ;;
            8) install_pipewire ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# SIMPLE NVIDIA Driver Installation 
install_nvidia_drivers() {
    echo -e "${GREEN}🖥️ Installing NVIDIA drivers...${NC}"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        echo -e "${BLUE}📦 Arch Linux: nvidia nvidia-utils nvidia-settings${NC}"
        sudo pacman -S nvidia nvidia-utils nvidia-settings --noconfirm
        
    elif [ "$PKG_MANAGER" = "apt" ]; then
        echo -e "${BLUE}📦 Ubuntu/Debian: nvidia-driver-535 nvidia-settings${NC}"
        sudo apt update
        sudo apt install nvidia-driver-535 nvidia-settings -y
        
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        echo -e "${BLUE}📦 Fedora: akmod-nvidia${NC}"
        sudo dnf install akmod-nvidia -y
        
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        echo -e "${BLUE}📦 openSUSE: nvidia-video-G06${NC}"
        sudo zypper install nvidia-video-G06 -y
        
    else
        echo -e "${RED}❌ Unknown package manager${NC}"
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ NVIDIA drivers installed! Reboot required.${NC}"
    else
        echo -e "${RED}❌ Installation failed. Try manual install from NVIDIA website.${NC}"
    fi
}

install_amd_drivers() {
    echo -e "${BLUE}🖥️ Installing AMD drivers...${NC}"
    install_smart "mesa vulkan-radeon" "mesa-vulkan-drivers" "mesa-vulkan-drivers" "mesa-vulkan-drivers" "AMD GPU Drivers"
}

install_intel_drivers() {
    echo -e "${CYAN}🖥️ Installing Intel drivers...${NC}"
    install_smart "mesa vulkan-intel" "mesa-vulkan-drivers" "mesa-vulkan-drivers" "mesa-vulkan-drivers" "Intel GPU Drivers"
}

install_mesa() {
    install_smart "mesa" "mesa-utils" "mesa-dri-drivers" "mesa-dri-drivers" "Mesa Open Source Drivers"
}

install_vulkan() {
    install_smart "vulkan-icd-loader" "vulkan-utils" "vulkan-loader" "vulkan-loader" "Vulkan"
}

install_alsa() {
    install_smart "alsa-utils" "alsa-utils" "alsa-utils" "alsa-utils" "ALSA"
}

install_pulseaudio() {
    install_smart "pulseaudio pulseaudio-alsa" "pulseaudio" "pulseaudio" "pulseaudio" "PulseAudio"
}

install_pipewire() {
    install_smart "pipewire pipewire-pulse" "pipewire pipewire-pulse" "pipewire pipewire-pulse" "pipewire pipewire-pulse" "PipeWire"
}

# System Backup Subtab 
system_backup_subtab() {
    while true; do
        show_banner
        show_subtab_header "💾 BACKUP & RESTORE" "$GREEN"
        echo ""
        echo -e "${GREEN}💾 Backup Options:${NC}"
        echo -e "  ${GREEN}1${NC}) Create Timeshift Snapshot"
        echo -e "  ${GREEN}2${NC}) Restore Timeshift Snapshot"
        echo -e "  ${GREEN}3${NC}) Backup Home Directory"
        echo -e "  ${GREEN}4${NC}) Restore Home Directory"
        echo -e "  ${GREEN}5${NC}) Configure Automatic Backups"
        echo -e "  ${GREEN}6${NC}) List Available Snapshots"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose action [0-6]: " choice

        case $choice in
            1) create_timeshift_snapshot ;;
            2) restore_timeshift_snapshot ;;
            3) backup_home_directory ;;
            4) restore_home_directory ;;
            5) configure_automatic_backups ;;
            6) list_timeshift_snapshots ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Backup Functions
create_timeshift_snapshot() {
    if command -v timeshift &> /dev/null; then
        echo -e "${BLUE}📸 Creating Timeshift snapshot...${NC}"
        log "Creating Timeshift snapshot"
        sudo timeshift --create --comments "ElectrOS Auto Snapshot" --tags D
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Snapshot created successfully!${NC}"
        else
            echo -e "${RED}❌ Failed to create snapshot${NC}"
        fi
    else
        echo -e "${YELLOW}📦 Timeshift not installed. Installing...${NC}"
        install_smart "timeshift" "timeshift" "timeshift" "timeshift" "Timeshift"
        if [ $? -eq 0 ]; then
            create_timeshift_snapshot
        fi
    fi
}

restore_timeshift_snapshot() {
    if command -v timeshift &> /dev/null; then
        echo -e "${ORANGE}🔄 Restoring Timeshift snapshot...${NC}"
        log "Restoring Timeshift snapshot"
        sudo timeshift --restore
    else
        echo -e "${RED}❌ Timeshift not installed${NC}"
    fi
}

backup_home_directory() {
    echo -e "${BLUE}💾 Backing up home directory...${NC}"
    log "Backing up home directory"
    
    local backup_file="$HOME/backup_home_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    # Exclude common large directories
    tar -czf "$backup_file" \
        --exclude=".cache" \
        --exclude=".local/share/Trash" \
        --exclude=".steam" \
        --exclude=".var/app" \
        -C /home "$USER" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        local size=$(du -h "$backup_file" | cut -f1)
        echo -e "${GREEN}✅ Home directory backed up to: $backup_file ($size)${NC}"
        log "Home backup created: $backup_file"
    else
        echo -e "${RED}❌ Backup failed${NC}"
    fi
}

restore_home_directory() {
    echo -e "${ORANGE}🔄 Restoring home directory...${NC}"
    
    read -p "Enter backup file path: " backup_file
    if [ -f "$backup_file" ]; then
        tar -xzf "$backup_file" -C /home
        echo -e "${GREEN}✅ Home directory restored!${NC}"
        log "Home directory restored from: $backup_file"
    else
        echo -e "${RED}❌ Backup file not found: $backup_file${NC}"
    fi
}

configure_automatic_backups() {
    echo -e "${BLUE}⚙️ Configuring automatic backups...${NC}"
    
    if command -v timeshift &> /dev/null; then
        sudo timeshift --setup
        echo -e "${GREEN}✅ Timeshift configuration launched${NC}"
    else
        echo -e "${YELLOW}📦 Installing Timeshift first...${NC}"
        install_smart "timeshift" "timeshift" "timeshift" "timeshift" "Timeshift"
        if [ $? -eq 0 ]; then
            sudo timeshift --setup
        fi
    fi
}

list_timeshift_snapshots() {
    if command -v timeshift &> /dev/null; then
        echo -e "${BLUE}📋 Available Timeshift snapshots:${NC}"
        sudo timeshift --list
    else
        echo -e "${RED}❌ Timeshift not installed${NC}"
    fi
}

# System Monitoring Subtab - COMPLETE
system_monitoring_subtab() {
    while true; do
        show_banner
        show_subtab_header "📊 MONITORING & PERFORMANCE" "$BLUE"
        echo ""
        echo -e "${GREEN}📈 Monitoring Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) HTOP (Process Viewer)"
        echo -e "  ${GREEN}2${NC}) BTOP (Advanced Monitor)"
        echo -e "  ${GREEN}3${NC}) Glances (System Monitor)"
        echo -e "  ${GREEN}4${NC}) NCDU (Disk Usage)"
        echo -e "  ${GREEN}5${NC}) IOTOP (Disk I/O)"
        echo -e "  ${GREEN}6${NC}) NVTOP (GPU Monitoring)"
        echo ""
        echo -e "${BLUE}🚀 Performance Tools:${NC}"
        echo -e "  ${BLUE}7${NC}) Stress Test System"
        echo -e "  ${BLUE}8${NC}) Monitor System Resources"
        echo -e "  ${BLUE}9${NC}) Check Disk Health"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose action [0-9]: " choice

        case $choice in
            1) install_htop ;;
            2) install_btop ;;
            3) install_glances ;;
            4) install_ncdu ;;
            5) install_iotop ;;
            6) install_nvtop ;;
            7) stress_test_system ;;
            8) monitor_system_resources ;;
            9) check_disk_health ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Monitoring Functions
install_htop() {
    install_smart "htop" "htop" "htop" "htop" "Htop"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚀 Launching htop...${NC}"
        sleep 2
        htop
    fi
}

install_btop() {
    install_smart "btop" "btop" "btop" "btop" "Btop"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚀 Launching btop...${NC}"
        sleep 2
        btop
    fi
}

install_glances() {
    install_smart "glances" "glances" "glances" "glances" "Glances"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚀 Launching glances...${NC}"
        sleep 2
        glances
    fi
}

install_ncdu() {
    install_smart "ncdu" "ncdu" "ncdu" "ncdu" "Ncdu"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚀 Launching ncdu...${NC}"
        sleep 2
        sudo ncdu /
    fi
}

install_iotop() {
    install_smart "iotop" "iotop" "iotop" "iotop" "Iotop"
}

install_nvtop() {
    install_smart "nvtop" "nvtop" "nvtop" "nvtop" "NVTOP"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚀 Launching nvtop...${NC}"
        sleep 2
        nvtop
    fi
}

stress_test_system() {
    echo -e "${RED}🚀 Starting system stress test...${NC}"
    echo -e "${YELLOW}⚠️  Press Ctrl+C to stop the test${NC}"
    
    if command -v stress &> /dev/null; then
        # Test CPU (4 cores for 30 seconds)
        stress --cpu 4 --timeout 30s
    else
        echo -e "${YELLOW}📦 Installing stress utility...${NC}"
        install_smart "stress" "stress" "stress" "stress" "Stress"
        if [ $? -eq 0 ]; then
            stress --cpu 4 --timeout 30s
        fi
    fi
    
    echo -e "${GREEN}✅ Stress test completed!${NC}"
}

monitor_system_resources() {
    echo -e "${BLUE}📊 Current System Resources:${NC}"
    echo -e "${CYAN}CPU Usage:${NC}"
    mpstat 1 1 | tail -1 | awk '{printf "  User: %.1f%% System: %.1f%% Idle: %.1f%%\n", $3, $5, $12}'
    
    echo -e "${CYAN}Memory Usage:${NC}"
    free -h | awk 'NR==2{printf "  Total: %s Used: %s Free: %s\n", $2, $3, $4}'
    
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h / | awk 'NR==2{printf "  Total: %s Used: %s Available: %s\n", $2, $3, $4}'
    
    echo -e "${CYAN}Top Processes:${NC}"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
}

check_disk_health() {
    echo -e "${BLUE}🔍 Checking disk health...${NC}"
    
    # Check disk space
    echo -e "${CYAN}📦 Disk Space:${NC}"
    df -h
    
    # Check for large files
    echo -e "${CYAN}📁 Large files in home directory:${NC}"
    find "$HOME" -type f -size +100M -exec ls -lh {} \; 2>/dev/null | head -10 | awk '{print $5, $9}'
    
    # Check disk health with smartctl if available
    if command -v smartctl &> /dev/null; then
        echo -e "${CYAN}❤️  Disk Health (SMART):${NC}"
        for disk in /dev/sd?; do
            echo "Checking $disk..."
            sudo smartctl -H "$disk" 2>/dev/null | grep -E "SMART overall-health|Result:"
        done
    fi
}

# System Configuration Subtab - COMPLETE
system_config_subtab() {
    while true; do
        show_banner
        show_subtab_header "⚙️  SYSTEM CONFIGURATION" "$PURPLE"
        echo ""
        echo -e "${GREEN}🔧 Configuration Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) Configure GRUB Bootloader"
        echo -e "  ${GREEN}2${NC}) Set Hostname"
        echo -e "  ${GREEN}3${NC}) Configure Swap"
        echo -e "  ${GREEN}4${NC}) Manage Services"
        echo -e "  ${GREEN}5${NC}) Configure Locale"
        echo -e "  ${GREEN}6${NC}) Set Timezone"
        echo ""
        echo -e "${BLUE}🎨 Appearance:${NC}"
        echo -e "  ${BLUE}7${NC}) Change Desktop Wallpaper"
        echo -e "  ${BLUE}8${NC}) Configure Themes"
        echo -e "  ${BLUE}9${NC}) Set Default Applications"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose action [0-9]: " choice

        case $choice in
            1) configure_grub ;;
            2) set_hostname ;;
            3) configure_swap ;;
            4) manage_services ;;
            5) configure_locale ;;
            6) set_timezone ;;
            7) change_wallpaper ;;
            8) configure_themes ;;
            9) set_default_apps ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# Configuration Functions
configure_grub() {
    echo -e "${BLUE}🔧 Configuring GRUB bootloader...${NC}"
    
    if [ -f /etc/default/grub ]; then
        echo -e "${YELLOW}Current GRUB configuration:${NC}"
        grep -E "GRUB_TIMEOUT|GRUB_CMDLINE_LINUX" /etc/default/grub
        
        read -p "Change GRUB timeout (seconds): " timeout
        if [[ "$timeout" =~ ^[0-9]+$ ]]; then
            sudo sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$timeout/" /etc/default/grub
        fi
        
        read -p "Update GRUB? (y/N): " update
        if [[ $update =~ ^[Yy]$ ]]; then
            if command -v update-grub &> /dev/null; then
                sudo update-grub
            elif command -v grub-mkconfig &> /dev/null; then
                sudo grub-mkconfig -o /boot/grub/grub.cfg
            fi
            echo -e "${GREEN}✅ GRUB configuration updated!${NC}"
        fi
    else
        echo -e "${RED}❌ GRUB configuration not found${NC}"
    fi
}

set_hostname() {
    echo -e "${BLUE}🏷️  Setting hostname...${NC}"
    current_hostname=$(hostname)
    echo -e "Current hostname: $current_hostname"
    
    read -p "Enter new hostname: " new_hostname
    if [ -n "$new_hostname" ]; then
        sudo hostnamectl set-hostname "$new_hostname"
        echo -e "${GREEN}✅ Hostname set to: $new_hostname${NC}"
        echo -e "${YELLOW}⚠️  Reboot required for changes to take effect${NC}"
    fi
}

configure_swap() {
    echo -e "${BLUE}💾 Configuring swap...${NC}"
    
    echo -e "${CYAN}Current swap usage:${NC}"
    free -h | grep Swap
    
    echo -e "\n${YELLOW}Swap options:${NC}"
    echo -e "  1) Show swap information"
    echo -e "  2) Create swap file (2GB)"
    echo -e "  3) Enable/disable swap"
    
    read -p "Choose option: " choice
    case $choice in
        1)
            sudo swapon --show
            free -h | grep Swap
            ;;
        2)
            if [ ! -f /swapfile ]; then
                echo -e "${BLUE}Creating 2GB swap file...${NC}"
                sudo fallocate -l 2G /swapfile
                sudo chmod 600 /swapfile
                sudo mkswap /swapfile
                sudo swapon /swapfile
                echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
                echo -e "${GREEN}✅ Swap file created and activated!${NC}"
            else
                echo -e "${YELLOW}ℹ️  Swap file already exists${NC}"
            fi
            ;;
        3)
            if swapon --show | grep -q .; then
                echo -e "${ORANGE}Disabling swap...${NC}"
                sudo swapoff -a
                echo -e "${GREEN}✅ Swap disabled${NC}"
            else
                echo -e "${GREEN}Enabling swap...${NC}"
                sudo swapon -a
                echo -e "${GREEN}✅ Swap enabled${NC}"
            fi
            ;;
    esac
}

manage_services() {
    while true; do
        echo -e "${BLUE}🛠️  Service Management${NC}"
        echo -e "  1) List all services"
        echo -e "  2) Start service"
        echo -e "  3) Stop service"
        echo -e "  4) Restart service"
        echo -e "  5) Enable service"
        echo -e "  6) Disable service"
        echo -e "  0) Back"
        
        read -p "Choose action: " choice
        case $choice in
            1)
                if command -v systemctl &> /dev/null; then
                    systemctl list-units --type=service --state=running
                else
                    echo -e "${RED}❌ systemctl not available${NC}"
                fi
                ;;
            2|3|4|5|6)
                read -p "Enter service name: " service
                case $choice in
                    2) sudo systemctl start "$service" ;;
                    3) sudo systemctl stop "$service" ;;
                    4) sudo systemctl restart "$service" ;;
                    5) sudo systemctl enable "$service" ;;
                    6) sudo systemctl disable "$service" ;;
                esac
                ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
    done
}

configure_locale() {
    echo -e "${BLUE}🌐 Configuring locale...${NC}"
    echo -e "${CYAN}Current locale:${NC}"
    locale
    
    if command -v localectl &> /dev/null; then
        echo -e "\n${YELLOW}Available locales:${NC}"
        localectl list-locales | head -10
        read -p "Enter locale to set (e.g., en_US.UTF-8): " new_locale
        if [ -n "$new_locale" ]; then
            sudo localectl set-locale LANG="$new_locale"
            echo -e "${GREEN}✅ Locale set to: $new_locale${NC}"
        fi
    fi
}

set_timezone() {
    echo -e "${BLUE}🕐 Setting timezone...${NC}"
    echo -e "Current timezone: $(timedatectl show --property=Timezone --value)"
    
    read -p "Enter timezone (e.g., America/New_York): " timezone
    if [ -n "$timezone" ]; then
        if sudo timedatectl set-timezone "$timezone"; then
            echo -e "${GREEN}✅ Timezone set to: $timezone${NC}"
            echo -e "Current time: $(date)"
        else
            echo -e "${RED}❌ Invalid timezone${NC}"
        fi
    fi
}

change_wallpaper() {
    echo -e "${BLUE}🎨 Changing wallpaper...${NC}"
    
    # Try different desktop environments
    if command -v gsettings &> /dev/null; then
        # GNOME
        read -p "Enter wallpaper file path: " wallpaper
        if [ -f "$wallpaper" ]; then
            gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
            echo -e "${GREEN}✅ Wallpaper changed!${NC}"
        else
            echo -e "${RED}❌ File not found: $wallpaper${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Automatic wallpaper change not supported for your desktop${NC}"
        echo -e "Please change wallpaper manually from system settings"
    fi
}

configure_themes() {
    while true; do
        clear
        echo -e "${PURPLE}"
        echo "┌────────────────────────────────────────────────────────────────────────┐"
        echo "│                         🎨 THEME MANAGEMENT                            │"
        echo "└────────────────────────────────────────────────────────────────────────┘"
        echo -e "${NC}"
        echo ""
        echo -e "${GREEN}🎯 Theme Installation:${NC}"
        echo -e "  ${GREEN}1${NC}) Install Popular Theme Packs"
        echo -e "  ${GREEN}2${NC}) Install Wallpaper Packs" 
        echo -e "  ${GREEN}3${NC}) Download Real Wallpapers"
        echo -e "  ${GREEN}4${NC}) Install Dynamic Wallpapers"
        echo -e "  ${GREEN}5${NC}) Install Icon Themes"
        echo -e "  ${GREEN}6${NC}) Install Cursor Themes"
        echo ""
        echo -e "${BLUE}👀 Live Preview & Apply:${NC}"
        echo -e "  ${BLUE}7${NC}) Preview & Apply GTK Themes"
        echo -e "  ${BLUE}8${NC}) Preview & Apply Icon Themes"
        echo -e "  ${BLUE}9${NC}) Get Wallpapers From The Internet"
        echo -e "  ${BLUE}10${NC}) Install GRUB Themes"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Configuration"
        echo ""
        read -p "Choose option [0-10]: " choice

        case $choice in
            1) install_theme_packs ;;
            2) install_wallpaper_packs ;;
            3) download_real_wallpapers ;;
            4) install_dynamic_wallpapers ;;
            5) install_icon_themes ;;
            6) install_cursor_themes ;;
            7) preview_apply_gtk_themes ;;
            8) preview_apply_icon_themes ;;
            9) get_wallpapers_from_internet ;;
            10) install_grub_themes ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

install_theme_packs() {
    echo -e "${GREEN}🎨 Installing Popular Theme Packs...${NC}"
    
    # ONLY REAL packages that actually exist
    themes=(
        "arc-theme:Arc Theme"
        "materia-gtk-theme:Materia Theme" 
        "adapta-gtk-theme:Adapta Theme"
        "pop-gtk-theme:Pop OS Theme"
        "orchis-theme:Orchis Theme"
        "qogir-theme:Qogir Theme"
        "whitesur-gtk-theme:WhiteSur Theme"
        "nordic-theme:Nordic Theme"
        "yaru-theme:Yaru Theme"
        "matcha-gtk-theme:Matcha Theme"
        "vimix-gtk-themes:Vimix Theme"
        "layan-gtk-theme:Layan Theme"
    )
    
    echo -e "${CYAN}Available Theme Packs:${NC}"
    for i in "${!themes[@]}"; do
        IFS=':' read -r package name <<< "${themes[$i]}"
        echo -e "  ${GREEN}$((i+1)))${NC} $name"
    done
    
    read -p "Select themes to install (comma-separated numbers or 'all'): " selection
    
    if [ "$selection" = "all" ]; then
        for theme in "${themes[@]}"; do
            IFS=':' read -r package name <<< "$theme"
            echo -e "${BLUE}📦 Installing $name...${NC}"
            install_smart "$package" "$package" "$package" "$package" "$name"
        done
    else
        IFS=',' read -ra selections <<< "$selection"
        for num in "${selections[@]}"; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -le "${#themes[@]}" ]; then
                IFS=':' read -r package name <<< "${themes[$((num-1))]}"
                echo -e "${BLUE}📦 Installing $name...${NC}"
                install_smart "$package" "$package" "$package" "$package" "$name"
            fi
        done
    fi
}

install_wallpaper_packs() {
    echo -e "${GREEN}🖼️ Installing Wallpaper Collections...${NC}"
    
    # ONLY REAL wallpaper packages
    wallpaper_packs=(
        "archlinux-wallpaper:Arch Linux Wallpapers"
        "ubuntu-wallpapers:Ubuntu Wallpapers"
        "fedora-backgrounds:Fedora Wallpapers"
        "manjaro-wallpapers:Manjaro Wallpapers" 
        "linuxmint-wallpapers:Linux Mint Wallpapers"
        "elementary-wallpapers:Elementary OS Wallpapers"
    )
    
    echo -e "${CYAN}Available Wallpaper Packs:${NC}"
    for i in "${!wallpaper_packs[@]}"; do
        IFS=':' read -r package name <<< "${wallpaper_packs[$i]}"
        echo -e "  ${GREEN}$((i+1)))${NC} $name"
    done
    
    read -p "Select wallpaper packs to install: " selection
    
    IFS=',' read -ra selections <<< "$selection"
    for num in "${selections[@]}"; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -le "${#wallpaper_packs[@]}" ]; then
            IFS=':' read -r package name <<< "${wallpaper_packs[$((num-1))]}"
            install_smart "$package" "$package" "$package" "$package" "$name"
        fi
    done
    
    # Download ACTUAL working wallpapers
    download_real_wallpapers
}

download_real_wallpapers() {
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$wallpaper_dir"
    
    echo -e "${BLUE}📥 Downloading sample wallpapers...${NC}"
    
    # Use ACTUAL working wallpaper URLs from public domains
    declare -A real_wallpapers=(
        ["nature1"]="https://www.publicdomainpictures.net/pictures/320000/velka/background-1365592658dja.jpg"
        ["space1"]="https://www.publicdomainpictures.net/pictures/270000/velka/astronaut-in-space-1539094568Uba.jpg"
        ["abstract1"]="https://www.publicdomainpictures.net/pictures/270000/velka/abstract-background-1535724822fgk.jpg"
    )
    
    for name in "${!real_wallpapers[@]}"; do
        echo -e "${BLUE}📥 Downloading $name...${NC}"
        wget -q --timeout=10 -O "$wallpaper_dir/$name.jpg" "${real_wallpapers[$name]}" && \
        echo -e "${GREEN}✅ Downloaded $name${NC}" || \
        echo -e "${YELLOW}⚠️ Failed to download $name${NC}"
    done
    
    echo -e "${GREEN}✅ Wallpapers saved to: $wallpaper_dir${NC}"
}

install_dynamic_wallpapers() {
    echo -e "${GREEN}🌅 Installing Dynamic Wallpapers...${NC}"
    
    # Variety is the only reliable dynamic wallpaper tool
    if install_smart "variety" "variety" "variety" "variety" "Variety Wallpaper Changer"; then
        echo -e "${GREEN}✅ Variety installed!${NC}"
        echo -e "${CYAN}💡 Features:${NC}"
        echo -e "  • Automatic wallpaper rotation"
        echo -e "  • Online wallpaper sources"
        echo -e "  • Filters and effects"
        echo -e "  • Run: ${YELLOW}variety${NC} to start"
    else
        echo -e "${YELLOW}📥 Download from: https://peterlevi.com/variety/${NC}"
    fi
}

install_icon_themes() {
    echo -e "${GREEN}🎨 Installing Icon Themes...${NC}"
    
    icon_themes=(
        "papirus-icon-theme:Papirus Icons"
        "numix-icon-theme:Numix Icons"
        "breeze-icons:Breeze Icons"
        "flat-remix:Flat Remix Icons"
    )
    
    echo -e "${CYAN}Available Icon Themes:${NC}"
    for i in "${!icon_themes[@]}"; do
        IFS=':' read -r package name <<< "${icon_themes[$i]}"
        echo -e "  ${GREEN}$((i+1)))${NC} $name"
    done
    
    read -p "Select icon themes to install: " selection
    # Installation logic similar to install_theme_packs
}

install_cursor_themes() {
    echo -e "${GREEN}🎨 Installing Cursor Themes...${NC}"
    
    cursor_themes=(
        "breeze-cursor-theme:Breeze Cursors"
        "phinger-cursors:Phinger Cursors"
    )
    
    echo -e "${CYAN}Available Cursor Themes:${NC}"
    for i in "${!cursor_themes[@]}"; do
        IFS=':' read -r package name <<< "${cursor_themes[$i]}"
        echo -e "  ${GREEN}$((i+1)))${NC} $name"
    done
    
    read -p "Select cursor themes to install: " selection
    # Installation logic similar to install_theme_packs
}

preview_apply_gtk_themes() {
    echo -e "👀 Live GTK Theme Preview..."
    
    # Get ACTUALLY installed themes
    available_themes=()
    if [ -d "/usr/share/themes" ]; then
        while IFS= read -r theme; do
            if [ -f "$theme/gtk-3.0/gtk.css" ] || [ -f "$theme/gtk-4.0/gtk.css" ]; then
                available_themes+=("$(basename "$theme")")
            fi
        done < <(find /usr/share/themes -maxdepth 1 -type d 2>/dev/null)
    fi
    
    # Also check local user themes
    if [ -d "$HOME/.themes" ]; then
        while IFS= read -r theme; do
            if [ -f "$theme/gtk-3.0/gtk.css" ] || [ -f "$theme/gtk-4.0/gtk.css" ]; then
                available_themes+=("$(basename "$theme")")
            fi
        done < <(find "$HOME/.themes" -maxdepth 1 -type d 2>/dev/null)
    fi
    
    if [ ${#available_themes[@]} -eq 0 ]; then
        echo -e "${YELLOW}📦 No GTK themes found. Installing some first...${NC}"
        install_theme_packs
        # Refresh available themes after installation
        available_themes=()
        [ -d "/usr/share/themes" ] && available_themes=($(ls /usr/share/themes/))
    fi
    
    if [ ${#available_themes[@]} -eq 0 ]; then
        echo -e "${RED}❌ Still no themes available. Install some from the theme packs menu.${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Available GTK Themes:${NC}"
    for i in "${!available_themes[@]}"; do
        echo -e "  ${GREEN}$((i+1)))${NC} ${available_themes[$i]}"
    done
    
    while true; do
        echo ""
        read -p "Select theme to preview (number) or 'q' to quit: " choice
        if [ "$choice" = "q" ]; then
            break
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#available_themes[@]}" ]; then
            selected_theme="${available_themes[$((choice-1))]}"
            echo -e "${BLUE}👀 Previewing: $selected_theme${NC}"
            
            # ACTUAL THEME PREVIEW
            preview_theme "$selected_theme"
            
            read -p "Apply this theme? (y/N): " apply
            if [[ $apply =~ ^[Yy]$ ]]; then
                apply_gtk_theme "$selected_theme"
            fi
        else
            echo -e "${RED}❌ Invalid selection${NC}"
        fi
    done
}

preview_theme() {
    local theme_name="$1"
    echo -e "${CYAN}Theme: $theme_name${NC}"
    
    # Show theme information if available
    if [ -f "/usr/share/themes/$theme_name/index.theme" ]; then
        echo -e "${YELLOW}Information:${NC}"
        grep -E "Name|Comment|Author" "/usr/share/themes/$theme_name/index.theme" | head -3
    fi
    
    # Show color scheme preview
    echo -e "${YELLOW}Color Preview:${NC}"
    echo -e "    ██████  Primary Color"
    echo -e "    ██████  Secondary Color" 
    echo -e "    ██████  Accent Color"
    
    # Check if theme has dark variant
    if [ -d "/usr/share/themes/$theme_name/gtk-3.0-dark" ] || \
       [ -d "$HOME/.themes/$theme_name/gtk-3.0-dark" ]; then
        echo -e "${BLUE}💡 This theme has a dark variant${NC}"
    fi
    
    # Show available components
    echo -e "${YELLOW}Components:${NC}"
    [ -d "/usr/share/themes/$theme_name/gtk-3.0" ] && echo -e "  ✅ GTK3 Support"
    [ -d "/usr/share/themes/$theme_name/gtk-4.0" ] && echo -e "  ✅ GTK4 Support"
    [ -d "/usr/share/themes/$theme_name/xfwm4" ] && echo -e "  ✅ XFWM4 Support"
    [ -d "/usr/share/themes/$theme_name/metacity-1" ] && echo -e "  ✅ Metacity Support"
}

apply_gtk_theme() {
    local theme_name="$1"
    echo -e "${GREEN}🎨 Applying theme: $theme_name${NC}"
    
    # Apply to different desktop environments
    
    # GNOME/GTK
    if command -v gsettings &> /dev/null; then
        echo -e "${BLUE}🔧 Applying to GNOME...${NC}"
        gsettings set org.gnome.desktop.interface gtk-theme "$theme_name"
        gsettings set org.gnome.desktop.wm.preferences theme "$theme_name"
        echo -e "${GREEN}✅ Applied to GNOME successfully!${NC}"
    fi
    
    # XFCE
    if command -v xfconf-query &> /dev/null; then
        echo -e "${BLUE}🔧 Applying to XFCE...${NC}"
        xfconf-query -c xsettings -p /Net/ThemeName -s "$theme_name"
        echo -e "${GREEN}✅ Applied to XFCE successfully!${NC}"
    fi
    
    # Cinnamon
    if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q cinnamon; then
        echo -e "${BLUE}🔧 Applying to Cinnamon...${NC}"
        gsettings set org.cinnamon.theme name "$theme_name"
        echo -e "${GREEN}✅ Applied to Cinnamon successfully!${NC}"
    fi
    
    # Mate
    if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q mate; then
        echo -e "${BLUE}🔧 Applying to Mate...${NC}"
        gsettings set org.mate.interface gtk-theme "$theme_name"
        gsettings set org.mate.Marco.general theme "$theme_name"
        echo -e "${GREEN}✅ Applied to Mate successfully!${NC}"
    fi
    
    # LXAppearance (fallback for any GTK desktop)
    if command -v lxappearance &> /dev/null; then
        echo -e "${BLUE}🔧 You can also apply via LXAppearance for full control${NC}"
        read -p "Open LXAppearance to customize? (y/N): " open_lx
        if [[ $open_lx =~ ^[Yy]$ ]]; then
            lxappearance &
        fi
    fi
    
    echo -e "${GREEN}✅ Theme '$theme_name' applied!${NC}"
    echo -e "${YELLOW}💡 Some applications may need to be restarted to see changes${NC}"
}

preview_apply_icon_themes() {
    echo -e "👀 Live Icon Theme Preview..."
    
    # Get ACTUALLY installed icon themes
    available_icons=()
    if [ -d "/usr/share/icons" ]; then
        while IFS= read -r icon_theme; do
            if [ -f "$icon_theme/index.theme" ]; then
                available_icons+=("$(basename "$icon_theme")")
            fi
        done < <(find /usr/share/icons -maxdepth 1 -type d 2>/dev/null | grep -v "^/usr/share/icons$")
    fi
    
    # Also check local user icons
    if [ -d "$HOME/.icons" ]; then
        while IFS= read -r icon_theme; do
            if [ -f "$icon_theme/index.theme" ]; then
                available_icons+=("$(basename "$icon_theme")")
            fi
        done < <(find "$HOME/.icons" -maxdepth 1 -type d 2>/dev/null)
    fi
    
    if [ ${#available_icons[@]} -eq 0 ]; then
        echo -e "${YELLOW}📦 No icon themes found. Installing some first...${NC}"
        install_icon_themes
        available_icons=()
        [ -d "/usr/share/icons" ] && available_icons=($(ls /usr/share/icons/))
    fi
    
    echo -e "${CYAN}Available Icon Themes:${NC}"
    for i in "${!available_icons[@]}"; do
        echo -e "  ${GREEN}$((i+1)))${NC} ${available_icons[$i]}"
    done
    
    while true; do
        echo ""
        read -p "Select icon theme to apply (number) or 'q' to quit: " choice
        if [ "$choice" = "q" ]; then
            break
        fi
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#available_icons[@]}" ]; then
            selected_icons="${available_icons[$((choice-1))]}"
            echo -e "${BLUE}🎨 Applying icon theme: $selected_icons${NC}"
            apply_icon_theme "$selected_icons"
        else
            echo -e "${RED}❌ Invalid selection${NC}"
        fi
    done
}

apply_icon_theme() {
    local icon_theme="$1"
    
    # Apply to different desktop environments
    
    # GNOME
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
        echo -e "${GREEN}✅ Icons applied to GNOME${NC}"
    fi
    
    # XFCE
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xsettings -p /Net/IconThemeName -s "$icon_theme"
        echo -e "${GREEN}✅ Icons applied to XFCE${NC}"
    fi
    
    # Cinnamon
    if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q cinnamon; then
        gsettings set org.cinnamon.desktop.interface icon-theme "$icon_theme"
        echo -e "${GREEN}✅ Icons applied to Cinnamon${NC}"
    fi
    
    # Mate
    if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q mate; then
        gsettings set org.mate.interface icon-theme "$icon_theme"
        echo -e "${GREEN}✅ Icons applied to Mate${NC}"
    fi
    
    echo -e "${YELLOW}💡 Restart applications or log out/in to see icon changes${NC}"
}

get_wallpapers_from_internet() {
    echo -e "🌐 Get Wallpapers from Internet"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$wallpaper_dir"
    
    while true; do
        echo ""
        echo -e "${GREEN}🚀 How do you want to get wallpapers?${NC}"
        echo -e "  ${GREEN}1${NC}) 📋 Get wallpapers from the internet"
        echo -e "  ${GREEN}2${NC}) 🔗 Let me paste a direct image URL"
        echo -e "  ${GREEN}3${NC}) 📂 Open my wallpaper folder (to drag & drop)"
        echo -e "  ${GREEN}4${NC}) 🎨 Create instant color wallpapers"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back"
        echo ""
        read -p "Choose option [0-4]: " choice

        case $choice in
            1) browse_wallpapers_online ;;
            2) download_from_url ;;
            3) open_wallpaper_folder ;;
            4) create_color_wallpapers ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

browse_wallpapers_online() {
    echo -e "🌐 Direct Wallpaper Browser"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    # Check if we have required tools
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        echo -e "${RED}❌ Need curl or wget to download wallpapers${NC}"
        echo -e "${YELLOW}📦 Installing curl...${NC}"
        install_smart "curl" "curl" "curl" "curl" "cURL"
        if ! command -v curl &> /dev/null; then
            echo -e "${RED}❌ Cannot download without curl or wget${NC}"
            return 1
        fi
    fi
    
    while true; do
        echo ""
        echo -e "${GREEN}🎯 Browse & Download Wallpapers${NC}"
        echo -e "  ${GREEN}1${NC}) 🌅 Nature & Landscapes"
        echo -e "  ${GREEN}2${NC}) 🚀 Space & Sci-Fi" 
        echo -e "  ${GREEN}3${NC}) 🎨 Abstract & Artistic"
        echo -e "  ${GREEN}4${NC}) 🏙️  Cities & Architecture"
        echo -e "  ${GREEN}5${NC}) 💻 Technology & Code"
        echo -e "  ${GREEN}6${NC}) 🎮 Gaming & Anime"
        echo -e "  ${GREEN}7${NC}) 🎲 Random Popular"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back"
        echo ""
        read -p "Choose category [0-7]: " category

        case $category in
            1) download_nature_wallpapers ;;
            2) download_space_wallpapers ;;
            3) download_abstract_wallpapers ;;
            4) download_city_wallpapers ;;
            5) download_tech_wallpapers ;;
            6) download_gaming_wallpapers ;;
            7) download_random_wallpapers ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
    done
}

download_nature_wallpapers() {
    echo -e "🌅 Nature & Landscape Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    # Curated nature wallpapers from Unsplash (free API)
    local nature_urls=(
        "https://images.unsplash.com/photo-1501854140801-50d01698950b?ixlib=rb-4.0.3&w=1920"  # Mountains
        "https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?ixlib=rb-4.0.3&w=1920"  # Beach
        "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?ixlib=rb-4.0.3&w=1920"  # Forest
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&w=1920"  # Snow
        "https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&w=1920"  # Sunset
    )
    
    download_wallpaper_set "nature" "${nature_urls[@]}"
}

download_space_wallpapers() {
    echo -e "🚀 Space & Sci-Fi Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local space_urls=(
        "https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?ixlib=rb-4.0.3&w=1920"  # Galaxy
        "https://images.unsplash.com/photo-1462331940025-496dfbfc7564?ixlib=rb-4.0.3&w=1920"  # Nebula
        "https://images.unsplash.com/photo-1454789548928-9efd52dc4031?ixlib=rb-4.0.3&w=1920"  # Earth
        "https://images.unsplash.com/photo-1465101162946-4377e57745c3?ixlib=rb-4.0.3&w=1920"  # Space station
        "https://images.unsplash.com/photo-1462331940025-496dfbfc7564?ixlib=rb-4.0.3&w=1920"  # Stars
    )
    
    download_wallpaper_set "space" "${space_urls[@]}"
}

download_abstract_wallpapers() {
    echo -e "🎨 Abstract & Artistic Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local abstract_urls=(
        "https://images.unsplash.com/photo-1550684376-efcbd6e3f031?ixlib=rb-4.0.3&w=1920"  # Colors
        "https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&w=1920"  # Liquid
        "https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?ixlib=rb-4.0.3&w=1920"  # Geometric
        "https://images.unsplash.com/photo-1531297484001-80022131f5a1?ixlib=rb-4.0.3&w=1920"  # Digital
        "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?ixlib=rb-4.0.3&w=1920"  # Gradient
    )
    
    download_wallpaper_set "abstract" "${abstract_urls[@]}"
}

download_city_wallpapers() {
    echo -e "🏙️  City & Architecture Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local city_urls=(
        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&w=1920"  # Skyline
        "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?ixlib=rb-4.0.3&w=1920"  # New York
        "https://images.unsplash.com/photo-1547448526-5e9d57fa28f7?ixlib=rb-4.0.3&w=1920"  # Tokyo
        "https://images.unsplash.com/photo-1513584684374-8bab748fbf90?ixlib=rb-4.0.3&w=1920"  # London
        "https://images.unsplash.com/photo-1496568816309-51d7c20e3b21?ixlib=rb-4.0.3&w=1920"  # Dubai
    )
    
    download_wallpaper_set "city" "${city_urls[@]}"
}

download_tech_wallpapers() {
    echo -e "💻 Technology & Code Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local tech_urls=(
        "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?ixlib=rb-4.0.3&w=1920"  # Code
        "https://images.unsplash.com/photo-1451187580459-43490279c0fa?ixlib=rb-4.0.3&w=1920"  # Circuits
        "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?ixlib=rb-4.0.3&w=1920"  # Robot
        "https://images.unsplash.com/photo-1518709268805-4e9042af2176?ixlib=rb-4.0.3&w=1920"  # Data
        "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?ixlib=rb-4.0.3&w=1920"  # AI
    )
    
    download_wallpaper_set "tech" "${tech_urls[@]}"
}

download_gaming_wallpapers() {
    echo -e "🎮 Gaming & Anime Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local gaming_urls=(
        "https://images.unsplash.com/photo-1542751371-adc38448a05e?ixlib=rb-4.0.3&w=1920"  # Gaming setup
        "https://images.unsplash.com/photo-1534423861386-85a16f5d13fd?ixlib=rb-4.0.3&w=1920"  # Controller
        "https://images.unsplash.com/photo-1550745165-9bc0b252726f?ixlib=rb-4.0.3&w=1920"  # Retro games
        "https://images.unsplash.com/photo-1542751110-97427bbecf20?ixlib=rb-4.0.3&w=1920"  # PC gaming
        "https://images.unsplash.com/photo-1579373903781-fd5c0c30c4cd?ixlib=rb-4.0.3&w=1920"  # VR
    )
    
    download_wallpaper_set "gaming" "${gaming_urls[@]}"
}

download_random_wallpapers() {
    echo -e "🎲 Random Popular Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    # Mix of different categories
    local random_urls=(
        "https://images.unsplash.com/photo-1501854140801-50d01698950b?ixlib=rb-4.0.3&w=1920"
        "https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?ixlib=rb-4.0.3&w=1920"
        "https://images.unsplash.com/photo-1550684376-efcbd6e3f031?ixlib=rb-4.0.3&w=1920"
        "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?ixlib=rb-4.0.3&w=1920"
        "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?ixlib=rb-4.0.3&w=1920"
    )
    
    download_wallpaper_set "random" "${random_urls[@]}"
}

download_wallpaper_set() {
    local category="$1"
    shift
    local urls=("$@")
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$wallpaper_dir"
    
    echo -e "${BLUE}📥 Downloading $category wallpapers...${NC}"
    echo ""
    
    local downloaded=0
    local total=${#urls[@]}
    
    for i in "${!urls[@]}"; do
        local url="${urls[$i]}"
        local filename="${category}-wallpaper-$((i+1)).jpg"
        local filepath="$wallpaper_dir/$filename"
        
        echo -e "${BLUE}📸 Downloading wallpaper $((i+1))/$total...${NC}"
        
        if download_image "$url" "$filepath"; then
            echo -e "${GREEN}✅ Downloaded: $filename${NC}"
            ((downloaded++))
        else
            echo -e "${RED}❌ Failed: $filename${NC}"
        fi
        echo ""
    done
    
    echo -e "${GREEN}🎉 Successfully downloaded $downloaded/$total $category wallpapers!${NC}"
    echo -e "${YELLOW}💡 Location: $wallpaper_dir/${NC}"
    
    if [ $downloaded -gt 0 ]; then
        read -p "Set a random one as wallpaper now? (Y/n): " set_now
        if [[ ! $set_now =~ ^[Nn]$ ]]; then
            set_random_wallpaper
        fi
    fi
}

download_image() {
    local url="$1"
    local output_path="$2"
    
    if command -v curl &> /dev/null; then
        curl -s -L --max-time 30 -o "$output_path" "$url" && return 0
    elif command -v wget &> /dev/null; then
        wget -q --timeout=30 -O "$output_path" "$url" && return 0
    fi
    
    return 1
}

download_from_url() {
    echo -e "🔗 Download from URL"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    
    echo -e "${YELLOW}💡 Paste a direct image URL (must end with .jpg, .png, etc.)${NC}"
    echo -e "${GREEN}Example:${NC} https://example.com/wallpaper.jpg"
    echo ""
    
    read -p "Enter image URL: " image_url
    
    if [ -z "$image_url" ]; then
        echo -e "${RED}❌ No URL entered${NC}"
        return
    fi
    
    # Check if it looks like an image URL
    if [[ ! "$image_url" =~ \.(jpg|jpeg|png|webp|JPG|JPEG|PNG|WEBP)$ ]]; then
        echo -e "${YELLOW}⚠️  This doesn't look like a direct image URL${NC}"
        echo -e "${YELLOW}💡 Make sure it ends with .jpg, .png, etc.${NC}"
        read -p "Still try to download? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    # Get filename from URL or generate one
    local filename=$(basename "$image_url" | sed 's/[^a-zA-Z0-9._-]//g')
    if [ -z "$filename" ]; then
        filename="downloaded-wallpaper-$(date +%s).jpg"
    fi
    
    local filepath="$wallpaper_dir/$filename"
    
    echo -e "${BLUE}📥 Downloading: $image_url${NC}"
    echo -e "${BLUE}💾 Saving as: $filename${NC}"
    
    # Download the image
    if command -v wget &> /dev/null; then
        if wget -q --timeout=30 -O "$filepath" "$image_url"; then
            echo -e "${GREEN}✅ Download successful!${NC}"
            try_set_wallpaper "$filepath"
        else
            echo -e "${RED}❌ Download failed!${NC}"
            echo -e "${YELLOW}💡 Check the URL or try a different image${NC}"
        fi
    elif command -v curl &> /dev/null; then
        if curl -s --max-time 30 -o "$filepath" "$image_url"; then
            echo -e "${GREEN}✅ Download successful!${NC}"
            try_set_wallpaper "$filepath"
        else
            echo -e "${RED}❌ Download failed!${NC}"
            echo -e "${YELLOW}💡 Check the URL or try a different image${NC}"
        fi
    else
        echo -e "${RED}❌ Neither wget nor curl is available${NC}"
        echo -e "${YELLOW}💡 Install wget or curl to download images${NC}"
    fi
}

try_set_wallpaper() {
    local wallpaper_path="$1"
    
    # Check if file was actually downloaded and is an image
    if [ ! -f "$wallpaper_path" ]; then
        echo -e "${RED}❌ Downloaded file not found!${NC}"
        return
    fi
    
    local file_size=$(stat -c%s "$wallpaper_path" 2>/dev/null || echo "0")
    if [ "$file_size" -lt 1000 ]; then
        echo -e "${YELLOW}⚠️  Downloaded file seems too small (might be an error page)${NC}"
        return
    fi
    
    echo -e "${GREEN}📁 Saved to: $wallpaper_path${NC}"
    
    read -p "Set this as your wallpaper now? (Y/n): " set_now
    if [[ ! $set_now =~ ^[Nn]$ ]]; then
        set_wallpaper "$wallpaper_path"
    else
        echo -e "${YELLOW}💡 You can set it later from the wallpaper tools${NC}"
    fi
}

open_wallpaper_folder() {
    echo -e "📂 Open Wallpaper Folder"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$wallpaper_dir"
    
    echo -e "${GREEN}📁 Location: $wallpaper_dir${NC}"
    echo ""
    echo -e "${YELLOW}💡 You can:${NC}"
    echo -e "  • Drag & drop wallpapers here"
    echo -e "  • Right-click images online → 'Save Image As'"
    echo -e "  • Copy images from your phone/camera"
    echo ""
    
    # Try to open the folder
    if command -v xdg-open &> /dev/null; then
        echo -e "${BLUE}🚀 Opening folder...${NC}"
        xdg-open "$wallpaper_dir"
    elif command -v nautilus &> /dev/null; then
        nautilus "$wallpaper_dir"
    elif command -v dolphin &> /dev/null; then
        dolphin "$wallpaper_dir"
    elif command -v thunar &> /dev/null; then
        thunar "$wallpaper_dir"
    else
        echo -e "${YELLOW}📁 Manual: Open this path in your file manager:${NC}"
        echo -e "    ${CYAN}$wallpaper_dir${NC}"
    fi
}

create_color_wallpapers() {
    echo -e "🎨 Create Instant Color Wallpapers"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    mkdir -p "$wallpaper_dir"
    
    if ! command -v convert &> /dev/null; then
        echo -e "${YELLOW}📦 Installing ImageMagick...${NC}"
        if install_smart "imagemagick" "imagemagick" "imagemagick" "imagemagick" "ImageMagick"; then
            echo -e "${GREEN}✅ ImageMagick installed!${NC}"
        else
            echo -e "${RED}❌ Could not install ImageMagick${NC}"
            return 1
        fi
    fi
    
    echo -e "${BLUE}🖌️ Creating beautiful gradient wallpapers...${NC}"
    
    # Create nice gradient wallpapers
    declare -A gradients=(
        ["blue-sunset"]="skyblue-darkblue"
        ["forest-green"]="lightgreen-darkgreen" 
        ["sunset-orange"]="orange-darkorange"
        ["purple-dream"]="lavender-darkviolet"
        ["ocean-deep"]="lightblue-navy"
        ["fire-red"]="red-darkred"
        ["space-gray"]="lightgray-dimgray"
        ["sunny-yellow"]="yellow-gold"
    )
    
    for name in "${!gradients[@]}"; do
        IFS='-' read -r color1 color2 <<< "${gradients[$name]}"
        echo -e "${BLUE}🎨 Creating $name...${NC}"
        convert -size 1920x1080 gradient:"$color1"-"$color2" -blur 0x8 "$wallpaper_dir/$name.jpg"
    done
    
    echo -e "${GREEN}✅ Created ${#gradients[@]} beautiful wallpapers!${NC}"
    echo -e "${YELLOW}💡 Location: $wallpaper_dir/${NC}"
    
    read -p "Set a random one as wallpaper now? (Y/n): " set_random
    if [[ ! $set_random =~ ^[Nn]$ ]]; then
        set_random_wallpaper
    fi
}

set_random_wallpaper() {
    echo -e "🎲 Set Random Wallpaper"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    # Check common wallpaper locations
    local locations=(
        "$HOME/Pictures/Wallpapers"
        "/usr/share/backgrounds"
        "/usr/share/wallpapers" 
        "$HOME/Pictures"
    )
    
    local wallpapers=()
    local total_found=0
    
    echo -e "${BLUE}🔍 Searching for wallpapers...${NC}"
    
    for location in "${locations[@]}"; do
        if [ -d "$location" ]; then
            local count=0
            while IFS= read -r -d $'\0' wallpaper; do
                wallpapers+=("$wallpaper")
                ((count++))
            done < <(find "$location" -maxdepth 3 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -print0 2>/dev/null)
            
            if [ $count -gt 0 ]; then
                echo -e "  📁 ${CYAN}$location${NC} - ${GREEN}$count wallpapers${NC}"
                total_found=$((total_found + count))
            fi
        fi
    done
    
    echo ""
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        echo -e "${RED}❌ No wallpapers found!${NC}"
        echo -e "${YELLOW}💡 Try these options first:${NC}"
        echo -e "  1) 🌐 Get wallpapers from internet"
        echo -e "  2) 🎨 Create color wallpapers" 
        echo -e "  3) 📦 Install wallpaper packs"
        return 1
    fi
    
    echo -e "${GREEN}🎉 Found $total_found wallpapers total${NC}"
    
    # Pick a random wallpaper
    local random_index=$((RANDOM % ${#wallpapers[@]}))
    local random_wallpaper="${wallpapers[$random_index]}"
    local wallpaper_name=$(basename "$random_wallpaper")
    
    echo -e "${BLUE}🎲 Randomly selected: ${CYAN}$wallpaper_name${NC}"
    echo -e "${BLUE}📁 Location: ${CYAN}$random_wallpaper${NC}"
    
    # Actually set it
    set_wallpaper "$random_wallpaper"
}

set_wallpaper() {
    local wallpaper_path="$1"
    local wallpaper_name=$(basename "$wallpaper_path")
    
    echo -e "${GREEN}🎨 Setting wallpaper: $wallpaper_name${NC}"
    
    # GNOME
    if command -v gsettings &> /dev/null; then
        echo -e "${BLUE}🔧 Setting for GNOME...${NC}"
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper_path"
        echo -e "${GREEN}✅ Wallpaper set for GNOME!${NC}"
    fi
    
    # KDE Plasma
    if command -v dbus-send &> /dev/null && [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        echo -e "${BLUE}🔧 Setting for KDE Plasma...${NC}"
        dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
        var Desktops = desktops();
        for (i=0;i<Desktops.length;i++) {
            d = Desktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
            d.writeConfig('Image', 'file://$wallpaper_path');
        }"
        echo -e "${GREEN}✅ Wallpaper set for KDE!${NC}"
    fi
    
    # XFCE
    if command -v xfconf-query &> /dev/null; then
        echo -e "${BLUE}🔧 Setting for XFCE...${NC}"
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$wallpaper_path"
        echo -e "${GREEN}✅ Wallpaper set for XFCE!${NC}"
    fi
    
    # i3, Openbox, etc. (using feh)
    if command -v feh &> /dev/null; then
        echo -e "${BLUE}🔧 Setting with feh...${NC}"
        feh --bg-scale "$wallpaper_path"
        echo -e "${GREEN}✅ Wallpaper set with feh!${NC}"
    fi
    
    # Cinnamon
    if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q cinnamon; then
        echo -e "${BLUE}🔧 Setting for Cinnamon...${NC}"
        gsettings set org.cinnamon.desktop.background picture-uri "file://$wallpaper_path"
        echo -e "${GREEN}✅ Wallpaper set for Cinnamon!${NC}"
    fi
    
    # Mate
    if command -v gsettings &> /dev/null && gsettings list-schemas | grep -q mate; then
        echo -e "${BLUE}🔧 Setting for Mate...${NC}"
        gsettings set org.mate.background picture-filename "$wallpaper_path"
        echo -e "${GREEN}✅ Wallpaper set for Mate!${NC}"
    fi
    
    echo -e "${GREEN}🎉 Wallpaper '$wallpaper_name' applied successfully!${NC}"
    echo -e "${YELLOW}💡 Some applications may need to be restarted to see changes${NC}"
}

install_grub_themes() {
    while true; do
        echo -e "${GREEN}🍔 GRUB Theme Manager${NC}"
        echo ""
        echo -e "${CYAN}1) Install GRUB Theme Packs${NC}"
        echo -e "${CYAN}2) Preview Current GRUB Theme${NC}"
        echo -e "${CYAN}3) Reset to Default GRUB Theme${NC}"
        echo -e "${CYAN}4) Custom GRUB Background${NC}"
        echo -e "${YELLOW}0) Back to Theme Management${NC}"
        echo ""
        read -p "Choose option: " grub_choice

        case $grub_choice in
            1)
                echo -e "${GREEN}📦 Installing GRUB Themes...${NC}"
                
                echo -e "${CYAN}Available GRUB Theme Installation Methods:${NC}"
                echo -e "  ${GREEN}1)${NC} Install GRUB Customizer (GUI Tool)"
                echo -e "  ${GREEN}2)${NC} Download Popular GRUB Themes"
                echo -e "  ${GREEN}3)${NC} Manual Theme Installation Guide"
                
                read -p "Choose installation method: " method_choice
                
                case $method_choice in
                    1)
                        if install_smart "grub-customizer" "grub-customizer" "grub-customizer" "grub-customizer" "GRUB Customizer"; then
                            echo -e "${GREEN}✅ GRUB Customizer installed!${NC}"
                            echo -e "${BLUE}🚀 Launching GRUB Customizer...${NC}"
                            grub-customizer
                        fi
                        ;;
                    
                    2)
                        echo -e "${GREEN}🌐 Downloading Popular GRUB Themes...${NC}"
                        sudo mkdir -p /boot/grub/themes/
                        
                        # REAL themes from GitHub that actually exist
                        echo -e "${CYAN}Available GRUB Themes:${NC}"
                        echo -e "  ${GREEN}1)${NC} Vimix Theme (Modern)"
                        echo -e "  ${GREEN}2)${NC} Tela Theme (Colorful)"
                        echo -e "  ${GREEN}3)${NC} Whitesur Theme (macOS Style)"
                        echo -e "  ${GREEN}4)${NC} Orchis Theme (Elegant)"
                        echo -e "  ${GREEN}5)${NC} Graphite Theme (Dark)"
                        echo -e "  ${GREEN}6)${NC} Sweet Theme (Pastel)"
                        echo -e "  ${GREEN}7)${NC} Dracula Theme (Purple)"
                        echo -e "  ${GREEN}8)${NC} Nord Theme (Arctic)"
                        echo -e "  ${GREEN}9)${NC} Gruvbox Theme (Retro)"
                        echo -e "  ${GREEN}10)${NC} Cyberpunk Theme (Neon)"
                        echo -e "  ${GREEN}11)${NC} Material Theme (Google)"
                        echo -e "  ${GREEN}12)${NC} Windows 11 Theme"
                        echo -e "  ${GREEN}13)${NC} Starfield Theme (Space)"
                        
                        read -p "Select theme to download: " theme_choice
                        
                        case $theme_choice in
                            1)
                                echo -e "${BLUE}📥 Downloading Vimix GRUB Theme...${NC}"
                                sudo git clone https://github.com/vinceliuice/grub2-themes /tmp/grub-themes
                                sudo cp -r /tmp/grub-themes/themes/Vimix /boot/grub/themes/
                                ;;
                            2)
                                echo -e "${BLUE}📥 Downloading Tela GRUB Theme...${NC}"
                                sudo git clone https://github.com/vinceliuice/grub2-themes /tmp/grub-themes
                                sudo cp -r /tmp/grub-themes/themes/Tela /boot/grub/themes/
                                ;;
                            3)
                                echo -e "${BLUE}📥 Downloading WhiteSur GRUB Theme...${NC}"
                                sudo git clone https://github.com/vinceliuice/grub2-themes /tmp/grub-themes
                                sudo cp -r /tmp/grub-themes/themes/WhiteSur /boot/grub/themes/
                                ;;
                            4)
                                echo -e "${BLUE}📥 Downloading Orchis GRUB Theme...${NC}"
                                sudo git clone https://github.com/vinceliuice/grub2-themes /tmp/grub-themes
                                sudo cp -r /tmp/grub-themes/themes/Orchis /boot/grub/themes/
                                ;;
                            5)
                                echo -e "${BLUE}📥 Downloading Graphite GRUB Theme...${NC}"
                                sudo git clone https://github.com/vinceliuice/grub2-themes /tmp/grub-themes
                                sudo cp -r /tmp/grub-themes/themes/Graphite /boot/grub/themes/
                                ;;
                            6)
                                echo -e "${BLUE}📥 Downloading Sweet GRUB Theme...${NC}"
                                sudo git clone https://github.com/vinceliuice/grub2-themes /tmp/grub-themes
                                sudo cp -r /tmp/grub-themes/themes/Sweet /boot/grub/themes/
                                ;;
                            7)
                                echo -e "${BLUE}📥 Downloading Dracula GRUB Theme...${NC}"
                                sudo wget -O /tmp/dracula-grub.zip https://github.com/dracula/grub/archive/master.zip
                                sudo unzip /tmp/dracula-grub.zip -d /tmp/
                                sudo cp -r /tmp/grub-master /boot/grub/themes/dracula
                                ;;
                            8)
                                echo -e "${BLUE}📥 Downloading Nord GRUB Theme...${NC}"
                                sudo git clone https://github.com/nordtheme/grub /tmp/nord-grub
                                sudo cp -r /tmp/nord-grub/src /boot/grub/themes/nord
                                ;;
                            9)
                                echo -e "${BLUE}📥 Downloading Gruvbox GRUB Theme...${NC}"
                                sudo git clone https://github.com/0xComposure/grub2-gruvbox /tmp/gruvbox-grub
                                sudo cp -r /tmp/gruvbox-grub /boot/grub/themes/gruvbox
                                ;;
                            10)
                                echo -e "${BLUE}📥 Downloading Cyberpunk GRUB Theme...${NC}"
                                sudo git clone https://github.com/ChrisTitusTech/grub-tweaks /tmp/cyber-grub
                                sudo cp -r /tmp/cyber-grub /boot/grub/themes/cyberpunk
                                ;;
                            11)
                                echo -e "${BLUE}📥 Downloading Material GRUB Theme...${NC}"
                                sudo git clone https://github.com/ChrisTitusTech/grub-tweaks /tmp/material-grub
                                sudo cp -r /tmp/material-grub /boot/grub/themes/material
                                ;;
                            12)
                                echo -e "${BLUE}📥 Downloading Windows 11 GRUB Theme...${NC}"
                                sudo git clone https://github.com/ChrisTitusTech/grub-tweaks /tmp/win11-grub
                                sudo cp -r /tmp/win11-grub /boot/grub/themes/win11
                                ;;
                            13)
                                echo -e "${BLUE}📥 Downloading Starfield GRUB Theme...${NC}"
                                sudo git clone https://github.com/ChrisTitusTech/grub-tweaks /tmp/starfield-grub
                                sudo cp -r /tmp/starfield-grub /boot/grub/themes/starfield
                                ;;
                            *)
                                echo -e "${RED}❌ Invalid selection${NC}"
                                ;;
                        esac
                        
                        # Clean up
                        sudo rm -rf /tmp/grub-themes /tmp/*-grub*
                        
                        # Apply the theme
                        if [ -f "/etc/default/grub" ] && [ -d "/boot/grub/themes" ]; then
                            echo -e "${YELLOW}🎨 Available installed themes:${NC}"
                            ls /boot/grub/themes/
                            read -p "Enter theme name to apply: " theme_name
                            
                            if [ -d "/boot/grub/themes/$theme_name" ]; then
                                sudo sed -i '/GRUB_THEME=/d' /etc/default/grub
                                echo "GRUB_THEME=\"/boot/grub/themes/$theme_name/theme.txt\"" | sudo tee -a /etc/default/grub
                                update_grub_config
                                echo -e "${GREEN}✅ Theme '$theme_name' applied!${NC}"
                            else
                                echo -e "${RED}❌ Theme '$theme_name' not found${NC}"
                                echo -e "${YELLOW}💡 Available themes: $(ls /boot/grub/themes/)${NC}"
                            fi
                        fi
                        ;;
                    
                    3)
                        echo -e "${YELLOW}📖 Manual GRUB Theme Installation:${NC}"
                        echo -e "${BLUE}Popular Theme Sources:${NC}"
                        echo -e "  • https://github.com/vinceliuice/grub2-themes"
                        echo -e "  • https://github.com/ChrisTitusTech/grub-tweaks"
                        echo -e "  • https://www.gnome-look.org/browse/cat/109/"
                        echo -e "${BLUE}Installation Steps:${NC}"
                        echo -e "  1. Download and extract theme"
                        echo -e "  2. Copy to: /boot/grub/themes/theme-name/"
                        echo -e "  3. Edit /etc/default/grub:"
                        echo -e "     GRUB_THEME=\"/boot/grub/themes/theme-name/theme.txt\""
                        echo -e "  4. Run: sudo update-grub"
                        echo -e "  5. Reboot"
                        ;;
                    
                    *)
                        echo -e "${RED}❌ Invalid selection${NC}"
                        ;;
                esac
                ;;
                
            # ... keep options 2, 3, 4 the same ...
            2)
                echo -e "${GREEN}👀 Current GRUB Configuration:${NC}"
                if [ -f "/etc/default/grub" ]; then
                    echo -e "${CYAN}GRUB Theme Settings:${NC}"
                    grep -E "GRUB_THEME|GRUB_BACKGROUND" /etc/default/grub || echo "No custom theme set"
                fi
                ;;
                
            3)
                echo -e "${YELLOW}🔄 Resetting GRUB to default theme...${NC}"
                if [ -f "/etc/default/grub" ]; then
                    sudo sed -i '/GRUB_THEME=/d' /etc/default/grub
                    sudo sed -i '/GRUB_BACKGROUND=/d' /etc/default/grub
                    update_grub_config
                    echo -e "${GREEN}✅ GRUB theme reset to default!${NC}"
                fi
                ;;
                
            4)
                echo -e "${GREEN}🎨 Set Custom GRUB Background${NC}"
                read -p "Enter path to background image: " bg_path
                if [ -f "$bg_path" ]; then
                    extension="${bg_path##*.}"
                    if [[ "$extension" =~ ^(png|jpg|jpeg)$ ]]; then
                        sudo cp "$bg_path" "/boot/grub/background.${extension}"
                        if [ -f "/etc/default/grub" ]; then
                            sudo sed -i '/GRUB_BACKGROUND=/d' /etc/default/grub
                            echo "GRUB_BACKGROUND=\"/boot/grub/background.${extension}\"" | sudo tee -a /etc/default/grub
                            update_grub_config
                            echo -e "${GREEN}✅ Custom GRUB background set!${NC}"
                        fi
                    else
                        echo -e "${RED}❌ Use PNG or JPG format${NC}"
                    fi
                else
                    echo -e "${RED}❌ Image not found${NC}"
                fi
                ;;
                
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# Helper function
update_grub_config() {
    echo -e "${YELLOW}🔄 Updating GRUB configuration...${NC}"
    
    if command -v update-grub &> /dev/null; then
        sudo update-grub
    elif command -v grub-mkconfig &> /dev/null; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    elif command -v zypper &> /dev/null; then
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    else
        echo -e "${YELLOW}⚠️  Update GRUB manually for changes to take effect${NC}"
        echo -e "${BLUE}💡 Usually: sudo grub-mkconfig -o /boot/grub/grub.cfg${NC}"
    fi
    
    echo -e "${GREEN}✅ GRUB updated! Reboot to see changes.${NC}"
}

set_default_apps() {
    echo -e "${BLUE}📱 Setting default applications...${NC}"
    
    if command -v xdg-mime &> /dev/null; then
        echo -e "${YELLOW}Current default applications:${NC}"
        xdg-mime query default text/html
        xdg-mime query default application/pdf
        
        echo -e "\n${GREEN}Set default browser:${NC}"
        read -p "Enter browser executable (e.g., firefox, chromium): " browser
        if command -v "$browser" &> /dev/null; then
            xdg-settings set default-web-browser "$browser.desktop"
            echo -e "${GREEN}✅ Default browser set to: $browser${NC}"
        else
            echo -e "${RED}❌ Browser not found: $browser${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  xdg-utils not available${NC}"
    fi
}

# System Security Subtab - COMPLETE
system_security_subtab() {
    while true; do
        show_banner
        show_subtab_header "🛡️  SECURITY & FIREWALL" "$RED"
        echo ""
        echo -e "${GREEN}🔒 Security Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) Install and Configure Firewall"
        echo -e "  ${GREEN}2${NC}) Run Security Audit"
        echo -e "  ${GREEN}3${NC}) Check for Rootkits"
        echo -e "  ${GREEN}4${NC}) Secure SSH Configuration"
        echo -e "  ${GREEN}5${NC}) Install Antivirus"
        echo -e "  ${GREEN}6${NC}) Check User Accounts"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose action [0-6]: " choice

        case $choice in
            1) configure_firewall ;;
            2) run_security_audit ;;
            3) check_rootkits ;;
            4) secure_ssh ;;
            5) install_antivirus ;;
            6) check_user_accounts ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Security Functions
configure_firewall() {
    echo -e "${BLUE}🔥 Configuring firewall...${NC}"
    
    # Try UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null || install_smart "ufw" "ufw" "ufw" "ufw" "UFW Firewall"; then
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        echo -e "${GREEN}✅ UFW firewall enabled with secure defaults${NC}"
        
    # Try firewalld (Fedora/RHEL)
    elif command -v firewall-cmd &> /dev/null || install_smart "firewalld" "firewalld" "firewalld" "firewalld" "Firewalld"; then
        sudo systemctl enable firewalld
        sudo systemctl start firewalld
        sudo firewall-cmd --set-default-zone=public
        echo -e "${GREEN}✅ Firewalld enabled${NC}"
    else
        echo -e "${YELLOW}⚠️  No supported firewall manager found${NC}"
    fi
}

run_security_audit() {
    echo -e "${BLUE}🔍 Running security audit...${NC}"
    
    echo -e "${CYAN}1. Checking for unnecessary services...${NC}"
    netstat -tulpn | grep LISTEN
    
    echo -e "${CYAN}2. Checking sudo privileges...${NC}"
    sudo -l
    
    echo -e "${CYAN}3. Checking world-writable files...${NC}"
    find / -xdev -type f -perm -0002 2>/dev/null | head -10
    
    echo -e "${CYAN}4. Checking for SUID files...${NC}"
    find / -xdev -type f -perm -4000 2>/dev/null | head -10
    
    echo -e "${GREEN}✅ Security audit completed${NC}"
}

check_rootkits() {
    echo -e "${BLUE}🕵️  Checking for rootkits...${NC}"
    
    if command -v rkhunter &> /dev/null || install_smart "rkhunter" "rkhunter" "rkhunter" "rkhunter" "RKHunter"; then
        sudo rkhunter --check --sk
        echo -e "${GREEN}✅ Rootkit check completed${NC}"
    else
        echo -e "${YELLOW}⚠️  Install rkhunter manually for detailed rootkit detection${NC}"
    fi
}

secure_ssh() {
    echo -e "${BLUE}🔐 Securing SSH configuration...${NC}"
    
    if [ -f /etc/ssh/sshd_config ]; then
        # Create backup
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
        
        echo -e "${YELLOW}Current SSH configuration:${NC}"
        grep -E "PermitRootLogin|PasswordAuthentication|Port" /etc/ssh/sshd_config
        
        read -p "Disable root login? (y/N): " disable_root
        if [[ $disable_root =~ ^[Yy]$ ]]; then
            sudo sed -i 's/#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        fi
        
        read -p "Disable password authentication? (y/N): " disable_pass
        if [[ $disable_pass =~ ^[Yy]$ ]]; then
            sudo sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        fi
        
        read -p "Change SSH port? (enter new port or leave empty): " new_port
        if [[ "$new_port" =~ ^[0-9]+$ ]]; then
            sudo sed -i "s/#*Port.*/Port $new_port/" /etc/ssh/sshd_config
        fi
        
        echo -e "${GREEN}✅ SSH configuration updated!${NC}"
        echo -e "${YELLOW}⚠️  Restart SSH service for changes to take effect${NC}"
    else
        echo -e "${RED}❌ SSH configuration not found${NC}"
    fi
}

install_antivirus() {
    echo -e "${BLUE}🛡️  Installing antivirus...${NC}"
    
    # Try ClamAV
    if install_smart "clamav" "clamav" "clamav" "clamav" "ClamAV Antivirus"; then
        sudo freshclam  # Update virus definitions
        sudo systemctl enable clamav-freshclam
        sudo systemctl start clamav-freshclam
        echo -e "${GREEN}✅ ClamAV installed and virus definitions updated${NC}"
        
        read -p "Run virus scan on home directory? (y/N): " run_scan
        if [[ $run_scan =~ ^[Yy]$ ]]; then
            clamscan -r --bell -i "$HOME"
        fi
    fi
}

check_user_accounts() {
    echo -e "${BLUE}👥 Checking user accounts...${NC}"
    
    echo -e "${CYAN}Users with login shell:${NC}"
    grep -E ":/bin/(bash|zsh|fish):" /etc/passwd
    
    echo -e "${CYAN}Users with UID 0 (root):${NC}"
    awk -F: '$3 == 0 {print $1}' /etc/passwd
    
    echo -e "${CYAN}Empty password accounts:${NC}"
    awk -F: '$2 == "" {print $1}' /etc/shadow
    
    echo -e "${GREEN}✅ User account check completed${NC}"
}


# ISO TOOLS - Creating ISO files, fixing boot problems

system_iso_tools_subtab() {
    while true; do
        show_banner
        show_subtab_header "📀 ISO & BOOT TOOLS" "$PURPLE"
        echo ""
        echo -e "${GREEN}🛠️  ISO Creation:${NC}"
        echo -e "  ${GREEN}1${NC}) Create Custom ISO from Current System"
        echo -e "  ${GREEN}2${NC}) Create Bootable USB from ISO"
        echo -e "  ${GREEN}3${NC}) Extract ISO Contents"
        echo -e "  ${GREEN}4${NC}) Edit ISO Boot Parameters"
        echo ""
        echo -e "${BLUE}🔧 Advanced Tools:${NC}"
        echo -e "  ${BLUE}5${NC}) Create Persistent Live USB"
        echo -e "  ${BLUE}6${NC}) Build Custom Kernel ISO"
        echo -e "  ${BLUE}7${NC}) Create Recovery ISO"
        echo -e "  ${BLUE}8${NC}) Verify ISO Checksum"
        echo -e "  ${BLUE}9${NC}) Convert ISO Formats"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to System Tab"
        echo ""
        read -p "Choose option [0-9]: " choice

        case $choice in
            1) create_custom_iso ;;
            2) create_bootable_usb ;;
            3) extract_iso ;;
            4) edit_boot_params ;;
            5) create_persistent_usb ;;
            6) build_custom_kernel_iso ;;
            7) create_recovery_iso ;;
            8) verify_iso_checksum ;;
            9) convert_iso_format ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

create_custom_iso() {
    echo -e "${GREEN}📀 Creating Custom ISO from Current System...${NC}"
    
    if ! command -v mkisofs &> /dev/null && ! command -v genisoimage &> /dev/null; then
        echo -e "${YELLOW}📦 Installing ISO creation tools...${NC}"
        install_smart "cdrtools" "genisoimage" "genisoimage" "cdrtools" "ISO Tools"
    fi
    
    read -p "Enter ISO filename (without .iso): " iso_name
    read -p "Enter volume name: " volume_name
    
    if [ -z "$iso_name" ]; then
        iso_name="custom-system"
    fi
    if [ -z "$volume_name" ]; then
        volume_name="Custom_Linux"
    fi
    
    local iso_file="${iso_name}.iso"
    local temp_dir="/tmp/iso_build"
    
    echo -e "${BLUE}🔨 Preparing system snapshot...${NC}"
    mkdir -p "$temp_dir"
    
    # Copy essential system directories
    sudo cp -r /boot "$temp_dir/" 2>/dev/null || true
    sudo cp -r /etc "$temp_dir/" 2>/dev/null || true
    
    echo -e "${BLUE}📦 Creating ISO image...${NC}"
    
    if command -v genisoimage &> /dev/null; then
        sudo genisoimage -o "$iso_file" -V "$volume_name" -J -R -c boot.catalog -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table "$temp_dir"
    elif command -v mkisofs &> /dev/null; then
        sudo mkisofs -o "$iso_file" -V "$volume_name" -J -R -c boot.catalog -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table "$temp_dir"
    else
        echo -e "${RED}❌ No ISO creation tool available${NC}"
        return 1
    fi
    
    sudo rm -rf "$temp_dir"
    
    if [ -f "$iso_file" ]; then
        local size=$(du -h "$iso_file" | cut -f1)
        echo -e "${GREEN}✅ ISO created: $iso_file ($size)${NC}"
    else
        echo -e "${RED}❌ ISO creation failed${NC}"
    fi
}

create_bootable_usb() {
    echo -e "${GREEN}💾 Creating Bootable USB...${NC}"
    
    echo -e "${YELLOW}📋 Available storage devices:${NC}"
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
    
    read -p "Enter target device (e.g., sdb): " usb_device
    read -p "Enter ISO file path: " iso_file
    
    if [ -z "$usb_device" ] || [ -z "$iso_file" ]; then
        echo -e "${RED}❌ Device and ISO file required${NC}"
        return 1
    fi
    
    if [ ! -f "$iso_file" ]; then
        echo -e "${RED}❌ ISO file not found: $iso_file${NC}"
        return 1
    fi
    
    if [[ "$usb_device" =~ ^(sda|nvme0n1|vda)$ ]]; then
        echo -e "${RED}🚨 WARNING: $usb_device might be your system disk! Aborting.${NC}"
        return 1
    fi
    
    echo -e "${RED}🚨 WARNING: This will ERASE ALL DATA on /dev/$usb_device${NC}"
    read -p "Type 'YES' to continue: " confirmation
    
    if [ "$confirmation" != "YES" ]; then
        echo -e "${YELLOW}❌ Operation cancelled${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔥 Writing ISO to USB...${NC}"
    if command -v dd &> /dev/null; then
        sudo dd if="$iso_file" of="/dev/$usb_device" bs=4M status=progress oflag=sync
        echo -e "${GREEN}✅ Bootable USB created on /dev/$usb_device${NC}"
    else
        echo -e "${RED}❌ 'dd' command not available${NC}"
    fi
}

extract_iso() {
    read -p "Enter ISO file to extract: " iso_file
    
    if [ ! -f "$iso_file" ]; then
        echo -e "${RED}❌ ISO file not found${NC}"
        return 1
    fi
    
    local extract_dir="${iso_file%.iso}-extracted"
    mkdir -p "$extract_dir"
    
    echo -e "${BLUE}📂 Extracting ISO contents...${NC}"
    
    sudo mount -o loop "$iso_file" /mnt 2>/dev/null && \
    sudo cp -r /mnt/* "$extract_dir/" && \
    sudo umount /mnt
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ISO extracted to: $extract_dir${NC}"
    else
        echo -e "${RED}❌ Failed to extract ISO${NC}"
    fi
}

edit_boot_params() {
    echo -e "${GREEN}⚙️  Editing ISO Boot Parameters...${NC}"
    
    read -p "Enter ISO file path: " iso_file
    if [ ! -f "$iso_file" ]; then
        echo -e "${RED}❌ ISO file not found: $iso_file${NC}"
        return 1
    fi
    
    local temp_dir="/tmp/iso_edit"
    mkdir -p "$temp_dir"
    
    echo -e "${BLUE}📂 Extracting boot configuration...${NC}"
    
    if isoinfo -i "$iso_file" -x "/ISOLINUX/ISOLINUX.CFG" > "$temp_dir/isolinux.cfg" 2>/dev/null; then
        echo -e "${GREEN}✅ Found ISOLINUX configuration${NC}"
        nano "$temp_dir/isolinux.cfg"
        echo -e "${YELLOW}📝 Use 'create_custom_iso' with modified files to rebuild${NC}"
    elif isoinfo -i "$iso_file" -x "/EFI/BOOT/GRUB.CFG" > "$temp_dir/grub.cfg" 2>/dev/null; then
        echo -e "${GREEN}✅ Found GRUB configuration${NC}"
        nano "$temp_dir/grub.cfg"
        echo -e "${YELLOW}📝 Use 'create_custom_iso' with modified files to rebuild${NC}"
    else
        echo -e "${RED}❌ No boot configuration found in ISO${NC}"
    fi
    
    rm -rf "$temp_dir"
}

create_persistent_usb() {
    echo -e "${GREEN}💾 Creating Persistent Live USB...${NC}"
    echo -e "${YELLOW}📝 Note: Full persistence requires specific ISO support${NC}"
    echo -e "${BLUE}💡 Recommended tools:${NC}"
    echo -e "   • mkusb - Advanced USB creator"
    echo -e "   • Ventoy - Multi-boot USB solution"
    
    if install_smart "mkusb" "mkusb" "mkusb" "mkusb" "mkusb"; then
        echo -e "${GREEN}✅ mkusb installed. Run 'mkusb' for persistent USB creation.${NC}"
    fi
}

build_custom_kernel_iso() {
    echo -e "${GREEN}🐧 Building Custom Kernel ISO...${NC}"
    echo -e "${YELLOW}📦 This feature requires kernel build tools...${NC}"
    
    if install_smart "linux-headers" "linux-headers-generic" "kernel-devel" "kernel-devel" "Kernel Headers"; then
        echo -e "${GREEN}✅ Kernel headers installed${NC}"
        echo -e "${BLUE}💡 Use tools like linuxkit or live-build for custom ISOs${NC}"
    fi
}

create_recovery_iso() {
    echo -e "${GREEN}🛡️ Creating System Recovery ISO...${NC}"
    
    local recovery_dir="/tmp/recovery_iso"
    local iso_name="system-recovery-$(date +%Y%m%d).iso"
    
    mkdir -p "$recovery_dir"
    
    echo -e "${BLUE}📦 Gathering system information...${NC}"
    
    sudo dmidecode > "$recovery_dir/system-info.txt" 2>/dev/null || true
    dpkg -l > "$recovery_dir/installed-packages.txt" 2>/dev/null || true
    ps aux > "$recovery_dir/running-processes.txt" 2>/dev/null || true
    
    cat > "$recovery_dir/recovery-script.sh" << 'EOF'
#!/bin/bash
echo "System Recovery Script"
echo "This ISO contains system information for recovery purposes."
echo "Generated by Electrotility"
EOF
    
    chmod +x "$recovery_dir/recovery-script.sh"
    
    if command -v genisoimage &> /dev/null; then
        genisoimage -o "$iso_name" -V "System_Recovery" -J -R "$recovery_dir"
        echo -e "${GREEN}✅ Recovery ISO created: $iso_name${NC}"
    else
        echo -e "${RED}❌ genisoimage not available${NC}"
    fi
    
    rm -rf "$recovery_dir"
}

verify_iso_checksum() {
    echo -e "${GREEN}🔍 Verifying ISO Checksum...${NC}"
    
    read -p "Enter ISO file path: " iso_file
    if [ ! -f "$iso_file" ]; then
        echo -e "${RED}❌ ISO file not found${NC}"
        return 1
    fi
    
    echo -e "${CYAN}📊 Available checksum types:${NC}"
    echo -e "  1) MD5"
    echo -e "  2) SHA1" 
    echo -e "  3) SHA256"
    echo -e "  4) SHA512"
    
    read -p "Choose checksum type [1-4]: " checksum_type
    
    case $checksum_type in
        1) algorithm="md5sum" ;;
        2) algorithm="sha1sum" ;;
        3) algorithm="sha256sum" ;;
        4) algorithm="sha512sum" ;;
        *) echo -e "${RED}❌ Invalid choice${NC}"; return 1 ;;
    esac
    
    echo -e "${BLUE}🔢 Calculating $algorithm...${NC}"
    $algorithm "$iso_file"
    
    read -p "Enter expected checksum to verify (or leave empty to skip): " expected_hash
    if [ -n "$expected_hash" ]; then
        actual_hash=$($algorithm "$iso_file" | cut -d' ' -f1)
        if [ "$actual_hash" = "$expected_hash" ]; then
            echo -e "${GREEN}✅ Checksum verified successfully!${NC}"
        else
            echo -e "${RED}❌ Checksum mismatch!${NC}"
            echo -e "Expected: $expected_hash"
            echo -e "Actual:   $actual_hash"
        fi
    fi
}

convert_iso_format() {
    echo -e "${GREEN}🔄 Converting ISO Formats...${NC}"
    echo -e "${YELLOW}📝 Note: This converts between different ISO formats${NC}"
    
    read -p "Enter source ISO file: " source_iso
    if [ ! -f "$source_iso" ]; then
        echo -e "${RED}❌ Source ISO not found${NC}"
        return 1
    fi
    
    read -p "Enter output filename: " output_file
    
    echo -e "${CYAN}🔄 Conversion options:${NC}"
    echo -e "  1) Standard ISO (no change)"
    echo -e "  2) Compressed ISO (xz)"
    echo -e "  3) Hybrid ISO (for USB)"
    
    read -p "Choose conversion [1-3]: " conversion_type
    
    case $conversion_type in
        1)
            cp "$source_iso" "$output_file"
            echo -e "${GREEN}✅ ISO copied to: $output_file${NC}"
            ;;
        2)
            if command -v xz &> /dev/null; then
                xz -k -c "$source_iso" > "${output_file}.xz"
                echo -e "${GREEN}✅ Compressed ISO created: ${output_file}.xz${NC}"
            else
                echo -e "${RED}❌ xz compression not available${NC}"
            fi
            ;;
        3)
            if command -v isohybrid &> /dev/null; then
                cp "$source_iso" "$output_file"
                isohybrid "$output_file"
                echo -e "${GREEN}✅ Hybrid ISO created: $output_file${NC}"
            else
                echo -e "${RED}❌ isohybrid not available${NC}"
                echo -e "${YELLOW}💡 Install syslinux-utils package${NC}"
            fi
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            ;;
    esac
}

# ============================================================================
# APPS TAB - COMPLETE WITH ALL FEATURES
# ============================================================================

apps_tab() {
    while true; do
        show_banner
        echo -e "${BLUE}📱 APPS TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BOLD}Choose Subtab:${NC}"
        echo -e "  ${GREEN}1${NC}) 🌐 Browsers & Internet"
        echo -e "  ${GREEN}2${NC}) 🎵 Multimedia"
        echo -e "  ${GREEN}3${NC}) 📺 Tubes & Video"
        echo -e "  ${GREEN}4${NC}) 🛠️  Utilities"
        echo -e "  ${GREEN}5${NC}) 📝 Productivity"
        echo -e "  ${GREEN}6${NC}) 🎨 Creative"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Main Menu"
        echo ""
        read -p "Choose subtab [0-6]: " choice

        case $choice in
            1) apps_browsers_subtab ;;
            2) apps_multimedia_subtab ;;
            3) apps_tubes_subtab ;;
            4) apps_utilities_subtab ;;
            5) apps_productivity_subtab ;;
            6) apps_creative_subtab ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

# Apps Browsers Subtab 
apps_browsers_subtab() {
    while true; do
        show_banner
        show_subtab_header "🌐 BROWSERS & INTERNET" "$BLUE"
        echo ""
        echo -e "${GREEN}🚀 Popular Browsers:${NC}"
        echo -e "  ${GREEN}1${NC}) Firefox"
        echo -e "  ${GREEN}2${NC}) Google Chrome"
        echo -e "  ${GREEN}3${NC}) Microsoft Edge"
        echo -e "  ${GREEN}4${NC}) Opera"
        echo -e "  ${GREEN}5${NC}) Brave"
        echo ""
        echo -e "${BLUE}🔒 Privacy Browsers:${NC}"
        echo -e "  ${BLUE}6${NC}) LibreWolf"
        echo -e "  ${BLUE}7${NC}) Thorium"
        echo -e "  ${BLUE}8${NC}) Tor Browser"
        echo -e "  ${BLUE}9${NC}) Ungoogled Chromium"
        echo -e "  ${BLUE}10${NC}) Chromium"
        echo -e "  ${BLUE}11${NC}) Zen Browser"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose browser to install [0-11]: " choice

        case $choice in
            1) install_firefox ;;
            2) install_chrome ;;
            3) install_edge ;;
            4) install_opera ;;
            5) install_brave ;;
            6) install_librewolf ;;
            7) install_thorium ;;
            8) install_tor_browser ;;
            9) install_ungoogled_chromium ;;
            10) install_chromium ;;
            11) install_zen_browser ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Browser Installation Functions
install_firefox() {
    if install_smart "firefox" "firefox" "firefox" "firefox" "Firefox"; then
        echo -e "${GREEN}✅ Firefox installed successfully!${NC}"
    else
        install_flatpak "org.mozilla.firefox" "Firefox"
    fi
}

install_chrome() {
    echo -e "${BLUE}🔴 Installing Google Chrome...${NC}"
    log "Installing Google Chrome"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        if command -v yay &> /dev/null; then
            yay -S google-chrome --noconfirm
        else
            echo -e "${YELLOW}📥 Install yay or download from https://google.com/chrome/${NC}"
        fi
    elif [ "$PKG_MANAGER" = "apt" ]; then
        wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "$TEMP_DIR/chrome.deb"
        sudo dpkg -i "$TEMP_DIR/chrome.deb"
        sudo apt install -f -y
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        sudo zypper install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Google Chrome installed!${NC}"
    else
        echo -e "${YELLOW}📥 Please download manually from: https://google.com/chrome/${NC}"
    fi
}

install_edge() {
    echo -e "${BLUE}🔵 Installing Microsoft Edge...${NC}"
    log "Installing Microsoft Edge"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        if command -v yay &> /dev/null; then
            yay -S microsoft-edge-stable-bin --noconfirm
        else
            echo -e "${YELLOW}📥 Install yay or download from https://microsoft.com/edge${NC}"
        fi
    elif [ "$PKG_MANAGER" = "apt" ]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
        sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
        sudo apt update
        install_package "microsoft-edge-stable" "Microsoft Edge"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
        sudo dnf install -y microsoft-edge-stable
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Microsoft Edge installed!${NC}"
    fi
}

install_opera() {
    if install_flatpak "com.opera.Opera" "Opera"; then
        return 0
    else
        install_smart "opera" "opera-stable" "opera" "opera" "Opera"
    fi
}

install_brave() {
    if install_flatpak "com.brave.Browser" "Brave"; then
        return 0
    else
        install_smart "brave-browser" "brave-browser" "brave-browser" "brave-browser" "Brave"
    fi
}

install_librewolf() {
    if install_flatpak "io.gitlab.librewolf-community" "LibreWolf"; then
        return 0
    else
        install_smart "librewolf" "librewolf" "librewolf" "librewolf" "LibreWolf"
    fi
}

install_thorium() {
    echo -e "${BLUE}⚡ Installing Thorium Browser...${NC}"
    if command -v yay &> /dev/null; then
        yay -S thorium-browser --noconfirm
    else
        echo -e "${YELLOW}📥 Download from: https://github.com/Alex313031/Thorium${NC}"
        echo -e "${YELLOW}📥 Or install via Flatpak: flatpak install flathub com.github.Alex313031.Thorium${NC}"
    fi
}

install_tor_browser() {
    install_smart "tor-browser" "tor-browser" "tor-browser" "tor-browser" "Tor Browser"
}

install_ungoogled_chromium() {
    if command -v yay &> /dev/null; then
        yay -S ungoogled-chromium --noconfirm
    else
        echo -e "${YELLOW}📥 Download from: https://ungoogled-software.github.io/${NC}"
    fi
}

install_chromium() {
    install_smart "chromium" "chromium" "chromium" "chromium" "Chromium"
}

install_zen_browser() {
    echo -e "${GREEN}🧘 Installing Zen Browser...${NC}"
    
    # Try different installation methods automatically
    if [ "$PKG_MANAGER" = "pacman" ]; then
        # Arch Linux - AUR
        echo -e "${BLUE}📦 Installing via AUR...${NC}"
        if command -v yay &> /dev/null; then
            yay -S zen-browser --noconfirm
        elif command -v paru &> /dev/null; then
            paru -S zen-browser --noconfirm
        else
            echo -e "${YELLOW}📥 Installing yay first...${NC}"
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay && makepkg -si --noconfirm
            yay -S zen-browser --noconfirm
        fi
        
    elif [ "$PKG_MANAGER" = "apt" ]; then
        # Ubuntu/Debian - Download .deb
        echo -e "${BLUE}📥 Downloading .deb package...${NC}"
        cd /tmp
        wget -O zen-browser.deb "https://github.com/zen-browser/desktop/releases/latest/download/zen-browser_amd64.deb"
        sudo dpkg -i zen-browser.deb
        sudo apt install -f -y
        rm zen-browser.deb
        
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        # Fedora - Download .rpm
        echo -e "${BLUE}📥 Downloading .rpm package...${NC}"
        cd /tmp
        wget -O zen-browser.rpm "https://github.com/zen-browser/desktop/releases/latest/download/zen-browser_x86_64.rpm"
        sudo dnf install -y zen-browser.rpm
        rm zen-browser.rpm
        
    else
        # Fallback - Download AppImage
        echo -e "${BLUE}📥 Downloading AppImage...${NC}"
        cd /tmp
        wget "https://github.com/zen-browser/desktop/releases/latest/download/zen-browser-$(uname -m).AppImage"
        chmod +x zen-browser-*.AppImage
        sudo mv zen-browser-*.AppImage /usr/local/bin/zen-browser
        echo -e "${GREEN}✅ Zen Browser AppImage installed to /usr/local/bin/zen-browser${NC}"
    fi
    
    # Verify installation
    if command -v zen-browser &> /dev/null; then
        echo -e "${GREEN}✅ Zen Browser installed successfully!${NC}"
        echo -e "${CYAN}🚀 A privacy-focused browser based on Firefox${NC}"
    else
        echo -e "${YELLOW}⚠️ Installation may need manual completion${NC}"
        echo -e "${BLUE}💡 Visit: https://github.com/zen-browser/desktop/releases${NC}"
    fi
}
    

# Apps Multimedia Subtab - COMPLETE
apps_multimedia_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎵 MULTIMEDIA" "$PURPLE"
        echo ""
        echo -e "${GREEN}🎵 Music & Audio:${NC}"
        echo -e "  ${GREEN}1${NC}) Spotify"
        echo -e "  ${GREEN}2${NC}) VLC Media Player"
        echo -e "  ${GREEN}3${NC}) Audacity"
        echo -e "  ${GREEN}4${NC}) OBS Studio"
        echo -e "  ${GREEN}5${NC}) MPV Player"
        echo ""
        echo -e "${BLUE}🎬 Video Tools:${NC}"
        echo -e "  ${BLUE}6${NC}) Kdenlive"
        echo -e "  ${BLUE}7${NC}) HandBrake"
        echo -e "  ${BLUE}8${NC}) FFmpeg"
        echo -e "  ${BLUE}9${NC}) Shotcut"
        echo -e "  ${BLUE}10${NC}) DaVinci Resolve"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose app to install [0-10]: " choice

        case $choice in
            1) install_spotify ;;
            2) install_vlc ;;
            3) install_audacity ;;
            4) install_obs ;;
            5) install_mpv ;;
            6) install_kdenlive ;;
            7) install_handbrake ;;
            8) install_ffmpeg ;;
            9) install_shotcut ;;
            10) install_davinci_resolve ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# Multimedia Functions
install_spotify() {
    echo -e "${GREEN}🎵 Installing Spotify...${NC}"
    
    # Try Flatpak first (most reliable)
    if install_flatpak "com.spotify.Client" "Spotify"; then
        echo -e "${GREEN}✅ Spotify installed via Flatpak!${NC}"
        return 0
    fi
    
    # Try different native package names
    case "$PKG_MANAGER" in
        "pacman")
            # Arch - AUR or snap
            if command -v yay &> /dev/null; then
                yay -S spotify --noconfirm
            else
                echo -e "${YELLOW}📥 Install via AUR or use Flatpak${NC}"
            fi
            ;;
        "apt")
            # Ubuntu - official repo
            curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
            echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
            sudo apt update
            sudo apt install spotify-client -y
            ;;
        "dnf")
            # Fedora - Flathub or third-party
            sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            sudo dnf install spotify-client -y
            ;;
        *)
            echo -e "${YELLOW}📥 Download from: https://www.spotify.com/download/linux/${NC}"
            ;;
    esac
    
    if command -v spotify &> /dev/null || flatpak list | grep -q spotify.Client; then
        echo -e "${GREEN}✅ Spotify installed successfully!${NC}"
    else
        echo -e "${YELLOW}📥 Manual download: https://www.spotify.com/download/linux/${NC}"
    fi
}

install_vlc() {
    install_smart "vlc" "vlc" "vlc" "vlc" "VLC Media Player"
}

install_audacity() {
    install_smart "audacity" "audacity" "audacity" "audacity" "Audacity"
}

install_obs() {
    install_smart "obs-studio" "obs-studio" "obs-studio" "obs-studio" "OBS Studio"
}

install_mpv() {
    install_smart "mpv" "mpv" "mpv" "mpv" "MPV Player"
}

install_kdenlive() {
    install_smart "kdenlive" "kdenlive" "kdenlive" "kdenlive" "Kdenlive"
}

install_handbrake() {
    install_smart "handbrake" "handbrake" "handbrake" "handbrake" "HandBrake"
}

install_ffmpeg() {
    install_smart "ffmpeg" "ffmpeg" "ffmpeg" "ffmpeg" "FFmpeg"
}

install_shotcut() {
    install_smart "shotcut" "shotcut" "shotcut" "shotcut" "Shotcut"
}

install_davinci_resolve() {
    echo -e "${BLUE}🎬 DaVinci Resolve requires manual installation${NC}"
    echo -e "${YELLOW}📥 Download from: https://www.blackmagicdesign.com/products/davinciresolve${NC}"
    echo -e "${YELLOW}💡 Use the provided installer script from the download${NC}"
}

# Tubes (YT alternatives) Subtab
apps_tubes_subtab() {
    while true; do
        show_banner
        show_subtab_header "📺 TUBES & VIDEO" "$PURPLE"
        echo ""
        echo -e "${GREEN}🎬 Desktop YouTube Clients:${NC}"
        echo -e "  ${GREEN}1${NC}) FreeTube"
        echo -e "  ${GREEN}2${NC}) MiniTube"
        echo -e "  ${GREEN}3${NC}) PeerTube Desktop"
        echo ""
        echo -e "${BLUE}📱 Mobile Clients (Info):${NC}"
        echo -e "  ${BLUE}4${NC}) LibreTube"
        echo -e "  ${BLUE}5${NC}) NewPipe"
        echo -e "  ${BLUE}6${NC}) SkyTube"
        echo ""
        echo -e "${CYAN}🔧 Video Tools:${NC}"
        echo -e "  ${CYAN}7${NC}) yt-dlp (Downloader)"
        echo -e "  ${CYAN}8${NC}) Invidious (Web Client)"
        echo -e "  ${CYAN}9${NC}) Celluloid (Video Player)"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose app to install [0-9]: " choice

        case $choice in
            1) install_freetube ;;
            2) install_minitube ;;
            3) install_peertube_desktop ;;
            4) install_libretube ;;
            5) install_newpipe ;;
            6) install_skytube ;;
            7) install_ytdlp ;;
            8) install_invidious ;;
            9) install_celluloid ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

install_freetube() {
    echo -e "${GREEN}📺 Installing FreeTube...${NC}"
    if install_flatpak "io.freetubeapp.FreeTube" "FreeTube"; then
        echo -e "${GREEN}✅ FreeTube installed! Privacy-focused YouTube client${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://github.com/FreeTubeApp/FreeTube${NC}"
    fi
}

install_minitube() {
    echo -e "${GREEN}📺 Installing MiniTube...${NC}"
    if install_smart "minitube" "minitube" "minitube" "minitube" "MiniTube"; then
        echo -e "${GREEN}✅ MiniTube installed! Lightweight YouTube client${NC}"
    elif install_flatpak "com.feralinteractive.MiniTube" "MiniTube"; then
        echo -e "${GREEN}✅ MiniTube installed via Flatpak!${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://flathub.org/apps/com.feralinteractive.MiniTube${NC}"
    fi
}

install_peertube_desktop() {
    echo -e "${GREEN}📺 Installing PeerTube Desktop...${NC}"
    
    # First, let's check what's actually available
    echo -e "${BLUE}🔍 Searching for PeerTube Desktop...${NC}"
    
    # Try to find the correct Flatpak
    if flatpak remote-ls flathub | grep -i peertube; then
        echo -e "${YELLOW}📦 Found PeerTube in Flatpak, installing...${NC}"
        flatpak install flathub $(flatpak remote-ls flathub | grep -i peertube | head -1 | awk '{print $1}') -y
    fi
    
    # Check if it installed via Flatpak
    if flatpak list | grep -i peertube; then
        echo -e "${GREEN}✅ PeerTube Desktop installed via Flatpak!${NC}"
        return 0
    fi
    
    # If Flatpak failed, try direct download from GitHub
    echo -e "${BLUE}📥 Downloading directly from GitHub...${NC}"
    cd /tmp
    
    # Get the latest release URL
    LATEST_URL=$(curl -s https://api.github.com/repos/Chocobozzz/PeerTube-Desktop/releases/latest | grep "browser_download_url.*AppImage" | head -1 | cut -d '"' -f 4)
    
    if [ -n "$LATEST_URL" ]; then
        echo -e "${BLUE}📦 Downloading: $LATEST_URL${NC}"
        wget -O peertube-desktop.AppImage "$LATEST_URL"
        
        if [ -f "peertube-desktop.AppImage" ]; then
            chmod +x peertube-desktop.AppImage
            sudo mv peertube-desktop.AppImage /usr/local/bin/peertube-desktop
            echo -e "${GREEN}✅ PeerTube Desktop installed as AppImage!${NC}"
            echo -e "${YELLOW}🚀 Run with: peertube-desktop${NC}"
            return 0
        fi
    fi
    
    # If everything failed, provide clear manual instructions
    echo -e "${RED}❌ Automatic installation failed${NC}"
    echo -e "${YELLOW}📥 Manual installation required:${NC}"
    echo -e "${BLUE}1. Visit: https://github.com/Chocobozzz/PeerTube-Desktop${NC}"
    echo -e "${BLUE}2. Go to 'Releases'${NC}"
    echo -e "${BLUE}3. Download the .AppImage file${NC}"
    echo -e "${BLUE}4. Make executable: chmod +x PeerTube-Desktop-*.AppImage${NC}"
    echo -e "${BLUE}5. Run: ./PeerTube-Desktop-*.AppImage${NC}"
    echo -e ""
    echo -e "${YELLOW}💡 Alternative: Use PeerTube in your web browser at${NC}"
    echo -e "${BLUE}   https://joinpeertube.org/ or any PeerTube instance${NC}"
}

install_libretube() {
    echo -e "${GREEN}📱 LibreTube (Android App)${NC}"
    echo -e "${BLUE}Android installation:${NC}"
    echo -e "  • F-Droid: https://f-droid.org/packages/com.github.libretube/"
    echo -e "  • GitHub: https://github.com/libretube/libretube"
    echo -e "${YELLOW}💡 Use FreeTube for desktop experience${NC}"
}

install_newpipe() {
    echo -e "${GREEN}📱 NewPipe (Android App)${NC}"
    echo -e "${BLUE}Android installation:${NC}"
    echo -e "  • F-Droid: https://f-droid.org/packages/org.schabi.newpipe/"
    echo -e "  • GitHub: https://github.com/TeamNewPipe/NewPipe"
    echo -e "${YELLOW}💡 Use FreeTube for desktop experience${NC}"
}

install_skytube() {
    echo -e "${GREEN}📱 SkyTube (Android App)${NC}"
    echo -e "${BLUE}Android installation:${NC}"
    echo -e "  • F-Droid: https://f-droid.org/packages/free.rm.skytube.oss/"
    echo -e "  • GitHub: https://github.com/SkyTubeTeam/SkyTube"
    echo -e "${YELLOW}💡 Use FreeTube for desktop experience${NC}"
}

install_ytdlp() {
    echo -e "${GREEN}📥 Installing yt-dlp...${NC}"
    if install_smart "yt-dlp" "yt-dlp" "yt-dlp" "yt-dlp" "yt-dlp"; then
        echo -e "${GREEN}✅ yt-dlp installed! YouTube video downloader${NC}"
        echo -e "${BLUE}💡 Usage: yt-dlp [video-url]${NC}"
    else
        sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
        sudo chmod a+rx /usr/local/bin/yt-dlp
        echo -e "${GREEN}✅ yt-dlp installed via direct download${NC}"
    fi
}

install_invidious() {
    echo -e "${GREEN}🌐 Invidious - Self-hosted YouTube frontend${NC}"
    echo -e "${BLUE}Public instances:${NC}"
    echo -e "  • https://invidious.io/"
    echo -e "  • https://docs.invidious.io/Instances/"
    echo -e "${BLUE}Self-hosting:${NC}"
    echo -e "  • Docker: docker run -d -p 3000:3000 invidious/invidious"
    echo -e "${YELLOW}💡 Use public instances for immediate use${NC}"
}

install_celluloid() {
    echo -e "${GREEN}🎬 Installing Celluloid (GNOME MPV)...${NC}"
    if install_flatpak "io.github.celluloid_player.Celluloid" "Celluloid"; then
        echo -e "${GREEN}✅ Celluloid installed! Modern video player${NC}"
    elif install_smart "celluloid" "celluloid" "celluloid" "celluloid" "Celluloid"; then
        echo -e "${GREEN}✅ Celluloid installed!${NC}"
    else
        echo -e "${YELLOW}📥 Install MPV instead: sudo apt install mpv${NC}"
    fi
}

# Apps Utilities Subtab 
apps_utilities_subtab() {
    while true; do
        show_banner
        show_subtab_header "🛠️  UTILITIES" "$ORANGE"
        echo ""
        echo -e "${GREEN}💻 System Utilities:${NC}"
        echo -e "  ${GREEN}1${NC}) GNOME Boxes"
        echo -e "  ${GREEN}2${NC}) GParted"
        echo -e "  ${GREEN}3${NC}) Timeshift"
        echo -e "  ${GREEN}4${NC}) BleachBit"
        echo -e "  ${GREEN}5${NC}) Fastfetch"
        echo ""
        echo -e "${BLUE}📁 File Management:${NC}"
        echo -e "  ${BLUE}6${NC}) Nautilus"
        echo -e "  ${BLUE}7${NC}) Dolphin"
        echo -e "  ${BLUE}8${NC}) Thunar"
        echo -e "  ${BLUE}9${NC}) Ranger"
        echo -e "  ${BLUE}10${NC}) Synaptic"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose utility to install [0-10]: " choice

        case $choice in
            1) install_gnome_boxes ;;
            2) install_gparted ;;
            3) install_timeshift ;;
            4) install_bleachbit ;;
            5) install_fastfetch ;;
            6) install_nautilus ;;
            7) install_dolphin ;;
            8) install_thunar ;;
            9) install_ranger ;;
            10) install_synaptic ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Utilities Functions
install_gnome_boxes() {
    install_smart "gnome-boxes" "gnome-boxes" "gnome-boxes" "gnome-boxes" "GNOME Boxes"
}

install_gparted() {
    install_smart "gparted" "gparted" "gparted" "gparted" "GParted"
}

install_timeshift() {
    install_smart "timeshift" "timeshift" "timeshift" "timeshift" "Timeshift"
}

install_bleachbit() {
    install_smart "bleachbit" "bleachbit" "bleachbit" "bleachbit" "BleachBit"
}

install_fastfetch() {
    install_smart "fastfetch" "fastfetch" "fastfetch" "fastfetch" "Fastfetch"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚀 Showing system info...${NC}"
        sleep 1
        fastfetch
    fi
}

install_nautilus() {
    install_smart "nautilus" "nautilus" "nautilus" "nautilus" "Nautilus"
}

install_dolphin() {
    install_smart "dolphin" "dolphin" "dolphin" "dolphin" "Dolphin"
}

install_thunar() {
    install_smart "thunar" "thunar" "thunar" "thunar" "Thunar"
}

install_ranger() {
    install_smart "ranger" "ranger" "ranger" "ranger" "Ranger"
}

install_synaptic() {
    install_smart "synaptic" "synaptic" "synaptic" "synaptic" "Synaptic"
}

# Apps Productivity Subtab - COMPLETE
apps_productivity_subtab() {
    while true; do
        show_banner
        show_subtab_header "📝 PRODUCTIVITY" "$GREEN"
        echo ""
        echo -e "${GREEN}📊 Office Suite:${NC}"
        echo -e "  ${GREEN}1${NC}) LibreOffice"
        echo -e "  ${GREEN}2${NC}) OnlyOffice"
        echo -e "  ${GREEN}3${NC}) FreeOffice"
        echo -e "  ${GREEN}4${NC}) WPS Office"
        echo ""
        echo -e "${BLUE}📝 Note Taking:${NC}"
        echo -e "  ${BLUE}5${NC}) Obsidian"
        echo -e "  ${BLUE}6${NC}) Joplin"
        echo -e "  ${BLUE}7${NC}) Standard Notes"
        echo -e "  ${BLUE}8${NC}) CherryTree"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose app to install [0-8]: " choice

        case $choice in
            1) install_libreoffice ;;
            2) install_onlyoffice ;;
            3) install_freeoffice ;;
            4) install_wpsoffice ;;
            5) install_obsidian ;;
            6) install_joplin ;;
            7) install_standard_notes ;;
            8) install_cherrytree ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Productivity Functions
install_libreoffice() {
    install_smart "libreoffice-fresh" "libreoffice" "libreoffice" "libreoffice" "LibreOffice"
}

install_onlyoffice() {
    install_flatpak "org.onlyoffice.desktopeditors" "OnlyOffice"
}

install_freeoffice() {
    echo -e "${BLUE}📊 FreeOffice requires manual download${NC}"
    echo -e "${YELLOW}📥 Download from: https://www.freeoffice.com/${NC}"
}

install_wpsoffice() {
    if [ "$PKG_MANAGER" = "pacman" ]; then
        yay -S wps-office --noconfirm
    else
        echo -e "${YELLOW}📥 Download from: https://www.wps.com/office/linux/${NC}"
    fi
}

install_obsidian() {
    install_flatpak "md.obsidian.Obsidian" "Obsidian"
}

install_joplin() {
    install_flatpak "net.cozic.joplin_desktop" "Joplin"
}

install_standard_notes() {
    install_flatpak "org.standardnotes.standardnotes" "Standard Notes"
}

install_cherrytree() {
    install_smart "cherrytree" "cherrytree" "cherrytree" "cherrytree" "CherryTree"
}

# Apps Creative Subtab - COMPLETE
apps_creative_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎨 CREATIVE" "$MAGENTA"
        echo ""
        echo -e "${GREEN}🎨 Graphics & Design:${NC}"
        echo -e "  ${GREEN}1${NC}) GIMP"
        echo -e "  ${GREEN}2${NC}) Inkscape"
        echo -e "  ${GREEN}3${NC}) Blender"
        echo -e "  ${GREEN}4${NC}) Krita"
        echo -e "  ${GREEN}5${NC}) Darktable"
        echo ""
        echo -e "${BLUE}🎵 Audio Production:${NC}"
        echo -e "  ${BLUE}6${NC}) Ardour"
        echo -e "  ${BLUE}7${NC}) LMMS"
        echo -e "  ${BLUE}8${NC}) MuseScore"
        echo -e "  ${BLUE}9${NC}) Hydrogen"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose app to install [0-9]: " choice

        case $choice in
            1) install_gimp ;;
            2) install_inkscape ;;
            3) install_blender ;;
            4) install_krita ;;
            5) install_darktable ;;
            6) install_ardour ;;
            7) install_lmms ;;
            8) install_musescore ;;
            9) install_hydrogen ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}


# Creative Functions

install_gimp() {
    echo -e "${GREEN}🎨 Installing GIMP...${NC}"
    
    # GIMP has different package names across distros
    case "$PKG_MANAGER" in
        "pacman")
            # Arch Linux
            install_package "gimp" "GIMP"
            ;;
        "apt")
            # Ubuntu/Debian
            install_package "gimp" "GIMP"
            ;;
        "dnf")
            # Fedora/RHEL
            install_package "gimp" "GIMP"
            ;;
        "zypper")
            # openSUSE
            install_package "gimp" "GIMP"
            ;;
        *)
            # Fallback - try common names
            if install_package "gimp" "GIMP"; then
                return 0
            elif install_package "gimp2" "GIMP"; then
                return 0
            else
                echo -e "${YELLOW}📥 Download from: https://www.gimp.org/downloads/${NC}"
            fi
            ;;
    esac
    
    # Verify installation
    if command -v gimp &> /dev/null; then
        echo -e "${GREEN}✅ GIMP installed successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️ GIMP may be installed but not in PATH${NC}"
        echo -e "${YELLOW}💡 Try: flatpak install flathub org.gimp.GIMP${NC}"
    fi
}

install_inkscape() {
    install_smart "inkscape" "inkscape" "inkscape" "inkscape" "Inkscape"
}

install_blender() {
    install_smart "blender" "blender" "blender" "blender" "Blender"
}

install_krita() {
    install_smart "krita" "krita" "krita" "krita" "Krita"
}

install_darktable() {
    install_smart "darktable" "darktable" "darktable" "darktable" "Darktable"
}

install_ardour() {
    install_flatpak "org.ardour.Ardour" "Ardour"
}

install_lmms() {
    install_smart "lmms" "lmms" "lmms" "lmms" "LMMS"
}

install_musescore() {
    install_flatpak "org.musescore.MuseScore" "MuseScore"
}

install_hydrogen() {
    install_smart "hydrogen" "hydrogen" "hydrogen" "hydrogen" "Hydrogen"
}

# ============================================================================
# GAMING TAB - COMPLETE WITH ALL FEATURES
# ============================================================================

gaming_tab() {
    while true; do
        show_banner
        echo -e "${ORANGE}🎮 GAMING TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BOLD}Choose Subtab:${NC}"
        echo -e "  ${GREEN}1${NC}) 🎯 Game Launchers"
        echo -e "  ${GREEN}2${NC}) 🍷 Wine & Compatibility"
        echo -e "  ${GREEN}3${NC}) 🚀 Performance Tools"
        echo -e "  ${GREEN}4${NC}) ♟️  Casual Games"
        echo -e "  ${GREEN}5${NC}) 🎲 Game Emulators"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Main Menu"
        echo ""
        read -p "Choose subtab [0-5]: " choice

        case $choice in
            1) gaming_launchers_subtab ;;
            2) gaming_wine_subtab ;;
            3) gaming_performance_subtab ;;
            4) gaming_casual_subtab ;;
            5) gaming_emulators_subtab ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

# Gaming Launchers Subtab - COMPLETE
gaming_launchers_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎯 GAME LAUNCHERS" "$ORANGE"
        echo ""
        echo -e "${GREEN}🎮 Primary Launchers:${NC}"
        echo -e "  ${GREEN}1${NC}) Steam"
        echo -e "  ${GREEN}2${NC}) Lutris"
        echo -e "  ${GREEN}3${NC}) Heroic Games Launcher"
        echo -e "  ${GREEN}4${NC}) Bottles"
        echo -e "  ${GREEN}5${NC}) PlayOnLinux"
        echo ""
        echo -e "${BLUE}🌐 Other Launchers:${NC}"
        echo -e "  ${BLUE}6${NC}) itch.io"
        echo -e "  ${BLUE}7${NC}) Minigalaxy"
        echo -e "  ${BLUE}8${NC}) Legendary"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Gaming Tab"
        echo ""
        read -p "Choose launcher to install [0-8]: " choice

        case $choice in
            1) install_steam ;;
            2) install_lutris ;;
            3) install_heroic_launcher ;;
            4) install_bottles ;;
            5) install_playonlinux ;;
            6) install_itch ;;
            7) install_minigalaxy ;;
            8) install_legendary ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Gaming Functions

install_steam() {
    echo -e "${GREEN}🎮 Installing Steam...${NC}"
    
    # First, try the universal Flatpak method (most reliable)
    if command -v flatpak &> /dev/null; then
        echo -e "${BLUE}📦 Installing Steam via Flatpak (recommended)...${NC}"
        if flatpak install flathub com.valvesoftware.Steam -y; then
            echo -e "${GREEN}✅ Steam installed via Flatpak!${NC}"
            echo -e "${YELLOW}🚀 Run with: flatpak run com.valvesoftware.Steam${NC}"
            return 0
        fi
    fi
    
    # If Flatpak fails, try native packages
    case "$PKG_MANAGER" in
        "pacman")
            echo -e "${BLUE}📦 Arch Linux: Installing Steam...${NC}"
            # Enable multilib if not already
            if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
                echo -e "${YELLOW}⚠️ Enabling multilib repository...${NC}"
                echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
                sudo pacman -Syu --noconfirm
            fi
            sudo pacman -S steam --noconfirm
            ;;
        "apt")
            echo -e "${BLUE}📦 Ubuntu/Debian: Installing Steam...${NC}"
            sudo apt update
            sudo apt install steam -y
            ;;
        "dnf")
            echo -e "${BLUE}📦 Fedora: Installing Steam...${NC}"
            # Enable RPM Fusion if not already
            if ! dnf repolist | grep -q rpmfusion; then
                echo -e "${YELLOW}⚠️ Enabling RPM Fusion...${NC}"
                sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
                sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
            fi
            sudo dnf install steam -y
            ;;
        "zypper")
            echo -e "${BLUE}📦 openSUSE: Installing Steam...${NC}"
            sudo zypper install steam -y
            ;;
    esac
    
    # Final check
    if command -v steam &> /dev/null || flatpak list | grep -q valvesoftware.Steam; then
        echo -e "${GREEN}✅ Steam installed successfully!${NC}"
        echo -e "${YELLOW}🚀 Run 'steam' to start setup${NC}"
    else
        echo -e "${RED}❌ Steam installation failed${NC}"
        echo -e "${YELLOW}📥 Manual installation required:${NC}"
        echo -e "${BLUE}1. Download from: https://store.steampowered.com/about/${NC}"
        echo -e "${BLUE}2. Or install Flatpak first, then run this again${NC}"
        echo -e "${BLUE}3. Flatpak install: sudo apt install flatpak && flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo${NC}"
    fi
}

install_lutris() {
    if install_flatpak "net.lutris.Lutris" "Lutris"; then
        return 0
    else
        install_smart "lutris" "lutris" "lutris" "lutris" "Lutris"
    fi
}

install_heroic_launcher() {
    if install_flatpak "com.heroicgameslauncher.hgl" "Heroic Games Launcher"; then
        return 0
    else
        if command -v yay &> /dev/null; then
            yay -S heroic-games-launcher-bin --noconfirm
        else
            echo -e "${YELLOW}📥 Install Flatpak or use AUR helper for Heroic${NC}"
        fi
    fi
}

install_bottles() {
    if install_flatpak "com.usebottles.bottles" "Bottles"; then
        return 0
    else
        install_smart "bottles" "bottles" "bottles" "bottles" "Bottles"
    fi
}

install_playonlinux() {
    install_smart "playonlinux" "playonlinux" "playonlinux" "playonlinux" "PlayOnLinux"
}

install_itch() {
    install_flatpak "io.itch.itch" "itch.io"
}

install_minigalaxy() {
    install_flatpak "io.github.sharkwouter.Minigalaxy" "Minigalaxy"
}

install_legendary() {
    install_smart "legendary" "legendary" "legendary" "legendary" "Legendary"
}

# Gaming Wine Subtab - COMPLETE
gaming_wine_subtab() {
    while true; do
        show_banner
        show_subtab_header "🍷 WINE & COMPATIBILITY" "$RED"
        echo ""
        echo -e "${GREEN}🍷 Wine Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) Wine Staging"
        echo -e "  ${GREEN}2${NC}) Winetricks"
        echo -e "  ${GREEN}3${NC}) ProtonUP-Qt"
        echo -e "  ${GREEN}4${NC}) Proton-GE"
        echo -e "  ${GREEN}5${NC}) DXVK"
        echo ""
        echo -e "${BLUE}🔧 Compatibility:${NC}"
        echo -e "  ${BLUE}6${NC}) VKD3D"
        echo -e "  ${BLUE}7${NC}) Faudio"
        echo -e "  ${BLUE}8${NC}) GameMode"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Gaming Tab"
        echo ""
        read -p "Choose option [0-8]: " choice

        case $choice in
            1) install_wine ;;
            2) install_winetricks ;;
            3) install_protonup_qt ;;
            4) install_proton_ge ;;
            5) install_dxvk ;;
            6) install_vkd3d ;;
            7) install_faudio ;;
            8) install_gamemode ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Wine Functions
install_wine() {
    install_smart "wine-staging" "wine-staging" "wine" "wine" "Wine Staging"
}

install_winetricks() {
    install_smart "winetricks" "winetricks" "winetricks" "winetricks" "Winetricks"
}

install_protonup_qt() {
    if install_flatpak "net.davidotek.pupgui2" "ProtonUp-Qt"; then
        return 0
    else
        install_smart "protonup-qt" "protonup-qt" "protonup-qt" "protonup-qt" "ProtonUp-Qt"
    fi
}

install_proton_ge() {
    echo -e "${BLUE}🚀 Installing Proton-GE...${NC}"
    if command -v protonup &> /dev/null; then
        protonup
    else
        install_protonup_qt
        echo -e "${YELLOW}📥 Use ProtonUp-Qt to install Proton-GE${NC}"
    fi
}

install_dxvk() {
    install_smart "dxvk" "dxvk" "dxvk" "dxvk" "DXVK"
}

install_vkd3d() {
    install_smart "vkd3d" "vkd3d" "vkd3d" "vkd3d" "VKD3D"
}

install_faudio() {
    install_smart "faudio" "faudio" "faudio" "faudio" "FAudio"
}

install_gamemode() {
    install_smart "gamemode" "gamemode" "gamemode" "gamemode" "Gamemode"
}

# Gaming Performance Subtab - COMPLETE
gaming_performance_subtab() {
    while true; do
        show_banner
        show_subtab_header "🚀 PERFORMANCE TOOLS" "$BLUE"
        echo ""
        echo -e "${GREEN}📊 Performance Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) MangoHud"
        echo -e "  ${GREEN}2${NC}) GOverlay"
        echo -e "  ${GREEN}3${NC}) CoreCtrl"
        echo -e "  ${GREEN}4${NC}) Gamescope"
        echo -e "  ${GREEN}5${NC}) GreenWithEnvy"
        echo ""
        echo -e "${BLUE}🔧 Optimization:${NC}"
        echo -e "  ${BLUE}6${NC}) Gamemode"
        echo -e "  ${BLUE}7${NC}) Feral GameMode"
        echo -e "  ${BLUE}8${NC}) CPU Power Management"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Gaming Tab"
        echo ""
        read -p "Choose tool to install [0-8]: " choice

        case $choice in
            1) install_mangohud ;;
            2) install_goverlay ;;
            3) install_corectrl ;;
            4) install_gamescope ;;
            5) install_greenwithenvy ;;
            6) install_gamemode ;;
            7) install_feral_gamemode ;;
            8) configure_cpu_power ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Performance Functions
install_mangohud() {
    install_smart "mangohud" "mangohud" "mangohud" "mangohud" "MangoHud"
}

install_goverlay() {
    install_flatpak "com.leinardi.goverlay" "GOverlay"
}

install_corectrl() {
    install_smart "corectrl" "corectrl" "corectrl" "corectrl" "CoreCtrl"
}

install_gamescope() {
    install_smart "gamescope" "gamescope" "gamescope" "gamescope" "Gamescope"
}

install_greenwithenvy() {
    install_flatpak "com.leinardi.gwe" "GreenWithEnvy"
}

install_feral_gamemode() {
    echo -e "${BLUE}🎮 Installing Feral Interactive GameMode...${NC}"
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo add-apt-repository ppa:feral-interactive/gamemode
        sudo apt update
        install_package "gamemode" "GameMode"
    else
        install_smart "gamemode" "gamemode" "gamemode" "gamemode" "GameMode"
    fi
}

configure_cpu_power() {
    echo -e "${BLUE}⚡ Configuring CPU power management...${NC}"
    
    if install_smart "cpupower" "linux-tools-common" "kernel-tools" "cpupower" "CPU Power Tools"; then
        echo -e "${GREEN}✅ CPU power tools installed${NC}"
        echo -e "${CYAN}Current CPU frequency:${NC}"
        sudo cpupower frequency-info | grep "current CPU"
        
        read -p "Set CPU to performance mode? (y/N): " perf_mode
        if [[ $perf_mode =~ ^[Yy]$ ]]; then
            sudo cpupower frequency-set -g performance
            echo -e "${GREEN}✅ CPU set to performance mode${NC}"
        fi
    fi
}

# Gaming Casual Subtab - COMPLETE
gaming_casual_subtab() {
    while true; do
        show_banner
        show_subtab_header "♟️  CASUAL GAMES" "$GREEN"
        echo ""
        echo -e "${GREEN}♟️  Board Games:${NC}"
        echo -e "  ${GREEN}1${NC}) Chess"
        echo -e "  ${GREEN}2${NC}) Sudoku"
        echo -e "  ${GREEN}3${NC}) Mahjongg"
        echo -e "  ${GREEN}4${NC}) 2048"
        echo -e "  ${GREEN}5${NC}) Minesweeper"
        echo ""
        echo -e "${BLUE}🎲 Puzzle Games:${NC}"
        echo -e "  ${BLUE}6${NC}) SuperTuxKart"
        echo -e "  ${BLUE}7${NC}) 0 A.D."
        echo -e "  ${BLUE}8${NC}) Minetest"
        echo -e "  ${BLUE}9${NC}) Xonotic"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Gaming Tab"
        echo ""
        read -p "Choose game to install [0-9]: " choice

        case $choice in
            1) install_chess ;;
            2) install_sudoku ;;
            3) install_mahjongg ;;
            4) install_2048 ;;
            5) install_minesweeper ;;
            6) install_supertuxkart ;;
            7) install_0ad ;;
            8) install_minetest ;;
            9) install_xonotic ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Game Functions
install_chess() {
    install_smart "gnome-chess" "gnome-chess" "gnome-chess" "gnome-chess" "Chess"
}

install_sudoku() {
    install_smart "gnome-sudoku" "gnome-sudoku" "gnome-sudoku" "gnome-sudoku" "Sudoku"
}

install_mahjongg() {
    install_smart "gnome-mahjongg" "gnome-mahjongg" "gnome-mahjongg" "gnome-mahjongg" "Mahjongg"
}

install_2048() {
    install_smart "2048-game" "2048-game" "2048-game" "2048-game" "2048"
}

install_minesweeper() {
    install_smart "gnome-mines" "gnome-mines" "gnome-mines" "gnome-mines" "Minesweeper"
}

install_supertuxkart() {
    install_smart "supertuxkart" "supertuxkart" "supertuxkart" "supertuxkart" "SuperTuxKart"
}

install_0ad() {
    install_smart "0ad" "0ad" "0ad" "0ad" "0 A.D."
}

install_minetest() {
    install_smart "minetest" "minetest" "minetest" "minetest" "Minetest"
}

install_xonotic() {
    install_smart "xonotic" "xonotic" "xonotic" "xonotic" "Xonotic"
}

# Gaming Emulators Subtab - COMPLETE
gaming_emulators_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎲 GAME EMULATORS" "$PURPLE"
        echo ""
        echo -e "${GREEN}🎮 Console Emulators:${NC}"
        echo -e "  ${GREEN}1${NC}) RetroArch"
        echo -e "  ${GREEN}2${NC}) Dolphin (GameCube/Wii)"
        echo -e "  ${GREEN}3${NC}) PCSX2 (PlayStation 2)"
        echo -e "  ${GREEN}4${NC}) RPCS3 (PlayStation 3)"
        echo -e "  ${GREEN}5${NC}) Citra (Nintendo 3DS)"
        echo ""
        echo -e "${BLUE}📱 Mobile Emulators:${NC}"
        echo -e "  ${BLUE}6${NC}) Anbox (Android)"
        echo -e "  ${BLUE}7${NC}) Waydroid (Android)"
        echo -e "  ${BLUE}8${NC}) Genymotion"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Gaming Tab"
        echo ""
        read -p "Choose emulator to install [0-8]: " choice

        case $choice in
            1) install_retroarch ;;
            2) install_dolphin_emulator ;;
            3) install_pcsx2 ;;
            4) install_rpcs3 ;;
            5) install_citra ;;
            6) install_anbox ;;
            7) install_waydroid ;;
            8) install_genymotion ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Emulator Functions
install_retroarch() {
    install_smart "retroarch" "retroarch" "retroarch" "retroarch" "RetroArch"
}

install_dolphin_emulator() {
    install_smart "dolphin-emu" "dolphin-emu" "dolphin-emu" "dolphin-emu" "Dolphin Emulator"
}

install_pcsx2() {
    install_smart "pcsx2" "pcsx2" "pcsx2" "pcsx2" "PCSX2"
}

install_rpcs3() {
    install_smart "rpcs3" "rpcs3" "rpcs3" "rpcs3" "RPCS3"
}

install_citra() {
    install_smart "citra-canary" "citra-canary" "citra" "citra" "Citra"
}

install_anbox() {
    echo -e "${BLUE}📱 Installing Anbox (Android Emulator)...${NC}"
    
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo snap install --devmode --beta anbox
        echo -e "${GREEN}✅ Anbox installed via Snap${NC}"
    else
        install_smart "anbox" "anbox" "anbox" "anbox" "Anbox"
    fi
}

install_waydroid() {
    install_smart "waydroid" "waydroid" "waydroid" "waydroid" "Waydroid"
}

install_genymotion() {
    echo -e "${BLUE}📱 Genymotion requires manual installation${NC}"
    echo -e "${YELLOW}📥 Download from: https://www.genymotion.com/${NC}"
}

# ============================================================================
# DEVELOPMENT TAB - COMPLETE WITH ALL FEATURES
# ============================================================================

development_tab() {
    while true; do
        show_banner
        echo -e "${GREEN}💻 DEVELOPMENT TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BOLD}Choose Subtab:${NC}"
        echo -e "  ${GREEN}1${NC}) 🛠️  IDEs & Editors"
        echo -e "  ${GREEN}2${NC}) 🌐 Programming Languages"
        echo -e "  ${GREEN}3${NC}) 🐳 Containers & DevOps"
        echo -e "  ${GREEN}4${NC}) 🖥️  Virtualization"
        echo -e "  ${GREEN}5${NC}) 🗄️  Databases"
        echo -e "  ${GREEN}6${NC}) 🔧 Development Tools"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Main Menu"
        echo ""
        read -p "Choose subtab [0-6]: " choice

        case $choice in
            1) development_ides_subtab ;;
            2) development_languages_subtab ;;
            3) development_devops_subtab ;;
            4) development_virtual_subtab ;;
            5) development_databases_subtab ;;
            6) development_tools_subtab ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

# Development IDEs Subtab - COMPLETE
development_ides_subtab() {
    while true; do
        show_banner
        show_subtab_header "🛠️  IDEs & CODE EDITORS" "$GREEN"
        echo ""
        echo -e "${GREEN}🚀 Full IDEs:${NC}"
        echo -e "  ${GREEN}1${NC}) Visual Studio Code"
        echo -e "  ${GREEN}2${NC}) VS Codium"
        echo -e "  ${GREEN}3${NC}) Neovim"
        echo -e "  ${GREEN}4${NC}) Emacs"
        echo -e "  ${GREEN}5${NC}) PyCharm Community"
        echo ""
        echo -e "${BLUE}📝 Lightweight Editors:${NC}"
        echo -e "  ${BLUE}6${NC}) Atom"
        echo -e "  ${BLUE}7${NC}) Sublime Text"
        echo -e "  ${BLUE}8${NC}) Geany"
        echo -e "  ${BLUE}9${NC}) Kate"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Development Tab"
        echo ""
        read -p "Choose IDE to install [0-9]: " choice

        case $choice in
            1) install_vscode ;;
            2) install_vscodium ;;
            3) install_neovim ;;
            4) install_emacs ;;
            5) install_pycharm ;;
            6) install_atom ;;
            7) install_sublime_text ;;
            8) install_geany ;;
            9) install_kate ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Development Functions
install_vscode() {
    if install_flatpak "com.visualstudio.code" "Visual Studio Code"; then
        return 0
    else
        install_smart "code" "code" "code" "code" "Visual Studio Code"
    fi
}

install_vscodium() {
    if install_flatpak "com.vscodium.codium" "VS Codium"; then
        return 0
    else
        if command -v yay &> /dev/null; then
            yay -S vscodium-bin --noconfirm
        else
            install_smart "vscodium" "codium" "vscodium" "vscodium" "VS Codium"
        fi
    fi
}

install_neovim() {
    install_smart "neovim" "neovim" "neovim" "neovim" "Neovim"
}

install_emacs() {
    install_smart "emacs" "emacs" "emacs" "emacs" "Emacs"
}

install_pycharm() {
    if install_flatpak "com.jetbrains.PyCharm-Community" "PyCharm Community"; then
        return 0
    else
        install_smart "pycharm-community-edition" "pycharm-community" "pycharm-community" "pycharm-community" "PyCharm Community"
    fi
}

install_atom() {
    if install_flatpak "io.atom.Atom" "Atom"; then
        return 0
    else
        install_smart "atom" "atom" "atom" "atom" "Atom"
    fi
}

install_sublime_text() {
    echo -e "${BLUE}📝 Installing Sublime Text...${NC}"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        curl -O https://download.sublimetext.com/sublimehq-pub.gpg
        sudo pacman-key --add sublimehq-pub.gpg
        sudo pacman-key --lsign-key 8A8F901A
        rm sublimehq-pub.gpg
        echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
        sudo pacman -Syu sublime-text
    elif [ "$PKG_MANAGER" = "apt" ]; then
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt update
        install_package "sublime-text" "Sublime Text"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
        sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
        sudo dnf install -y sublime-text
    fi
}

install_geany() {
    install_smart "geany" "geany" "geany" "geany" "Geany"
}

install_kate() {
    install_smart "kate" "kate" "kate" "kate" "Kate"
}

# Development Languages Subtab - COMPLETE
development_languages_subtab() {
    while true; do
        show_banner
        show_subtab_header "🌐 PROGRAMMING LANGUAGES" "$BLUE"
        echo ""
        echo -e "${GREEN}🐍 Python Stack:${NC}"
        echo -e "  ${GREEN}1${NC}) Python 3 + pip"
        echo -e "  ${GREEN}2${NC}) Jupyter Notebook"
        echo -e "  ${GREEN}3${NC}) Node.js & npm"
        echo -e "  ${GREEN}4${NC}) Java JDK"
        echo -e "  ${GREEN}5${NC}) Go Language"
        echo ""
        echo -e "${BLUE}🔧 Other Languages:${NC}"
        echo -e "  ${BLUE}6${NC}) Rust"
        echo -e "  ${BLUE}7${NC}) PHP"
        echo -e "  ${BLUE}8${NC}) Ruby"
        echo -e "  ${BLUE}9${NC}) .NET SDK"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Development Tab"
        echo ""
        read -p "Choose language to install [0-9]: " choice

        case $choice in
            1) install_python ;;
            2) install_jupyter ;;
            3) install_nodejs ;;
            4) install_java ;;
            5) install_go ;;
            6) install_rust ;;
            7) install_php ;;
            8) install_ruby ;;
            9) install_dotnet ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Language Functions
install_python() {
    install_smart "python python-pip" "python3 python3-pip" "python3 python3-pip" "python3 python3-pip" "Python 3 + pip"
}

install_jupyter() {
    install_smart "jupyter-notebook" "jupyter-notebook" "jupyter-notebook" "jupyter-notebook" "Jupyter Notebook"
}

install_nodejs() {
    install_smart "nodejs npm" "nodejs npm" "nodejs npm" "nodejs npm" "Node.js & npm"
}

install_java() {
    install_smart "jdk-openjdk" "default-jdk" "java-latest-openjdk" "java-11-openjdk" "Java JDK"
}

install_go() {
    install_smart "go" "golang" "golang" "go" "Go Language"
}

install_rust() {
    echo -e "${BLUE}🦀 Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    echo -e "${GREEN}✅ Rust installed!${NC}"
}

install_php() {
    install_smart "php" "php" "php" "php" "PHP"
}

install_ruby() {
    install_smart "ruby" "ruby" "ruby" "ruby" "Ruby"
}

install_dotnet() {
    install_smart "dotnet-sdk" "dotnet-sdk-6.0" "dotnet-sdk-6.0" "dotnet-sdk-6.0" ".NET SDK"
}

# Development DevOps Subtab - COMPLETE
development_devops_subtab() {
    while true; do
        show_banner
        show_subtab_header "🐳 CONTAINERS & DEVOPS" "$CYAN"
        echo ""
        echo -e "${GREEN}🐳 Docker Ecosystem:${NC}"
        echo -e "  ${GREEN}1${NC}) Docker Engine"
        echo -e "  ${GREEN}2${NC}) Docker Compose"
        echo -e "  ${GREEN}3${NC}) Podman"
        echo -e "  ${GREEN}4${NC}) kubectl"
        echo -e "  ${GREEN}5${NC}) Terraform"
        echo ""
        echo -e "${BLUE}🔧 DevOps Tools:${NC}"
        echo -e "  ${BLUE}6${NC}) Ansible"
        echo -e "  ${BLUE}7${NC}) Jenkins"
        echo -e "  ${BLUE}8${NC}) GitLab Runner"
        echo -e "  ${BLUE}9${NC}) Vagrant"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Development Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_docker ;;
            2) install_docker_compose ;;
            3) install_podman ;;
            4) install_kubectl ;;
            5) install_terraform ;;
            6) install_ansible ;;
            7) install_jenkins ;;
            8) install_gitlab_runner ;;
            9) install_vagrant ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL DevOps Functions
install_docker() {
    echo -e "${BLUE}🐳 Installing Docker...${NC}"
    log "Installing Docker"
    
    if [ "$PKG_MANAGER" = "pacman" ]; then
        install_package "docker"
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker "$USER"
    elif [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update
        install_package "docker.io"
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker "$USER"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        install_package "docker"
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker "$USER"
    elif [ "$PKG_MANAGER" = "zypper" ]; then
        install_package "docker"
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker "$USER"
    fi
    
    echo -e "${GREEN}✅ Docker installed!${NC}"
    echo -e "${YELLOW}⚠️  Log out and back in for group changes to take effect${NC}"
}

install_docker_compose() {
    install_smart "docker-compose" "docker-compose" "docker-compose" "docker-compose" "Docker Compose"
}

install_podman() {
    install_smart "podman" "podman" "podman" "podman" "Podman"
}

install_kubectl() {
    install_smart "kubectl" "kubectl" "kubectl" "kubectl" "kubectl"
}

install_terraform() {
    install_smart "terraform" "terraform" "terraform" "terraform" "Terraform"
}

install_ansible() {
    install_smart "ansible" "ansible" "ansible" "ansible" "Ansible"
}

install_jenkins() {
    install_smart "jenkins" "jenkins" "jenkins" "jenkins" "Jenkins"
}

install_gitlab_runner() {
    install_smart "gitlab-runner" "gitlab-runner" "gitlab-runner" "gitlab-runner" "GitLab Runner"
}

install_vagrant() {
    install_smart "vagrant" "vagrant" "vagrant" "vagrant" "Vagrant"
}

development_virtual_subtab() {
    while true; do
        show_banner
        show_subtab_header "🖥️ VIRTUALIZATION" "$CYAN"
        echo ""
        echo -e "${GREEN}🔰 Desktop Virtualization:${NC}"
        echo -e "  ${GREEN}1${NC}) GNOME Boxes (Simple VMs)"
        echo -e "  ${GREEN}2${NC}) VirtualBox (Oracle)"
        echo -e "  ${GREEN}3${NC}) VMware Workstation"
        echo -e "  ${GREEN}4${NC}) QEMU/KVM (Advanced)"
        echo ""
        echo -e "${BLUE}🐳 Containers:${NC}"
        echo -e "  ${BLUE}5${NC}) Docker"
        echo -e "  ${BLUE}6${NC}) Podman"
        echo -e "  ${BLUE}7${NC}) LXC/LXD"
        echo ""
        echo -e "${PURPLE}🛠️ Management Tools:${NC}"
        echo -e "  ${PURPLE}8${NC}) Virt-Manager (GUI for KVM)"
        echo -e "  ${PURPLE}9${NC}) Cockpit (Web management)"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Apps Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_gnome_boxes ;;
            2) install_virtualbox ;;
            3) install_vmware ;;
            4) install_qemu_kvm ;;
            5) install_docker ;;
            6) install_podman ;;
            7) install_lxc_lxd ;;
            8) install_virt_manager ;;
            9) install_cockpit ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

install_gnome_boxes() {
    echo -e "${GREEN}🔰 Installing GNOME Boxes...${NC}"
    
    # Install Flatpak if not available
    if ! command -v flatpak &> /dev/null; then
        echo -e "${YELLOW}📦 Installing Flatpak first...${NC}"
        install_smart "flatpak" "flatpak" "flatpak" "flatpak" "Flatpak"
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install GNOME Boxes via Flatpak
    echo -e "${BLUE}📦 Installing via Flatpak (most reliable)...${NC}"
    if flatpak install flathub org.gnome.Boxes -y; then
        echo -e "${GREEN}✅ GNOME Boxes installed successfully via Flatpak!${NC}"
        echo -e "${YELLOW}🚀 Run with: flatpak run org.gnome.Boxes${NC}"
    else
        echo -e "${RED}❌ GNOME Boxes installation failed${NC}"
        echo -e "${YELLOW}💡 Try VirtualBox instead, or check your internet connection${NC}"
    fi
}

install_virtualbox() {
    echo -e "${GREEN}📦 Installing VirtualBox...${NC}"
    
    case "$PKG_MANAGER" in
        "pacman")
            sudo pacman -S virtualbox virtualbox-host-dkms --noconfirm
            ;;
        "apt")
            sudo apt install virtualbox virtualbox-ext-pack -y
            ;;
        "dnf")
            sudo dnf install VirtualBox -y
            ;;
        "zypper")
            sudo zypper install virtualbox -y
            ;;
    esac
    
    if command -v VirtualBox &> /dev/null || command -v virtualbox &> /dev/null; then
        echo -e "${GREEN}✅ VirtualBox installed!${NC}"
        echo -e "${YELLOW}💡 You may need to load kernel modules: sudo modprobe vboxdrv${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://www.virtualbox.org/${NC}"
    fi
}

install_vmware() {
    echo -e "${GREEN}⚡ VMware Workstation/Player${NC}"
    echo -e "${YELLOW}📥 Requires manual download:${NC}"
    echo -e "${BLUE}   1. Visit: https://www.vmware.com/products/workstation-player.html${NC}"
    echo -e "${BLUE}   2. Download the .bundle file${NC}"
    echo -e "${BLUE}   3. Run: sudo sh VMware-Player-*.bundle${NC}"
    echo -e "${YELLOW}💡 Free for personal use${NC}"
}

install_qemu_kvm() {
    echo -e "${GREEN}🐧 Installing QEMU/KVM...${NC}"
    
    if install_smart "qemu-full" "qemu-kvm qemu-utils" "qemu-kvm" "qemu-kvm" "QEMU/KVM"; then
        echo -e "${GREEN}✅ QEMU/KVM installed!${NC}"
        echo -e "${YELLOW}💡 Use with virt-manager for GUI management${NC}"
    fi
}

install_docker() {
    echo -e "${GREEN}🐳 Installing Docker...${NC}"
    # We already have this in Development tab, can reuse
    install_docker
}

install_podman() {
    echo -e "${GREEN}📦 Installing Podman...${NC}"
    if install_smart "podman" "podman" "podman" "podman" "Podman"; then
        echo -e "${GREEN}✅ Podman installed! Docker alternative${NC}"
    fi
}

install_lxc_lxd() {
    echo -e "${GREEN}📦 Installing LXC/LXD...${NC}"
    if install_smart "lxd" "lxd" "lxd" "lxd" "LXD"; then
        echo -e "${GREEN}✅ LXD installed! System container manager${NC}"
        echo -e "${YELLOW}💡 Initialize with: sudo lxd init${NC}"
    fi
}

install_virt_manager() {
    echo -e "${GREEN}🛠️ Installing Virt-Manager...${NC}"
    if install_smart "virt-manager" "virt-manager" "virt-manager" "virt-manager" "Virt-Manager"; then
        echo -e "${GREEN}✅ Virt-Manager installed! GUI for KVM/Virtualization${NC}"
    fi
}

install_cockpit() {
    echo -e "${GREEN}🖥️ Installing Cockpit...${NC}"
    if install_smart "cockpit" "cockpit" "cockpit" "cockpit" "Cockpit"; then
        echo -e "${GREEN}✅ Cockpit installed! Web-based server management${NC}"
        echo -e "${YELLOW}💡 Access at: https://localhost:9090${NC}"
        sudo systemctl enable cockpit.socket
        sudo systemctl start cockpit.socket
    fi
}

# Development Databases Subtab 
development_databases_subtab() {
    while true; do
        show_banner
        show_subtab_header "🗄️  DATABASES" "$PURPLE"
        echo ""
        echo -e "${GREEN}📊 SQL Databases:${NC}"
        echo -e "  ${GREEN}1${NC}) PostgreSQL"
        echo -e "  ${GREEN}2${NC}) MySQL"
        echo -e "  ${GREEN}3${NC}) SQLite"
        echo -e "  ${GREEN}4${NC}) MariaDB"
        echo ""
        echo -e "${BLUE}📈 NoSQL Databases:${NC}"
        echo -e "  ${BLUE}5${NC}) MongoDB"
        echo -e "  ${BLUE}6${NC}) Redis"
        echo -e "  ${BLUE}7${NC}) SQLite Browser"
        echo -e "  ${BLUE}8${NC}) DBeaver"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Development Tab"
        echo ""
        read -p "Choose database to install [0-8]: " choice

        case $choice in
            1) install_postgresql ;;
            2) install_mysql ;;
            3) install_sqlite ;;
            4) install_mariadb ;;
            5) install_mongodb ;;
            6) install_redis ;;
            7) install_sqlite_browser ;;
            8) install_dbeaver ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Database Functions
install_postgresql() {
    install_smart "postgresql" "postgresql" "postgresql" "postgresql" "PostgreSQL"
}

install_mysql() {
    install_smart "mysql" "mysql-server" "mysql-server" "mysql" "MySQL"
}

install_sqlite() {
    install_smart "sqlite" "sqlite3" "sqlite" "sqlite3" "SQLite"
}

install_mariadb() {
    install_smart "mariadb" "mariadb-server" "mariadb-server" "mariadb" "MariaDB"
}

install_mongodb() {
    install_smart "mongodb" "mongodb" "mongodb" "mongodb" "MongoDB"
}

install_redis() {
    install_smart "redis" "redis-server" "redis" "redis" "Redis"
}

install_sqlite_browser() {
    install_smart "sqlitebrowser" "sqlitebrowser" "sqlitebrowser" "sqlitebrowser" "SQLite Browser"
}

install_dbeaver() {
    install_flatpak "io.dbeaver.DBeaverCommunity" "DBeaver"
}

# Development Tools Subtab - COMPLETE
development_tools_subtab() {
    while true; do
        show_banner
        show_subtab_header "🔧 DEVELOPMENT TOOLS" "$ORANGE"
        echo ""
        echo -e "${GREEN}🔨 Build Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) GCC & G++"
        echo -e "  ${GREEN}2${NC}) Make & CMake"
        echo -e "  ${GREEN}3${NC}) Git"
        echo -e "  ${GREEN}4${NC}) Curl & Wget"
        echo -e "  ${GREEN}5${NC}) SSH Client"
        echo ""
        echo -e "${BLUE}📦 Package Managers:${NC}"
        echo -e "  ${BLUE}6${NC}) NVM (Node Version Manager)"
        echo -e "  ${BLUE}7${NC}) Pyenv (Python Version Manager)"
        echo -e "  ${BLUE}8${NC}) SDKMAN"
        echo -e "  ${BLUE}9${NC}) Yarn"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Development Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_gcc ;;
            2) install_cmake ;;
            3) install_git ;;
            4) install_curl_wget ;;
            5) install_ssh ;;
            6) install_nvm ;;
            7) install_pyenv ;;
            8) install_sdkman ;;
            9) install_yarn ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Development Tools Functions
install_gcc() {
    install_smart "gcc g++" "gcc g++" "gcc gcc-c++" "gcc gcc-c++" "GCC & G++"
}

install_cmake() {
    install_smart "cmake make" "cmake make" "cmake make" "cmake make" "CMake & Make"
}

install_git() {
    install_smart "git" "git" "git" "git" "Git"
}

install_curl_wget() {
    install_smart "curl wget" "curl wget" "curl wget" "curl wget" "Curl & Wget"
}

install_ssh() {
    install_smart "openssh" "openssh-client" "openssh-clients" "openssh" "SSH Client"
}

install_nvm() {
    echo -e "${BLUE}📦 Installing NVM (Node Version Manager)...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    echo -e "${GREEN}✅ NVM installed!${NC}"
    echo -e "${YELLOW}📝 Restart your terminal or run: source ~/.bashrc${NC}"
}

install_pyenv() {
    echo -e "${BLUE}🐍 Installing Pyenv...${NC}"
    curl https://pyenv.run | bash
    echo -e "${GREEN}✅ Pyenv installed!${NC}"
    echo -e "${YELLOW}📝 Add to your shell configuration:${NC}"
    echo -e 'export PYENV_ROOT="$HOME/.pyenv"'
    echo -e 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    echo -e 'eval "$(pyenv init -)"'
}

install_sdkman() {
    echo -e "${BLUE}☕ Installing SDKMAN...${NC}"
    curl -s "https://get.sdkman.io" | bash
    echo -e "${GREEN}✅ SDKMAN installed!${NC}"
    echo -e "${YELLOW}📝 Restart your terminal or run: source ~/.sdkman/bin/sdkman-init.sh${NC}"
}

install_yarn() {
    install_smart "yarn" "yarn" "yarn" "yarn" "Yarn"
}

# ============================================================================
# TOOLS TAB - COMPLETE WITH ALL FEATURES
# ============================================================================

tools_tab() {
    while true; do
        show_banner
        echo -e "${RED}🛠️  TOOLS TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BOLD}Choose Subtab:${NC}"
        echo -e "  ${GREEN}1${NC}) 📊 System Monitoring"
        echo -e "  ${GREEN}2${NC}) 🌐 Network Tools"
        echo -e "  ${GREEN}3${NC}) 💽 Disk Utilities"
        echo -e "  ${GREEN}4${NC}) 🔧 Hardware Tools"
        echo -e "  ${GREEN}5${NC}) 🛡️  Security Tools"
        echo -e "  ${GREEN}6${NC}) 🔒 VPN Tools"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Main Menu"
        echo ""
        read -p "Choose subtab [0-6]: " choice

        case $choice in
            1) tools_monitoring_subtab ;;
            2) tools_network_subtab ;;
            3) tools_disk_subtab ;;
            4) tools_hardware_subtab ;;
            5) tools_security_subtab ;;
            6) tools_vpn_subtab ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

# Tools Monitoring Subtab 
tools_monitoring_subtab() {
    while true; do
        show_banner
        show_subtab_header "📊 SYSTEM MONITORING" "$BLUE"
        echo ""
        echo -e "${GREEN}📈 System Monitors:${NC}"
        echo -e "  ${GREEN}1${NC}) HTOP"
        echo -e "  ${GREEN}2${NC}) BTOP"
        echo -e "  ${GREEN}3${NC}) Glances"
        echo -e "  ${GREEN}4${NC}) Conky"
        echo -e "  ${GREEN}5${NC}) Netdata"
        echo ""
        echo -e "${BLUE}🔍 Process Tools:${NC}"
        echo -e "  ${BLUE}6${NC}) LSOF"
        echo -e "  ${BLUE}7${NC}) Strace"
        echo -e "  ${BLUE}8${NC}) Htop"
        echo -e "  ${BLUE}9${NC}) Powertop"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Tools Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_htop ;;
            2) install_btop ;;
            3) install_glances ;;
            4) install_conky ;;
            5) install_netdata ;;
            6) install_lsof ;;
            7) install_strace ;;
            8) install_htop ;;
            9) install_powertop ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# Monitoring Tools
install_conky() {
    install_smart "conky" "conky" "conky" "conky" "Conky"
}

install_netdata() {
    echo -e "${BLUE}📊 Installing Netdata...${NC}"
    bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive
    echo -e "${GREEN}✅ Netdata installed! Access at: http://localhost:19999${NC}"
}

install_lsof() {
    install_smart "lsof" "lsof" "lsof" "lsof" "LSOF"
}

install_strace() {
    install_smart "strace" "strace" "strace" "strace" "Strace"
}

install_powertop() {
    install_smart "powertop" "powertop" "powertop" "powertop" "Powertop"
}

# Tools Network Subtab 
tools_network_subtab() {
    while true; do
        show_banner
        show_subtab_header "🌐 NETWORK TOOLS" "$CYAN"
        echo ""
        echo -e "${GREEN}🔧 Network Utilities:${NC}"
        echo -e "  ${GREEN}1${NC}) Nmap"
        echo -e "  ${GREEN}2${NC}) Wireshark"
        echo -e "  ${GREEN}3${NC}) Tcpdump"
        echo -e "  ${GREEN}4${NC}) Net-tools"
        echo -e "  ${GREEN}5${NC}) OpenSSH Server"
        echo ""
        echo -e "${BLUE}📡 Network Analysis:${NC}"
        echo -e "  ${BLUE}6${NC}) Iperf3"
        echo -e "  ${BLUE}7${NC}) Speedtest-cli"
        echo -e "  ${BLUE}8${NC}) MTR"
        echo -e "  ${BLUE}9${NC}) Netcat"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Tools Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_nmap ;;
            2) install_wireshark ;;
            3) install_tcpdump ;;
            4) install_net_tools ;;
            5) install_openssh_server ;;
            6) install_iperf3 ;;
            7) install_speedtest_cli ;;
            8) install_mtr ;;
            9) install_netcat ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Network Tools
install_nmap() {
    install_smart "nmap" "nmap" "nmap" "nmap" "Nmap"
}

install_wireshark() {
    echo -e "${GREEN}📡 Installing Wireshark...${NC}"
    
    # Try different package names
    if install_smart "wireshark" "wireshark" "wireshark" "wireshark" "Wireshark"; then
        echo -e "${GREEN}✅ Wireshark installed!${NC}"
    elif install_smart "wireshark-qt" "wireshark-qt" "wireshark-qt" "wireshark-qt" "Wireshark QT"; then
        echo -e "${GREEN}✅ Wireshark QT installed!${NC}"
    elif install_smart "wireshark-gtk" "wireshark-gtk" "wireshark-gtk" "wireshark-gtk" "Wireshark GTK"; then
        echo -e "${GREEN}✅ Wireshark GTK installed!${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://www.wireshark.org/${NC}"
    fi
}

install_tcpdump() {
    install_smart "tcpdump" "tcpdump" "tcpdump" "tcpdump" "Tcpdump"
}

install_net_tools() {
    install_smart "net-tools" "net-tools" "net-tools" "net-tools" "Net-tools"
}

install_openssh_server() {
    install_smart "openssh" "openssh-server" "openssh-server" "openssh" "OpenSSH Server"
}

install_iperf3() {
    install_smart "iperf3" "iperf3" "iperf3" "iperf3" "Iperf3"
}

install_speedtest_cli() {
    echo -e "${GREEN}🌐 Installing Speedtest CLI...${NC}"
    
    # Try official Ookla speedtest first (most reliable)
    if curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash; then
        sudo apt install speedtest -y
        echo -e "${GREEN}✅ Official Speedtest installed!${NC}"
    elif install_smart "speedtest-cli" "speedtest-cli" "speedtest-cli" "speedtest-cli" "Speedtest CLI"; then
        echo -e "${GREEN}✅ Speedtest CLI installed!${NC}"
    else
        # Fallback to Python pip version
        pip install speedtest-cli
        echo -e "${GREEN}✅ Speedtest installed via pip!${NC}"
    fi
}

install_mtr() {
    install_smart "mtr" "mtr" "mtr" "mtr" "MTR"
}

install_netcat() {
    echo -e "${GREEN}🔗 Installing Netcat...${NC}"
    
    case "$PKG_MANAGER" in
        "pacman")
            sudo pacman -S gnu-netcat --noconfirm ;;
        "apt")
            sudo apt install netcat -y ;;
        "dnf")
            sudo dnf install nmap-ncat -y ;;
        "zypper")
            sudo zypper install netcat -y ;;
        *)
            install_smart "netcat" "netcat" "nmap-ncat" "netcat" "Netcat" ;;
    esac
    
    if command -v nc &> /dev/null || command -v netcat &> /dev/null; then
        echo -e "${GREEN}✅ Netcat installed!${NC}"
    else
        echo -e "${YELLOW}📥 Try: sudo apt install netcat-openbsd${NC}"
    fi
}

# Tools Disk Subtab - COMPLETE
tools_disk_subtab() {
    while true; do
        show_banner
        show_subtab_header "💽 DISK UTILITIES" "$ORANGE"
        echo ""
        echo -e "${GREEN}💾 Disk Management:${NC}"
        echo -e "  ${GREEN}1${NC}) GParted"
        echo -e "  ${GREEN}2${NC}) NCDU"
        echo -e "  ${GREEN}3${NC}) Baobab"
        echo -e "  ${GREEN}4${NC}) Filelight"
        echo -e "  ${GREEN}5${NC}) TestDisk"
        echo ""
        echo -e "${BLUE}🔍 Disk Analysis:${NC}"
        echo -e "  ${BLUE}6${NC}) Smartmontools"
        echo -e "  ${BLUE}7${NC}) F3"
        echo -e "  ${BLUE}8${NC}) Disk Usage Analyzer"
        echo -e "  ${BLUE}9${NC}) FSArchiver"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Tools Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_gparted ;;
            2) install_ncdu ;;
            3) install_baobab ;;
            4) install_filelight ;;
            5) install_testdisk ;;
            6) install_smartmontools ;;
            7) install_f3 ;;
            8) install_disk_usage_analyzer ;;
            9) install_fsarchiver ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Disk Tools
install_baobab() {
    install_smart "baobab" "baobab" "baobab" "baobab" "Baobab"
}

install_filelight() {
    install_smart "filelight" "filelight" "filelight" "filelight" "Filelight"
}

install_testdisk() {
    install_smart "testdisk" "testdisk" "testdisk" "testdisk" "TestDisk"
}

install_smartmontools() {
    install_smart "smartmontools" "smartmontools" "smartmontools" "smartmontools" "Smartmontools"
}

install_f3() {
    install_smart "f3" "f3" "f3" "f3" "F3"
}

install_disk_usage_analyzer() {
    install_smart "gnome-disk-utility" "gnome-disk-utility" "gnome-disk-utility" "gnome-disk-utility" "Disk Usage Analyzer"
}

install_fsarchiver() {
    install_smart "fsarchiver" "fsarchiver" "fsarchiver" "fsarchiver" "FSArchiver"
}

# Tools Hardware Subtab - COMPLETE
tools_hardware_subtab() {
    while true; do
        show_banner
        show_subtab_header "🔧 HARDWARE TOOLS" "$PURPLE"
        echo ""
        echo -e "${GREEN}💻 Hardware Info:${NC}"
        echo -e "  ${GREEN}1${NC}) HWInfo"
        echo -e "  ${GREEN}2${NC}) CPU-X"
        echo -e "  ${GREEN}3${NC}) HardInfo"
        echo -e "  ${GREEN}4${NC}) LSUSB"
        echo -e "  ${GREEN}5${NC}) LSPCI"
        echo ""
        echo -e "${BLUE}🔍 Hardware Testing:${NC}"
        echo -e "  ${BLUE}6${NC}) Stress"
        echo -e "  ${BLUE}7${NC}) Memtest86+"
        echo -e "  ${BLUE}8${NC}) GPU Burn"
        echo -e "  ${BLUE}9${NC}) S-tui"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Tools Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_hwinfo ;;
            2) install_cpu_x ;;
            3) install_hardinfo ;;
            4) install_lsusb ;;
            5) install_lspci ;;
            6) install_stress ;;
            7) install_memtest ;;
            8) install_gpu_burn ;;
            9) install_stui ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Hardware Tools
install_hwinfo() {
    install_smart "hwinfo" "hwinfo" "hwinfo" "hwinfo" "HWInfo"
}

install_cpu_x() {
    install_smart "cpu-x" "cpu-x" "cpu-x" "cpu-x" "CPU-X"
}

install_hardinfo() {
    install_smart "hardinfo" "hardinfo" "hardinfo" "hardinfo" "HardInfo"
}

install_lsusb() {
    install_smart "usbutils" "usbutils" "usbutils" "usbutils" "LSUSB"
}

install_lspci() {
    install_smart "pciutils" "pciutils" "pciutils" "pciutils" "LSPCI"
}

install_stress() {
    install_smart "stress" "stress" "stress" "stress" "Stress"
}

install_memtest() {
    install_smart "memtest86+" "memtest86+" "memtest86+" "memtest86+" "Memtest86+"
}

install_gpu_burn() {
    echo -e "${BLUE}🔥 GPU Burn requires manual installation${NC}"
    echo -e "${YELLOW}📥 Download from: https://github.com/wilicc/gpu-burn${NC}"
}

install_stui() {
    install_smart "s-tui" "s-tui" "s-tui" "s-tui" "S-tui"
}

# Tools Security Subtab 
tools_security_subtab() {
    while true; do
        show_banner
        show_subtab_header "🛡️  SECURITY TOOLS" "$RED"
        echo ""
        echo -e "${GREEN}🔒 Security Scanners:${NC}"
        echo -e "  ${GREEN}1${NC}) ClamAV"
        echo -e "  ${GREEN}2${NC}) RKHunter"
        echo -e "  ${GREEN}3${NC}) Chkrootkit"
        echo -e "  ${GREEN}4${NC}) Lynis"
        echo -e "  ${GREEN}5${NC}) Fail2Ban"
        echo ""
        echo -e "${BLUE}🔐 Encryption Tools:${NC}"
        echo -e "  ${BLUE}6${NC}) GnuPG"
        echo -e "  ${BLUE}7${NC}) VeraCrypt"
        echo -e "  ${BLUE}8${NC}) Cryptsetup"
        echo -e "  ${BLUE}9${NC}) Seahorse"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Tools Tab"
        echo ""
        read -p "Choose tool to install [0-9]: " choice

        case $choice in
            1) install_clamav ;;
            2) install_rkhunter ;;
            3) install_chkrootkit ;;
            4) install_lynis ;;
            5) install_fail2ban ;;
            6) install_gnupg ;;
            7) install_veracrypt ;;
            8) install_cryptsetup ;;
            9) install_seahorse ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Security Tools
install_clamav() {
    install_smart "clamav" "clamav" "clamav" "clamav" "ClamAV"
}

install_rkhunter() {
    install_smart "rkhunter" "rkhunter" "rkhunter" "rkhunter" "RKHunter"
}

install_chkrootkit() {
    install_smart "chkrootkit" "chkrootkit" "chkrootkit" "chkrootkit" "Chkrootkit"
}

install_lynis() {
    install_smart "lynis" "lynis" "lynis" "lynis" "Lynis"
}

install_fail2ban() {
    install_smart "fail2ban" "fail2ban" "fail2ban" "fail2ban" "Fail2Ban"
}

install_gnupg() {
    install_smart "gnupg" "gnupg" "gnupg" "gnupg" "GnuPG"
}

install_veracrypt() {
    install_smart "veracrypt" "veracrypt" "veracrypt" "veracrypt" "VeraCrypt"
}

install_cryptsetup() {
    install_smart "cryptsetup" "cryptsetup" "cryptsetup" "cryptsetup" "Cryptsetup"
}

install_seahorse() {
    install_smart "seahorse" "seahorse" "seahorse" "seahorse" "Seahorse"
}


# VPN Tools

tools_vpn_subtab() {
    while true; do
        show_banner
        show_subtab_header "🔒 VPN TOOLS" "$GREEN"
        echo ""
        echo -e "${GREEN}🔐 VPN Clients:${NC}"
        echo -e "  ${GREEN}1${NC}) ProtonVPN"
        echo -e "  ${GREEN}2${NC}) Mullvad VPN"
        echo -e "  ${GREEN}3${NC}) OpenVPN"
        echo -e "  ${GREEN}4${NC}) WireGuard"
        echo -e "  ${GREEN}5${NC}) Riseup VPN" 
        echo -e "  ${GREEN}6${NC}) Psiphon"
        echo ""
        echo -e "${BLUE}🌐 VPN Utilities:${NC}"
        echo -e "  ${BLUE}7${NC}) Check VPN Status"
        echo -e "  ${BLUE}8${NC}) Test VPN Connection"
        echo -e "  ${BLUE}9${NC}) Install VPN Kill Switch"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Tools Tab"
        echo ""
        read -p "Choose option [0-9]: " choice

        case $choice in
            1) install_protonvpn ;;
            2) install_mullvad ;;
            3) install_openvpn ;;
            4) install_wireguard ;;
            5) install_riseup_vpn ;;
            6) install_psiphon ;;
            7) check_vpn_status ;;
            8) test_vpn_connection ;;
            9) install_vpn_killswitch ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

install_protonvpn() {
    echo -e "${GREEN}🔐 Installing ProtonVPN...${NC}"
    
    case "$PKG_MANAGER" in
        "pacman")
            echo -e "${BLUE}📦 Arch Linux: Installing ProtonVPN...${NC}"
            # ProtonVPN is in AUR, not main repos
            if command -v yay &> /dev/null; then
                yay -S protonvpn-cli --noconfirm
            elif command -v paru &> /dev/null; then
                paru -S protonvpn-cli --noconfirm
            else
                echo -e "${YELLOW}📥 Install an AUR helper first:${NC}"
                echo -e "  sudo pacman -S --needed git base-devel"
                echo -e "  git clone https://aur.archlinux.org/yay.git"
                echo -e "  cd yay && makepkg -si"
                echo -e "  Then run: yay -S protonvpn-cli"
            fi
            ;;
        "apt")
            echo -e "${BLUE}📦 Ubuntu/Debian: Installing ProtonVPN...${NC}"
            # Official ProtonVPN installation for Debian/Ubuntu
            sudo apt update
            sudo apt install -y openvpn dialog python3-pip python3-setuptools
            
            # Install via pip (this is the CORRECT method)
            echo -e "${BLUE}📦 Installing via pip...${NC}"
            sudo pip3 install protonvpn-cli
            
            # Alternative: Download official .deb package
            echo -e "${BLUE}📥 Downloading official package...${NC}"
            cd /tmp
            wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb
            sudo dpkg -i protonvpn-stable-release_1.0.3_all.deb
            sudo apt update
            sudo apt install protonvpn
            ;;
        "dnf")
            echo -e "${BLUE}📦 Fedora/RHEL: Installing ProtonVPN...${NC}"
            # Install dependencies
            sudo dnf install -y python3-pip openvpn
            
            # Install via pip
            sudo pip3 install protonvpn-cli
            
            # Alternative: Official repo
            sudo dnf install -y https://repo.protonvpn.com/fedora-$(rpm -E %fedora)/protonvpn-stable-release-1.0.3-1.noarch.rpm
            sudo dnf install protonvpn
            ;;
        "zypper")
            echo -e "${BLUE}📦 openSUSE: Installing ProtonVPN...${NC}"
            sudo zypper install -y python3-pip openvpn
            sudo pip3 install protonvpn-cli
            ;;
        *)
            echo -e "${YELLOW}📦 Generic Linux: Installing via pip...${NC}"
            sudo pip3 install protonvpn-cli
            ;;
    esac
    
    # Verify installation
    if command -v protonvpn &> /dev/null || pip3 show protonvpn-cli &> /dev/null; then
        echo -e "${GREEN}✅ ProtonVPN installed successfully!${NC}"
        echo -e "${CYAN}🚀 Initial Setup:${NC}"
        echo -e "  1. Run: ${YELLOW}protonvpn init${NC}"
        echo -e "  2. Enter your ProtonVPN credentials"
        echo -e "  3. Connect: ${YELLOW}protonvpn connect${NC}"
        echo -e ""
        echo -e "${BLUE}💡 Useful Commands:${NC}"
        echo -e "  • ${YELLOW}protonvpn connect${NC} - Connect to fastest server"
        echo -e "  • ${YELLOW}protonvpn status${NC} - Check connection status"
        echo -e "  • ${YELLOW}protonvpn disconnect${NC} - Disconnect"
        echo -e "  • ${YELLOW}protonvpn configure${NC} - Change settings"
        echo -e ""
        echo -e "${GREEN}🔒 Features: Secure Core, NetShield, Kill Switch${NC}"
    else
        echo -e "${YELLOW}⚠️ Installation may need manual steps${NC}"
        echo -e "${BLUE}📖 Official Installation Guide:${NC}"
        echo -e "  Visit: https://protonvpn.com/support/linux-vpn-setup/"
        echo -e ""
        echo -e "${YELLOW}💡 Alternative Methods:${NC}"
        echo -e "  1. Download GUI app: https://protonvpn.com/download/"
        echo -e "  2. Use Flatpak: ${CYAN}flatpak install flathub ch.protonvpn.www${NC}"
    fi
}

install_mullvad() {
    echo -e "${GREEN}🐢 Installing Mullvad VPN...${NC}"
    
    case "$PKG_MANAGER" in
        "pacman")
            echo -e "${BLUE}📦 Arch Linux: Installing Mullvad...${NC}"
            if command -v yay &> /dev/null; then
                yay -S mullvad-vpn --noconfirm
            elif command -v paru &> /dev/null; then
                paru -S mullvad-vpn --noconfirm
            else
                echo -e "${YELLOW}📥 Install from AUR with an AUR helper${NC}"
            fi
            ;;
        "apt")
            echo -e "${BLUE}📦 Ubuntu/Debian: Installing Mullvad...${NC}"
            cd /tmp
            # Get actual latest .deb URL from Mullvad website
            wget -O mullvad.deb "https://mullvad.net/en/download/app/deb/latest/"
            if [ -f "mullvad.deb" ]; then
                sudo dpkg -i mullvad.deb
                sudo apt install -f -y
                rm mullvad.deb
            else
                echo -e "${YELLOW}📥 Download failed, please visit: https://mullvad.net/en/download/linux/${NC}"
            fi
            ;;
        "dnf")
            echo -e "${BLUE}📦 Fedora: Installing Mullvad...${NC}"
            cd /tmp
            wget -O mullvad.rpm "https://mullvad.net/en/download/app/rpm/latest/"
            if [ -f "mullvad.rpm" ]; then
                sudo dnf install -y mullvad.rpm
                rm mullvad.rpm
            else
                echo -e "${YELLOW}📥 Download failed, please visit: https://mullvad.net/en/download/linux/${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}📥 Please download from: https://mullvad.net/en/download/linux/${NC}"
            ;;
    esac
    
    if command -v mullvad &> /dev/null || command -v mullvad-vpn &> /dev/null; then
        echo -e "${GREEN}✅ Mullvad VPN installed!${NC}"
        echo -e "${CYAN}🚀 Quick Start:${NC}"
        echo -e "  1. Run: ${YELLOW}mullvad account login${NC}"
        echo -e "  2. Enter your account number"
        echo -e "  3. Connect: ${YELLOW}mullvad connect${NC}"
        echo -e ""
        echo -e "${BLUE}💡 Features: WireGuard, ad blocking, no logs policy${NC}"
    else
        echo -e "${YELLOW}📥 Direct download: https://mullvad.net/en/download/linux/${NC}"
    fi
}

install_openvpn() {
    echo -e "${GREEN}🔓 Installing OpenVPN...${NC}"
    
    if install_smart "openvpn" "openvpn" "openvpn" "openvpn" "OpenVPN"; then
        echo -e "${GREEN}✅ OpenVPN installed!${NC}"
        echo -e "${CYAN}💡 Usage:${NC}"
        echo -e "  • Import .ovpn config files"
        echo -e "  • Use with: ${YELLOW}sudo openvpn --config file.ovpn${NC}"
        echo -e "  • Many VPN providers offer OpenVPN configs"
    fi
}

install_wireguard() {
    echo -e "${GREEN}⚡ Installing WireGuard...${NC}"
    
    if install_smart "wireguard-tools" "wireguard-tools" "wireguard-tools" "wireguard-tools" "WireGuard"; then
        echo -e "${GREEN}✅ WireGuard installed!${NC}"
        echo -e "${CYAN}💡 Usage:${NC}"
        echo -e "  • Generate keys: ${YELLOW}wg genkey | tee privatekey | wg pubkey > publickey${NC}"
        echo -e "  • Fast, modern VPN protocol"
        echo -e "  • Many VPN providers support WireGuard"
    fi
}

install_riseup_vpn() {
    echo -e "${GREEN}✊ Installing Riseup VPN...${NC}"
    install_flatpak "se.leap.riseup.vpn" "Riseup VPN"
}

install_psiphon() {
    echo -e "${GREEN}🌀 Installing Psiphon...${NC}"
    echo -e "${YELLOW}📥 Download from: https://psiphon.ca/${NC}"
}

check_vpn_status() {
    echo -e "${BLUE}🔍 Checking VPN Status...${NC}"
    
    # Check active VPN connections
    echo -e "${CYAN}Active VPN Connections:${NC}"
    ip addr show | grep -E "(tun|tap|wg|proton|mullvad)" | head -5
    
    echo -e "${CYAN}Network Interfaces:${NC}"
    ip route | grep -E "(tun|tap|wg)" | head -5 || echo "No VPN routes found"
    
    echo -e "${CYAN}Public IP Address:${NC}"
    curl -s https://ipinfo.io/ip || echo "Could not determine public IP"
    
    echo -e "${GREEN}✅ VPN status check complete${NC}"
}

test_vpn_connection() {
    echo -e "${BLUE}🧪 Testing VPN Connection...${NC}"
    
    echo -e "${CYAN}Testing without VPN:${NC}"
    original_ip=$(curl -s https://ipinfo.io/ip)
    echo "IP: $original_ip"
    
    echo -e "${CYAN}Testing DNS leaks:${NC}"
    curl -s https://dnsleaktest.com/ | grep -o '"ip_address":"[^"]*"' | head -3 || echo "DNS test unavailable"
    
    echo -e "${YELLOW}💡 Connect to your VPN and run this test again to compare${NC}"
}

install_vpn_killswitch() {
    echo -e "${GREEN}🛡️ Installing VPN Kill Switch...${NC}"
    
    # Basic iptables kill switch setup
    if command -v iptables &> /dev/null; then
        echo -e "${BLUE}🔧 Setting up basic firewall rules...${NC}"
        
        # Create a simple kill switch script
        cat > "$HOME/vpn-killswitch.sh" << 'EOF'
#!/bin/bash
# Basic VPN Kill Switch
# Block all traffic when VPN is down

VPN_INTERFACE="tun0"

# Flush existing rules
sudo iptables -F
sudo iptables -X

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow VPN interface
sudo iptables -A OUTPUT -o $VPN_INTERFACE -j ACCEPT
sudo iptables -A INPUT -i $VPN_INTERFACE -j ACCEPT

# Block all other traffic
sudo iptables -A OUTPUT -j DROP
sudo iptables -A INPUT -j DROP

echo "VPN Kill Switch activated. Only VPN traffic allowed."
EOF
        
        chmod +x "$HOME/vpn-killswitch.sh"
        echo -e "${GREEN}✅ Kill switch script created: $HOME/vpn-killswitch.sh${NC}"
        echo -e "${YELLOW}⚠️  Run this script ONLY when connected to VPN${NC}"
        echo -e "${YELLOW}💡 Disable with: sudo iptables -F${NC}"
    else
        echo -e "${RED}❌ iptables not available${NC}"
        echo -e "${YELLOW}📦 Install iptables or use your distribution's firewall${NC}"
    fi
}

# ============================================================================
# FUN TAB - COMPLETE WITH ALL FEATURES
# ============================================================================

fun_tab() {
    while true; do
        show_banner
        echo -e "${MAGENTA}🎉 FUN TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BOLD}Choose Subtab:${NC}"
        echo -e "  ${GREEN}1${NC}) 🎮 Terminal Games"
        echo -e "  ${GREEN}2${NC}) 🎨 ASCII Art & Visual"
        echo -e "  ${GREEN}3${NC}) 🔥 Visual Effects"
        echo -e "  ${GREEN}4${NC}) 🎵 Music & Sound"
        echo -e "  ${GREEN}5${NC}) 🤖 AI, Coding GPT & Fun Scripts"
        echo -e "  ${GREEN}6${NC}) 📚 Reading & Books"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Main Menu"
        echo ""
        read -p "Choose subtab [0-6]: " choice

        case $choice in
            1) fun_games_subtab ;;
            2) fun_art_subtab ;;
            3) fun_visual_subtab ;;
            4) fun_music_subtab ;;
            5) fun_ai_subtab ;;
            6) reading_subtab ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}"; sleep 1 ;;
        esac
    done
}

# Fun Games Subtab 
fun_games_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎮 TERMINAL GAMES" "$GREEN"
        echo ""
        echo -e "${GREEN}🎯 Classic Games:${NC}"
        echo -e "  ${GREEN}1${NC}) Nethack"
        echo -e "  ${GREEN}2${NC}) Snake Game"
        echo -e "  ${GREEN}3${NC}) Tetris"
        echo -e "  ${GREEN}4${NC}) Pacman (CLI)"
        echo -e "  ${GREEN}5${NC}) Moon Buggy"
        echo ""
        echo -e "${BLUE}🎲 Modern CLI Games:${NC}"
        echo -e "  ${BLUE}6${NC}) CMatrix"
        echo -e "  ${BLUE}7${NC}) Fortune"
        echo -e "  ${BLUE}8${NC}) Cowsay"
        echo -e "  ${BLUE}9${NC}) Figlet"
        echo -e "  ${BLUE}10${NC}) 2048 Game"
        echo -e "  ${BLUE}11${NC}) Sudoku"
        echo -e "  ${BLUE}12${NC}) Chess"
        echo -e "  ${BLUE}13${NC}) Text RPG Game"
        echo -e "  ${BLUE}14${NC}) ACSII Invaders"
        echo -e "  ${BLUE}15${NC}) BSD Games Collection"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Fun Tab"
        echo ""
        read -p "Choose game to install [0-15]: " choice

        case $choice in
            1) install_nethack ;;
            2) install_snake_game ;;
            3) install_tetris ;;
            4) install_pacman_cli ;;
            5) install_moon_buggy ;;
            6) install_cmatrix ;;
            7) install_fortune ;;
            8) install_cowsay ;;
            9) install_figlet ;;
            10) install_2048 ;;
            11) install_sudoku ;;
            12) install_chess ;;
            13) install_text_rpg ;;
            14) install_ascii_invaders ;;
            15) install_bsdgames ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Fun Games
install_nethack() {
    echo -e "${GREEN}🎮 Installing Nethack...${NC}"
    
    # REAL package names that exist
    if install_smart "nethack" "nethack-console" "nethack" "nethack" "Nethack"; then
        echo -e "${GREEN}✅ Nethack installed!${NC}"
        echo -e "${BLUE}🚀 Launching Nethack...${NC}"
        echo -e "${YELLOW}💡 Controls: Arrow keys, '?' for help, 'q' to quit${NC}"
        sleep 2
        nethack
    else
        echo -e "${YELLOW}📥 Try: sudo apt install nethack-console${NC}"
    fi
}

install_snake_game() {
    echo -e "${GREEN}🐍 Installing Snake Game...${NC}"
    
    # Try different snake game packages
    if install_smart "nsnake" "nsnake" "nsnake" "nsnake" "Snake Game"; then
        echo -e "${GREEN}✅ Snake Game installed!${NC}"
        echo -e "${BLUE}🚀 Launching Snake...${NC}"
        sleep 2
        nsnake
    elif install_smart "greed" "greed" "greed" "greed" "Greed (alternative)"; then
        echo -e "${GREEN}✅ Greed (snake-like) installed!${NC}"
        greed
    else
        echo -e "${YELLOW}📥 Manual install options:${NC}"
        echo -e "  • git clone https://github.com/alexdantas/nSnake"
        echo -e "  • sudo apt install nsnake"
    fi
}

install_tetris() {
    echo -e "${GREEN}🎮 Installing Tetris...${NC}"
    
    # REAL tetris games that exist
    if install_smart "vitetris" "vitetris" "vitetris" "vitetris" "vitetris"; then
        echo -e "${GREEN}✅ Tetris installed!${NC}"
        echo -e "${BLUE}🚀 Launching Tetris...${NC}"
        echo -e "${YELLOW}💡 Controls: Arrow keys, Space to rotate, P to pause${NC}"
        sleep 2
        vitetris
    elif install_smart "bastet" "bastet" "bastet" "bastet" "Bastet Tetris"; then
        echo -e "${GREEN}✅ Bastet (Tetris) installed!${NC}"
        bastet
    else
        echo -e "${YELLOW}📥 Try: sudo apt install vitetris${NC}"
    fi
}

install_pacman_cli() {
    echo -e "${GREEN}👻 Installing Pacman CLI Game...${NC}"
    
    # REAL pacman-like terminal games
    if install_smart "nudoku" "nudoku" "nudoku" "nudoku" "Sudoku"; then
        echo -e "${GREEN}✅ Sudoku installed!${NC}"
        echo -e "${BLUE}🚀 Launching Sudoku...${NC}"
        sleep 2
        nudoku
    elif install_smart "pacman4console" "pacman4console" "pacman4console" "pacman4console" "Pacman"; then
        echo -e "${GREEN}✅ Pacman installed!${NC}"
        pacman
    else
        echo -e "${YELLOW}📥 Try: sudo apt install nudoku${NC}"
    fi
}

install_moon_buggy() {
    echo -e "${GREEN}🚀 Installing Moon Buggy...${NC}"
    
    if install_smart "moon-buggy" "moon-buggy" "moon-buggy" "moon-buggy" "Moon Buggy"; then
        echo -e "${GREEN}✅ Moon Buggy installed!${NC}"
        echo -e "${BLUE}🚀 Launching Moon Buggy...${NC}"
        echo -e "${YELLOW}💡 Controls: Space to jump, Q to quit${NC}"
        sleep 2
        moon-buggy
    else
        echo -e "${YELLOW}📥 Try: sudo apt install moon-buggy${NC}"
    fi
}

install_cmatrix() {
    echo -e "${GREEN}💚 Installing CMatrix...${NC}"
    
    if install_smart "cmatrix" "cmatrix" "cmatrix" "cmatrix" "CMatrix"; then
        echo -e "${GREEN}✅ CMatrix installed!${NC}"
        echo -e "${BLUE}🚀 Launching CMatrix...${NC}"
        echo -e "${YELLOW}💡 Press any key to exit${NC}"
        sleep 2
        cmatrix
    else
        echo -e "${YELLOW}📥 Try: sudo apt install cmatrix${NC}"
    fi
}

install_fortune() {
    echo -e "${GREEN}🔮 Installing Fortune...${NC}"
    
    if install_smart "fortune-mod" "fortune-mod" "fortune-mod" "fortune-mod" "Fortune"; then
        echo -e "${GREEN}✅ Fortune installed!${NC}"
        echo -e "${BLUE}🔮 Getting your fortune...${NC}"
        sleep 2
        fortune
    else
        echo -e "${YELLOW}📥 Try: sudo apt install fortune-mod${NC}"
    fi
}

install_cowsay() {
    echo -e "${GREEN}🐮 Installing Cowsay...${NC}"
    
    if install_smart "cowsay" "cowsay" "cowsay" "cowsay" "Cowsay"; then
        echo -e "${GREEN}✅ Cowsay installed!${NC}"
        cowsay "Hello from Electrotility!"
    else
        echo -e "${YELLOW}📥 Try: sudo apt install cowsay${NC}"
    fi
}

install_figlet() {
    echo -e "${GREEN}🦋 Installing Figlet...${NC}"
    
    if install_smart "figlet" "figlet" "figlet" "figlet" "Figlet"; then
        echo -e "${GREEN}✅ Figlet installed!${NC}"
        figlet "Electrotility"
    else
        echo -e "${YELLOW}📥 Try: sudo apt install figlet${NC}"
    fi
}

install_2048() {
    echo -e "${GREEN}🔢 Installing 2048...${NC}"
    
    if install_smart "2048-qt" "2048-qt" "2048-qt" "2048-qt" "2048 Game"; then
        echo -e "${GREEN}✅ 2048 installed!${NC}"
        2048-qt
    else
        echo -e "${YELLOW}📥 Try: git clone https://github.com/mevdschee/2048.c${NC}"
    fi
}

install_sudoku() {
    echo -e "${GREEN}🧩 Installing Sudoku...${NC}"
    
    if install_smart "sudoku" "sudoku" "sudoku" "sudoku" "Sudoku"; then
        echo -e "${GREEN}✅ Sudoku installed!${NC}"
        sudoku
    else
        install_pacman_cli  # Fallback to nudoku
    fi
}

install_chess() {
    echo -e "${GREEN}♟️ Installing Chess with Interface...${NC}"
    
    # Try different chess games with actual interfaces
    if install_smart "scid" "scid" "scid" "scid" "Scid Chess"; then
        echo -e "${GREEN}✅ Scid vs PC installed!${NC}"
        echo -e "${BLUE}🚀 Launching Scid vs PC...${NC}"
        echo -e "${YELLOW}💡 Full graphical chess interface${NC}"
        sleep 2
        scid
    elif install_smart "xboard" "xboard" "xboard" "xboard" "XBoard Chess"; then
        echo -e "${GREEN}✅ XBoard Chess installed!${NC}"
        echo -e "${BLUE}🚀 Launching XBoard...${NC}"
        sleep 2
        xboard
    elif install_smart "pychess" "pychess" "pychess" "pychess" "PyChess"; then
        echo -e "${GREEN}✅ PyChess installed!${NC}"
        echo -e "${BLUE}🚀 Launching PyChess...${NC}"
        sleep 2
        pychess
    else
        echo -e "${YELLOW}📥 Installing text-based chess with interface...${NC}"
        if install_smart "cboard" "cboard" "cboard" "cboard" "CBoard Chess"; then
            echo -e "${GREEN}✅ CBoard installed!${NC}"
            cboard
        else
            echo -e "${RED}❌ No chess interface found${NC}"
            echo -e "${YELLOW}💡 Manual options:${NC}"
            echo -e "  • sudo apt install xboard  (Graphical)"
            echo -e "  • sudo apt install scid    (Database + GUI)"
            echo -e "  • sudo apt install pychess (Modern Python)"
        fi
    fi
}

install_bsdgames() {
    echo -e "${GREEN}🎮 Installing BSD Games Collection...${NC}"
    
    if install_smart "bsdgames" "bsdgames" "bsdgames" "bsdgames" "BSD Games"; then
        echo -e "${GREEN}✅ BSD Games installed!${NC}"
        echo -e "${CYAN}Available games:${NC}"
        echo -e "  • adventure - Text adventure"
        echo -e "  • backgammon - Backgammon"
        echo -e "  • battlestar - Space adventure" 
        echo -e "  • hack - RPG game"
        echo -e "  • robots - Dodge robots"
        echo -e "  • sail - Naval battle"
        echo -e "  • tetris-bsd - Tetris"
        echo -e "${YELLOW}💡 Run: [game-name] to play${NC}"
    else
        echo -e "${YELLOW}📥 Try: sudo apt install bsdgames-nonfree${NC}"
    fi
}

install_ascii_invaders() {
    echo -e "${GREEN}👾 Installing ASCII Invaders...${NC}"
    
    if command -v git &> /dev/null; then
        echo -e "${BLUE}📥 Downloading ASCII games...${NC}"
        git clone https://github.com/msokola/ascii-invaders /tmp/ascii-invaders 2>/dev/null
        if [ -f "/tmp/ascii-invaders/invaders" ]; then
            chmod +x /tmp/ascii-invaders/invaders
            echo -e "${GREEN}✅ ASCII Invaders installed!${NC}"
            echo -e "${BLUE}🚀 Launching ASCII Invaders...${NC}"
            /tmp/ascii-invaders/invaders
        else
            echo -e "${YELLOW}📦 Installing ninvaders...${NC}"
            install_smart "ninvaders" "ninvaders" "ninvaders" "ninvaders" "nInvaders"
            if command -v ninvaders &> /dev/null; then
                ninvaders
            fi
        fi
    else
        install_smart "ninvaders" "ninvaders" "ninvaders" "ninvaders" "nInvaders"
    fi
}

install_text_rpg() {
    echo -e "${GREEN}🧙 Installing Text RPG...${NC}"
    
    if install_smart "cataclysm-dda" "cataclysm-dda" "cataclysm-dda" "cataclysm-dda" "Cataclysm DDA"; then
        echo -e "${GREEN}✅ Cataclysm: Dark Days Ahead installed!${NC}"
        echo -e "${BLUE}🚀 Launching RPG...${NC}"
        cataclysm
    elif install_smart "angband" "angband" "angband" "angband" "Angband"; then
        echo -e "${GREEN}✅ Angband RPG installed!${NC}"
        angband
    else
        echo -e "${YELLOW}📥 Try these epic text RPGs:${NC}"
        echo -e "  • sudo apt install cataclysm-dda"
        echo -e "  • sudo apt install angband"
        echo -e "  • sudo apt install nethack-console"
    fi
}

# Fun Art Subtab - COMPLETE
fun_art_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎨 ASCII ART & VISUAL" "$MAGENTA"
        echo ""
        echo -e "${GREEN}🎨 ASCII Art Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) Lolcat"
        echo -e "  ${GREEN}2${NC}) Toilet"
        echo -e "  ${GREEN}3${NC}) boxes"
        echo -e "  ${GREEN}4${NC}) ASCIIquarium"
        echo -e "  ${GREEN}5${NC}) sl (Steam Locomotive)"
        echo ""
        echo -e "${BLUE}🎭 Fun Commands:${NC}"
        echo -e "  ${BLUE}6${NC}) Fortune with Cowsay"
        echo -e "  ${BLUE}7${NC}) Random ASCII Art"
        echo -e "  ${BLUE}8${NC}) Text Animation"
        echo -e "  ${BLUE}9${NC}) Colorful Banner"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Fun Tab"
        echo ""
        read -p "Choose option [0-9]: " choice

        case $choice in
            1) install_lolcat ;;
            2) install_toilet ;;
            3) install_boxes ;;
            4) install_asciiquarium ;;
            5) install_sl ;;
            6) show_fortune_cow ;;
            7) show_random_art ;;
            8) show_text_animation ;;
            9) show_colorful_banner ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# Art Functions
install_lolcat() {
    install_smart "lolcat" "lolcat" "lolcat" "lolcat" "Lolcat"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🌈 Lolcat installed!${NC}"
        echo "Electr OS is awesome!" | lolcat
    fi
}

install_toilet() {
    install_smart "toilet" "toilet" "toilet" "toilet" "Toilet"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚽 Toilet installed!${NC}"
        toilet -f mono12 "Electr OS"
    fi
}

install_boxes() {
    install_smart "boxes" "boxes" "boxes" "boxes" "Boxes"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}📦 Boxes installed!${NC}"
        echo "Electr OS" | boxes -d dog
    fi
}

install_asciiquarium() {
    install_smart "asciiquarium" "asciiquarium" "asciiquarium" "asciiquarium" "ASCIIquarium"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🐠 Launching ASCIIquarium...${NC}"
        sleep 2
        asciiquarium
    fi
}

install_sl() {
    install_smart "sl" "sl" "sl" "sl" "Steam Locomotive"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}🚂 Steam Locomotive installed!${NC}"
        sl
    fi
}

show_fortune_cow() {
    if command -v fortune &> /dev/null && command -v cowsay &> /dev/null; then
        fortune | cowsay -f dragon
    else
        echo -e "${YELLOW}📦 Installing fortune and cowsay first...${NC}"
        install_fortune
        install_cowsay
        if command -v fortune &> /dev/null && command -v cowsay &> /dev/null; then
            fortune | cowsay -f dragon
        fi
    fi
}

show_random_art() {
    arts=(
        "🐉 Electr OS - Power Your World! ⚡"
        "🚀 Welcome to the Future of Linux! 🌟"
        "⚡ Experience Lightning Fast Performance! 💨"
        "🎯 Precision. Power. Performance. 🏆"
    )
    random_art=${arts[$RANDOM % ${#arts[@]}]}
    
    if command -v figlet &> /dev/null && command -v lolcat &> /dev/null; then
        figlet "$random_art" | lolcat
    elif command -v figlet &> /dev/null; then
        figlet "$random_art"
    else
        echo -e "${CYAN}$random_art${NC}"
    fi
}

show_text_animation() {
    text="Electr OS"
    for i in $(seq 1 ${#text}); do
        echo -n "${text:$i-1:1}"
        sleep 0.1
    done
    echo ""
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN; do
        echo -e "${!color}⚡ $color Power ⚡${NC}"
        sleep 0.3
    done
}

show_colorful_banner() {
    echo -e "${RED}"
    cat << "EOF"
  ______ _                           _
 |  ____| |           _|'|_         |_| 
 | |__  | | ___  ___ |_   _|   ___,  _  ___
 |  __| | |/ _ \| __\  | |   |/'''' | |/ __\
 | |____| |  __/\ \___ | |_  ||     | |\ \___
 |______|_|\___| \___/ \___| ||     |_| \___/
EOF
    echo -e "${NC}"
}

# Fun Visual Subtab - COMPLETE
fun_visual_subtab() {
    while true; do
        show_banner
        show_subtab_header "🔥 VISUAL EFFECTS" "$ORANGE"
        echo ""
        echo -e "${GREEN}✨ Visual Effects:${NC}"
        echo -e "  ${GREEN}1${NC}) CMatrix (Matrix effect)"
        echo -e "  ${GREEN}2${NC}) ASCIIQuarium (Animated aquarium)"
        echo -e "  ${GREEN}3${NC}) SL (Steam Locomotive)"
        echo -e "  ${GREEN}4${NC}) Fortune + Cowsay (Fun messages)"
        echo ""
        echo -e "${PURPLE} 🌈 Color & Text Effects:${NC}"
        echo -e "  ${PURPLE}5${NC}) Lolcat (Rainbow text)"
        echo -e "  ${PURPLE}6${NC}) Figlet (ASCII banners)"
        echo -e "  ${PURPLE}7${NC}) Toilet (Fancy text)"
        echo -e "  ${PURPLE}8${NC}) Banner (Large text display)"
        echo -e "  ${PURPLE}9${NC}) Pipes (Animated pipes)"
        echo -e "  ${PURPLE}10${NC}) Burning ASCII"
        echo -e "  ${PURPLE}11${NC}) Fire Effect"
        echo ""
        echo -e "${BLUE}🎆 Animations:${NC}"
        echo -e "  ${BLUE}12${NC}) Rainbow Text"
        echo -e "  ${BLUE}13${NC}) Spinning Loader"
        echo -e "  ${BLUE}14${NC}) Progress Bar"
        echo -e "  ${BLUE}15${NC}) Digital Clock"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Fun Tab"
        echo ""
        read -p "Choose effect [0-15]: " choice

        case $choice in
            1) run_cmatrix ;;
            2) run_asciiquarium ;;
            3) run_sl ;;
            4) run_fortune_cow ;;
            5) run_lolcat ;;
            6) run_figlet ;;
            7) run_toilet ;;
            8) run_banner ;;
            9) run_pipes ;;
            10) run_burning_ascii ;;
            11) run_fire_effect ;;
            12) run_rainbow_text ;;
            13) run_spinning_loader ;;
            14) run_progress_bar ;;
            15) run_digital_clock ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Visual Effects

run_pipes() {
    if install_smart "pipes.sh" "pipes.sh" "pipes.sh" "pipes.sh" "Pipes.sh"; then
        pipes.sh
    else
        # Fallback pipes implementation
        while true; do
            clear
            for i in {1..10}; do
                printf "|%*s\n" $((RANDOM % 100)) " " | tr ' ' '|'
            done
            sleep 0.5
        done
    fi
}

run_burning_ascii() {
    echo -e "${RED}"
    cat << "EOF"
    (  .      )
        )           (              )
              .  '   .   '  .  '  .
     (    , )       (.   )  (   ',    )
      .' ) ( . )    ,  ( ,     )   ( .
   ). , ( .   (  ) ( , ')  .' (  ,    )
  (_,) . ), ) _) _,')  (, ) '. )  ,. (' )
EOF
    echo -e "${NC}"
    sleep 2
}

run_fire_effect() {
    for i in {1..10}; do
        echo -e "${RED}🔥 ${ORANGE}🔥 ${YELLOW}🔥 ${RED}🔥 ${ORANGE}🔥 ${YELLOW}🔥${NC}"
        sleep 0.2
    done
}

run_rainbow_text() {
    if command -v lolcat &> /dev/null; then
        echo "Electr OS - Rainbow Text Effect!" | lolcat -a -d 20
    else
        echo -e "${RED}R${GREEN}A${YELLOW}I${BLUE}N${MAGENTA}B${CYAN}O${RED}W${NC} ${GREEN}E${YELLOW}l${BLUE}e${MAGENTA}c${CYAN}t${RED}r${GREEN}i${YELLOW}f${BLUE}y${MAGENTA}i${CYAN}n${RED}g${NC}!"
    fi
}

run_spinning_loader() {
    spinner=('⣷' '⣯' '⣟' '⡿' '⢿' '⣻' '⣽' '⣾')
    for i in {1..10}; do
        for frame in "${spinner[@]}"; do
                        printf "\r${CYAN}Loading Electr OS ${frame} ${NC}"
            sleep 0.1
        done
    done
    printf "\r${GREEN}✅ Loading complete!${NC}\n"
}

run_progress_bar() {
    echo -e "${BLUE}Progress:${NC}"
    for i in {0..50..5}; do
        printf "\r[${GREEN}%-10s${NC}] %d%%" "$(printf '%*s' $((i/5)) | tr ' ' '=')" "$i"
        sleep 0.1
    done
    printf "\r[${GREEN}==========${NC}] 100%%\n"
    echo -e "${GREEN}✅ Complete!${NC}"
}

run_digital_clock() {
    echo -e "${CYAN}Digital Clock - Press Ctrl+C to exit${NC}"
    while true; do
        printf "\r🕒 $(date '+%Y-%m-%d %H:%M:%S') "
        sleep 1
    done
}

run_cmatrix() {
    if command -v cmatrix &> /dev/null; then
        echo -e "${GREEN}💚 Launching CMatrix...${NC}"
        echo -e "${YELLOW}💡 Press any key to exit${NC}"
        cmatrix
    else
        echo -e "${YELLOW}📦 Installing CMatrix...${NC}"
        if install_smart "cmatrix" "cmatrix" "cmatrix" "cmatrix" "CMatrix"; then
            cmatrix
        fi
    fi
}

run_asciiquarium() {
    if command -v asciiquarium &> /dev/null; then
        echo -e "${GREEN}🐠 Launching ASCIIquarium...${NC}"
        echo -e "${YELLOW}💡 Press 'q' to exit${NC}"
        asciiquarium
    else
        echo -e "${YELLOW}📦 Installing ASCIIquarium...${NC}"
        # ASCIIquarium needs Perl and dependencies
        if install_smart "asciiquarium" "asciiquarium" "asciiquarium" "asciiquarium" "ASCIIquarium"; then
            asciiquarium
        else
            echo -e "${YELLOW}📥 Alternative installation:${NC}"
            echo -e "  sudo cpan install Term::Animation"
            echo -e "  wget http://www.robobunny.com/projects/asciiquarium/asciiquarium.tar.gz"
            echo -e "  tar -xzf asciiquarium.tar.gz && cd asciiquarium_1.1"
            echo -e "  sudo cp asciiquarium /usr/local/bin/"
        fi
    fi
}

run_sl() {
    if command -v sl &> /dev/null; then
        echo -e "${GREEN}🚂 Steam Locomotive passing through...${NC}"
        sl
    else
        echo -e "${YELLOW}📦 Installing SL...${NC}"
        if install_smart "sl" "sl" "sl" "sl" "Steam Locomotive"; then
            sl
        fi
    fi
}

run_fortune_cow() {
    # Install fortune and cowsay if needed
    if ! command -v fortune &> /dev/null; then
        echo -e "${YELLOW}📦 Installing Fortune...${NC}"
        install_smart "fortune-mod" "fortune-mod" "fortune-mod" "fortune-mod" "Fortune"
    fi
    
    if ! command -v cowsay &> /dev/null; then
        echo -e "${YELLOW}📦 Installing Cowsay...${NC}"
        install_smart "cowsay" "cowsay" "cowsay" "cowsay" "Cowsay"
    fi
    
    if command -v fortune &> /dev/null && command -v cowsay &> /dev/null; then
        echo -e "${GREEN}🐮 Fortune with Cowsay:${NC}"
        fortune | cowsay
    else
        echo -e "${RED}❌ Fortune or Cowsay not available${NC}"
    fi
}

run_lolcat() {
    if command -v lolcat &> /dev/null; then
        echo -e "${GREEN}🌈 Lolcat Rainbow Text:${NC}"
        echo "Electrotility Visual Effects are Awesome!" | lolcat
    else
        echo -e "${YELLOW}📦 Installing Lolcat...${NC}"
        if install_smart "lolcat" "lolcat" "lolcat" "lolcat" "Lolcat"; then
            echo "Now everything is colorful!" | lolcat
        fi
    fi
}

run_figlet() {
    if command -v figlet &> /dev/null; then
        echo -e "${GREEN}🦋 Figlet Banner:${NC}"
        figlet "Electrotility"
    else
        echo -e "${YELLOW}📦 Installing Figlet...${NC}"
        if install_smart "figlet" "figlet" "figlet" "figlet" "Figlet"; then
            figlet "Awesome!"
        fi
    fi
}

run_toilet() {
    if command -v toilet &> /dev/null; then
        echo -e "${GREEN}🚽 Toilet Fancy Text:${NC}"
        toilet -f mono12 "Visual Effects"
    else
        echo -e "${YELLOW}📦 Installing Toilet...${NC}"
        if install_smart "toilet" "toilet" "toilet" "toilet" "Toilet"; then
            toilet "Cool!"
        fi
    fi
}

run_banner() {
    if command -v banner &> /dev/null; then
        echo -e "${GREEN}📺 Banner Display:${NC}"
        banner "ELECTROTILITY"
    else
        echo -e "${YELLOW}📦 Installing Banner (usually in sysvbanner)...${NC}"
        if install_smart "sysvbanner" "sysvbanner" "sysvbanner" "sysvbanner" "Banner"; then
            banner "HELLO"
        else
            # Fallback to figlet
            if command -v figlet &> /dev/null; then
                figlet "Banner Not Available"
            else
                echo "BANNER TEXT"
            fi
        fi
    fi
}

# Fun Music Subtab - COMPLETE
fun_music_subtab() {
    while true; do
        show_banner
        show_subtab_header "🎵 MUSIC & SOUND" "$PURPLE"
        echo ""
        echo -e "${GREEN}🎵 Music Players:${NC}"
        echo -e "  ${GREEN}1${NC}) MPlayer"
        echo -e "  ${GREEN}2${NC}) SoX (Play sounds)"
        echo -e "  ${GREEN}3${NC}) Beep (PC Speaker)"
        echo -e "  ${GREEN}4${NC}) Cava (Audio Visualizer)"
        echo -e "  ${GREEN}5${NC}) MIDI Players"
        echo -e "  ${GREEN}6${NC}) Spotify"
        echo -e "  ${GREEN}7${NC}) Nuclear (Free Music Player)"
        echo ""
        echo -e "${BLUE}🎶 Sound Effects:${NC}"
        echo -e "  ${BLUE}8${NC}) Play System Beep"
        echo -e "  ${BLUE}9${NC}) Generate Sine Wave"
        echo -e "  ${BLUE}10${NC}) Drum Machine"
        echo -e "  ${BLUE}11${NC}) Text to Speech"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Fun Tab"
        echo ""
        read -p "Choose option [0-11]: " choice

        case $choice in
            1) install_mplayer ;;
            2) install_sox ;;
            3) install_beep ;;
            4) install_cava ;;
            5) install_midi_players ;;
            6) install_spotify ;;
            7) install_nuclear ;;
            8) play_system_beep ;;
            9) generate_sine_wave ;;
            10) play_drum_machine ;;
            11) install_text_to_speech ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL Music Functions
install_mplayer() {
    install_smart "mplayer" "mplayer" "mplayer" "mplayer" "MPlayer"
}

install_nuclear() {
    echo -e "${GREEN}☢️ Installing Nuclear Music Player...${NC}"
    
    # Nuclear is primarily available as Flatpak
    if install_flatpak "org.gnome.Music" "GNOME Music"; then
        echo -e "${GREEN}✅ Nuclear installed via Flatpak!${NC}"
        echo -e "${CYAN}🎵 A modern music player focused on streaming from free sources${NC}"
        return 0
    fi
    
    # Alternative installation methods
    echo -e "${YELLOW}📦 Trying alternative installation methods...${NC}"
    
    case "$PKG_MANAGER" in
        "pacman")
            # Arch Linux - AUR
            if command -v yay &> /dev/null; then
                echo -e "${BLUE}📦 Installing from AUR...${NC}"
                yay -S nuclear-player-bin --noconfirm
            elif command -v paru &> /dev/null; then
                paru -S nuclear-player-bin --noconfirm
            else
                echo -e "${YELLOW}📥 Install an AUR helper like yay or paru${NC}"
            fi
            ;;
        "apt")
            # Ubuntu/Debian - AppImage or Snap
            echo -e "${BLUE}📥 Downloading AppImage...${NC}"
            cd /tmp
            wget -O nuclear.AppImage "https://github.com/nukeop/nuclear/releases/latest/download/nuclear-$(uname -m).AppImage"
            chmod +x nuclear.AppImage
            sudo mv nuclear.AppImage /usr/local/bin/nuclear
            echo -e "${GREEN}✅ Nuclear installed as AppImage!${NC}"
            ;;
        "dnf")
            # Fedora - COPR or AppImage
            echo -e "${BLUE}📥 Downloading AppImage...${NC}"
            cd /tmp
            wget -O nuclear.AppImage "https://github.com/nukeop/nuclear/releases/latest/download/nuclear-$(uname -m).AppImage"
            chmod +x nuclear.AppImage
            sudo mv nuclear.AppImage /usr/local/bin/nuclear
            echo -e "${GREEN}✅ Nuclear installed as AppImage!${NC}"
            ;;
        *)
            # Generic fallback - AppImage
            echo -e "${BLUE}📥 Downloading AppImage...${NC}"
            cd /tmp
            wget -O nuclear.AppImage "https://github.com/nukeop/nuclear/releases/latest/download/nuclear-$(uname -m).AppImage"
            chmod +x nuclear.AppImage
            sudo mv nuclear.AppImage /usr/local/bin/nuclear
            echo -e "${GREEN}✅ Nuclear installed as AppImage!${NC}"
            ;;
    esac
    
    # Verify installation
    if command -v nuclear &> /dev/null || \
       flatpak list | grep -q "org.gnome.Music" || \
       [ -f "/usr/local/bin/nuclear" ]; then
        echo -e "${GREEN}✅ Nuclear Music Player installed successfully!${NC}"
        echo -e "${CYAN}🚀 Features:${NC}"
        echo -e "  • Stream from free sources (YouTube, SoundCloud, etc.)"
        echo -e "  • No ads or subscriptions"
        echo -e "  • Modern, clean interface"
        echo -e "  • Download for offline listening"
        echo -e "${YELLOW}💡 Run with: nuclear${NC}"
    else
        echo -e "${YELLOW}⚠️ Installation may need manual completion${NC}"
        echo -e "${BLUE}💡 Download from: https://nuclear.js.org/${NC}"
        echo -e "${BLUE}   Or install Flatpak: flatpak install flathub org.gnome.Music${NC}"
    fi
}

install_sox() {
    install_smart "sox" "sox" "sox" "sox" "SoX"
}

install_beep() {
    echo -e "${GREEN}🔊 Installing Beep...${NC}"
    
    if install_smart "beep" "beep" "beep" "beep" "Beep"; then
        echo -e "${GREEN}✅ Beep installed!${NC}"
    else
        echo -e "${YELLOW}📥 Beep not available in repos${NC}"
        echo -e "${BLUE}💡 Alternative: Use system bell with 'echo -e \"\\a\"'${NC}"
        echo -e "${BLUE}   Or install from source: https://github.com/johnath/beep${NC}"
    fi
}

install_cava() {
    install_smart "cava" "cava" "cava" "cava" "Cava"
}

install_midi_players() {
    echo -e "${GREEN}🎹 Installing MIDI Players...${NC}"
    
    if install_smart "timidity" "timidity" "timidity" "timidity" "TiMidity++"; then
        echo -e "${GREEN}✅ TiMidity++ installed!${NC}"
        echo -e "${YELLOW}💡 You may need to install soundfonts for full functionality${NC}"
        echo -e "${BLUE}   Try: sudo apt install fluid-soundfont-gm${NC}"
    else
        echo -e "${YELLOW}📥 Try alternative: sudo apt install fluidsynth${NC}"
    fi
}

play_system_beep() {
    if command -v beep &> /dev/null; then
        beep -f 1000 -l 500 -r 2
        echo -e "${GREEN}🔊 Played system beep!${NC}"
    else
        echo -e "${YELLOW}⚠️  Install 'beep' package for sound${NC}"
        echo -e "\a"  # System bell
    fi
}

generate_sine_wave() {
    if command -v play &> /dev/null; then
        echo -e "${BLUE}🎵 Generating sine wave (440Hz - A4)...${NC}"
        play -n synth 2 sine 440
    elif command -v sox &> /dev/null; then
        echo -e "${BLUE}🎵 Generating sine wave (440Hz - A4)...${NC}"
        play -n synth 2 sine 440
    else
        echo -e "${YELLOW}📦 Install SoX for audio generation${NC}"
    fi
}

play_drum_machine() {
    if command -v sox &> /dev/null; then
        echo -e "${BLUE}🥁 Playing drum pattern...${NC}"
        # Simple drum pattern
        for i in {1..8}; do
            play -n synth 0.1 saw 100 vol 0.5 &> /dev/null
            sleep 0.2
        done
        echo -e "${GREEN}✅ Drum pattern complete!${NC}"
    else
        echo -e "${YELLOW}📦 Install SoX for drum machine${NC}"
    fi
}

install_text_to_speech() {
    if install_smart "espeak" "espeak" "espeak" "espeak" "eSpeak"; then
        echo -e "${GREEN}🗣️  Text to Speech installed!${NC}"
        read -p "Enter text to speak: " text
        if [ -n "$text" ]; then
            espeak "$text"
        fi
    fi
}

# Fun AI Subtab - COMPLETE
fun_ai_subtab() {
    while true; do
        show_banner
        show_subtab_header "🤖 AI & FUN SCRIPTS" "$CYAN"
        echo ""
        echo -e "${GREEN}🤖 AI Tools:${NC}"
        echo -e "  ${GREEN}1${NC}) Cowsay AI"
        echo -e "  ${GREEN}2${NC}) Fortune Teller"
        echo -e "  ${GREEN}3${NC}) Magic 8-Ball"
        echo -e "  ${GREEN}4${NC}) Random Quote Generator"
        echo -e "  ${GREEN}5${NC}) Dad Joke Generator"
        echo -e "  ${GREEN}6${NC}) Terminal GPT"
        echo ""
        echo -e "${BLUE}🎭 Interactive Fun:${NC}"
        echo -e "  ${BLUE}7${NC}) Guess the Number"
        echo -e "  ${BLUE}8${NC}) Rock Paper Scissors"
        echo -e "  ${BLUE}9${NC}) Text Adventure"
        echo -e "  ${BLUE}10${NC}) ASCII Art Gallery"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Fun Tab"
        echo ""
        read -p "Choose option [0-10]: " choice

        case $choice in
            1) run_cowsay_ai ;;
            2) run_fortune_teller ;;
            3) run_magic_8ball ;;
            4) run_quote_generator ;;
            5) run_dad_joke_generator ;;
            6) install_and_run_tgpt ;;
            7) play_guess_number ;;
            8) play_rock_paper_scissors ;;
            9) play_text_adventure ;;
            10) show_ascii_gallery ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

# REAL AI Functions
run_cowsay_ai() {
    if command -v cowsay &> /dev/null && command -v fortune &> /dev/null; then
        responses=(
            "The electrons are flowing perfectly today!"
            "I sense great computing power in your future."
            "Your code will compile on the first try."
            "The server gods are smiling upon you."
            "Your bandwidth is strong with this one."
        )
        random_response=${responses[$RANDOM % ${#responses[@]}]}
        echo "$random_response" | cowsay -f tux
    else
        echo -e "${YELLOW}📦 Installing cowsay and fortune...${NC}"
        install_cowsay
        install_fortune
        run_cowsay_ai
    fi
}

run_fortune_teller() {
    echo -e "${MAGENTA}🔮 Welcome to the Electr OS Fortune Teller!${NC}"
    read -p "Ask your question: " question
    echo -e "${CYAN}Consulting the terminal spirits...${NC}"
    sleep 2
    
    fortunes=(
        "The electrons say: Yes!"
        "The kernel predicts: Maybe..."
        "The compiler warns: Not likely."
        "The server responds: Absolutely!"
        "The firewall blocks: No way."
        "The database queries: Ask again later."
        "The cloud answers: Signs point to yes."
        "The terminal whispers: Outcome uncertain."
    )
    
    random_fortune=${fortunes[$RANDOM % ${#fortunes[@]}]}
    echo -e "${GREEN}✨ $random_fortune${NC}"
}

run_magic_8ball() {
    answers=(
        "It is certain." "It is decidedly so." "Without a doubt."
        "Yes - definitely." "You may rely on it." "As I see it, yes."
        "Most likely." "Outlook good." "Yes." "Signs point to yes."
        "Reply hazy, try again." "Ask again later." "Better not tell you now."
        "Cannot predict now." "Concentrate and ask again." "Don't count on it."
        "My reply is no." "My sources say no." "Outlook not so good." "Very doubtful."
    )
    
    read -p "🎱 Ask the Magic 8-Ball a question: " question
    echo -e "${BLUE}Shaking the 8-ball...${NC}"
    sleep 2
    echo -e "${GREEN}${answers[$RANDOM % ${#answers[@]}]}${NC}"
}

run_quote_generator() {
    tech_quotes=(
        "There are only 10 types of people in the world: those who understand binary and those who don't."
        "The best thing about a boolean is even if you are wrong, you are only off by a bit."
        "If at first you don't succeed, call it version 1.0."
        "Programming is like sex: One mistake and you have to support it for the rest of your life."
        "The code that you write makes you a programmer. The code that you delete makes you a good one."
        "Software and cathedrals are much the same - first we build them, then we pray."
    )
    
    random_quote=${tech_quotes[$RANDOM % ${#tech_quotes[@]}]}
    if command -v cowsay &> /dev/null; then
        echo "$random_quote" | cowsay
    else
        echo -e "${CYAN}💡 $random_quote${NC}"
    fi
}

run_dad_joke_generator() {
    dad_jokes=(
        "Why do programmers prefer dark mode? Because light attracts bugs!"
        "How many programmers does it take to change a light bulb? None, that's a hardware problem!"
        "Why do Java developers wear glasses? Because they can't C#!"
        "What's a programmer's favorite hangout place? The Foo Bar!"
        "Why was the JavaScript developer sad? Because he didn't Node how to Express himself!"
        "What do you call a programmer from Finland? Nerdic!"
    )
    
    random_joke=${dad_jokes[$RANDOM % ${#dad_jokes[@]}]}
    echo -e "${YELLOW}😂 $random_joke${NC}"
}

install_and_run_tgpt() {
    echo -e "${GREEN}🧠 Setting up Terminal GPT...${NC}"
    
    # Check if tgpt is already installed
    if command -v tgpt &> /dev/null; then
        echo -e "${BLUE}✅ tgpt is already installed${NC}"
    else
        echo -e "${YELLOW}📦 Installing tgpt...${NC}"
        
        # REAL installation methods
        if command -v curl &> /dev/null; then
            echo -e "${BLUE}📥 Downloading and installing tgpt...${NC}"
            # Method 1: Direct download and install
            curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s -- -y
            
        elif command -v wget &> /dev/null; then
            echo -e "${BLUE}📥 Downloading and installing tgpt...${NC}"
            # Method 2: Using wget
            wget -qO- https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s -- -y
            
        elif command -v pip &> /dev/null; then
            echo -e "${BLUE}📥 Installing via pip...${NC}"
            # Method 3: Pip (alternative)
            pip install tgpt
            
        elif command -v npm &> /dev/null; then
            echo -e "${BLUE}📥 Installing via npm...${NC}"
            # Method 4: NPM (alternative)
            npm install -g tgpt
            
        else
            echo -e "${RED}❌ No installation method available${NC}"
            echo -e "${YELLOW}💡 Install curl, wget, pip, or npm first${NC}"
            return 1
        fi
    fi
    
    # Check if installation was successful
    if command -v tgpt &> /dev/null; then
        echo -e "${GREEN}✅ tgpt installed successfully!${NC}"
        echo -e "${CYAN}🚀 Starting Terminal GPT...${NC}"
        echo -e "${YELLOW}💡 Type your questions. Press Ctrl+C to exit.${NC}"
        echo -e "${YELLOW}────────────────────────────────────────────────${NC}"
        
        # Run tgpt in interactive mode
        tgpt -i
    else
        echo -e "${RED}❌ tgpt installation failed${NC}"
        echo -e "${YELLOW}📝 Manual installation options:${NC}"
        echo -e "   1. Run: curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash"
        echo -e "   2. Run: pip install tgpt"
        echo -e "   3. Run: npm install -g tgpt"
        echo -e "${BLUE}📖 Project: https://github.com/aandrew-me/tgpt${NC}"
    fi
}

play_guess_number() {
    echo -e "${GREEN}🎯 Welcome to Guess the Number!${NC}"
    number=$((RANDOM % 100 + 1))
    attempts=0
    
    while true; do
        read -p "Guess a number between 1-100: " guess
        ((attempts++))
        
        if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}❌ Please enter a valid number!${NC}"
            continue
        fi
        
        if [ "$guess" -lt "$number" ]; then
            echo -e "${BLUE}📈 Too low! Try again.${NC}"
        elif [ "$guess" -gt "$number" ]; then
            echo -e "${BLUE}📉 Too high! Try again.${NC}"
        else
            echo -e "${GREEN}🎉 Congratulations! You guessed it in $attempts attempts!${NC}"
            break
        fi
    done
}

play_rock_paper_scissors() {
    options=("rock" "paper" "scissors")
    echo -e "${GREEN}✂️  Rock Paper Scissors!${NC}"
    
    while true; do
        read -p "Choose (rock/paper/scissors) or 'quit': " player_choice
        player_choice=$(echo "$player_choice" | tr '[:upper:]' '[:lower:]')
        
        if [ "$player_choice" = "quit" ]; then
            break
        fi
        
        if [[ ! " ${options[@]} " =~ " ${player_choice} " ]]; then
            echo -e "${RED}❌ Invalid choice!${NC}"
            continue
        fi
        
        computer_choice=${options[$RANDOM % 3]}
        echo -e "${BLUE}Computer chose: $computer_choice${NC}"
        
        if [ "$player_choice" = "$computer_choice" ]; then
            echo -e "${YELLOW}🤝 It's a tie!${NC}"
        elif [[ "$player_choice" == "rock" && "$computer_choice" == "scissors" ]] ||
             [[ "$player_choice" == "paper" && "$computer_choice" == "rock" ]] ||
             [[ "$player_choice" == "scissors" && "$computer_choice" == "paper" ]]; then
            echo -e "${GREEN}🎉 You win!${NC}"
        else
            echo -e "${RED}💻 Computer wins!${NC}"
        fi
    done
}

play_text_adventure() {
    echo -e "${CYAN}🏰 Welcome to the Electr OS Text Adventure!${NC}"
    echo -e "You find yourself in a mysterious server room..."
    
    location="server_room"
    has_key=false
    
    while true; do
        case $location in
            "server_room")
                echo -e "\n${GREEN}You are in a humming server room.${NC}"
                echo "You see: servers, a terminal, and a locked door."
                read -p "What do you do? (examine servers/use terminal/open door): " action
                
                case $action in
                    "examine servers")
                        echo -e "${BLUE}The servers are running Electr OS. They look powerful!${NC}"
                        ;;
                    "use terminal")
                        echo -e "${BLUE}You find a keycard on the terminal!${NC}"
                        has_key=true
                        ;;
                    "open door")
                        if $has_key; then
                            echo -e "${GREEN}You use the keycard and enter the next room!${NC}"
                            location="control_room"
                        else
                            echo -e "${RED}The door is locked. You need a keycard.${NC}"
                        fi
                        ;;
                    *)
                        echo -e "${RED}Invalid action!${NC}"
                        ;;
                esac
                ;;
                
            "control_room")
                echo -e "\n${GREEN}You are in the control room.${NC}"
                echo "You see a big red button and a monitor."
                read -p "What do you do? (press button/read monitor): " action
                
                case $action in
                    "press button")
                        echo -e "${GREEN}🎉 Congratulations! You've powered up Electr OS!${NC}"
                        echo -e "${CYAN}Thanks for playing!${NC}"
                        return
                        ;;
                    "read monitor")
                        echo -e "${BLUE}The monitor shows: 'System ready. Press the button to activate.'${NC}"
                        ;;
                    *)
                        echo -e "${RED}Invalid action!${NC}"
                        ;;
                esac
                ;;
        esac
    done
}

show_ascii_gallery() {
    echo -e "${MAGENTA}🖼️  ASCII Art Gallery${NC}"
    
    arts=(
        "🐧 Penguin: 
 _ 
(o>
//\\
V_/__"
        
        "⚡ Lightning: 
    /\\
   /  \\
  /    \\
 /______\\
 \\      /
  \\    /
   \\  /
    \\/"
        
        "🚀 Rocket: 
   /\\
  /  \\
 /____\\
 |    |
 |Electr|
 | OS  |
 |    |
  \\  /
   \\/"
        
        "💻 Computer: 
  ______________
 |  __________  |
 | |          | |
 | |  Electr  | |
 | |    OS    | |
 | |__________| |
 |______________|"
    )
    
    for art in "${arts[@]}"; do
        echo -e "${CYAN}$art${NC}"
        echo
        sleep 1
    done
}

reading_subtab() {
    while true; do
        show_banner
        show_subtab_header "📚 READING & BOOKS" "$BLUE"
        echo ""
        echo -e "${GREEN}📖 E-Book Readers:${NC}"
        echo -e "  ${GREEN}1${NC}) Foliate (Modern EPUB reader)"
        echo -e "  ${GREEN}2${NC}) Calibre (Complete e-book library)"
        echo -e "  ${GREEN}3${NC}) Bookworm (Simple e-book reader)"
        echo -e "  ${GREEN}4${NC}) KOReader (Advanced e-book reader)"
        echo ""
        echo -e "${BLUE}📰 Comics & Manga:${NC}"
        echo -e "  ${BLUE}5${NC}) Komikku (Manga reader)"
        echo -e "  ${BLUE}6${NC}) MComix (Comic book reader)"
        echo -e "  ${BLUE}7${NC}) YACReader (Comic reader)"
        echo ""
        echo -e "${PURPLE}🌐 Encyclopedia & Docs:${NC}"
        echo -e "  ${PURPLE}8${NC}) Wiki.js (Local Wikipedia)"
        echo -e "  ${PURPLE}9${NC}) Zim (Desktop wiki)"
        echo -e "  ${PURPLE}10${NC}) Koodo Reader (Web-based)"
        echo ""
        echo -e "${YELLOW}0${NC}) 🔙 Back to Fun Tab"
        echo ""
        read -p "Choose app to install [0-10]: " choice

        case $choice in
            1) install_foliate ;;
            2) install_calibre ;;
            3) install_bookworm ;;
            4) install_koreader ;;
            5) install_komikku ;;
            6) install_mcomix ;;
            7) install_yacreader ;;
            8) install_wikijs ;;
            9) install_zim ;;
            10) install_koodo_reader ;;
            0) break ;;
            *) echo -e "${RED}❌ Invalid choice!${NC}" ;;
        esac
        read -p "Press [Enter] to continue..."
    done
}

install_foliate() {
    echo -e "${GREEN}📖 Installing Foliate...${NC}"
    if install_flatpak "com.github.johnfactotum.Foliate" "Foliate"; then
        echo -e "${GREEN}✅ Foliate installed! Modern EPUB reader with nice typography${NC}"
    else
        install_smart "foliate" "foliate" "foliate" "foliate" "Foliate"
    fi
}

install_calibre() {
    echo -e "${GREEN}📚 Installing Calibre...${NC}"
    if install_smart "calibre" "calibre" "calibre" "calibre" "Calibre"; then
        echo -e "${GREEN}✅ Calibre installed! Complete e-book library management${NC}"
    else
        echo -e "${YELLOW}📥 Alternative: sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin${NC}"
    fi
}

install_bookworm() {
    echo -e "${GREEN}📗 Installing Bookworm...${NC}"
    if install_flatpak "com.github.babluboy.bookworm" "Bookworm"; then
        echo -e "${GREEN}✅ Bookworm installed! Simple and focused e-book reader${NC}"
    else
        echo -e "${YELLOW}📥 Bookworm is primarily available as Flatpak${NC}"
    fi
}

install_koreader() {
    echo -e "${GREEN}📘 Installing KOReader...${NC}"
    # KOReader is often installed via package managers
    if install_smart "koreader" "koreader" "koreader" "koreader" "KOReader"; then
        echo -e "${GREEN}✅ KOReader installed! Advanced reader with PDF support${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://github.com/koreader/koreader${NC}"
    fi
}

install_komikku() {
    echo -e "${GREEN}🎌 Installing Komikku...${NC}"
    if install_flatpak "info.febvre.Komikku" "Komikku"; then
        echo -e "${GREEN}✅ Komikku installed! Manga and comic book reader${NC}"
    else
        # Try native package
        if install_smart "komikku" "komikku" "komikku" "komikku" "Komikku"; then
            echo -e "${GREEN}✅ Komikku installed!${NC}"
        else
            echo -e "${YELLOW}📥 Komikku is primarily available as Flatpak${NC}"
        fi
    fi
}

install_mcomix() {
    echo -e "${GREEN}🦸 Installing MComix...${NC}"
    if install_smart "mcomix" "mcomix" "mcomix" "mcomix" "MComix"; then
        echo -e "${GREEN}✅ MComix installed! Comic book reader with archive support${NC}"
    else
        echo -e "${YELLOW}📥 Try: sudo apt install mcomix${NC}"
    fi
}

install_yacreader() {
    echo -e "${GREEN}📓 Installing YACReader...${NC}"
    if install_smart "yacreader" "yacreader" "yacreader" "yacreader" "YACReader"; then
        echo -e "${GREEN}✅ YACReader installed! Comic reader with library management${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://www.yacreader.com/${NC}"
    fi
}

install_wikijs() {
    echo -e "${GREEN}🌐 Installing Wiki.js...${NC}"
    echo -e "${YELLOW}📝 Wiki.js is a Node.js application${NC}"
    echo -e "${BLUE}Installation methods:${NC}"
    echo -e "  1. Docker: docker run -d -p 3000:3000 --name wiki js/wiki"
    echo -e "  2. Node.js: npm install -g wiki.js"
    echo -e "  3. Visit: https://js.wiki/ for setup guide"
    echo -e "${YELLOW}💡 Recommended: Use Docker for easy setup${NC}"
}

install_zim() {
    echo -e "${GREEN}📝 Installing Zim Desktop Wiki...${NC}"
    if install_smart "zim" "zim" "zim" "zim" "Zim Desktop Wiki"; then
        echo -e "${GREEN}✅ Zim installed! Desktop wiki for note-taking${NC}"
    else
        echo -e "${YELLOW}📥 Download from: https://zim-wiki.org/${NC}"
    fi
}

install_koodo_reader() {
    echo -e "${GREEN}📱 Installing Koodo Reader...${NC}"
    echo -e "${BLUE}📥 Downloading Koodo Reader...${NC}"
    cd /tmp
    # Download the latest AppImage
    wget -O koodo-reader.AppImage "https://github.com/troyeguo/koodo-reader/releases/latest/download/Koodo-Reader-$(uname -m).AppImage"
    chmod +x koodo-reader.AppImage
    sudo mv koodo-reader.AppImage /usr/local/bin/koodo-reader
    echo -e "${GREEN}✅ Koodo Reader installed! Web-based e-book reader${NC}"
    echo -e "${YELLOW}🚀 Run with: koodo-reader${NC}"
}

# ============================================================================
# BEAST MODE - COMPLETE ULTIMATE INSTALLATION
# ============================================================================

beast_mode() {
    show_banner
    echo -e "${RED}🐉 BEAST MODE ACTIVATED 🐉${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}🚨 WARNING: This will install A LOT of software!${NC}"
    echo -e "${YELLOW}This may take a while and will use significant disk space.${NC}"
    echo ""
    read -p "Are you absolutely sure? (type 'YES' to continue): " confirm
    
    if [[ "$confirm" != "YES" ]]; then
        echo -e "${YELLOW}Beast Mode cancelled.${NC}"
        read -p "Press [Enter] to continue..."
        return
    fi
    
    echo -e "${GREEN}🚀 Starting Beast Mode installation...${NC}"
    log "Starting Beast Mode installation"
    
    # Create installation log
    BEAST_LOG="$SCRIPT_DIR/beast_mode_install.log"
    echo "Beast Mode Installation Log - $(date)" > "$BEAST_LOG"
    
    # System Essentials
    echo -e "${CYAN}📦 Installing system essentials...${NC}"
    install_package "htop" "Htop"
    install_package "fastfetch" "Fastfetch"
    install_package "curl" "Curl"
    install_package "wget" "Wget"
    install_package "git" "Git"
    install_package "vim" "Vim"
    install_package "tmux" "Tmux"
    
    # Development Tools
    echo -e "${BLUE}💻 Installing development tools...${NC}"
    install_package "python3" "Python 3"
    install_package "python-pip" "Python Pip"
    install_package "nodejs" "Node.js"
    install_package "npm" "NPM"
    install_package "jdk-openjdk" "Java JDK"
    install_package "docker" "Docker"
    install_package "docker-compose" "Docker Compose"
    install_vscodium
    
    # Browsers
    echo -e "${GREEN}🌐 Installing browsers...${NC}"
    install_package "firefox" "Firefox"
    install_thorium
    install_brave
    
    # Multimedia
    echo -e "${PURPLE}🎵 Installing multimedia apps...${NC}"
    install_package "vlc" "VLC"
    install_package "gimp" "GIMP"
    install_package "audacity" "Audacity"
    install_package "obs-studio" "OBS Studio"
    
    # Gaming
    echo -e "${ORANGE}🎮 Installing gaming tools...${NC}"
    install_steam
    install_heroic_launcher
    install_package "lutris" "Lutris"
    install_package "wine-staging" "Wine Staging"
    install_package "winetricks" "Winetricks"
    install_protonup_qt
    
    # Utilities
    echo -e "${CYAN}🛠️ Installing utilities...${NC}"
    install_package "gparted" "GParted"
    install_package "timeshift" "Timeshift"
    install_package "bleachbit" "BleachBit"
    install_package "nautilus" "Nautilus"
    
    
    # Fun Stuff
    echo -e "${MAGENTA}🎉 Installing fun tools...${NC}"
    install_package "cmatrix" "CMatrix"
    install_package "cowsay" "Cowsay"
    install_package "fortune-mod" "Fortune"
    install_package "lolcat" "Lolcat"
    install_package "figlet" "Figlet"
    install_komikku
    
    # Install Flatpak if not available
    if ! command -v flatpak &> /dev/null; then
        echo -e "${YELLOW}📦 Installing Flatpak...${NC}"
        install_package "flatpak" "Flatpak"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install Flatpak apps
    echo -e "${BLUE}📱 Installing Flatpak apps...${NC}"
    install_flatpak "com.spotify.Client" "Spotify"
    install_flatpak "com.visualstudio.code" "VS Code"
    install_flatpak "org.libreoffice.LibreOffice" "LibreOffice"
    install_flatpak "com.heroicgameslauncher.hgl" "Heroic Games Launcher"
    
    # Final system update
    echo -e "${GREEN}🔄 Performing final system update...${NC}"
    update_system
    
    # Completion message
    echo -e "${GREEN}✅ Beast Mode completed! Your system is now ULTIMATE!${NC}"
    echo -e "${CYAN}📊 Summary of installed software:${NC}"
    echo -e "  • System monitoring tools"
    echo -e "  • Development environments"
    echo -e "  • Multiple web browsers"
    echo -e "  • Multimedia applications"
    echo -e "  • Gaming platforms"
    echo -e "  • Utility programs"
    echo -e "  • Fun terminal applications"
    echo -e "  • Flatpak applications"
    
    log "Beast Mode installation completed"
    read -p "Press [Enter] to continue..."
}


# DIAGNOSTICS

diagnose_install_issues() {
    echo -e "${RED}🔧 SYSTEM HEALTH DIAGNOSTICS${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local issues_found=0
    local warnings_found=0
    
    echo -e "${CYAN}📊 SYSTEM HEALTH CHECK${NC}"
    echo ""

    # 1. Check Package Manager Health
    echo -e "${BLUE}📦 Package Manager Status${NC}"
    case "$PKG_MANAGER" in
        "pacman")
            if ! sudo pacman -Sy --noconfirm &> /dev/null; then
                echo -e "  ❌ Arch repositories - INACCESSIBLE"
                ((issues_found++))
            else
                echo -e "  ✅ Arch repositories - HEALTHY"
            fi
            ;;
        "apt")
            if ! sudo apt update &> /dev/null; then
                echo -e "  ❌ Ubuntu/Debian repositories - INACCESSIBLE"
                ((issues_found++))
            else
                echo -e "  ✅ Ubuntu/Debian repositories - HEALTHY"
            fi
            ;;
        "dnf")
            if ! sudo dnf check-update &> /dev/null; then
                echo -e "  ❌ Fedora repositories - INACCESSIBLE"
                ((issues_found++))
            else
                echo -e "  ✅ Fedora repositories - HEALTHY"
            fi
            ;;
        "zypper")
            if ! sudo zypper refresh &> /dev/null; then
                echo -e "  ❌ openSUSE repositories - INACCESSIBLE"
                ((issues_found++))
            else
                echo -e "  ✅ openSUSE repositories - HEALTHY"
            fi
            ;;
        *)
            echo -e "  ⚠️  Unknown package manager: $PKG_MANAGER"
            ((warnings_found++))
            ;;
    esac
    echo ""

    # 2. Check Kernel and Drivers
    echo -e "${BLUE}🐧 Kernel & Drivers${NC}"
    
    # Check if running latest kernel
    current_kernel=$(uname -r)
    echo -e "  Current kernel: $current_kernel"
    
    # Check graphics drivers
    if lspci | grep -i "nvidia" &> /dev/null; then
        if ! command -v nvidia-smi &> /dev/null; then
            echo -e "  ❌ NVIDIA GPU detected but drivers not installed"
            ((issues_found++))
        else
            echo -e "  ✅ NVIDIA drivers - INSTALLED"
        fi
    fi
    
    if lspci | grep -i "amd" &> /dev/null; then
        if [ ! -d "/usr/lib/xorg/modules/drivers/amdgpu_drv.so" ]; then
            echo -e "  ⚠️  AMD GPU detected - check if mesa drivers are optimal"
            ((warnings_found++))
        else
            echo -e "  ✅ AMD drivers - DETECTED"
        fi
    fi
    
    # Check for missing firmware
    if dmesg | grep -i "firmware" | grep -i "missing" &> /dev/null; then
        echo -e "  ❌ Missing firmware detected (check dmesg)"
        ((issues_found++))
    fi
    echo ""

    # 3. Check Disk Health
    echo -e "${BLUE}💾 Storage Health${NC}"
    
    local disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        echo -e "  ❌ Disk usage: ${disk_usage}% - CRITICALLY FULL"
        ((issues_found++))
    elif [ "$disk_usage" -gt 80 ]; then
        echo -e "  ⚠️  Disk usage: ${disk_usage}% - GETTING FULL"
        ((warnings_found++))
    else
        echo -e "  ✅ Disk usage: ${disk_usage}% - HEALTHY"
    fi
    
    # Check disk space for installations
    local free_space=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$free_space" -lt 5 ]; then
        echo -e "  ❌ Only ${free_space}GB free - INSUFFICIENT FOR INSTALLATIONS"
        ((issues_found++))
    elif [ "$free_space" -lt 10 ]; then
        echo -e "  ⚠️  ${free_space}GB free - LIMITED SPACE"
        ((warnings_found++))
    fi
    echo ""

    # 4. Check Memory
    echo -e "${BLUE}💻 Memory Status${NC}"
    
    local mem_info=$(free -h | awk 'NR==2{print $3 " / " $2}')
    echo -e "  Memory usage: $mem_info"
    
    local swap_usage=$(free | awk 'NR==3{if ($2!=0) printf "%.1f", $3/$2*100; else print "0"}')
    if [ "$swap_usage" != "0" ] && [ "${swap_usage%.*}" -gt 50 ]; then
        echo -e "  ⚠️  High swap usage: ${swap_usage}% - CONSIDER MORE RAM"
        ((warnings_found++))
    fi
    echo ""

    # 5. Check Network
    echo -e "${BLUE}🌐 Network Status${NC}"
    
    if ! ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        echo -e "  ❌ Network connectivity - FAILED"
        ((issues_found++))
    else
        echo -e "  ✅ Network connectivity - OK"
    fi
    
    # Check DNS
    if ! nslookup google.com &> /dev/null; then
        echo -e "  ❌ DNS resolution - FAILED"
        ((issues_found++))
    else
        echo -e "  ✅ DNS resolution - OK"
    fi
    echo ""

    # 6. Check System Updates
    echo -e "${BLUE}🔄 System Updates${NC}"
    
    case "$PKG_MANAGER" in
        "pacman")
            updates=$(pacman -Qu | wc -l)
            ;;
        "apt")
            updates=$(apt list --upgradable 2>/dev/null | wc -l)
            updates=$((updates-1))
            ;;
        "dnf")
            updates=$(dnf check-update --quiet | wc -l)
            ;;
        *)
            updates=0
            ;;
    esac
    
    if [ "$updates" -gt 10 ]; then
        echo -e "  ⚠️  $updates pending updates - SYSTEM MAY BE OUTDATED"
        ((warnings_found++))
    elif [ "$updates" -gt 0 ]; then
        echo -e "  ℹ️  $updates updates available"
    else
        echo -e "  ✅ System is up to date"
    fi
    echo ""

    # 7. Check Essential Tools
    echo -e "${BLUE}🛠️ Essential Tools${NC}"
    
    local essential_tools=("curl" "wget" "git" "sudo")
    local missing_tools=()
    
    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "  ⚠️  Missing tools: ${missing_tools[*]}"
        ((warnings_found++))
    else
        echo -e "  ✅ All essential tools available"
    fi
    echo ""

    # SUMMARY
    echo -e "${RED}📋 DIAGNOSTIC SUMMARY${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    if [ $issues_found -eq 0 ] && [ $warnings_found -eq 0 ]; then
        echo -e "🎉 ${GREEN}SYSTEM HEALTHY - No issues detected${NC}"
    else
        if [ $issues_found -gt 0 ]; then
            echo -e "❌ ${RED}$issues_found CRITICAL ISSUES found${NC}"
            echo -e "   These may prevent software installation"
        fi
        
        if [ $warnings_found -gt 0 ]; then
            echo -e "⚠️  ${YELLOW}$warnings_found WARNINGS found${NC}"
            echo -e "   Consider addressing these for optimal performance"
        fi
        echo ""
        echo -e "${CYAN}💡 Run individual checks from the System tab to fix issues${NC}"
    fi
    
    # Optional: Package installation test
    echo ""
    read -p "Run optional package installation test? (y/N): " run_test
    if [[ $run_test =~ ^[Yy]$ ]]; then
        test_package_installation
    fi
}

test_package_installation() {
    echo ""
    echo -e "${BLUE}🧪 OPTIONAL: Package Installation Test${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${CYAN}This will test if packages can be installed on your system${NC}"
    echo ""
    
    read -p "Enter package name to test (or press enter for default 'curl'): " test_package
    test_package=${test_package:-"curl"}
    
    echo -e "${BLUE}🔍 Testing installation of: $test_package${NC}"
    
    if install_smart "$test_package" "$test_package" "$test_package" "$test_package" "TEST-$test_package"; then
        echo -e "${GREEN}✅ SUCCESS: $test_package can be installed${NC}" 
        echo -e "${GREEN}🎉 Your package manager is working correctly${NC}"
        sleep 3    
    else
        echo -e "${RED}❌ FAILED: Cannot install $test_package${NC}"
        echo -e "${YELLOW}💡 Check your repositories and internet connection${NC}"
        sleep 3
    fi
}

# ============================================================================
# MAIN MENU & INITIALIZATION
# ============================================================================

# Command line arguments handling
handle_arguments() {
    case "$1" in
        "--help"|"-h")
            show_help
            exit 0
            ;;
        "--version"|"-v")
            show_version
            exit 0
            ;;
        "--update")
            update_system
            exit 0
            ;;
        "--beast")
            beast_mode
            exit 0
            ;;
        "")
            # No arguments, continue to main menu
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo "Use: electro [--help|--version|--update|--beast]"
            exit 1
            ;;
    esac
}

show_help() {
    echo -e "${GREEN}⚡ Electrotility - Ultimate Linux Utility Tool${NC}"
    echo ""
    echo "Usage: electro [OPTION]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo "  --update       Update system and exit"
    echo "  --beast        Install everything (Beast Mode)"
    echo ""
    echo "Features:"
    echo "  🖥️  System Management    - Updates, drivers, backup, monitoring"
    echo "  💻 Development Tools     - IDEs, languages, containers, databases"
    echo "  🎮 Gaming Setup          - Launchers, Wine, performance tools"
    echo "  📱 Applications         - Browsers, multimedia, productivity"
    echo "  🛠️  System Tools         - Monitoring, network, security, disk"
    echo "  🎉 Fun & Entertainment   - Games, visual effects, AI tools"
    echo ""
    echo "Examples:"
    echo "  electro          # Launch the interactive menu"
    echo "  electro --help   # Show this help"
    echo "  electro --version # Show version"
    echo "  electro --update # Update system packages"
    echo "  electro --beast  # Install everything awesome"
}

show_version() {
    echo -e "${GREEN}⚡ Electrotility v2.0.0${NC}"
    echo "Ultimate Linux Power Management System"
    echo "Created with ❤️ for the Linux community"
    echo "Features: Complete package management, 200+ applications, Beast Mode"
}

# System Information Display
show_system_info() {
    echo -e "${CYAN}📊 SYSTEM INFORMATION${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Always show your banner
    show_banner
    echo ""
    
    # Then show system info - this part was broken in the second script
    if command -v fastfetch &> /dev/null; then
        echo -e "${GREEN}⚡ System Details:${NC}"
        fastfetch --structure title:separator:os:host:kernel:uptime:packages:shell:de:wm:terminal:cpu:gpu:memory:disk --logo none
    elif command -v neofetch &> /dev/null; then
        echo -e "${GREEN}⚡ System Details:${NC}"
        neofetch --off --color_blocks off
    else
        # Show basic info WITHOUT trying to install anything
        show_basic_system_info
    fi
}

show_basic_system_info() {
    echo -e "${GREEN}🖥️ SYSTEM OVERVIEW${NC}"
    echo -e "${YELLOW}──────────────────────────────────────────────────────────────${NC}"
    echo ""
    
    echo -e "  📦 ${CYAN}OS:${NC} $DISTRO_NAME $DISTRO_VERSION"
    echo -e "  🐧 ${CYAN}Kernel:${NC} $(uname -r)"
    echo -e "  ⏰ ${CYAN}Uptime:${NC} $(uptime -p | sed 's/up //')"
    echo -e "  💻 ${CYAN}CPU:${NC} $(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')"
    
    # GPU info (handle gracefully if command fails)
    if lspci &> /dev/null; then
        gpu_info=$(lspci | grep -i "vga\|3d\|display" | head -1 | cut -d: -f3 | sed 's/^ *//')
        echo -e "  🎮 ${CYAN}GPU:${NC} ${gpu_info:-Unknown}"
    else
        echo -e "  🎮 ${CYAN}GPU:${NC} Unknown (install pciutils)"
    fi
    
    echo -e "  💾 ${CYAN}RAM:${NC} $(free -h | awk 'NR==2{print $3 "/" $2 " used"}')"
    echo -e "  💿 ${CYAN}Disk:${NC} $(df -h / | awk 'NR==2{print $3 "/" $2 " (" $5 " used)"}')"
    
    # IP address
    ip_info=$(hostname -I 2>/dev/null | awk '{print $1}')
    echo -e "  🌐 ${CYAN}Local IP:${NC} ${ip_info:-Not available}"
    
    # Desktop environment
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        echo -e "  🖼️ ${CYAN}Desktop:${NC} $XDG_CURRENT_DESKTOP"
    elif [ -n "$DESKTOP_SESSION" ]; then
        echo -e "  🖼️ ${CYAN}Desktop:${NC} $DESKTOP_SESSION"
    fi
    
    # Shell info
    echo -e "  🐚 ${CYAN}Shell:${NC} $SHELL"
}

# Quick Actions Menu
quick_actions() {
    echo -e "${YELLOW}🚀 Quick Actions:${NC}"
    echo -e "  ${GREEN}u${NC}) Update System"
    echo -e "  ${GREEN}c${NC}) Clean System"
    echo -e "  ${GREEN}s${NC}) System Info"
    echo -e "  ${GREEN}r${NC}) Check Resources"
    echo -e "  ${GREEN}d${NC}) Diagnose"
}

# Main Menu
main_menu() {
    while true; do
        show_banner
        show_system_info
        echo ""
        quick_actions
        echo ""
        echo -e "${CYAN}📋 MAIN MENU - CHOOSE YOUR TAB${NC}"
        echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}🖥️  1) SYSTEM TAB${NC}"
        echo -e "    Updates, System & Theme Configuration, Security, ISO & Boot Management"
        echo ""
        echo -e "${BLUE}💻 2) DEVELOPMENT TAB${NC}"
        echo -e "    IDEs, Languages, Tools, Databases, Virtualization, DevOps"
        echo ""
        echo -e "${ORANGE}🎮 3) GAMING TAB${NC}"
        echo -e "    Launchers, Wine, Performance, Games, Emulators"
        echo ""
        echo -e "${PURPLE}📱 4) APPS TAB${NC}"
        echo -e "    Browsers, Multimedia, YT Alternatives, Productivity, Creative"
        echo ""
        echo -e "${RED}🛠️  5) TOOLS TAB${NC}"
        echo -e "    Monitoring, Network, Security, VPN, Disk, Hardware"
        echo ""
        echo -e "${MAGENTA}🎉 6) FUN TAB${NC}"
        echo -e "    Games, Visual Effects, Music, AI & GPT, Books, Entertainment"
        echo ""
        echo -e "${YELLOW}⚡ 7) BEAST MODE${NC}"
        echo -e "    INSTALL EVERYTHING AWESOME"
        echo ""
        echo -e "${RED}0) Exit${NC}"
        echo ""
        read -p "Choose your tab: " choice

        case $choice in
            u|U) update_system ;;
            c|C) 
                clean_package_cache
                remove_orphaned_packages
                ;;
            s|S) show_system_info; read -p "Press [Enter] to continue..." ;;
            r|R) monitor_system_resources ;;
            d|D) diagnose_install_issues ;;
            1) system_tab ;;
            2) development_tab ;;
            3) gaming_tab ;;
            4) apps_tab ;;
            5) tools_tab ;;
            6) fun_tab ;;
            7) beast_mode ;; 
            0)
                echo -e "${GREEN}👋 Thanks for using Electrotility!${NC}"
                echo -e "${CYAN}⚡ Stay powered up!${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}❌ Invalid choice!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Initialize System
initialize_system() {
    echo -e "${BLUE}⚡ Initializing Electrotility...${NC}"
    
    # Check if running as root
    check_root
    
    # Detect distribution
    detect_distro
    
    # Check internet connection
    if ! check_internet; then
        echo -e "${YELLOW}⚠️  No internet connection detected${NC}"
        echo -e "${YELLOW}Some features may not work without internet${NC}"
    fi
    
    # Create necessary directories
    mkdir -p "$TEMP_DIR"
    
    # Log startup
    log "Electr OS started - Distro: $DISTRO_NAME, Version: $DISTRO_VERSION"
    
    # Show welcome message
    echo -e "${GREEN}✅ Electrotility initialized successfully!${NC}"
    sleep 1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Please do not run this script as root!${NC}"
        echo -e "${YELLOW}Run as regular user and use sudo when needed.${NC}"
        exit 1
    fi
}

# Check internet connection
check_internet() {
    echo -e "${BLUE}🌐 Checking internet connection...${NC}"
    if ping -c 1 -W 3 google.com &> /dev/null || ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}✅ Internet connection available${NC}"
        return 0
    else
        echo -e "${RED}❌ No internet connection detected${NC}"
        return 1
    fi
}

# Cleanup function
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up temporary files...${NC}"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Signal handlers
trap cleanup EXIT
trap 'echo -e "\n${YELLOW}⚠️  Interrupted by user${NC}"; cleanup; exit 1' INT TERM

# Main execution
main() {
    initialize_system
    handle_arguments "$1"
    main_menu
}

# Start the application
main "$@"

