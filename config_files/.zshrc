# Starship Prompt
eval "$(starship init zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Personal aliases
alias supa="supabase"
alias py="python3"
alias sail="./vendor/bin/sail"

# History config
HISTFILE=~/.zsh_history
HISTSIZE=100
SAVEHIST=2000
setopt INC_APPEND_HISTORY SHARE_HISTORY

export ANDROID_HOME=${HOME}/Android/Sdk
export PATH=${ANDROID_HOME}/tools:${PATH}
export PATH=${ANDROID_HOME}/emulator:${PATH}
export PATH=${ANDROID_HOME}/platform-tools:${PATH}
