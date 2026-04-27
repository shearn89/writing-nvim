-- Editor options optimised for prose

local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- Display
opt.number = false           -- no line numbers when writing
opt.relativenumber = false
opt.cursorline = false       -- distraction
opt.signcolumn = "no"
opt.laststatus = 0           -- hide status line for max focus
opt.cmdheight = 1
opt.showmode = false
opt.showcmd = false
opt.ruler = false

-- Editing
opt.wrap = true
opt.linebreak = true         -- wrap on word boundaries
opt.breakindent = true
opt.smoothscroll = true
opt.scrolloff = 999          -- typewriter scrolling: cursor stays centred
opt.sidescrolloff = 8

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.fillchars = { eob = " " }  -- hide ~ on empty lines

-- Tabs (for any code blocks you write)
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- GUI font (used by Neovide)
opt.guifont = "JetBrainsMono Nerd Font:h14"

-- Neovide-specific niceties (only apply when running in Neovide)
if g.neovide then
  g.neovide_padding_top = 40
  g.neovide_padding_bottom = 40
  g.neovide_padding_left = 80
  g.neovide_padding_right = 80
  g.neovide_cursor_animation_length = 0.05
  g.neovide_cursor_trail_size = 0.3
  g.neovide_cursor_vfx_mode = ""        -- set to "railgun" for fun
  g.neovide_scroll_animation_length = 0.2
  g.neovide_floating_blur_amount_x = 4.0
  g.neovide_floating_blur_amount_y = 4.0
  g.neovide_floating_shadow = true
  g.neovide_window_blurred = true       -- macOS only
  g.neovide_opacity = 0.96
end
