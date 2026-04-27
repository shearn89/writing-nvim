-- Keymaps tuned for prose

local map = vim.keymap.set

-- Move by visual lines, not real lines (matters when wrap is on)
map({ "n", "x" }, "j", "gj", { silent = true })
map({ "n", "x" }, "k", "gk", { silent = true })
map({ "n", "x" }, "0", "g0", { silent = true })
map({ "n", "x" }, "$", "g$", { silent = true })

-- Quick file ops
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Toggle zen mode
map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen mode" })

-- Toggle Twilight (dim inactive paragraphs)
map("n", "<leader>t", "<cmd>Twilight<CR>", { desc = "Toggle Twilight" })

-- Toggle markdown rendering
map("n", "<leader>m", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown render" })

-- Toggle spell
map("n", "<leader>s", "<cmd>set spell!<CR>", { desc = "Toggle spell" })

-- Word count
map("n", "<leader>c", function()
  local wc = vim.fn.wordcount()
  print(string.format("Words: %d  Chars: %d", wc.words, wc.chars))
end, { desc = "Word count" })

-- Quickly fix the previous spelling mistake without leaving insert
map("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u")
