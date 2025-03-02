#!/usr/bin/env bash
#
# Author:         Joao Pedro Barbosa
# Based on:       https://raw.githubusercontent.com/Diolinux/pop-os-postinstall/refs/heads/main/pop-os-postinstall.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #
set -e  

##URLS

URL_DISCORD="https://discord.com/api/download?platform=linux&format=deb"
URL_VSCODE="https://vscode.download.prss.microsoft.com/dbazure/download/stable/e54c774e0add60467559eb0d1e229c6452cf8447/code_1.97.2-1739406807_amd64.deb"
URL_WARP="https://app.warp.dev/get_warp\?package\=deb"


DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
FILE="/home/$USER/.config/gtk-3.0/bookmarks"


#COLORS

ORANGE='\e[1;93m'
BLUE='\e[1;94m'
NON_COLOR='\e[0m'


#FUNCTIONS

# Atualizando repositório e fazendo atualização do sistema

apt_update(){
  sudo apt update && sudo apt dist-upgrade -y
}

# Internet conectando?
testes_internet(){
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${ORANGE}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${NON_COLOR}"
  exit 1
else
  echo -e "${BLUE}[INFO] - Conexão com a Internet funcionando normalmente.${NON_COLOR}"
fi
}

# ------------------------------------------------------------------------------ #


## Removendo travas eventuais do apt ##
travas_apt(){
  sudo rm -f /var/lib/dpkg/lock-frontend
  sudo rm -f /var/cache/apt/archives/lock
}

## Atualizando o repositório ##
just_apt_update(){
sudo apt update -y
}

##DEB SOFTWARES TO INSTALL

PROGRAMAS_PARA_INSTALAR=(
  vlc
  folder-color
  git
  wget
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##

install_debs(){

echo -e "${BLUE}[INFO] - Baixando pacotes .deb${NON_COLOR}"

mkdir -p "$DIRETORIO_DOWNLOADS"
cd "$DIRETORIO_DOWNLOADS"

wget --content-disposition -c "$URL_DISCORD"
wget --content-disposition -c "$URL_VSCODE"
wget -c "$URL_WARP" -O warp-terminal-latest.deb

cd "$HOME"

## Instalando pacotes .deb baixados na sessão anterior ##
echo -e "${BLUE}[INFO] - Instalando pacotes .deb baixados${NON_COLOR}"
sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

# Instalar programas no apt
echo -e "${BLUE}[INFO] - Instalando pacotes apt do repositório${NON_COLOR}"

for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_programa" -y
  else
    echo "[INSTALADO] - $nome_do_programa"
  fi
done

}
## Instalando pacotes Flatpak ##
install_flatpaks(){

  echo -e "${BLUE}[INFO] - Instalando pacotes flatpak${NON_COLOR}"

flatpak install flathub com.obsproject.Studio -y
flatpak install flathub org.gimp.GIMP -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub org.telegram.desktop -y
flatpak install flathub io.dbeaver.DBeaverCommunity -y

}

##Instalando Docker ##
install_docker(){

# Remove pacotes conflitantes
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Adicionar a chave GPG oficial do Docker:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Adicionar o repositório as fontes Apt:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Instalando definitivamente docker e extensões
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

}

## Finalização, atualização e limpeza##

system_clean(){

apt_update -y
flatpak update -y
sudo apt autoclean -y
sudo apt autoremove -y
nautilus -q
}


#Cria pastas no nautilus
extra_config(){

mkdir -p /home/$USER/Temp
mkdir -p /home/$USER/Projects
mkdir -p /home/$USER/Vídeos/'OBS Rec'

#Adiciona atalhos ao Nautilus

if test -f "$FILE"; then
    echo "$FILE já existe"
else
    echo "$FILE não existe, criando..."
    touch /home/$USER/.config/gkt-3.0/bookmarks
fi

echo "file:///home/$USER/Temp 🕖 Temp" >> $FILE
echo "file:///home/$USER/Projects 🔧 Projects" >> $FILE
}

# -------------------------------EXECUÇÃO----------------------------------------- #

travas_apt
testes_internet
travas_apt
apt_update
travas_apt
just_apt_update
install_debs
install_flatpaks
extra_config
install_docker
apt_update
system_clean

## finalização

  echo -e "${BLUE}[INFO] - Script finalizado, instalação concluída! :)${NON_COLOR}"