---
title: "Neovim Reverse Lookup Cheetsheet"
---
# Neovim Reverse Lookup Cheetsheet

Look up what you need from the problem you have. Sections are ordered from the most urgent. Entries that need a recent version are marked, such as "0.11+".

## Find by symptom {#index}

| Symptom | Where to look |
| --- | --- |
| Something is wrong and you don't know where to start | [First steps](#first-steps) |
| Neovim won't start, errors everywhere, you need to fix your config | [Won't start or broken](#broken) |
| An option or a key mapping you set has no effect | [Settings or mappings don't work](#config) |
| Completion or go-to-definition doesn't work | [LSP doesn't work](#lsp) |
| Startup is slow | [Slow startup](#slow) |
| Colors or highlighting look wrong | [Wrong colors or highlighting](#highlight) |
| Yanked text can't be pasted outside Neovim | [Clipboard doesn't work](#clipboard) |
| A Lua error appears, or you want to check a value | [Inspect Lua](#lua) |
| You want to report a bug or search the help | [Look things up and report](#report) |

# First steps {#first-steps}

When you don't know the cause, check these in order.

## 1. Check error messages {#messages}

Messages that flashed by, for example at startup, can be read again here.

```vim
:messages
```

## 2. Check health {#checkhealth}

Lists problems with your setup and external tools.

```vim
:checkhealth
```

## 3. Find out whether your config is the cause {#clean}

Starts without your config and plugins. If the problem goes away, the cause is your config or a plugin.

```sh
nvim --clean
```

# Won't start or broken {#broken}

## Find your config file {#config-path}

`$MYVIMRC` is the config file that was loaded. If your config keeps Neovim from starting, open it with `nvim --clean` and fix it.

```vim
:echo $MYVIMRC
:echo stdpath('config')
```

`stdpath()` also tells you the other directories.

| Argument | What it holds |
| --- | --- |
| `config` | Config (`init.lua` and so on) |
| `data` | Plugins and other data |
| `state` | ShaDa (history and so on), swap files, undo |
| `cache` | Cache |
| `log` | Logs |

## Reproduce with a minimal config {#minimal-repro}

Use this to narrow down the plugin at fault, or to report a bug. Create `repro.lua` and list only the plugins you need. The example below uses lazy.nvim and puts everything in `.repro` under the working directory, so your usual setup stays untouched.

```lua
-- repro.lua
vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
  spec = {
    -- Add only the plugins needed to reproduce the problem.
  },
})
```

```sh
nvim -u repro.lua
```

# Settings or mappings don't work {#config}

## Find where an option was last set {#verbose-set}

Checks whether another setting or a plugin overrides yours.

```vim
:verbose set tabstop?
```

An option set from Lua only shows `Last set from Lua`. To see the file and line, start Neovim with `-V1` and run the same command.

```sh
nvim -V1
```

## Find where a key mapping was defined {#verbose-map}

```vim
:verbose map <leader>f
:verbose nmap
```

`<leader>` is replaced by the value of `mapleader`. For mappings defined in Lua, `nvim -V1` shows the location as above.

## Check which key the terminal sends {#check-key}

In insert mode, press `<C-v>` and then the key you want to check. The key Neovim receives is inserted as is. If nothing is inserted, or a different key appears, your terminal or tmux is taking the key.

```text
i  <C-v>  (the key to check)
```

# LSP doesn't work {#lsp}

## Check the state of LSP {#lsp-health}

Shows the running clients, their filetypes, the log location and more.

```vim
" 0.11+
:checkhealth vim.lsp
" Earlier versions (nvim-lspconfig)
:LspInfo
```

## Read the LSP log {#lsp-log}

Shows the log file location and opens it.

```vim
:lua =vim.lsp.get_log_path()
:execute 'tabnew' v:lua.vim.lsp.get_log_path()
```

With nvim-lspconfig installed, `:LspLog` opens it too. For a detailed log, raise the log level before the server starts, for example at the top of `init.lua`.

```lua
require("vim.lsp.log").set_level("debug")
```

The log grows quickly, so set the level back when you are done.

# Slow startup {#slow}

## Measure startup time {#startuptime}

Writes the time spent on each loaded file to `startup.log`.

```sh
nvim --startuptime startup.log
```

# Wrong colors or highlighting {#highlight}

## Find the highlight groups under the cursor {#inspect}

0.9+. Shows whether Treesitter, LSP semantic tokens or syntax highlighting sets the color.

```vim
:Inspect
```

# Clipboard doesn't work {#clipboard}

## Check whether the clipboard is available {#clipboard-check}

```vim
:echo has('clipboard')
:set clipboard?
:checkhealth
```

The Clipboard section of `:checkhealth` shows which tool is used. If none is available, install the one for your OS.

| Environment | Tool |
| --- | --- |
| macOS | `pbcopy` (built in) |
| Linux (Wayland) | `wl-clipboard` |
| Linux (X11) | `xclip` or `xsel` |
| WSL | `win32yank` |

To always use the system clipboard, set `vim.opt.clipboard = "unnamedplus"`.

# Inspect Lua {#lua}

## Print a Lua value {#lua-print}

`:lua =expr` prints the value pretty-printed (0.9+).

```vim
:lua =vim.bo.filetype
:lua =vim.fn.stdpath("config")
```

In scripts, use `vim.print()`.

```lua
vim.print(vim.opt.runtimepath:get())
```

## Lua guide

<https://neovim.io/doc/user/lua-guide.html>

# Look things up and report {#report}

## Check the version and build {#version}

Always needed when you report a bug.

```vim
:version
```

```sh
nvim --version
```

## Search the whole help {#helpgrep}

Finds which help pages mention a word. Step through the matches with `:cnext` and `:cprev`.

```vim
:helpgrep {pattern}
```

# Basic

## Start tutorial

```vim
:Tutor
```

# Link

- [Neovim official site](https://neovim.io/)
- [Official repository](https://github.com/neovim/neovim)

# Contribute

- [repo](https://github.com/ShortArrow/neovim-reverse-lookup/)
