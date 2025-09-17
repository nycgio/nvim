-- Theme Configuration and Switcher
local M = {}

-- List of available themes with their configurations
M.themes = {
  {
    name = "tokyonight",
    style = "night", -- night, storm, day, moon
    setup = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
        },
      })
      vim.cmd("colorscheme tokyonight")
    end
  },
  {
    name = "catppuccin",
    style = "mocha", -- latte, frappe, macchiato, mocha
    setup = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
      })
      vim.cmd("colorscheme catppuccin")
    end
  },
  {
    name = "rose-pine",
    style = "main", -- main, moon, dawn
    setup = function()
      require("rose-pine").setup({
        variant = "main",
        dark_variant = "main",
        bold_vert_split = false,
        dim_nc_background = false,
        disable_background = false,
        disable_float_background = false,
        disable_italics = false,
      })
      vim.cmd("colorscheme rose-pine")
    end
  },
  {
    name = "kanagawa",
    style = "wave", -- wave, dragon, lotus
    setup = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        theme = "wave",
      })
      vim.cmd("colorscheme kanagawa")
    end
  },
  {
    name = "nightfox",
    style = "nightfox", -- nightfox, dayfox, dawnfox, duskfox, nordfox, terafox, carbonfox
    setup = function()
      require("nightfox").setup({
        options = {
          compile_path = vim.fn.stdpath("cache") .. "/nightfox",
          compile_file_suffix = "_compiled",
          transparent = false,
          terminal_colors = true,
          dim_inactive = false,
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
      })
      vim.cmd("colorscheme nightfox")
    end
  },
  {
    name = "onedark",
    style = "dark", -- dark, darker, cool, deep, warm, warmer
    setup = function()
      require("onedark").setup({
        style = "dark",
        transparent = false,
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
      })
      require("onedark").load()
    end
  },
  {
    name = "dracula",
    setup = function()
      vim.cmd("colorscheme dracula")
    end
  },
  {
    name = "gruvbox-material",
    style = "hard", -- hard, medium, soft
    setup = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.cmd("colorscheme gruvbox-material")
    end
  },
}

-- Function to switch theme
function M.switch_theme(theme_name)
  for _, theme in ipairs(M.themes) do
    if theme.name == theme_name then
      local ok, err = pcall(theme.setup)
      if ok then
        vim.notify("Theme switched to " .. theme_name, vim.log.levels.INFO)
        -- Save the current theme preference
        vim.g.current_theme = theme_name
      else
        vim.notify("Failed to load theme " .. theme_name .. ": " .. err, vim.log.levels.ERROR)
      end
      return
    end
  end
  vim.notify("Theme " .. theme_name .. " not found", vim.log.levels.WARN)
end

-- Function to cycle through themes
function M.cycle_theme()
  local current = vim.g.current_theme or "catppuccin"
  local current_idx = 1

  for i, theme in ipairs(M.themes) do
    if theme.name == current then
      current_idx = i
      break
    end
  end

  local next_idx = current_idx % #M.themes + 1
  M.switch_theme(M.themes[next_idx].name)
end

-- Create a telescope picker for themes
function M.theme_picker()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local theme_names = {}
  for _, theme in ipairs(M.themes) do
    table.insert(theme_names, theme.name .. (theme.style and " (" .. theme.style .. ")" or ""))
  end

  pickers.new({}, {
    prompt_title = "Select Theme",
    finder = finders.new_table({
      results = theme_names,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local theme_name = selection[1]:match("^(%w+)")
          M.switch_theme(theme_name)
        end
      end)
      return true
    end,
  }):find()
end

-- Setup function
function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command("Theme", function(opts)
    M.switch_theme(opts.args)
  end, {
    nargs = 1,
    complete = function()
      local completions = {}
      for _, theme in ipairs(M.themes) do
        table.insert(completions, theme.name)
      end
      return completions
    end,
  })

  vim.api.nvim_create_user_command("ThemePicker", function()
    M.theme_picker()
  end, {})

  vim.api.nvim_create_user_command("ThemeCycle", function()
    M.cycle_theme()
  end, {})

  -- Set default theme (TokyoNight is most popular)
  M.switch_theme("tokyonight")
end

return M