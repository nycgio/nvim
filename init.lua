-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath);

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup("plugins",
  {
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

require("catppuccin").setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

vim.cmd("set expandtab");
vim.cmd("set tabstop=2");
vim.cmd("set softtabstop=2");
vim.cmd("set shiftwidth=2");
vim.g.mapleader = " ";

-- Theme will be set by theme config
-- vim.cmd.colorscheme "catppuccin"

local builtin = require("telescope.builtin");
vim.keymap.set('n', '<C-p>', builtin.find_files, {});
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {});
vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', {});

local config = require("nvim-treesitter.configs");
config.setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
  sync_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

-- Load plugin configurations
local status_ok, plugin_config = pcall(require, "config.plugins")
if status_ok then
  plugin_config.setup()
end

-- Load theme configuration
local theme_ok, theme_config = pcall(require, "config.themes")
if theme_ok then
  theme_config.setup()
end

-- LSP Keybindings
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- Diagnostic Settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Additional Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Buffer navigation
map("n", "<S-l>", ":bnext<CR>", opts)
map("n", "<S-h>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", opts)

-- Terminal
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", opts)
map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", opts)

-- Trouble
map("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts)
map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", opts)

-- Git
map("n", "<leader>gg", "<cmd>Git<cr>", opts)
map("n", "<leader>gd", "<cmd>Git diff<cr>", opts)

-- Theme Switcher
map("n", "<leader>tt", "<cmd>ThemePicker<cr>", opts)
map("n", "<leader>tn", "<cmd>ThemeCycle<cr>", opts)

-- Telescope
map("n", "<C-f>", ":Telescope<CR>", opts)
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", opts)
map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", opts)
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", opts)
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", opts)
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", opts)

-- Clear search highlighting
map("n", "<Esc><Esc>", ":nohlsearch<CR>", opts)

-- Better Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.pumheight = 10
vim.opt.clipboard = "unnamedplus"

