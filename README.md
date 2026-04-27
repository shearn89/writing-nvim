# writing-nvim

A distraction-free, themeable, neovim-powered writing setup. Lives alongside your
regular nvim config — does not touch it.

## What you get

- **Neovim with full vim power** as the editing engine
- **In-buffer markdown rendering** (render-markdown.nvim) — headings, code blocks,
  bullets, checkboxes, and tables render in place. No separate preview pane.
- **Zen mode** — centres your text, 80-column wide, fades everything else
- **Twilight** — dims paragraphs you're not currently editing
- **Typewriter scrolling** — cursor stays vertically centred
- **Soft wrap on word boundaries**, no line numbers, no sign column, no status line
- **Spell-check** auto-enabled for markdown and text files
- **Rose-pine theme** by default; trivially swappable

## Install

```bash
git clone <this-repo> ~/.config/writing-nvim
# or just copy the files there
```

The first `nvim` launch will bootstrap lazy.nvim and install all plugins.

For the gorgeous GUI angle, install [Neovide](https://neovide.dev/) too:

```bash
# macOS
brew install --cask neovide
# Linux: download AppImage from https://github.com/neovide/neovide/releases
# mise: 
mise use -g github:neovide/neovide
```

## Scoping: how to use it only for writing

Three approaches — combine as you like.

### 1. `NVIM_APPNAME` — a fully separate nvim "profile"

This config lives at `~/.config/writing-nvim` instead of `~/.config/nvim`.
Neovim's `NVIM_APPNAME` env var tells it which config dir to load.

```bash
# Add to your shell rc (~/.zshrc, ~/.bashrc, etc.)
alias write='NVIM_APPNAME=writing-nvim nvim'
alias gwrite='NVIM_APPNAME=writing-nvim neovide'
```

Now `write notes.md` opens it in writing mode; plain `nvim notes.md` opens your
regular dev config. Zero contamination between the two — separate plugins,
separate state, separate everything.

This is the cleanest option and what I'd recommend as the default.

### 2. Per-directory: launch the writing config only inside specific folders

Drop a `.envrc` in each writing folder and use [direnv](https://direnv.net/):

```bash
# ~/Documents/writing/.envrc
export NVIM_APPNAME=writing-nvim
```

Then `direnv allow` once. From then on, any time you `cd` into that folder,
plain `nvim` and `neovide` use the writing config. Outside that folder, your
regular nvim is unaffected.

You can also do this without direnv via a shell function:

```bash
nvim() {
  case "$PWD" in
    "$HOME/Documents/writing"*|"$HOME/notes"*)
      NVIM_APPNAME=writing-nvim command nvim "$@"
      ;;
    *)
      command nvim "$@"
      ;;
  esac
}
```

### 3. Per-file: switch on filetype within a single config

If you'd rather merge this *into* your existing nvim config rather than keep them
separate, the relevant plugins (zen-mode, twilight, render-markdown) are already
filetype-scoped via lazy.nvim's `ft = { "markdown" }`. The autocmd in `init.lua`
applies prose options only to markdown/text buffers. Just copy the plugin specs
and the autocmd block into your existing config.

The downside: your dev plugins (LSP, completion, copilot, linters) still load and
can creep visually into the writing experience. That's why I prefer option 1.

## "Looks gorgeous" checklist

For the Freewrite-software feel, also:

1. Use **Neovide** rather than a terminal — proper font shaping, ligatures, smooth
   cursor and scroll animation, blurred floating windows.
2. Install a beautiful font: **iA Writer Quattro** (free, designed for prose),
   **JetBrainsMono Nerd Font**, or **Berkeley Mono**. Set in `options.lua`:
   `opt.guifont = "iA Writer Quattro V:h15"`
3. Try alternate themes by changing `colorscheme()` in `plugins.lua`:
   - `rose-pine` (current) — soft, warm, easy on eyes
   - `kanagawa` — Japanese-inspired, gorgeous for prose
   - `gruvbox-material` — warm, paper-like
   - `catppuccin` — pastel, very themeable
4. The Neovide settings in `options.lua` already add generous padding (80px sides,
   40px top/bottom), subtle cursor trail, blurred floating windows, and slight
   transparency.

## Keymaps (leader = space)

| Key          | Action                       |
|--------------|------------------------------|
| `<leader>w`  | Save                         |
| `<leader>q`  | Quit                         |
| `<leader>z`  | Toggle Zen mode              |
| `<leader>t`  | Toggle Twilight (dimming)    |
| `<leader>m`  | Toggle markdown rendering    |
| `<leader>s`  | Toggle spell check           |
| `<leader>c`  | Show word/char count         |
| `<leader>f`  | Find file (Telescope)        |
| `<leader>/`  | Search in files              |
| `<leader>b`  | Buffer list                  |
| `Ctrl-l`     | Fix last spelling mistake (insert mode) |

## Customisation

- **Wider/narrower zen window**: `lua/writing/plugins.lua`, `zen-mode.nvim` opts,
  `window.width`.
- **Auto-zen on markdown open**: uncomment the `require("zen-mode").open()` line in
  `init.lua`.
- **Different theme**: replace the `rose-pine` block in `plugins.lua` and update
  the `colorscheme()` call.
- **Typewriter scrolling off**: set `opt.scrolloff` to something small like `8` in
  `options.lua`.
