-- Plugin configurations
local M = {}

function M.setup()
  -- LSP Configuration
  local status_ok, _ = pcall(require, "neodev")
  if status_ok then
    require("neodev").setup()
  end

  local mason_ok, mason = pcall(require, "mason")
  if mason_ok then
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })
  end

  -- Setup LSP servers
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

  if lspconfig_ok and cmp_lsp_ok then
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Mason-lspconfig setup (skip if causing issues)
    pcall(function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright" },
        automatic_installation = false,
        handlers = nil,
      })
    end)

    -- Manually setup servers to avoid the automatic_enable issue
    -- Lua
    pcall(function()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      })
    end)

    -- Python
    pcall(function()
      lspconfig.pyright.setup({
        capabilities = capabilities,
      })
    end)

    -- TypeScript/JavaScript - use ts_ls (new name)
    pcall(function()
      if lspconfig.ts_ls then
        lspconfig.ts_ls.setup({
          capabilities = capabilities,
        })
      elseif lspconfig.tsserver then
        lspconfig.tsserver.setup({
          capabilities = capabilities,
        })
      end
    end)
  end


  -- Autocompletion Configuration
  local cmp_ok, cmp = pcall(require, "cmp")
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  local lspkind_ok, lspkind = pcall(require, "lspkind")

  if cmp_ok and luasnip_ok then
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      formatting = lspkind_ok and {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
        }),
      } or {},
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
    })
  end

  -- Git Signs Configuration
  local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
  if gitsigns_ok then
    gitsigns.setup({
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
    })
  end

  -- Comment.nvim Configuration
  local comment_ok, comment = pcall(require, "Comment")
  if comment_ok then
    comment.setup({
      toggler = {
        line = "gcc",
        block = "gbc",
      },
      opleader = {
        line = "gc",
        block = "gb",
      },
    })
  end

  -- Surround Configuration
  local surround_ok, surround = pcall(require, "nvim-surround")
  if surround_ok then
    surround.setup()
  end

  -- Autopairs Configuration
  local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
  if autopairs_ok then
    autopairs.setup({
      check_ts = true,
      disable_filetype = { "TelescopePrompt" },
    })

    -- Integrate with nvim-cmp
    if cmp_ok then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end

  -- Which-key Configuration
  local wk_ok, wk = pcall(require, "which-key")
  if wk_ok then
    wk.setup({
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = false,
          nav = false,
          z = true,
          g = true,
        },
      },
      window = {
        border = "rounded",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = true,
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
      show_help = true,
      triggers = "auto",
    })

    -- Register key groups with proper descriptions
    local mappings = {
      ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>f"] = { name = "+find/format" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>l"] = { name = "+lsp" },
      ["<leader>r"] = { name = "+rename" },
      ["<leader>s"] = { name = "+search" },
      ["<leader>t"] = { name = "+terminal" },
      ["<leader>x"] = { name = "+diagnostics/trouble" },
    }

    wk.register(mappings)

  -- Indent Blankline Configuration
  local ibl_ok, ibl = pcall(require, "ibl")
  if ibl_ok then
    ibl.setup({
      indent = {
        char = "│",
      },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
        },
      },
    })
  end

  -- Better Escape Configuration
  local escape_ok, escape = pcall(require, "better_escape")
  if escape_ok then
    escape.setup({
      mapping = { "jk", "kj" },
    })
  end

  -- Todo Comments Configuration
  local todo_ok, todo = pcall(require, "todo-comments")
  if todo_ok then
    todo.setup()
  end

  -- Trouble Configuration
  local trouble_ok, trouble = pcall(require, "trouble")
  if trouble_ok then
    trouble.setup()
  end

  -- Toggleterm Configuration
  local term_ok, toggleterm = pcall(require, "toggleterm")
  if term_ok then
    toggleterm.setup({
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = {
        border = "curved",
      },
    })
  end

  -- Lualine Configuration
  local lualine_ok, lualine = pcall(require, "lualine")
  if lualine_ok then
    lualine.setup({
      options = {
        theme = "catppuccin",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    })
  end

  -- Bufferline Configuration
  local bufferline_ok, bufferline = pcall(require, "bufferline")
  if bufferline_ok then
    bufferline.setup({
      options = {
        separator_style = "thin",
        diagnostics = "nvim_lsp",
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })
  end

  -- Alpha (Dashboard) Configuration
  local alpha_ok, alpha = pcall(require, "alpha")
  if alpha_ok then
    local dashboard = require("alpha.themes.dashboard")
    dashboard.section.header.val = {
      [[                                                    ]],
      [[     ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗     ]],
      [[     ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║     ]],
      [[     ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║     ]],
      [[     ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║     ]],
      [[     ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║     ]],
      [[     ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝     ]],
      [[                                                    ]],
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
      dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
      dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    alpha.setup(dashboard.opts)
  end

  -- Auto Session Configuration
  local session_ok, session = pcall(require, "auto-session")
  if session_ok then
    session.setup({
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
    })
  end

  -- Neoscroll Configuration
  local neoscroll_ok, neoscroll = pcall(require, "neoscroll")
  if neoscroll_ok then
    neoscroll.setup()
  end

  -- Colorizer Configuration
  local colorizer_ok, colorizer = pcall(require, "colorizer")
  if colorizer_ok then
    colorizer.setup()
  end

  -- Treesitter Text Objects
  local ts_configs_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
  if ts_configs_ok then
    ts_configs.setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    })
  end
end

return M