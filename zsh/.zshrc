export TERM="xterm-kitty"  # Add this to your shell rc (e.g., ~/.bashrc, ~/.zshrc)
export MANPAGER="nvim +Man!"
if [ -n "${NVIM_LISTEN_ADDRESS+x}" ]; then
  export MANPAGER="/usr/local/bin/nvr -c 'Man!' -o -"
fi
export PATH=/home/xkenshi/usr/local/texlive/2024/bin/x86_64-linux:$PATH
export PATH=/home/xkea/.cargo/bin:$PATH
export MANPATH=/home/xkenshi/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH
export INFOPATH=/home/xkenshi/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH

export XDG_RUNTIME_DIR=/tmp/xdg-runtime-dir

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/codelldb/extension/adapter"

set -o vi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"



# Add in zsh plugins
zinit ice silent wait
zinit light zsh-users/zsh-syntax-highlighting
zinit ice silent wait
zinit light zsh-users/zsh-completions
zinit ice silent wait
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZP::tmux
zinit ice silent wait
zinit snippet OMZP::git
zinit ice silent wait
zinit snippet OMZP::sudo
zinit ice silent wait
zinit snippet OMZP::archlinux
zinit ice silent wait
zinit snippet OMZP::aws
zinit ice silent wait
zinit snippet OMZP::kubectl
zinit ice silent wait
zinit snippet OMZP::kubectx
zinit ice silent wait
zinit snippet OMZP::command-not-found
zinit ice silent wait


# Auto-start tmux only in interactive local shells, not nested or ssh
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [[ -z "$SSH_TTY" ]]; then
    tmux attach-session -t default || tmux new-session -s default
    exit
fi




# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q


#Starship config
eval "$(starship init zsh)"



# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias make-template='cp ~/.makefile_template ./Makefile && echo "Template Makefile created in current directory"'
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias cat=bat

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"


# Define Editor
export EDITOR=nvim

# -----------------------------------------------------
# ALIASES
# -----------------------------------------------------
alias catngrok="cat ~/connection.log | grep -o \"[0-9]\+\.tcp\.[a-z.]\+:[0-9]\+\""
alias c='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'
alias vim='$EDITOR'
alias ts='~/dotfiles/scripts/snapshot.sh'
alias matrix='cmatrix'
alias wifi='nmtui'
alias od='~/private/onedrive.sh'
alias rw='~/dotfiles/waybar/reload.sh'
alias winclass="xprop | grep 'CLASS'"
alias dot="cd ~/dotfiles"
alias cleanup='~/dotfiles/scripts/cleanup.sh'
# GIT
# -----------------------------------------------------
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gst="git stash"
alias gsp="git stash; git pull"
alias gcheck="git checkout"
alias gcredential="git config credential.helper store"

# -----------------------------------------------------
# SCRIPTS
# -----------------------------------------------------
#alias gr='python ~/dotfiles/scripts/growthrate.py'
#alias ChatGPT='python ~/mychatgpt/mychatgpt.py'
#alias chat='python ~/mychatgpt/mychatgpt.py'
#alias ascii='~/dotfiles/scripts/figlet.sh'

# -----------------------------------------------------
# VIRTUAL MACHINE
# -----------------------------------------------------
alias vm='~/private/launchvm.sh'
alias lg='~/dotfiles/scripts/looking-glass.sh'

# -----------------------------------------------------
# EDIT CONFIG FILES
# -----------------------------------------------------
alias confq='$EDITOR ~/dotfiles/qtile/config.py'
alias confp='$EDITOR ~/dotfiles/picom/picom.conf'
alias confb='$EDITOR ~/dotfiles/.zshrc'

# -----------------------------------------------------
# EDIT NOTES
# -----------------------------------------------------
alias notes='$EDITOR ~/notes.txt'

# -----------------------------------------------------
# SYSTEM
# -----------------------------------------------------
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias setkb='setxkbmap de;echo "Keyboard set back to de."'


 recovery-pacman() {
    pacman "$@"  \
    --log /dev/null   \
    --noscriptlet     \
    --dbonly          \
    --overwrite "*"   \
    --nodeps          \
    --needed
}

