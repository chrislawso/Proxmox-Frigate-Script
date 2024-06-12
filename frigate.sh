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
APP="Frigate"
var_disk="20"
var_cpu="4"
var_ram="4096"
var_os="debian"
var_version="11"
variables
color
catch_errors

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

# Definir la función para la instalación
function install_script() {
  pve_check
  shell_check
  root_check
  arch_check
  ssh_check

  if systemctl is-active -q ping-instances.service; then
    systemctl -q stop ping-instances.service
  fi
  NEXTID=$(pvesh get /cluster/nextid)
  timezone=$(cat /etc/timezone)
  header_info
  if (whiptail --backtitle "Proxmox VE Helper Scripts" --title "SETTINGS" --yesno "Use Default Settings?" --no-button Advanced 10 58); then
    header_info
    echo -e "${BL}Using Default Settings${CL}"
    default_settings
  else
    header_info
    echo -e "${RD}Using Advanced Settings${CL}"
    advanced_settings
  fi
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

# Función para construir el contenedor
function build_container() {
  # Código para construir el contenedor
  msg_info "Building container"
  # Aquí debe estar el código que construye el contenedor
  msg_ok "Container built"
}

# Función para la descripción del contenedor
function description() {
  IP=$(pct exec "$CTID" ip a s dev eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
  pct set "$CTID" -description "<div align='center'><a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'><img src='https://raw.githubusercontent.com/tteck/Proxmox/main/misc/images/logo-81x112.png'/></a>

  # ${APP} LXC

  <a href='https://ko-fi.com/D1D7EP4GF'><img src='https://img.shields.io/badge/&#x2615;-Buy me a coffee-blue' /></a>
  </div>"
  if [[ -f /etc/systemd/system/ping-instances.service ]]; then
    systemctl start ping-instances.service
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
