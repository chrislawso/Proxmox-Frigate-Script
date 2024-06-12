#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/mercuryin/Proxmox-Frigate-Script/main/build.func)
# Copyright (c) 2021-2024 tteck
# Authors: tteck (tteckster)
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
  clear
  cat <<"EOF"
    ______     _             __
   / ____/____(_)___ _____ _/ /____
  / /_  / ___/ / __ `/ __ `/ __/ _ \
 / __/ / /  / / /_/ / /_/ / /_/  __/
/_/   /_/  /_/\__, /\__,_/\__/\___/
             /____/

EOF
}

header_info
echo -e "Loading..."

# Definir variables de configuración
APP="Frigate"
var_disk="20"
var_cpu="4"
var_ram="4096"
var_os="debian"
var_version="11"

# Llamar a las funciones definidas en build.func
variables
color
catch_errors

# Definir la función para los valores predeterminados
function default_settings() {
  CT_TYPE="0"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
  if [[ ! -f /etc/systemd/system/frigate.service ]]; then 
    msg_error "No ${APP} Installation Found!"
    exit 1
  fi
  msg_error "There is currently no update path available."
  exit 1
}

# Función para iniciar la instalación
function start() {
  if command -v pveversion >/dev/null 2>&1; then
    if ! (whiptail --backtitle "Proxmox VE Helper Scripts" --title "${APP} LXC" --yesno "This will create a New ${APP} LXC. Proceed?" 10 58); then
      clear
      echo -e "⚠  User exited script \n"
      exit 1
    fi
    SPINNER_PID=""
    install_script
  fi

  if ! command -v pveversion >/dev/null 2>&1; then
    if ! (whiptail --backtitle "Proxmox VE Helper Scripts" --title "${APP} LXC UPDATE" --yesno "Support/Update functions for ${APP} LXC. Proceed?" 10 58); then
      clear
      echo -e "⚠  User exited script \n"
      exit 1
    fi
    SPINNER_PID=""
    update_script
  fi
}

# Iniciar el script
start
build_container
description

msg_info "Setting Container to Normal Resources"
pct set $CTID -memory 1024
msg_ok "Set Container to Normal Resources"
msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:5000${CL} \n"
echo -e "go2rtc should be reachable by going to the following URL.
         ${BL}http://${IP}:1984${CL} \n"
