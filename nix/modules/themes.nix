{ config, pkgs, lib, ... }:

{
  # Install themes and icons
  home.packages = with pkgs; [
    dracula-theme
    gruvbox-dark-icons-gtk

    # Fonts you use
    terminus_font
    hack-font    # For your Hack Nerd Font
  ];

  # Font configuration
  fonts.fontconfig.enable = true;

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-dark-icons-gtk;
    };
    font = {
      name = "Sans";
      size = 10;
    };
    gtk3.extraConfig = {
      gtk-button-images = 1;
      gtk-menu-images = 1;
      gtk-decoration-layout = "icon,menu:minimize,maximize,close";
    };
  };

  # If you want to manually install the themes as you did in your setup.sh
  home.activation = {
    installGruvboxPlus = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/.icons/Gruvbox-Plus-Dark" ]; then
        $DRY_RUN_CMD mkdir -p $HOME/.icons
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git /tmp/gruvbox-plus
        $DRY_RUN_CMD cp -r /tmp/gruvbox-plus/Gruvbox-Plus-Dark $HOME/.icons/
        $DRY_RUN_CMD rm -rf /tmp/gruvbox-plus
        echo "Installed Gruvbox-Plus-Dark icon theme"
      fi
    '';
  };
}
