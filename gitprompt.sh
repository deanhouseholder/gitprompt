## Git Prompt
# Author: Dean Householder <deanhouseholder@gmail.com>
# See README.md for more details

# Print a foreground color that is properly-escaped for PS1 prompts
fg() {
  printf "\[\e[38;5;$1m\]"
}

# Print a background color that is properly-escaped for PS1 prompts
bg() {
  printf "\[\e[48;5;$1m\]"
}

# Define Git Colors
git_style="$(fg 15)$(bg 17)"      # FG: White, BG: Dark Blue-Purple
git_clean="$(fg 46)"              # FG: Green
git_dirty="$(fg 196)"             # FG: Red
git_ignored="$(fg 240)"           # FG: Dark Gray
git_subdir="$(fg 251)"            # FG: Light Gray
git_submark="$(fg 166)"           # FG: Orange
git_no_remote="$(bg 254)"         # BG: Black

git_prompt() {
  # Check if current directory is a git repo
  git status &>/dev/null
  export gstatus=$?

  printf "${git_style} ["

  if [[ $gstatus -eq 0 ]]; then
    # User is currently inside a git repo directory

    export git_dir="$(git rev-parse --git-dir)"
    # Submodule Logic
    if [[ "$git_dir" =~ \.git/modules ]]; then
      local orig_dir="$PWD"
      local dira=($PWD)
      while true; do
        cd ..
        if [[ -f \.git ]] || [[ -d \.git ]]; then
          dira=("$PWD" "${dira[@]}")
        fi
        if [[ "$git-dir" == '.git' ]]; then
          break
        fi
      done
      for i in "${!dira[@]}"; do
        cd "${dira[$i]}"
        printf "${git_subdir}/$(basename $PWD)$git_style ("
        printf "$(git_display_branch)${git_style})"
        test $(($i+1)) -eq ${#dira[@]} || printf "$git_submark ↠ "
      done
    else
      # Not in a git submodule directory
      printf "$(git_display_branch)"
    fi
    # End of Submodule Logic

  else
    printf "$(git_display_branch)"
  fi

  printf "${git_style}]"
}

function git_display_branch {
  if [[ "$gstatus" -eq 0 ]]; then

    # Determine BG color
    if [[ -z "$(git status -s)" ]]; then
      printf "$git_clean"                               # Clean directory
    elif [[ "$(git check-ignore .)" == "." ]]; then
      printf "${git_ignored}"                           # Ignored directory
    else
      printf "$git_dirty"                               # Dirty directory
    fi

    # Display Branch name
    printf "$(git branch --show-current)"

    if [[ -f "$git_dir/MERGE_HEAD" ]]; then
      printf '|MERGING'
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
      printf "CHERRY-PICKING"
    elif [[ -f "$git_dir/REVERT_HEAD" ]]; then
      printf "|REVERTING"
    elif [[ -f "$git_dir/BISECT_LOG" ]]; then
      printf "|BISECTING"
    elif [[ -f "$git_dir/REBASE_HEAD" ]]; then
      printf "REBASING"
    elif [[ -d "$git_dir/rebase-apply" ]]; then
      printf "|REBASE"
    fi

    local output=''

    # Check if the branch is ahead or behind of repo
    local git_status="$(git status | grep 'Your branch')"
    if [[ "$git_status" =~ .*is\ behind.* ]]; then
      output+="«$(printf "$git_status" | sed -e 's~[^0-9]*\([0-9]\+\).*~\1~g')"
    elif [[ "$git_status" =~ .*is\ ahead.* ]]; then
      output+="»$(printf "$git_status" | sed -e 's~[^0-9]*\([0-9]\+\).*~\1~g')"
    fi

    # Check for Git Remotes
    local remotes=$(git remote -v | wc -l)
    if [[ "$remotes" -eq 0 ]]; then
      output+="¤"
    fi

    # Check for any Stashed code
    test -z "$(git stash list)" || output+='§'

    # If anything got added to the output var, print it w/ a space
    test -z "$output" || printf " $output"
  else
    printf "$git_dirty"

    # Check if in a Bare repository
    if [[ "$(git rev-parse --is-bare-repository 2>/dev/null)" == "true" ]]; then
      printf "!BARE REPO"

    # Check if in .git dir
    elif [[ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" == "true" ]]; then
      printf "!GIT DIR"
    fi
  fi
}
