# Dotfiles Configuration

## Automated Setup

This repository includes an automated `setup.sh` script that configures your environment with all necessary tools, plugins, and configurations. Follow the steps below to get started.

### Requirements

Ensure the following are installed on your system:
- **Git**: For version control and managing your dotfiles.
- **GNU Stow**: For creating and managing symbolic links.

### Installation

1. **Clone the Repository**
   ```bash
   git clone git@github.com:SeneAlukard/dotfiles.git ~/dotfiles
   ```

2. **Run the Setup Script**
   Navigate to the cloned repository and execute the setup script:
   ```bash
   cd ~/dotfiles
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Simulate the Setup (Optional)**
   To preview the changes the script will make, enable simulation mode:
   ```bash
   SIMULATE=true ./setup.sh
   ```

### What the Script Does
- Installs essential tools: `git`, `stow`, `zsh`, `fzf`, `neovim`, `tmux`, `curl`, `unzip`.
- Configures **Oh My Posh** and downloads themes.
- Sets up Zsh plugins, including:
  - `zsh-syntax-highlighting`
  - `zsh-autosuggestions`
  - `zsh-completions`
  - `zoxide`
  - `fzf`
- Configures **Neovim** with Lazy.nvim for plugin management.
- Installs **Tmux Plugin Manager (TPM)** and essential Tmux plugins.
- Symlinks your dotfiles to their appropriate locations using `stow`.

---

## Tools and Configurations

### Terminal
- **Terminal Emulator**: [Alacritty](https://github.com/alacritty/alacritty)

### Shell
- **Shell**: [Zsh](https://www.zsh.org/)

#### Zsh Plugins
- `zsh-syntax-highlighting`: Syntax highlighting for Zsh.
- `zsh-autosuggestions`: Fish-like autosuggestions for Zsh.
- `zsh-completions`: Additional completion definitions for Zsh.
- `zoxide`: Smarter `cd` command for quick directory navigation.
- `fzf`: Fuzzy finder for the command line.
- `starship`: Minimal and customizable prompt for any shell.
- `powerlevel10k`: Theme for Zsh that includes customizable status information.
- `zsh-history-substring-search`: Search Zsh history by substring.

### Editor
- **Editor**: [Neovim](https://neovim.io/)

#### Neovim Plugins
Includes plugins for:
- Aesthetic themes (`catppuccin`, `alpha`, etc.).
- Code completion and formatting (`completions`, `conform`).
- File navigation and management (`telescope`, `neotree`).
- Advanced syntax highlighting (`nvim_treesitter`).
- Distraction-free coding (`zen-mode`).

### Tmux
- **Configuration**: [Tmux](https://github.com/tmux/tmux/wiki)

#### Tmux Plugins
- `tmux-plugins/tpm`: Tmux Plugin Manager.
- `tmux-plugins/tmux-sensible`: Sensible default settings for Tmux.
- `dracula/tmux`: Dracula theme for Tmux.
- `tmux-plugins/tmux-resurrect`: Restore your Tmux sessions.
- `tmux-plugins/tmux-continuum`: Continuous saving of Tmux environment.
- `thepante-tmux-git-autofetch`: Auto-fetch Git repos when switching panes or windows.

---

## Desktop Environment
- **Desktop Environment**: [Xfce](https://www.xfce.org/)

---

## Key Features
- Modular dotfiles structure for easy management.
- Automated setup script to streamline installation.
- Focused on productivity and clean, customizable configurations.

---

For any issues or questions, feel free to open an issue or contact me.

