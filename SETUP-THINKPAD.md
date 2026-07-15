# ThinkPad T14 setup (mirror the MacBook Pro)

Two repos define the whole setup:

- **This repo** — the Neovim config (kickstart.nvim + `lua/custom/` plugins
  and keymaps, with plugin versions pinned in `lazy-lock.json`).
- **[Diaz1620/zellij-config](https://github.com/Diaz1620/zellij-config)** —
  the Zellij config (`config.kdl`).

`setup/thinkpad-setup.sh` bootstraps a fresh Linux machine to match the Mac.

## Quick start (ThinkPad, any apt/dnf/pacman distro)

```sh
git clone git@github.com:Diaz1620/kickstart.nvim.git ~/kickstart.nvim
cd ~/kickstart.nvim
./setup/thinkpad-setup.sh
```

The script:

1. Installs the external requirements: `git`, `make`, `gcc`, `unzip`,
   `ripgrep`, `fd`, and clipboard tools (`xclip` for X11, `wl-clipboard`
   for Wayland).
2. Installs the latest stable Neovim (official release tarball on
   Debian/Ubuntu, distro package on Fedora/Arch).
3. Installs the latest Zellij binary into `~/.local/bin`.
4. Installs the JetBrainsMono Nerd Font.
5. Symlinks this repo to `~/.config/nvim`, clones `zellij-config` to
   `~/zellij-config`, and symlinks it to `~/.config/zellij` — backing up
   anything already in those places. Zellij uses `~/.config/zellij` on both
   macOS and Linux, so the exact same `config.kdl` drives both machines.

Then:

1. Set your terminal's font to **JetBrainsMono Nerd Font** (only needed if
   you flip `vim.g.have_nerd_font` to `true` in `init.lua`, but it doesn't
   hurt to have it).
2. Run `nvim` once — lazy.nvim installs every plugin at the exact versions
   pinned in `lazy-lock.json`, so both machines run identical plugins.
3. Run `:checkhealth` to confirm everything is wired up.
4. Run `:Codeium Auth` — Windsurf/Codeium authentication is per-machine, so
   the ThinkPad needs its own sign-in.
5. Run `zellij` — your keybindings come straight from `zellij-config`.

## Keeping the machines in sync

Both configs are plain git repos symlinked into `~/.config`, so syncing is
just git:

- Tweak something on either machine → `git commit` + `git push` in
  `~/kickstart.nvim` or `~/zellij-config`.
- On the other machine → `git pull` (or just re-run
  `./setup/thinkpad-setup.sh`, which pulls `zellij-config` for you).

If the Mac doesn't use this symlink layout yet, set it up the same way:

```sh
git clone git@github.com:Diaz1620/kickstart.nvim.git ~/kickstart.nvim
git clone git@github.com:Diaz1620/zellij-config.git ~/zellij-config
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null
mv ~/.config/zellij ~/.config/zellij.backup 2>/dev/null
ln -s ~/kickstart.nvim ~/.config/nvim
ln -s ~/zellij-config ~/.config/zellij
```

## macOS → Linux differences to be aware of

- **Zellij keybindings carry over — and work better.** Your bindings lean on
  `Alt` (`Alt Left/Right` to move focus, `Alt n`/`Alt p` for tabs, `Alt w`
  for the session manager). On Linux the Alt key sends these natively; no
  "Option as Meta" terminal setting needed like on macOS.
- **Neovim clipboard.** Your `<M-c>` / `<leader>y` yank-to-clipboard maps use
  the `+` register, which needs `xclip` (X11) or `wl-clipboard` (Wayland) —
  the script installs both. `echo $XDG_SESSION_TYPE` tells you which session
  you're on.
- **Terminal copy/paste.** `Cmd+C`/`Cmd+V` in the Mac terminal becomes
  `Ctrl+Shift+C`/`Ctrl+Shift+V` in most Linux terminals.
- **PATH.** Zellij and (on Debian/Ubuntu) Neovim land in `~/.local/bin`.
  Most distros put it on `PATH` by default; the script warns if yours
  doesn't.
