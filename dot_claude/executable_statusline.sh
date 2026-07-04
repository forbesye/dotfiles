#!/bin/bash
# Claude Code status line, styled to match the Starship prompt in this dotfiles
# repo: yellow ◎ marker, blue directory (last 2 path components, ⌂ for home),
# and a △ git branch that hides on main/master.
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

# Directory: collapse $HOME to ⌂, keep only the last two path components.
disp=${dir/#$HOME/⌂}
short=$(printf '%s' "$disp" | awk -F/ '{ if (NF<=2) print $0; else print "□ "$(NF-1)"/"$NF }')

# Git branch (empty outside a repo); hide the noisy default branches.
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
case "$branch" in main|master) branch="" ;; esac

# ANSI: bright-yellow bold marker, dimmed model+context, italic blue dir, bright-blue branch.
Y='\033[1;93m'; D='\033[2;37m'; B='\033[3;34m'; G='\033[1;94m'; R='\033[0m'
out=$(printf "${Y}◎${R} ${D}%s${R} ${D}[%s%%]${R}  ${B}%s${R}" "$model" "$pct" "$short")
[ -n "$branch" ] && out="$out$(printf "  ${G}△ %s${R}" "$branch")"
printf '%b' "$out"
