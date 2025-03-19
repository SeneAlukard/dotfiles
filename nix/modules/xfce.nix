{ config, pkgs, lib, ... }:

{
  # Install XFCE packages
  home.packages = with pkgs; [
    # Core XFCE components
    xfce.xfwm4
    xfce.xfce4-panel
    xfce.xfce4-session
    xfce.xfce4-settings
    xfce.xfconf
    
    # File management
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    
    # Utilities from your configuration
    xfce.xfce4-appfinder
    xfce.xfce4-power-manager
    xfce.xfce4-screenshooter
    xfce.xfce4-terminal
    xfce.xfce4-taskmanager
    xfce.xfce4-notifyd
    xfce.xfce4-dict
    
    # Panel plugins found in your config
    xfce.xfce4-battery-plugin
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-netload-plugin
    
    # Other tools you use
    firefox
    alacritty    # Your preferred terminal emulator
  ];

  # Keep your custom configurations in place
  home.file = {
    # GTK 3 configuration
    ".config/gtk-3.0/gtk.css".source = ../gtk/.config/gtk-3.0/gtk.css;
    
    # GTK 4 configuration (symlink to GTK 3)
    ".config/gtk-4.0/gtk.css".source = ../gtk/.config/gtk-4.0/gtk.css;
    
    # XFCE configuration files
    ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml".source = 
      ../xfce4/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml;
    ".config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml".source = 
      ../xfce4/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml;
    ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml".source = 
      ../xfce4/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml;
    ".config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml".source = 
      ../xfce4/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml;
    ".config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".source = 
      ../xfce4/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml;
    
    # Panel launcher configurations
    ".config/xfce4/panel/launcher-17/17295476991.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-17/17295476991.desktop;
    ".config/xfce4/panel/launcher-18/17295476992.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-18/17295476992.desktop;
    ".config/xfce4/panel/launcher-19/17295476993.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-19/17295476993.desktop;
    ".config/xfce4/panel/launcher-20/17295476994.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-20/17295476994.desktop;
    ".config/xfce4/panel/launcher-25/17295493631.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-25/17295493631.desktop;
    ".config/xfce4/panel/launcher-26/17295494472.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-26/17295494472.desktop;
    ".config/xfce4/panel/launcher-27/17295494663.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-27/17295494663.desktop;
    ".config/xfce4/panel/launcher-28/17295494774.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-28/17295494774.desktop;
    ".config/xfce4/panel/launcher-30/17295496295.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-30/17295496295.desktop;
    ".config/xfce4/panel/launcher-32/17295496937.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-32/17295496937.desktop;
    ".config/xfce4/panel/launcher-35/17302416842.desktop".source = 
      ../xfce4/.config/xfce4/panel/launcher-35/17302416842.desktop;
    
    # Other panel configs
    ".config/xfce4/panel/netload-14.rc".source = 
      ../xfce4/.config/xfce4/panel/netload-14.rc;
    ".config/xfce4/panel/battery-9.rc".source = 
      ../xfce4/.config/xfce4/panel/battery-9.rc;
  };

  # Ensure the XFCE session is properly started
  xsession = {
    enable = true;
    windowManager.command = "xfce4-session";
  };
}
