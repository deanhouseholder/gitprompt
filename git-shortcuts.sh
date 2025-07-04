# Git Aliases
alias g='git'
alias branch='f(){ test -z "$1" && echo "No branch name given." && return 1; git fetch &>/dev/null; git checkout -b $1 &>/dev/null || git checkout $1 &>/dev/null; git branch -u origin/$1 $1 &>/dev/null; git push --set-upstream origin $1 &>/dev/null; }; f'
alias cleanup='d=($(git branch --merged | grep -Ev develop\|master | sed -e "s/^\*//" -e "s/^ *//g" | uniq)); if [[ ${#d[@]} -gt 0 ]]; then echo ${d[@]} | xargs git branch -d; fi'
alias g.='git add . && gs'
alias ga='git add'
alias gac='git add . && git commit && gpu'
alias gad='git status -s | awk '"'"'{print $2}'"'"''
alias gb='git branch -a'
alias gback='git checkout - >/dev/null'
alias gc='git commit'
alias gca='git commit -a --amend -C HEAD'
alias gcb='f(){ git checkout bugfix/$1 2>/dev/null; git branch -u origin/bugfix/$1 bugfix/$1 >/dev/null; }; f'
alias gcd='git checkout develop'
alias gcf='f(){ git checkout feature/$1 2>/dev/null; git branch -u origin/feature/$1 feature/$1 >/dev/null; }; f'
alias gch='f(){ git checkout hotfix/$1 2>/dev/null; git branch -u origin/hotfix/$1 hotfix/$1 >/dev/null; }; f'
alias gcm='git checkout master >/dev/null'
alias gcr='f(){ git checkout release/$1 2>/dev/null; git branch -u origin/release/$1 release/$1 >/dev/null; }; f'
alias gcs='f(){ git checkout support/$1 2>/dev/null; git branch -u origin/support/$1 support/$1 >/dev/null; }; f'
alias gd='git diff'
alias gds='git diff --cached'
alias gdw='git diff -w'
alias gf='git fetch'
alias gh='git help'
alias gha='git help -a'
alias ghash='git branch --contains'
alias gitcred='git config --global credential.helper "store --file ~/.git-credentials"'
alias gld='git show'
alias glf='git log --name-only'
alias glg='git log --oneline --graph --decorate'
alias glu='git log HEAD..origin/$(git branch --show-current)'
alias gmm='git merge master'
alias gp='git pull'
alias gps='gpu'
alias gr='git checkout -- .'
alias greset='gr && grm'
alias gru='git checkout . && git clean -df'
alias nah='greset'
alias grh='git reset --hard'
alias grm='gad | xargs rm -r 2>/dev/null'
alias gs='clear && git status --ignore-submodules 2>/dev/null'
alias gsa='clear && git status 2>/dev/null'
alias gss='git submodule status 2>/dev/null'
alias gsu='git submodule update'
alias gu='git update-git-for-windows'
alias gud='git stash; git pull; git stash pop'
alias gum='git stash; git checkout master; git pull; git checkout -; git stash pop'
alias renamebranch='git branch -m'
alias uncommit='git reset HEAD^'
alias wip='git commit -am "WIP"'

# Warn user if a given alias previously exists
function alias_check() {
  alias "$1" &>/dev/null
  if [[ $? -eq 0 ]]; then
    printf "Warning you have an alias defined for $1 which conflicts with GitPrompt\n"
    printf "Your alias will remain so the GitPrompt shortcut will not work.\n\n"
  fi
}

# Stash with optional name
alias_check stash
stash() {
  test -z "$1" && git stash || git stash save "$*"
}

alias_check restore
restore() {
  # Load the menu function
  source "$(dirname "$BASH_SOURCE")/menu.sh"

  # Get the full stash list with references and descriptions
  readarray -t stash_list < <(git stash list)

  # Check if the stash list is empty
  if [ ${#stash_list[@]} -eq 0 ]; then
    echo "No stashes found."
    return 0
  fi

  # Loop through each stash found
  stash_count=0
  menu=()
  for stash_info in "${stash_list[@]}"; do
    # Extract the stash reference using cut
    stash_ref=$(echo "$stash_info" | cut -d: -f1)
    # The rest of the line is the stash description
    stash_desc=$(echo "$stash_info" | cut -d: -f2-)

    menu_entry="Stash $stash_count: - $stash_desc"$'\n'
    menu_entry="$menu_entry$(git stash show --compact-summary --color=always $stash_ref)"
    menu=("${menu[@]}" "$menu_entry")
    let stash_count++
  done

  header="Select a stash to restore or press ESC to cancel"
  menu_padding=1 menu_bg="" menu "$header" "menu"

  # If there was an error, display it and return
  if [[ "$menu_status" -ne 0 ]]; then
    printf "\n%s\n\n" "$menu_msg"
    return 1
  fi

  stash_num=$menu_selected

  unset menu_bg
  unset menu_padding

  function prompt_for_action() {
    # Prompt for action
    header="You selected: ${stash_list[stash_num]}\n"
    header+="$(git stash show --compact-summary --color=always stash@{$stash_num})\n"
    header+="\nWhat do you want to do with this stash?"
    options=("Restore the Stash" "View a Diff" "Drop the Stash" "Save as Patch File" "Restore the Stash in New Branch" "Quit")
    menu "$header" "options"
    echo

    # If there was an error, display it and return
    if [[ "$menu_status" -ne 0 ]]; then
      printf "%s\n\n" "$menu_msg"
      return 1
    fi

    action=$menu_selected

    # Restore stash optionally by name
    if [[ $action -eq 0 ]]; then
      # Restore the Stash
      git stash pop stash@{$stash_num}
      echo
      return 1
    elif [[ $action -eq 1 ]]; then
      # View a Diff
      git stash show -p stash@{$stash_num}
      echo
      read -p "Press Enter to continue" key
      return 0
    elif [[ $action -eq 2 ]]; then
      # Drop a stash
      git stash drop stash@{$stash_num}
      echo
      return 1
    elif [[ $action -eq 3 ]]; then
      # Save as Patch file
      echo 'What filepath do you want to save to?'
      read filepath
      filepath="${filepath/#\~/$HOME}"
      git stash show -p stash@{$stash_num} >"$filepath"
      printf "\nWrote patch to %s\n\nPress Enter to return\n" "$filepath"
      read pause
      return 0
    elif [[ $action -eq 4 ]]; then
      # Restore the Stash in New Branch
      echo 'What branch name do you want to create? (no spaces)'
      read branchname
      git stash branch $branchname stash@{$stash_num}
      return 1
    elif [[ $action -eq 5 ]]; then
      # Quit
      return 1
    fi
  }

  while prompt_for_action; (( $? == 0 )); do
    # Repeating - Do nothing
    printf ""
  done
}


# Check to see if there are new commits on the current branch
alias_check check
function check() {

  # Check if in a git repo
  git status &>/dev/null
  test $? -ne 0 && printf "Not a git repo\n" && return 1

  # Fetch latest commits from git remote
  printf "\n${details}Checking for latest git changes...$n"
  git fetch &>/dev/null
  test $? -ne 0 && printf "\rFailed to check for updates from the git repo.\n\n" && return 1

  # Define variables
  if [[ $(tput colors) -eq 256 ]]; then
    # 256 color support
    local c_header="\e[4m\e[38;5;15m"
    local c_message="\e[1;80m"
    local c_hash="\e[38;5;178m"
    local c_committed="\e[38;5;110m"
    local c_author="\e[38;5;85m"
    local c_current="\e[38;5;15m"
    local c_newer="\e[38;5;185m"
    local c_older="\e[38;5;245m"
  else
    # 16 colors only
    local c_header="\e[1;32m"
    local c_message="\e[1;36m"
    local c_hash="\e[0;33m"
    local c_committed="\e[1;34m"
    local c_author="\e[1;36m"
    local c_current="\e[1;33m"
    local c_newer="\e[1;15m"
    local c_older="\e[37m"
  fi
  local n="\e[0m" # Reset to normal
  local s=$'\x01' # Obscure ASCII character as a separator
  local counter=-1
  local show_previous=3
  local git_log_format="%h$s%cr$s%cd$s%s$s%an"
  local git_branch=$(git branch | grep '*' | cut -d' ' -f2)
  local not_yet_pulled="$(git log HEAD..origin/$git_branch --date=default --pretty=format:"$git_log_format" --decorate=full)"
  local local_commits="$(git log --date=default --pretty=format:"$git_log_format")"
  local count_available=$(echo -n "$not_yet_pulled" | grep -c '^')
  local output=$(printf "Timeline \b${s}Hash${s}Committed${s}Author${s}Commit Message$n")
  test $count_available -eq 1 && local is_or_are="is" || local is_or_are="are"

  # Display status line
  printf "\rThere $is_or_are $c_message$count_available$n new updates available on the $c_message$git_branch$n branch which can be pulled.\n\n$c_header"

  # Function to display a single line with the proper formatting
  print_git_log() {
    test -z "$1" && return
    if [[ $counter -eq 0 ]]; then
      local marker="${c_current}Current \b$n" # \b is a hack to get columns to line up due to multi-byte characters for Newer and Older arrows
    elif [[ $counter -lt 0 ]]; then
      local marker="${c_newer}Newer ▲$n"
    else
      local marker="${c_older}Older ▼$n"
    fi
    IFS="$s" read -r -a column <<< "$1"
    local hash="${column[0]}"
    local committed="${column[1]}"
    local commit_msg="${column[3]}"
    local author="${column[4]}"
    output="$( \
      printf "$output\n" && \
      printf "%s$s$c_hash%s$n$s$c_committed%s$n$s$c_author%s$n$s%s\n\n" "$marker" "$hash" "$committed" "$author" "$commit_msg" \
    )"
  }

  # Display Newer commits
  while read line; do
    print_git_log "$line"
  done <<< "$not_yet_pulled"

  # Display Current and Older commits
  counter=0
  while read line; do
    test $counter -eq $show_previous && break
    print_git_log "$line"
    let counter++
  done <<< "$local_commits"

  # Display the output in columns
  printf "$output\n" | column -s "$s" -t
  echo
}

# Git Branch Remove (local and remote)
alias_check gbr
function gbr() {
  test -z "$1" && printf "\nSyntax: gbr [branch_to_delete]\n\n" && return 1
  local git_branch=$(git branch | grep '*' | cut -d' ' -f2)
  test "$git_branch" == "$1" && printf "\nError: Requested branch to delete ($1) is currently checked out.\n\n" && return 1
  echo
  read -p "Warning! Are you sure you want to delete branch: $1? [y/N] " p
  if [[ "$p" =~ [Yy] ]]; then
    git branch -d $1 &>/dev/null
    test $? -eq 0 && printf "\nRemoved branch locally.\n" || printf "\nFailed to remove branch locally.\n"
    git push origin --delete $1 &>/dev/null
    test $? -eq 0 && printf "Removed branch on origin.\n\n" || printf "Failed to remove branch on origin.\n\n"
  else
    printf "\nCanceled.\n\n"
  fi
}

# Git Diff a File/Dir
alias_check gdf
function gdf() {
  if [[ -z "$1" ]]; then
    printf "\n\e[36mGit Diff a File (or Directory) between X commits ago and Y commits ago\e[0m\n\n"
    printf "\e[31mError: No inputs given.\e[0m\n\n"
    printf "\e[1;34mSyntax: gdf FILE/DIRECTORY [X commits ago] [Y commits ago]\e[0m\n\n"
    printf "Example: to see changes of a file between previous revision and current committed revision:\ngdf FILE 1 0\n\n"
    printf "Example: to see changes of a file between four commits ago and previous revision:\ngdf FILE 3 1\n\n"
    printf "Example: to use a wildcard, put it in single quotes:\ngdf 'customer*' 1 0\n\n"
    printf "Note: If X and Y values are ommitted, it will default to diff of previous version and current version.\n"
    printf "Note: It is recommended to be consistent between older commits for the X value and newer commits for\n"
    printf "      the Y value. Otherwise, it will appear as if the code written was deleted.\n\n"
    return
  fi
  local start end
  test -z "$2" && start=0 || start="$2"
  test -z "$3" && end=1 || end="$3"
  # echo "start: $start | end: $end"
  git diff HEAD~$start HEAD~$end "$1"
}

# Set up (or fix) Git Flow
alias_check gitflow
function gitflow() {
    local git_flow_config="master\ndevelop\nfeature/\nbugfix/\nrelease/\nhotfix/\nsupport/\n\n\n"
    # Check to see if git flow is initialized and is correctly configured
    echo "Checking git flow config..."
    local git_flow_check=$(git flow config 2>/dev/null)
    if [[ $? -eq 1 ]]; then
      # Check if Git Flow is installed
      local git_check=$(git flow 2>&1 | grep 'not a git command' | wc -l)
      if [[ $git_check -eq 1 ]]; then
        printf "\nError: Git Flow is not installed.\n\nPlease run: \"apt install git-flow\"\n\n"
        return 1
      fi
      # Set Git Flow config
      echo "Configuring git flow"
      printf "$git_flow_config" | git flow init >/dev/null
    elif [[ $(echo "$git_flow_check" | grep "Feature branch prefix: feature/" | wc -l) -eq 0 ]]; then
      # Force reset of Git Flow config
      echo "Reconfiguring git flow"
      printf "$git_flow_config" | git flow init -f >/dev/null
    fi
}

# Commit log with colored output for last n commits
alias_check gl
function gl() {
  if [[ $1 -gt 0 ]]; then
    local count_prev=" -n $1"
  fi
  git log --graph --decorate $count_prev
}

# Commit log without graph (one line per commit) for last n commits
alias_check gla
function gla() {
  if [[ $1 -gt 0 ]]; then
    local count_prev=" -n $1"
  fi
  git log --oneline --all --source --decorate=short $count_prev
}

# Display the last commit (or last n commits) with a summary of the file(s) modified
alias_check glast
function glast() {
  if [[ $1 -gt 0 ]]; then
    local count_prev=" -n $1"
  fi
  git show --stat=$(tput cols) --compact-summary $count_prev
}

# Display Git Alias Menu
alias_check gm
function gm() {
  # Repeat String function
  repeat_string() {
    printf "%0.s$1" $(seq $2)
  }

  # Define some vars
  local title="Git Shortcuts Menu"
  local header='\e[38;5;15m'
  local n='\e[0m'

  # Get the contents of git-menu.md
  local script_path="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
  local output="$(command cat "$script_path/git-menu.md" | grep -E '^\|')"

  # Determine widths of columns
  local first_line="$(echo "$output" | head -n1)"
  local col1="$(echo "$first_line" | cut -d'|' -f2)"
  local col1_width="$((${#col1}+1))"
  local col2="$(echo "$first_line" | cut -d'|' -f3)"
  local col2_width="$((${#col2}+1))"
  local title_padding=$(((${#first_line}/2)-(${#title}/2)))

  # Create horizontal bars
  local middle_bar="├$(repeat_string '─' ${col1_width})┼$(repeat_string '─' ${col2_width})┤"
  output="$(echo "$output" | sed -E 's/^(\| -.*)$/ '"$middle_bar"'/')"
  local top_bar="┌$(repeat_string '─' $col1_width)┬$(repeat_string '─' $col2_width)┐"
  local bottom_bar="└$(repeat_string '─' $col1_width)┴$(repeat_string '─' $col2_width)┘"

  # Add colors and swap out pipes
  local help="$(echo "$output" | awk '{
    gsub("^\\| ([a-z\\[\\]][^ ]*)", " │ \033[36m"$2"\033[37m");    # Add color to the first column
    gsub("\\| Alias Name", " │ \033[1;37mAlias Name\033[0;37m");   # Bold the Alias Name header
    gsub("\\| Description", " │ \033[1;37mDescription\033[0;37m"); # Bold the Description header
    gsub("\\|", " │");
    print $0
  }')"

  # Display menu
  printf "\n$(repeat_string ' ' $title_padding)$header$title$n\n"
  printf " %s\n%s\n %s\n\n" "$top_bar" "$help" "$bottom_bar"
}

# Git push with auto-detect/fix "no upstream branch" defined error
function gpu() {
  local out="$(git push $@)"
  local upstream="$(echo "$out" | grep "git push --set-upstream")"
  if [[ "$(echo $upstream | wc -l)" -eq 1 ]]; then
    $upstream
  else
    echo "$out"
  fi
}

# Display the best guess at the git https url
alias_check gurl
function gurl() {
  local remote="$(git remote -v | head -n1 | awk '{print $2}')"
  if [[ "${remote:0:4}" != "http" ]]; then
    remote="https://$(echo "${remote:4}" | sed '0,/:/s//\//')"
  fi
  echo "$remote" | sed -e 's/\.git//'
}

# Replace the origin Remote for a new repo url
alias_check gro
function gro() {
  local remote_full="$(git remote -v | head -n1)"
  local remote="$(echo "$remote_full" | awk '{print $2}')"
  local origin="$(echo "$remote_full" | awk '{print $1}')"
  local new_remote
  if [[ "${remote:0:4}" == "http" ]]; then
    new_remote="git@$(echo "${remote:8}" | sed '0,/\//s//:/')"
  else
    new_remote="https://$(echo "${remote:4}" | sed '0,/:/s//\//')"
  fi
  printf "Swapping origin: $remote\nFor:             $new_remote\n"
  git remote remove $origin
  git remote add $origin $new_remote
  git fetch
  git branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD)
  printf "Done\n\nYour new remotes are:\n"
  git remote -v
}

# Rebase all commits in the branch
alias_check rebase
function rebase() {
  test -z "$1" && branch=master || branch="$1"
  git rebase -i $(git merge-base $branch@{u} HEAD)
}
