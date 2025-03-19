I have .profile thingy do i need to configure it for zsh or zsh automatically uses this:

# ~/.profile: executed by the command interpreter for login shells.

# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.

# See /usr/share/doc/bash/examples/startup-files for examples.

# Include user's private bin directory in PATH if it exists

if [ -d "$HOME/bin" ] ; then

    PATH="$HOME/bin:$PATH"

fi

# Include user's private .local/bin directory in PATH if it exists

if [ -d "$HOME/.local/bin" ] ; then

    PATH="$HOME/.local/bin:$PATH"

fi

# Add Cargo (Rust package manager) bin directory to PATH if it exists

if [ -d "$HOME/.cargo/bin" ] ; then

    PATH="$HOME/.cargo/bin:$PATH"

fi

# Add Go bin directory to PATH if it exists

if [ -d "$HOME/go/bin" ] ; then

    PATH="$HOME/go/bin:$PATH"

fi

# Add custom scripts directory to PATH if it exists

if [ -d "$HOME/dotfiles/scripts" ] ; then

    PATH="$HOME/dotfiles/scripts:$PATH"

fi

# Add TeX Live to PATH if it exists

if [ -d "/usr/local/texlive/2024/bin/x86_64-linux" ] ; then

    PATH="/usr/local/texlive/2024/bin/x86_64-linux:$PATH"

    MANPATH="/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH"

    INFOPATH="/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH"

fi

# Setup XDG runtime directory if it doesn't exist

if [ -z "$XDG_RUNTIME_DIR" ]; then

    export XDG_RUNTIME_DIR="/tmp/xdg-runtime-dir-$UID"

    mkdir -p "$XDG_RUNTIME_DIR"

    chmod 0700 "$XDG_RUNTIME_DIR"

fi

# Set default applications

export EDITOR=nvim

export VISUAL=nvim

export PAGER=less

export BROWSER=firefox

export TERMINAL=alacritty

# Set manpager to use Neovim

export MANPAGER="nvim +Man!"

# Settings for less

export LESS="-R"

export LESSHISTFILE="-"

# Locale settings

export LANG=en_US.UTF-8

export LC_ALL=en_US.UTF-8

# Colored GCC warnings and errors

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# History settings

export HISTSIZE=5000

export HISTFILESIZE=10000

export HISTCONTROL=ignoreboth:erasedups

# Enable colored output for various commands

export CLICOLOR=1

export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Python settings

export PYTHONDONTWRITEBYTECODE=1  # Don't create .pyc files

export PYTHONUNBUFFERED=1         # Don't buffer output

# Set VI mode for shell

set -o vi

# Source Nix profile if it exists

if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then

    . "$HOME/.nix-profile/etc/profile.d/nix.sh"

fi

# Auto-start X server on login (for tty1)

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then

    exec startx

fi
