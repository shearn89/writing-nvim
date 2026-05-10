-- Word count display for prose buffers.
-- Skips YAML frontmatter (a `---` block at the top of the file) so the
-- count reflects what you'd actually publish.

local M = {}

local CACHE_KEY = "writing_wordcount_cache"
local TICK_KEY = "writing_wordcount_tick"

-- Find the line index (1-based, exclusive) where frontmatter ends.
-- Returns 0 if there is no frontmatter.
local function frontmatter_end(buf)
  local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
  if not first or first ~= "---" then return 0 end
  -- Scan a bounded window; frontmatter is small in practice.
  local lines = vim.api.nvim_buf_get_lines(buf, 1, 200, false)
  for i, line in ipairs(lines) do
    if line == "---" or line == "..." then
      return i + 1  -- skip past the closing fence
    end
  end
  return 0
end

-- Count words in a body of text. Mirrors vim's wordcount(): runs of
-- non-whitespace separated by whitespace.
local function count_words(text)
  if text == "" then return 0 end
  local n = 0
  for _ in text:gmatch("%S+") do n = n + 1 end
  return n
end

function M.count(buf)
  buf = buf or 0
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end

  local tick = vim.api.nvim_buf_get_changedtick(buf)
  local cached_tick = vim.b[buf][TICK_KEY]
  if cached_tick == tick then
    return vim.b[buf][CACHE_KEY] or 0
  end

  local start = frontmatter_end(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, start, -1, false)
  local words = count_words(table.concat(lines, " "))

  vim.b[buf][CACHE_KEY] = words
  vim.b[buf][TICK_KEY] = tick
  return words
end

-- Public statusline/winbar expression.
function M.status()
  local n = M.count(0)
  return string.format("%d words", n)
end

-- One-shot report (used by <leader>c). Includes char count via vim.fn.wordcount().
function M.report()
  local words = M.count(0)
  local wc = vim.fn.wordcount()
  vim.notify(string.format("Words: %d (excl. frontmatter)  Chars: %d", words, wc.chars))
end

local group = vim.api.nvim_create_augroup("WritingWordcount", { clear = true })

function M.setup(opts)
  opts = opts or {}
  local filetypes = opts.filetypes or { "markdown", "text" }

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = filetypes,
    callback = function(args)
      vim.api.nvim_set_option_value(
        "winbar",
        "%=%#NonText#%{v:lua.require'writing.wordcount'.status()}",
        { scope = "local", win = 0 }
      )
      -- Touch the cache so the winbar paints immediately.
      M.count(args.buf)
    end,
  })

  -- Force a redraw of the winbar as you type. Without this it only updates
  -- on cursor moves / mode changes.
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = "*",
    callback = function(args)
      if vim.tbl_contains(filetypes, vim.bo[args.buf].filetype) then
        vim.cmd("redrawstatus")
      end
    end,
  })
end

return M
