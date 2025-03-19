.PHONY: stow unstow

stow:
	stow alacritty
	stow zsh
	stow nvim
	stow tmux
	stow gtk
	stow xfce4
	stow nix

unstow:
	stow -D alacritty
	stow -D zsh
	stow -D nvim
	stow -D tmux
	stow -D gtk
	stow -D xfce4
	stow -D nix
