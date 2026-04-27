-- Writing-focused Neovim config
-- Launch with: NVIM_APPNAME=writing-nvim nvim
-- Or alias: alias write='NVIM_APPNAME=writing-nvim nvim'

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("writing.options")
require("writing.keymaps")

require("lazy").setup("writing.plugins", {
  change_detection = { notify = false },
})

-- Auto-enter zen mode when opening a markdown file
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"
    vim.opt_local.conceallevel = 2
    -- Uncomment to auto-enter zen mode on every markdown open:
    -- require("zen-mode").open()
  end,
})
