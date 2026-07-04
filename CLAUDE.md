# CLAUDE.md

This repo is a **chezmoi source directory** (`~/.local/share/chezmoi`). Files here
are rendered into the user's home directory by chezmoi — they are not used in
place.

**Read [README.md](./README.md) for the full editing workflow and file-naming
convention.** Key points for working here:

- Source filenames encode attributes: `dot_` → leading `.`, `.tmpl` → Go
  template, `private_` → `0600`. Do **not** rename these away from the
  convention.
- After editing a source file, changes only reach `~` on `chezmoi apply`.
  Editing the applied file in `~` directly does *not* update this repo — use
  `chezmoi add <path>` to pull it back in.
- `.chezmoiscripts/` holds scripts run during `apply`. The package installer is
  `run_onchange_` and re-runs when `dot_Brewfile`'s hash (embedded in the
  script) changes — keep that `{{ include "dot_Brewfile" | sha256sum }}` line.
- `README.md` and `CLAUDE.md` are listed in `.chezmoiignore` so chezmoi does not
  create `~/README.md` / `~/CLAUDE.md`. Add any other repo-only docs there too.
- Never commit plaintext secrets; use `chezmoi add --encrypt` (see README).
- All git operations happen in this source repo. Verify with `chezmoi diff`
  before committing behavior changes.
