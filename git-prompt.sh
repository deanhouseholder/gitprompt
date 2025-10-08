## Git Prompt
# Author: Dean Householder <deanhouseholder@gmail.com>
# See README.md for more details

# If TERM is not set, set to 256 colors
test -z "$TERM" && export TERM=xterm-256color

# Print a foreground color that is properly-escaped for PS1 prompts
function gp_fg() {
  printf "\[\e[38;5;%sm\]" "$1"
}

# Print a background color that is properly-escaped for PS1 prompts
function gp_bg() {
  printf "\[\e[48;5;%sm\]" "$1"
}

# Reset the colors to default in the PS1 prompt
function gp_norm() {
  printf "\[\e[0m\]"
}

# Define Git Prompt Colors
git_style="$(gp_fg 15)$(gp_bg 17)"   # FG: White, BG: Dark Blue-Purple
git_clean="$(gp_fg 46)"              # FG: Green
git_dirty="$(gp_fg 196)"             # FG: Red
git_ignored="$(gp_fg 240)"           # FG: Dark Gray
git_subdir="$(gp_fg 251)"            # FG: Light Gray
git_submark="$(gp_fg 166)"           # FG: Orange

# -----------------------------------
# Displays the git part of the prompt
# -----------------------------------
function git_prompt() {
  # Check if current directory is a git repo
  git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  local gstatus=$?

  if [[ $gstatus -eq 0 ]] && [[ "$git_dir" != "." ]]; then
    # Inside a git repo directory
    export git_dir

    # Print starting block
    printf "%s [" "$git_style"

    # Submodule detection: if .git path includes .git/modules, we're inside a submodule
    if [[ ! "$git_dir" =~ \.git/modules/ ]]; then
      # Regular repo
      _git_display_branch "$PWD"
    else
      # Inside a submodule; build list from top repo -> current
      local cur="$PWD"
      local top=""
      local chain=()

      # Walk upward: collect each repo root where show-cdup is empty
      while :; do
        if [[ -e "$cur/.git" ]] && [[ "$(git -C "$cur" rev-parse --show-cdup 2>/dev/null)" == "" ]]; then
          chain=("$cur" "${chain[@]}") # Add this directory to an array of directories
        fi
        # If this level is the top repo (git-dir resolves to ".git"), stop
        if [[ -d "$cur/.git" ]] && [[ "$(git -C "$cur" rev-parse --git-dir 2>/dev/null)" == ".git" ]]; then
          top="$cur"
          break
        fi
        # Go up; if we're at filesystem root, bail
        local parent
        parent="$(dirname "$cur")"
        [[ "$parent" == "$cur" ]] && break
        cur="$parent"
      done

      # Render each hop: <subdir>/<name> (<branch/status>)
      local i
      for i in "${!chain[@]}"; do
        local repo="${chain[$i]}"
        printf "%s/%s%s (" "$git_subdir" "$(basename "$repo")" "$git_style"
        _git_display_branch "$repo"
        printf "%s)" "$git_style"
        test $((i+1)) -eq ${#chain[@]} || printf "%s ↠ " "$git_submark"
      done
    fi

    printf "%s]" "$git_style"
  else
    # Not a normal work tree — bare or inside .git?
    if [[ "$PWD" =~ \.git ]] && [[ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" == "true" ]]; then
      printf "%s [%s!GIT DIR%s]" "$git_style" "$git_dirty" "$git_style"
    elif [[ "$(git rev-parse --is-bare-repository 2>/dev/null)" == "true" ]]; then
      printf "%s [%s!BARE REPO%s]" "$git_style" "$git_dirty" "$git_style"
    fi
  fi
}

# ---------------------------------
# Displays the branch name along with status/color for the current repo
# ---------------------------------
_git_display_branch() {
  local repo="$1"

  # Determine color (ignored / clean / dirty)
  if GIT_OPTIONAL_LOCKS=0 git -C "$repo" check-ignore -q . 2>/dev/null; then
    printf "%s" "$git_ignored"
  else
    local dirty=0

    # Unstaged changes? (index vs worktree)
    GIT_OPTIONAL_LOCKS=0 git -C "$repo" diff-files --quiet --ignore-submodules -- 2>/dev/null || dirty=1

    # Staged changes? (index vs HEAD; handle unborn HEAD)
    if GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-parse -q --verify HEAD >/dev/null 2>&1; then
      GIT_OPTIONAL_LOCKS=0 git -C "$repo" diff-index --quiet --cached HEAD -- 2>/dev/null || dirty=1
    else
      GIT_OPTIONAL_LOCKS=0 git -C "$repo" diff-index --quiet --cached "$(git -C "$repo" hash-object -t tree /dev/null)" -- 2>/dev/null || dirty=1
    fi

    # Untracked files?
    if IFS= read -r -d '' _ < <(GIT_OPTIONAL_LOCKS=0 git -C "$repo" ls-files --others --exclude-standard -z 2>/dev/null); then
      dirty=1
    fi

    # Display background color according to status
    if [[ "$dirty" -eq 0 ]]; then
      printf "%s" "$git_clean"
    else
      printf "%s" "$git_dirty"
    fi
  fi

  local branch="$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null)"

  # Check if detached head
  if [[ "$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name HEAD 2>/dev/null)" == "HEAD" ]]; then
    printf "HEAD°%s" "$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" show -s --pretty=%h HEAD 2>/dev/null)"
  else
    # Display Branch name
    printf "%s" "$branch"
  fi

  # In-progress operations
  local gd="$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-parse --git-dir 2>/dev/null)" || return
  if   [[ -f "$gd/MERGE_HEAD" ]];                                 then printf '|MERGING'
  elif [[ -f "$gd/CHERRY_PICK_HEAD" ]];                           then printf '|CHERRY-PICKING'
  elif [[ -f "$gd/REVERT_HEAD" ]];                                then printf '|REVERTING'
  elif [[ -f "$gd/BISECT_LOG" ]];                                 then printf '|BISECTING'
  elif [[ -f "$gd/REBASE_HEAD" ]] || [[ -d "$gd/rebase-apply" ]]; then printf '|REBASING'
  fi

  # Check if the branch is ahead or behind of repo
  local output="" upstream
  upstream=$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) || upstream=""
  if [ -n "$upstream" ]; then
    # Get ahead/behind counts
    if IFS=$'\t' read -r behind ahead < <(GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-list --left-right --count "${upstream}...HEAD" 2>/dev/null); then
      [[ "$behind" -ne 0 ]] && output+="↓${behind}" # commits to pull
      [[ "$ahead"  -ne 0 ]] && output+="↑${ahead}"  # commits to push
    fi
  else
    # Check if no upstream remote defined
    [[ -z "$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" remote 2>/dev/null)" ]] && output+="¤"
  fi

  # Check for any Stashed code
  GIT_OPTIONAL_LOCKS=0 git -C "$repo" rev-parse --verify -q refs/stash >/dev/null && output+='§'

  # If anything was added to the output var, print it w/ a space
  [[ -n "$output" ]] && printf " %s" "$output"
}
