# Dotfiles

## Overview

This repository contains my personal dotfiles for Arch Linux, designed to provide a consistent computing environment across multiple machines. It includes configuration files for various tools and applications, as well as scripts to automate the installation and setup processes.

## Features

- **Modular Design**: Configurations are organized by application, making it easy to apply only what you need
- **Installation Guide**: Detailed guide for installing Arch Linux (with dual-boot options)
- **Automated Setup**: Scripts to install and configure all necessary applications
- **Development Tools**: Configurations for Neovim, Tmux, Git, and more
- **Desktop Environment**: XFCE4 configuration with custom themes and keybindings
- **Terminal Setup**: Alacritty configuration with Zsh, custom prompt, and plugins

## Components

### Shell
- **Zsh**: Enhanced shell with plugins and customizations
- **Tmux**: Terminal multiplexer with custom keybindings and plugins
- **Starship**: Cross-shell prompt with custom configuration

### Editor
- **Neovim**: Modern Vim with LSP support, code completion, and more
  - Custom keybindings and plugins
  - Language-specific configurations
  - Git integration

### Terminal
- **Alacritty**: Fast, GPU-accelerated terminal emulator
  - Custom colors and themes
  - Font configuration

### Desktop Environment
- **XFCE4**: Lightweight and customizable desktop environment
  - Custom panel layouts
  - Keyboard shortcuts
  - Theme and icon configuration

### Development
- **Git**: Version control configuration
- **Language-specific tools**: Configuration for Python, JavaScript, C/C++, and more

## Installation

### Full Arch Linux Installation

To install Arch Linux from scratch:

1. Boot from the Arch Linux installation media
2. Follow the instructions in the [Arch Installation Guide](archInstallGuide.md)
3. After installation, clone this repository and run the setup script

### Setting Up on Existing Installation

To set up these dotfiles on an existing Arch Linux installation:

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   ```

2. Run the setup script:
   ```bash
   cd ~/dotfiles
   chmod +x setup.sh
   ./setup.sh
   ```

3. For a preview of what the script will do without making changes:
   ```bash
   SIMULATE=true ./setup.sh
   ```

## Structure

The repository is structured as follows:

```
dotfiles/
├── alacritty/               # Alacritty terminal configuration
├── archInstallGuide.md      # Arch Linux installation guide
├── gtk3/                    # GTK3 theme configuration
├── gtk4/                    # GTK4 theme configuration
├── nix/                     # Nix package manager configuration
├── nvim/                    # Neovim configuration
├── README.md                # This file
├── setup.sh                 # Setup script
├── tmux/                    # Tmux configuration
├── xfce4/                   # XFCE4 configuration
└── zsh/                     # Zsh configuration
```

## Customization

Feel free to modify any of the configuration files to suit your needs. The setup script is designed to back up your existing configurations before applying the new ones.

You can also selectively apply configurations for specific tools by using GNU Stow:

```bash
cd ~/dotfiles
stow nvim     # Apply only Neovim configuration
stow zsh      # Apply only Zsh configuration
```

## Credits

These dotfiles are inspired by and incorporate elements from various open-source projects and other dotfiles repositories. Special thanks to:

- [Dracula Theme](https://draculatheme.com/)
- [Gruvbox Theme](https://github.com/morhetz/gruvbox)
- [The Primeagen](https://github.com/ThePrimeagen) for Neovim configurations
- [Luke Smith](https://github.com/LukeSmithxyz) for Zsh and terminal configurations

## License

This project is licensed under the MIT License - see the LICENSE file for details.
