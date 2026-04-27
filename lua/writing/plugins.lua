-- Plugin specs for the writing config

return {
  -- Theme: rose-pine. Swap for any colorscheme you like.
  -- Alternatives worth trying: kanagawa, tokyonight, gruvbox-material, catppuccin
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",         -- "main" | "moon" | "dawn"
        dark_variant = "moon",
        styles = {
          bold = true,
          italic = true,
          transparency = false,
        },
      })
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  -- Treesitter for proper markdown parsing
  -- nvim 0.12+: uses main branch (rewrite, requires tree-sitter CLI)
  -- nvim < 0.12: uses master branch (legacy configs API)
  -- The two branches have different module structures, so the config splits.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = vim.fn.has("nvim-0.12") == 1 and "main" or "master",
    -- build runs after plugin files are installed; module is fully available here
    build = function()
      if vim.fn.has("nvim-0.12") == 1 then
        require("nvim-treesitter").install({
          "markdown", "markdown_inline", "lua", "vim", "vimdoc",
        }):wait(300000)
      else
        vim.cmd("TSUpdate")
      end
    end,
    lazy = false,
    priority = 900,
    config = function()
      if vim.fn.has("nvim-0.12") == 1 then
        -- main branch: parsers installed by build; enable highlighting per-buffer
        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "markdown", "markdown_inline", "lua", "vim", "vimdoc" },
          callback = function(ev) vim.treesitter.start(ev.buf) end,
        })
      else
        -- master branch: legacy configs API
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "vimdoc" },
          sync_install = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end
    end,
  },

  -- In-buffer markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      heading = { sign = false, width = "block", left_pad = 2, right_pad = 4 },
      code    = { sign = false, width = "block", left_pad = 2, right_pad = 4 },
      bullet = { icons = { "•", "◦", "▪", "▫" } },
      checkbox = {
        unchecked = { icon = "  ☐ " },
        checked   = { icon = "  ☑ " },
      },
      pipe_table = { preset = "round" },
    },
  },

  -- Zen mode: centred buffer, hides everything else
  {
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.95,
        width = 120,        -- columns of text
        height = 1,        -- full height
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
          laststatus = 0,
        },
        twilight = { enabled = true },     -- dim inactive paragraphs
        gitsigns = { enabled = false },
        tmux = { enabled = false },
      },
    },
  },

  -- Twilight: dims paragraphs you're not currently editing
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    opts = {
      dimming = { alpha = 0.25 },
      context = 10,           -- lines of context around cursor that stay bright
      treesitter = true,
      expand = { "function", "method", "table", "if_statement" },
    },
  },

  -- Better file picker for opening notes (optional but worth it)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<CR>",  desc = "Find file" },
      { "<leader>/", "<cmd>Telescope live_grep<CR>",   desc = "Search in files" },
      { "<leader>b", "<cmd>Telescope buffers<CR>",     desc = "Buffers" },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
        layout_config = { width = 0.7, height = 0.8 },
      },
    },
  },

  -- Auto-pair quotes/brackets — handy for prose punctuation too
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
}
