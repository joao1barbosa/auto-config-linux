#!/usr/bin/env bash
#
# Author:         Joao Pedro Barbosa
# Based on:       https://raw.githubusercontent.com/Diolinux/pop-os-postinstall/refs/heads/main/pop-os-postinstall.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #
set -e  

##URLS
URL_DISCORD="https://discord.com/api/download?platform=linux&format=deb"
URL_VSCODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
# Não encontrei um lick que baixa automaticamente a versão mais recente
URL_WARP="https://releases.warp.dev/stable/v0.2025.02.26.08.02.stable_02/warp-terminal_0.2025.02.26.08.02.stable.02_amd64.deb"

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

## Adiciona repositórios necessários ##
add_repositories(){
  sudo add-apt-repository ppa:ondrej/php -y
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
  php
  python3
  python3-pip
  zsh
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##
install_debs(){

echo -e "${BLUE}[INFO] - Baixando pacotes .deb${NON_COLOR}"

mkdir -p "$DIRETORIO_DOWNLOADS"
cd "$DIRETORIO_DOWNLOADS"

wget --content-disposition -c "$URL_DISCORD"
wget --content-disposition -c "$URL_VSCODE"
wget --content-disposition -c "$URL_WARP"

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

  echo -e "${BLUE}[INFO] - Instalando Docker ${NON_COLOR}"

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
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER

}

## Instalar NVM e configurar o Node.js ##
install_nvm(){

  echo -e "${BLUE}[INFO] - Instalando NVM e Node.js (lts)${NON_COLOR}"

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  nvm install node
  nvm alias default node
  nvm use node

}

## Install Supabase ##
install_supabase(){
  echo -e "${BLUE}[INFO] - Instalando Supabase CLI${NON_COLOR}"

  sudo curl -L -o /usr/local/bin/supabase https://github.com/supabase/cli/releases/latest/download/supabase-linux-amd64

  sudo chmod +x /usr/local/bin/supabase
}

## Configurar ZSH com extensões ##
config_zsh(){
  echo -e "${BLUE}[INFO] - Configurando o ZSH${NON_COLOR}"

  cp ../_zsh-files/* "$HOME"

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # Clona repositório do tema powerlevel10k
  git clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

  # Adiciona extensões ao ZSH
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

  # Define o Zsh como shell padrão
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    echo "Zsh definido como shell padrão."
  else
    echo "Zsh já é o shell padrão."
  fi
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

echo "file:///home/$USER/Temp Temp" >> $FILE
echo "file:///home/$USER/Projects Projects" >> $FILE
}

## Config git ##
config_git(){
git config --global user.name joao1barbosa
git config --global user.email joao1.barbosa@outlook.com
git config --global core.editor code

}

## Configura fontes do sistema ##
config_fonts(){
  sudo cp -r ../_fonts/* /usr/share/fonts

  fc-cache -f -v

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
install_docker
install_nvm
install_supabase
extra_config
apt_update
config_git
config_fonts
system_clean
config_zsh
