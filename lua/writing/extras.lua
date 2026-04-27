-- Optional behavioural extras: autosave and typewriter sound effects
-- Both can be toggled at runtime via keybinds (see keymaps.lua) or
-- enabled/disabled by default via the config table at the top.

local M = {}

----------------------------------------------------------------------
-- Config defaults
----------------------------------------------------------------------

M.config = {
  autosave = {
    enabled = true,             -- on by default
    debounce_ms = 1500,         -- save 1.5s after you stop typing
    filetypes = { "markdown", "text" },  -- only autosave prose files
  },
  typewriter = {
    enabled = false,            -- off by default
    -- Path to a .wav/.ogg/.mp3 file. If nil, uses the system bell.
    -- Drop a key-click sample in ~/.config/writing-nvim/sounds/key.wav
    -- and point this at it.
    sound_file = vim.fn.stdpath("config") .. "/sounds/key.wav",
    return_sound_file = vim.fn.stdpath("config") .. "/sounds/return.wav",
    -- Player command. Auto-detected if nil. Override if you want.
    player = nil,
  },
}

----------------------------------------------------------------------
-- Autosave
----------------------------------------------------------------------

local autosave_timer = nil
local autosave_group = vim.api.nvim_create_augroup("WritingAutosave", { clear = true })

local function setup_autosave()
  vim.api.nvim_clear_autocmds({ group = autosave_group })
  if not M.config.autosave.enabled then return end

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = autosave_group,
    pattern = "*",
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if not vim.tbl_contains(M.config.autosave.filetypes, ft) then return end
      if vim.bo[args.buf].buftype ~= "" then return end       -- skip special buffers
      if vim.api.nvim_buf_get_name(args.buf) == "" then return end -- skip unnamed
      if not vim.bo[args.buf].modified then return end
      if vim.bo[args.buf].readonly then return end

      if autosave_timer then
        autosave_timer:stop()
        autosave_timer:close()
      end
      autosave_timer = vim.uv.new_timer()
      autosave_timer:start(M.config.autosave.debounce_ms, 0, vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].modified then
          vim.api.nvim_buf_call(args.buf, function()
            vim.cmd("silent! write")
          end)
        end
        if autosave_timer then
          autosave_timer:close()
          autosave_timer = nil
        end
      end))
    end,
  })
end

function M.toggle_autosave()
  M.config.autosave.enabled = not M.config.autosave.enabled
  setup_autosave()
  vim.notify("Autosave: " .. (M.config.autosave.enabled and "ON" or "OFF"))
end

----------------------------------------------------------------------
-- Typewriter sound effects
----------------------------------------------------------------------

-- Detect a usable audio player on the system.
local function detect_player()
  if M.config.typewriter.player then return M.config.typewriter.player end
  for _, candidate in ipairs({ "paplay", "aplay", "afplay", "play", "mpv" }) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

local function play_sound(path)
  if not path or vim.fn.filereadable(path) == 0 then return end
  local player = detect_player()
  if not player then return end

  -- Fire-and-forget; don't block typing.
  -- mpv needs --no-terminal to stay quiet.
  local args = { path }
  if player == "mpv" then
    args = { "--no-terminal", "--really-quiet", path }
  end
  vim.system({ player, unpack(args) }, { detach = true })
end

local typewriter_group = vim.api.nvim_create_augroup("WritingTypewriter", { clear = true })

local function setup_typewriter()
  vim.api.nvim_clear_autocmds({ group = typewriter_group })
  if not M.config.typewriter.enabled then return end

  if not detect_player() then
    vim.notify(
      "Typewriter: no audio player found (tried paplay, aplay, afplay, play, mpv). "
      .. "Install one or set typewriter.player in your config.",
      vim.log.levels.WARN
    )
    return
  end

  -- Per keystroke in insert mode
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = typewriter_group,
    pattern = "*",
    callback = function()
      play_sound(M.config.typewriter.sound_file)
    end,
  })

  -- Distinct sound on Enter (carriage return)
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = typewriter_group,
    pattern = "*",
    callback = function()
      vim.keymap.set("i", "<CR>", function()
        play_sound(M.config.typewriter.return_sound_file)
        return "<CR>"
      end, { expr = true, buffer = true })
    end,
  })
end

function M.toggle_typewriter()
  M.config.typewriter.enabled = not M.config.typewriter.enabled
  setup_typewriter()
  vim.notify("Typewriter sounds: " .. (M.config.typewriter.enabled and "ON" or "OFF"))
end

----------------------------------------------------------------------
-- Init
----------------------------------------------------------------------

function M.setup()
  setup_autosave()
  setup_typewriter()
end

return M
