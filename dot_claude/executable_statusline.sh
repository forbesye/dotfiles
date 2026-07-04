#!/bin/bash
# Claude Code status line, styled to match the "warm" Starship prompt in this
# dotfiles repo (dot_config/starship.toml): a gold ❯ marker + gold full path,
# a peach git branch, and red git-status flags (! ? + ⇡ ⇣), matching the
# palette gold=#f9e2af peach=#fab387 red=#f38ba8 maroon=#eba0ac.
input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "claude"')
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir="$PWD"

# Context-window usage as a whole-number percent. Prefer the value Claude Code
# precomputes; fall back to the latest turn's usage in the transcript.
pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
if [ -z "$pct" ]; then
  tp=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
  size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // 200000')
  if [ -n "$tp" ] && [ -f "$tp" ]; then
    used=$(tail -1 "$tp" | jq -r '(.api_response.usage // .message.usage // {}) | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))' 2>/dev/null)
    [ -n "$used" ] && [ "$size" -gt 0 ] && pct=$(( 100 * used / size ))
  fi
fi
pct=$(printf '%s' "$pct" | awk '{printf "%d", $1}')
[ -z "$pct" ] && pct=0

# Directory: full absolute path with $HOME collapsed to ~ (Starship shows the
# full path here — truncation_length = 0, truncate_to_repo = false).
disp=${dir/#$HOME/\~}

# Git branch (shown on every branch, matching the prompt's git_branch module).
branch=$(git -C "$dir" branch --show-current 2>/dev/null)

# Git status flags, mirroring the prompt: staged "+", modified "!", untracked
# "?", plus ahead/behind "⇡"/"⇣" against the upstream.
flags=""
if [ -n "$branch" ]; then
  porc=$(git -C "$dir" status --porcelain 2>/dev/null)
  printf '%s' "$porc" | grep -qE '^[MADRC]'  && flags="$flags+"
  printf '%s' "$porc" | grep -qE '^.[MD]'    && flags="$flags!"
  printf '%s' "$porc" | grep -qE '^\?\?'     && flags="$flags?"
  ab=$(git -C "$dir" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
  behind=$(printf '%s' "$ab" | awk '{print $1+0}')
  ahead=$(printf '%s' "$ab" | awk '{print $2+0}')
  [ "${ahead:-0}" -gt 0 ] 2>/dev/null  && flags="$flags⇡$ahead"
  [ "${behind:-0}" -gt 0 ] 2>/dev/null && flags="$flags⇣$behind"
fi

# Warm palette (truecolor): gold marker+dir, peach branch, red flags, dimmed
# gold model, maroon context percent.
GOLD='\033[1;38;2;249;226;175m'
PEACH='\033[1;38;2;250;179;135m'
RED='\033[38;2;243;139;168m'
MAROON='\033[3;38;2;235;160;172m'
DGOLD='\033[2;38;2;249;226;175m'
R='\033[0m'

out=$(printf "${GOLD}❯${R} ${GOLD}%s${R}" "$disp")
[ -n "$branch" ] && out="$out$(printf "  ${PEACH}%s${R}" "$branch")"
[ -n "$flags" ]  && out="$out$(printf " ${RED}%s${R}" "$flags")"
out="$out$(printf "   ${DGOLD}%s${R} ${MAROON}[%s%%]${R}" "$model" "$pct")"
printf '%b' "$out"
