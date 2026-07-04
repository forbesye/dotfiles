# dotfiles

Personal macOS dotfiles, managed with [chezmoi](https://chezmoi.io) and hosted on GitHub.

The **source repo** lives at `~/.local/share/chezmoi`. chezmoi renders the files
here into your home directory. You edit the source, then `chezmoi apply` writes
the result to `~`.

## Bootstrap a new machine

```bash
brew install chezmoi   # (the package script will also install Homebrew if missing)
chezmoi init --apply git@gitlab.com:forbesye/dotfiles.git
```

This clones the repo, writes every dotfile, installs all Homebrew packages
(`brew bundle`), and points iTerm2 at its tracked preferences.

## What's tracked

| Source file | Applied to | Notes |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | |
| `dot_fzf.zsh` | `~/.fzf.zsh` | |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | templated home path |
| `dot_Brewfile` | `~/.Brewfile` | Homebrew package manifest |
| `dot_claude/settings.json` | `~/.claude/settings.json` | Claude Code settings; rest of `~/.claude` is per-machine state and untracked |
| `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | global Claude Code instructions |
| `dot_claude/executable_statusline.sh` | `~/.claude/statusline.sh` | status line (model, context %, dir, git branch); Starship-styled |
| `dot_config/starship.toml` | `~/.config/starship.toml` | |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` | |
| `dot_config/iterm2/private_com.googlecode.iterm2.plist` | `~/.config/iterm2/...` | see [iTerm2](#iterm2) |
| `.chezmoiscripts/run_onchange_after_install-packages.sh.tmpl` | — | runs `brew bundle` on change |
| `.chezmoiscripts/run_once_after_configure-iterm2.sh` | — | sets iTerm2 custom-prefs folder |

### Naming convention

chezmoi encodes attributes in source filenames:

- `dot_` → a leading `.` in the target (`dot_zshrc` → `~/.zshrc`)
- `.tmpl` → the file is a [Go template](https://chezmoi.io/user-guide/templating/)
  (e.g. `{{ .chezmoi.homeDir }}`)
- `private_` → applied with `0600` permissions
- `.chezmoiscripts/` → scripts run during `apply`, not copied to `~`
  - `run_once_` runs once per machine; `run_onchange_` re-runs when its content changes

## Editing workflow

**Edit an existing dotfile** (two equivalent ways):

```bash
# A) edit the real file, then pull the change back into the repo
vim ~/.zshrc
chezmoi add ~/.zshrc

# B) edit the source directly, then push it out to ~
chezmoi edit ~/.zshrc
chezmoi apply
```

**Preview** what apply would change, in either direction:

```bash
chezmoi diff
```

**Add a new dotfile to management:**

```bash
chezmoi add ~/.config/nvim        # a file or a whole directory
```

**Add a Homebrew package:**

```bash
chezmoi edit ~/.Brewfile          # add a `brew "..."` or `cask "..."` line
chezmoi apply                     # Brewfile hash changes → install script re-runs
```

**Commit and push** (all git happens in the source repo):

```bash
chezmoi cd                        # cd into ~/.local/share/chezmoi
git add -A && git commit -m "…" && git push
exit
# shortcut without cd:  chezmoi git -- status   /   chezmoi git -- push
```

## iTerm2

iTerm2 preferences can't be tracked at their default `~/Library/Preferences`
location (macOS's `cfprefsd` overwrites the file). Instead this repo uses
iTerm2's **"load preferences from a custom folder"** feature pointed at
`~/.config/iterm2`. The `run_once_after_configure-iterm2.sh` script sets this
up on new machines.

To capture setting changes: iTerm2 saves its plist into `~/.config/iterm2` on
quit, then:

```bash
chezmoi add ~/.config/iterm2/com.googlecode.iterm2.plist
```

## Secrets

SSH private keys and other secrets are **not** stored in this repo in plaintext.
To manage encrypted secrets, use chezmoi's age encryption:

```bash
chezmoi add --encrypt ~/.ssh/id_ed25519
```
