## Git Prompt
# Author: Dean Householder <deanhouseholder@gmail.com>
# See README.md for more details

# If TERM is not set, set to 256 colors
test -z "$TERM" && export TERM=xterm-256color

# Print a foreground color that is properly-escaped for PS1 prompts
function fg() {
  printf "\[\e[38;5;$1m\]"
}

# Print a background color that is properly-escaped for PS1 prompts
function bg() {
  printf "\[\e[48;5;$1m\]"
}

# Reset the colors to default in the PS1 prompt
function norm() {
  printf "\[\e[0m\]"
}

# Define Git Prompt Colors
git_style="$(fg 15)$(bg 17)"      # FG: White, BG: Dark Blue-Purple
git_clean="$(fg 46)"              # FG: Green
git_dirty="$(fg 196)"             # FG: Red
git_ignored="$(fg 240)"           # FG: Dark Gray
git_subdir="$(fg 251)"            # FG: Light Gray
git_submark="$(fg 166)"           # FG: Orange
git_no_remote="$(bg 254)"         # BG: Black

# Define Git version
# git_version="$(git --version)"

# Displays the git part of the prompt
# Specifically this function determines if a dir is a git repo
# and if it is a submodule, get each nested status
function git_prompt() {
  # Check if current directory is a git repo
  git status &>/dev/null
  local gstatus=$?

  if [[ $gstatus -eq 0 ]]; then
    # Print starting block
    printf "${git_style} ["

    # User is currently inside a git repo directory
    export git_dir=$(git rev-parse --git-dir)

    # Detect if in a submodule repo directory
    # When in a submodule repo dir the `git rev-parse --git-dir` command will contain '.git/modules/'
    if [[ ! "$git_dir" =~ \.git/modules/ ]]; then
      # In a regular git repo directory (not a submodule dir)
      printf "$(git_display_branch)"
    else
      # User is in a submodule repo within a git repo
      local dira=() # Build an array of directories
      if [[ -f \.git ]] || [[ -d \.git ]]; then # If this is either a git repo dir or a submodule directory
        if [[ "$(git rev-parse --show-cdup 2>/dev/null)" == "" ]]; then
          dira=("$PWD" "${dira[@]}")  # Add this directory to an array of directories
        fi
      fi
      # Move up through the directories until you find the top .git directory
      while true; do
        cd ..
        if [[ -f \.git ]] || [[ -d \.git ]]; then # If this is either a git repo dir or a submodule directory
          if [[ "$(git rev-parse --show-cdup 2>/dev/null)" == "" ]]; then
            dira=("$PWD" "${dira[@]}")  # Add this directory to an array of directories
          fi
        fi
        # Possibly found it
        if [[ -d .git ]]; then
          # Save some cycles by only running this if susupected to be the top git repo dir
          if [[ "$(git rev-parse --git-dir 2>/dev/null)" == ".git" ]]; then
            break # Continue
          fi
        fi
      done
      for i in "${!dira[@]}"; do
        cd "${dira[$i]}"
        printf "${git_subdir}/$(basename $PWD)$git_style ("
        printf "$(git_display_branch)${git_style})"
        test $(($i+1)) -eq ${#dira[@]} || printf "$git_submark ↠ "
      done
    fi
    # End of Submodule Logic
    printf "${git_style}]"
  else
    # It might be a bare repo or inside a .git directory

    # Check if in a Bare repository
    if [[ "$(git rev-parse --is-bare-repository 2>/dev/null)" == "true" ]]; then
      printf "$git_dirty"
      printf "!BARE REPO"
      printf "${git_style}]"

    # Check if in .git dir
    elif [[ "$PWD" =~ /\.git/ ]]; then
      # Only run the following if the path contains '/.git/'
      if [[ "$(git rev-parse --is-inside-git-dir 2>/dev/null)" == "true" ]]; then
        printf "$git_dirty"
        printf "!GIT DIR"
        printf "${git_style}]"
      fi
    fi
  fi
}

# Displays the branch name along with status/color
function git_display_branch {
  # Determine BG color
  if [[ "$(git check-ignore .)" == "." ]]; then
    printf "$git_ignored"                             # Ignored directory
  elif [[ -z "$(git status -s)" ]]; then
    printf "$git_clean"                               # Clean directory
  else
    printf "$git_dirty"                               # Dirty directory
  fi

  # Get current branch name
  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

  # Check if detached head
  if [[ "$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)" == "HEAD" ]]; then
    printf "HEAD°$(git show -s --pretty=%h HEAD)"
  else
    # Display Branch name
    printf "$branch"
  fi

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
  # local remote="$(git branch --show-current -vv --format='%(upstream:remotename)')" (if Git version > 2.22)
  local remote="$(git branch -vv | grep -e '^*')"
  if [[ $remote =~ \[ ]]; then
    local remote_name="$(echo $remote | cut -d'[' -f2 | cut -d'/' -f1)"
    IFS=$'\t' read -r -a ahead_behind <<< "$(git rev-list --left-right --count "$remote_name"/"$branch"..."$branch")"
    if [[ ${ahead_behind[0]} -ne 0 ]]; then
      output+="«${ahead_behind[0]}"
    elif [[ ${ahead_behind[1]} -ne 0 ]]; then
      output+="»${ahead_behind[1]}"
    fi
  else
    # No Remotes found
    output+="¤"
  fi

  # Check for any Stashed code
  test -z "$(git stash list)" || output+='§'

  # If anything got added to the output var, print it w/ a space
  test -z "$output" || printf " $output"
}
