# Dotfiles Configuration

## Terminal
- **Terminal Emulator**: [Alacritty](https://github.com/alacritty/alacritty)

## Shell
- **Shell**: [Zsh](https://www.zsh.org/)

### Zsh Plugins
- `zsh-syntax-highlighting`: Syntax highlighting for Zsh.
- `zsh-autosuggestions`: Fish-like autosuggestions for Zsh.
- `zsh-completions`: Additional completion definitions for Zsh.
- `zoxide`: Smarter `cd` command for quick directory navigation.
- `fzf`: Fuzzy finder for the command line.
- `starship`: Minimal and customizable prompt for any shell.
- `powerlevel10k`: Theme for Zsh that includes customizable status information.
- `zsh-history-substring-search`: Search Zsh history by substring.

## Editor
- **Editor**: [Neovim](https://neovim.io/)

### Package Manager
- **Package Manager**: [Lazy](https://github.com/folke/lazy.nvim)

### Neovim Plugins
- `alpha`: Start screen for Neovim.
- `catppuccin`: A warm and soft aesthetic theme.
- `colorizer`: Displays color codes with their actual colors.
- `comment`: Easily comment and uncomment code.
- `completions`: Provides auto-completion support.
- `conform`: Code formatting and linting.
- `debugging`: Debugging tools integration.
- `flash`: Flash-like search functionality.
- `harpoon`: Quick navigation between files.
- `luarocks`: Lua module manager integration.
- `markdown-preview`: Live preview for Markdown files.
- `mason-nvim-dap`: Manages DAP (Debug Adapter Protocol) tools.
- `mason`: External tool installer.
- `mini-surround`: Surround text with customizable characters.
- `neotree`: A modern file explorer.
- `none-ls`: Linting and formatting via null-ls.
- `nvim-autopairs`: Automatic pairing of brackets and quotes.
- `nvim_treesitter`: Advanced syntax highlighting and code parsing.
- `oil`: File manager plugin.
- `rendermd`: Markdown rendering within Neovim.
- `tabout`: Easy tabbing out of pairs.
- `telescope`: Fuzzy finder for quick searching.
- `transparent`: Make Neovim background transparent.
- `treesj`: Code folding and expanding.
- `vimtex`: LaTeX support for Neovim.
- `zen-mode`: Distraction-free coding mode.

## Tmux
- **Configuration**: [Tmux](https://github.com/tmux/tmux/wiki)

### Tmux Plugins
- `tmux-plugins/tpm`: Tmux Plugin Manager.
- `tmux-plugins/tmux-sensible`: Sensible default settings for Tmux.
- `dracula/tmux`: Dracula theme for Tmux.
- `tmux-plugins/tmux-resurrect`: Restore your Tmux sessions.
- `tmux-plugins/tmux-continuum`: Continuous saving of Tmux environment.
- `thepante-tmux-git-autofetch`: Auto-fetch Git repos when switching panes or windows.

### Tmux Key Bindings
- **Vi Mode**: Enabled for navigating panes and copy mode.
- **Pane Navigation**: Use `Alt + arrow keys` to switch between panes without a prefix.
- **Window Swapping**: `Shift + arrow keys` to swap windows with the prefix.
- **Mouse Support**: Enabled for easy pane resizing and selection.
- **Clipboard Integration**: Copying with `y` and `Y` keys for system clipboard.
- **Reload Configuration**: Press `r` to reload `~/.tmux.conf`.

## Desktop Environment
- **Desktop Environment**: [Xfce](https://www.xfce.org/)

---

## Requirements

Ensure the following are installed:

### Essential Tools
- **Git**: For version control and managing your dotfiles.
- **GNU Stow**: For creating and managing symbolic links.

### Shell
- **Zsh**: Install and set as your default shell.
- **Zoxide**, **FZF**, **Starship**, **Powerlevel10k**, **Zsh plugins** (e.g., `zsh-syntax-highlighting`, `zsh-autosuggestions`).

### Editor
- **Neovim** (v0.8 or higher).
  - **Lazy Package Manager**: [Lazy.nvim](https://github.com/folke/lazy.nvim).

### Tmux
- **Tmux**: Version 3.0 or higher recommended.
- **Tmux Plugin Manager (TPM)** 

