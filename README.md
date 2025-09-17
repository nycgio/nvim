# Neovim Configuration

My personal Neovim configuration with Lazy.nvim plugin manager.

## Features

- **Plugin Manager**: Lazy.nvim for fast startup
- **Themes**: Multiple themes (Catppuccin, Tokyo Night, Rose Pine, etc.)
- **File Explorer**: Neo-tree
- **Fuzzy Finder**: Telescope
- **LSP Support**: Native LSP with Mason
- **Autocompletion**: nvim-cmp with multiple sources
- **Git Integration**: Fugitive, Gitsigns
- **AI Assistance**: GitHub Copilot
- **Status Line**: Lualine
- **Tab Line**: Bufferline
- **And more**: Treesitter, autopairs, surround, comment, etc.

## Installation

### Prerequisites

- Neovim >= 0.9.0
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- Node.js (for Copilot)
- ripgrep (for Telescope grep)
- fd (optional, for better file finding)

### Quick Install

1. **Backup existing config** (if any):
```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

2. **Clone this repository**:
```bash
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/.config/nvim
```

3. **Launch Neovim**:
```bash
nvim
```

4. **Wait for plugins to install** automatically on first launch

5. **Setup Copilot** (optional):
```vim
:Copilot setup
```

## Key Mappings

**Leader key**: `Space`

### Essential
- `<C-p>` - Find files
- `<C-f>` - Open Telescope
- `<C-n>` - Toggle Neo-tree file explorer
- `<C-j>` - Accept Copilot suggestion (in insert mode)

### Telescope
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Browse buffers
- `<leader>fh` - Search help
- `<leader>fo` - Recent files
- `<leader>fw` - Search word under cursor

### Git
- `<leader>gg` - Open Git fugitive
- `<leader>gd` - Git diff
- `<leader>gc` - Git commits (Telescope)
- `<leader>gb` - Git branches (Telescope)
- `<leader>gs` - Git status (Telescope)

### LSP (when attached)
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation
- `<leader>rn` - Rename
- `<leader>ca` - Code actions
- `<leader>f` - Format file

### Windows
- `<C-h/j/k/l>` - Navigate windows
- `<S-h/l>` - Navigate buffers
- `<leader>bd` - Delete buffer

### Other
- `<leader>tt` - Theme picker
- `<leader>tn` - Cycle theme
- `<leader>tf` - Terminal float
- `<leader>th` - Terminal horizontal
- `<Esc><Esc>` - Clear search highlighting

## Updating

```bash
cd ~/.config/nvim
git pull
```

Then in Neovim:
```vim
:Lazy sync
```

## Custom Configuration

To add your own settings without modifying the tracked files, create:
```bash
~/.config/nvim/lua/local.lua
```

This file is gitignored and can contain personal overrides.

## License

MIT