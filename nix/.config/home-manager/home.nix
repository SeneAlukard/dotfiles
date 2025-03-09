{ config, pkgs, ... }:

{
  home.username = "xkenshi";
  home.homeDirectory = "/home/xkenshi";

  home.stateVersion = "23.11"; # Adjust to match your Nixpkgs version

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    alacritty
    zsh
    tmux
    git
    fzf
    ripgrep
    bat
    starship
    qbittorrent
    aria2
    ncdu
    librewolf
    eza
    adwaita-icon-theme
    papirus-icon-theme
    gruvbox-dark-gtk
  ];
}

