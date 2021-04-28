# Git Aliases
alias g='git'
alias branch='f(){ test -z "$1" && echo "No branch name given." && return 1; git fetch &>/dev/null; git checkout -b $1 2>/dev/null || git checkout $1; git branch -u origin/$1 $1 2>/dev/null; gp; git push --set-upstream origin $1; }; f'
alias cleanup='d=($(git branch --merged | grep -Ev develop\|master | sed -e "s/^\*//" -e "s/^ *//g" | uniq)); if [[ ${#d[@]} -gt 0 ]]; then echo ${d[@]} | xargs git branch -d; fi'
alias g.='git add . && gs'
alias ga='git add'
alias gac='git add . && git commit && gpu'
alias gad='git status -s | awk '"'"'{print $2}'"'"''
alias gb='git branch -a'
alias gback='git checkout -'
alias gc='git commit'
alias gca='git commit -a --amend -C HEAD'
alias gcb='f(){ git checkout bugfix/$1 2>/dev/null; git branch -u origin/bugfix/$1 bugfix/$1 >/dev/null; }; f'
alias gcd='git checkout develop'
alias gcf='f(){ git checkout feature/$1 2>/dev/null; git branch -u origin/feature/$1 feature/$1 >/dev/null; }; f'
alias gch='f(){ git checkout hotfix/$1 2>/dev/null; git branch -u origin/hotfix/$1 hotfix/$1 >/dev/null; }; f'
alias gcm='git checkout master'
alias gcr='f(){ git checkout release/$1 2>/dev/null; git branch -u origin/release/$1 release/$1 >/dev/null; }; f'
alias gcs='f(){ git checkout support/$1 2>/dev/null; git branch -u origin/support/$1 support/$1 >/dev/null; }; f'
alias gd='git diff'
alias gf='git fetch'
alias gh='git help'
alias gha='git help -a'
alias ghash='git branch --contains'
alias gitcred='git config --global credential.helper "store --file ~/.git-credentials"'
alias gld='git show'
alias glf='git log --name-only'
alias glg='git log --oneline --graph --decorate'
alias gmm='git merge master'
alias gp='git pull'
alias gps='gpu'
alias gr='git checkout -- .'
alias greset='gr && grm'
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
alias restore='git stash pop'
alias stash='git stash'
alias uncommit='git reset HEAD^'
alias wip='git commit -am "WIP"'

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

# Git Diff a File/Dir
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
  echo "start: $start | end: $end"
  git diff HEAD~$start HEAD~$end "$1"
}

# Set up (or fix) Git Flow
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


# Check to see if there are new commits on the current branch
function check() {

  # Check if in a git repo
  git status &>/dev/null
  test $? -ne 0 && printf "Not a git repo\n" && return 1

  # Fetch latest commits from git remote
  printf "\n${details}Checking for latest git changes...$n"
  git fetch &>/dev/null
  test $? -ne 0 && printf "\rFailed to check for updates from the git repo.\n\n" && return 1

  # Define variables
  local header="\e[1m\e[32m"
  local message="\e[1m\e[36m"
  local details="\e[33m"
  local n="\e[m" # Reset to normal
  local s=$'\x01' # Obscure ASCII character as a separator
  local counter=-1
  local show_previous=3
  local git_log_format="%h$s%cr$s%cd$s%s$s%an"
  local git_branch=$(git branch | grep '*' | cut -d' ' -f2)
  local not_yet_pulled="$(git log HEAD..origin/$git_branch --date=default --pretty=format:"$git_log_format" --decorate=full)"
  local local_commits="$(git log --date=default --pretty=format:"$git_log_format")"
  local count_available=$(echo -n "$not_yet_pulled" | grep -c '^')
  local output=$(printf "Timeline${s}Hash${s}Committed${s}Author${s}Commit Message$n\n\n")
  test $count_available -eq 1 && local is_or_are="is" || local is_or_are="are"

  # Display status line
  printf "\rThere $is_or_are $message$count_available$n new updates available on the $message$git_branch$n branch which can be pulled.\n\n$header"

  # Function to display a single line with the proper formatting
  print_git_log() {
    test -z "$1" && return
    if [[ $counter -eq 0 ]]; then
      local marker="Current"
    elif [[ $counter -lt 0 ]]; then
      local marker="Newer ▲"
    else
      local marker="Older ▼"
    fi
    IFS="$s" read -r -a column <<< "$1"
    local hash="${column[0]}"
    local committed="${column[1]}"
    local commit_msg="${column[3]}"
    local author="${column[4]}"
    output="$(printf "$output\n" && printf "%s$s%s$s%s$s%s$s%s\n\n" "$marker" "$hash" "$committed" "$author" "$commit_msg")"
  }

  # Display not yet pulled commits
  while read line; do
    print_git_log "$line"
  done <<< "$not_yet_pulled"

  # Display local commits
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

# Display Git Alias Menu
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

# Warn user if a given alias previously exists
function alias_check() {
  alias "$1" &>/dev/null
  if [[ $? -eq 0 ]]; then
    printf "Warning you have an alias defined for $1 which conflicts with GitPrompt\n"
    printf "Your alias will remain so the GitPrompt shortcut will not work.\n\n"
  fi
}

# Display the last commit (or last n commits) with a summary of the file(s) modified
alias_check glast
function glast() {
  if [[ $1 -gt 0 ]]; then
    local count_prev=" -n $1"
  fi
  git show --stat=$(tput cols) --compact-summary $count_prev
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

alias_check gurl
function gurl() {
  local remote="$(git remote -v | head -n1 | awk '{print $2}')"
  if [[ "${remote:0:4}" != "http" ]]; then
    remote="https://$(echo "${remote:4}" | sed '0,/:/s//\//')"
  fi
  echo "$remote" | sed -e 's/\.git//'
}

alias_check swap_remote
function swap_remote() {
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
  printf "Done\n\nYour new remotes are:\n"
  git remote -v
}
