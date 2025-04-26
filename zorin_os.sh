#!/usr/bin/env bash
#
# Author:         Joao Pedro Barbosa
# Based on:       https://github.com/Diolinux/pop-os-postinstall/tree/main
#
# ----------------------------- VARIÁVEIS ----------------------------- #
set -e  

# URLS
URL_DISCORD="https://discord.com/api/download?platform=linux&format=deb"
URL_VSCODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
URL_CONFIGFILES="https://github.com/joao1barbosa/auto-config-linux/releases/download/latest/config_files.zip"

# Diretórios
DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"
FILE="/home/$USER/.config/gtk-3.0/bookmarks"

# Cores
ORANGE='\e[1;93m'
BLUE='\e[1;94m'
NON_COLOR='\e[0m'

# Softwares DEB para instalar
PROGRAMAS_PARA_INSTALAR=(
  vlc
  folder-color
  git
  wget
  php
  python3
  python3-pip
  zsh
  unzip
)

# Funções

## Atualiza repositório e faz atualização do sistema ##
apt_update(){

  sudo apt update && sudo apt dist-upgrade -y

}

## Testa internet ##
testes_internet(){

  if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
    echo -e "${ORANGE}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${NON_COLOR}"
    exit 1
  else
    echo -e "${BLUE}[INFO] - Conexão com a Internet funcionando normalmente.${NON_COLOR}"
  fi

}

## Remove travas eventuais do apt ##
travas_apt(){

  sudo rm -f /var/lib/dpkg/lock-frontend
  sudo rm -f /var/cache/apt/archives/lock

}

## Adiciona repositórios necessários ##
add_repositories(){

  sudo add-apt-repository ppa:ondrej/php -y
  sudo apt update -y

}

## Baixa e instala programas externos ##
install_debs(){

  echo -e "${BLUE}[INFO] - Baixando pacotes .deb${NON_COLOR}"
  
  mkdir -p "$DIRETORIO_DOWNLOADS"
  cd "$DIRETORIO_DOWNLOADS"
  
  wget --content-disposition -c "$URL_DISCORD"
  wget --content-disposition -c "$URL_VSCODE"
  
  cd "$HOME"
  
  echo -e "${BLUE}[INFO] - Instalando pacotes .deb baixados${NON_COLOR}"
  sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb
  
  echo -e "${BLUE}[INFO] - Instalando pacotes apt do repositório${NON_COLOR}"
  
  for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
    if ! dpkg -l | grep -q $nome_do_programa; then 
      sudo apt install "$nome_do_programa" -y
    else
      echo "[INSTALADO] - $nome_do_programa"
    fi
  done

}

## Instala pacotes Flatpak ##
install_flatpaks(){

  echo -e "${BLUE}[INFO] - Instalando pacotes flatpak${NON_COLOR}"

  flatpak install flathub com.obsproject.Studio -y
  flatpak install flathub org.gimp.GIMP -y
  flatpak install flathub com.spotify.Client -y
  flatpak install flathub org.telegram.desktop -y
  flatpak install flathub io.dbeaver.DBeaverCommunity -y
  flatpak install flathub app.zen_browser.zen -y

}

## Instala Docker ##
install_docker(){

  echo -e "${BLUE}[INFO] - Instalando Docker ${NON_COLOR}"

  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  
  sudo usermod -aG docker $USER

}

## Instala NVM e configura o Node.js ##
install_nvm(){

  echo -e "${BLUE}[INFO] - Instalando NVM e Node.js (lts)${NON_COLOR}"

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  nvm install node
  nvm alias default node
  nvm use node

}

## Instala Supabase ##
install_supabase(){

  echo -e "${BLUE}[INFO] - Instalando Supabase CLI${NON_COLOR}"

  cd "$DIRETORIO_DOWNLOADS"
  
  URL_SUPABASE=$(curl -s https://api.github.com/repos/supabase/cli/releases/latest | grep -oP 'https://[^"]+supabase_linux_amd64\.tar\.gz')
  curl -L -o supabase.tar.gz "$URL_SUPABASE"
  
  tar -xzf supabase.tar.gz supabase
  chmod +x supabase

  sudo mv supabase /usr/local/bin/supabase

  rm supabase.tar.gz

  cd "$HOME"

}

## Cria pastas no nautilus ##
extra_config(){

  mkdir -p /home/$USER/Temp
  mkdir -p /home/$USER/Projects
  
  if test -f "$FILE"; then
      echo "$FILE já existe"
  else
      echo "$FILE não existe, criando..."
      touch /home/$USER/.config/gkt-3.0/bookmarks
  fi
  
  echo "file:///home/$USER/Temp Temp" >> $FILE
  echo "file:///home/$USER/Projects Projects" >> $FILE

}

## Configura o Git ##
config_git(){

  git config --global user.name joao1barbosa
  git config --global user.email joao1.barbosa@outlook.com
  git config --global core.editor code

}

## Baixa arquivos para configuração ##
download_config_files(){

  echo -e "${BLUE}[INFO] - Baixando arquivos de Configuração${NON_COLOR}"

  cd "$DIRETORIO_DOWNLOADS"

  wget --content-disposition -c "$URL_CONFIGFILES"
  unzip config_files.zip

  cd "$HOME"

}

## Configura fontes ##
config_fonts(){

  echo -e "${BLUE}[INFO] - Configurando Fontes${NON_COLOR}"

  sudo cp -r $DIRETORIO_DOWNLOADS/config_files/Fonts/* /usr/share/fonts
  fc-cache -f -v

}

## Configura ZSH e extensões ##
config_zsh(){
  echo -e "${BLUE}[INFO] - Configurando o ZSH${NON_COLOR}"

  mkdir -p ~/.zsh

  cp -f $DIRETORIO_DOWNLOADS/config_files/.zshrc "$HOME"

  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

  CURRENT_SHELL=$(basename "$SHELL")
  ZSH_PATH=$(which zsh)

  if [ "$CURRENT_SHELL" != "zsh" ] && [ -n "$ZSH_PATH" ]; then
    echo "Definindo Zsh como shell padrão..."
    chsh -s "$ZSH_PATH" || echo "Erro ao alterar o shell padrão"
  else
    echo "Zsh já é o shell padrão ou não está instalado."
  fi

  cd "$HOME"
}

## Aplica personalizações ao Gnome Terminal ##
config_terminal(){

  dconf load /org/gnome/terminal/ < $DIRETORIO_DOWNLOADS/config_files/gnome-terminal.conf

}

## Finaliza, atualiza e limpa ##
system_clean(){

  rm -rf "$DIRETORIO_DOWNLOADS"
  apt_update -y
  flatpak update -y
  sudo apt autoclean -y
  sudo apt autoremove -y
  nautilus -q
}

# -------------------------------EXECUÇÃO----------------------------------------- #

testes_internet
travas_apt
apt_update
travas_apt
add_repositories
install_debs
install_flatpaks
install_docker
install_nvm
install_supabase
config_git
download_config_files
config_fonts
extra_config
apt_update
config_zsh
config_terminal
system_clean
