# Git Aliases
alias g='git'
alias gm='display_git_aliases'
alias gmenu='gm'
alias gh='git help'
alias gha='git help -a'
alias g.='git add . && gs'
alias ga='git add'
alias gac='git add . && git commit && git push'
alias gad='git status -s | awk '"'"'{print $2}'"'"''
alias gb='git branch -a'
alias gback='git checkout -'
alias gc='git commit'
alias gca='git commit -a --amend -C HEAD'
alias gcm='git checkout master'
alias gcd='git checkout develop'
alias gcb='f(){ git checkout bugfix/$1 2>/dev/null; git branch -u origin/bugfix/$1 bugfix/$1 >/dev/null; }; f'
alias gcf='f(){ git checkout feature/$1 2>/dev/null; git branch -u origin/feature/$1 feature/$1 >/dev/null; }; f'
alias gch='f(){ git checkout hotfix/$1 2>/dev/null; git branch -u origin/hotfix/$1 hotfix/$1 >/dev/null; }; f'
alias gcr='f(){ git checkout release/$1 2>/dev/null; git branch -u origin/release/$1 release/$1 >/dev/null; }; f'
alias gcs='f(){ git checkout support/$1 2>/dev/null; git branch -u origin/support/$1 support/$1 >/dev/null; }; f'
alias gd='git diff'
alias gf='git fetch'
alias ghash='git branch --contains'
alias gitcred='git config --global credential.helper "store --file ~/.git-credentials"'
alias gl='git log --graph --decorate'
alias glg='git log --oneline --graph --decorate'
alias gla='git log --oneline --all --source --decorate=short'
alias gld='git show'
alias glf='git log --name-only'
alias glast='git show --stat=$(tput cols) --compact-summary'
alias gp='git pull'
alias gps='git push'
alias gr='git checkout -- .'
alias grm='gad | xargs rm -r 2>/dev/null'
alias greset='gr && grm'
alias grh='git reset --hard'
alias gum='git stash; git checkout master; git pull; git checkout -; git stash pop'
alias gs='clear && git status --ignore-submodules 2>/dev/null'
alias gsa='clear && git status 2>/dev/null'
alias gss='git submodule status 2>/dev/null'
alias gsu='git submodule update'
alias gu='git update-git-for-windows'
alias cleanup='d=($(git branch --merged | grep -Ev develop\|master | sed -e "s/^\*//" -e "s/^ *//g" | uniq)); if [[ ${#d[@]} -gt 0 ]]; then echo ${d[@]} | xargs git branch -d; fi'
alias branch='f(){ test -z "$1" && echo "No branch name given." && return; git checkout -b $1 2>/dev/null || git checkout $1; git branch -u origin/$1 $1 2>/dev/null; gp; git push --set-upstream origin $1; }; f'
alias renamebranch='git branch -m'
alias stash='git stash'
alias restore='git stash pop'
alias wip='git commit -am "WIP"'


# Git Diff a File/Dir
gdf() {
  if [[ -z "$1" ]]; then
    printf "\n\e[36mGit Diff a File (or Directory) between X commits ago and Y commits ago\e[0m\n\n"
    printf "\e[31mError: No inputs given.\e[0m\n\n"
    printf "\e[1;34mSyntax: gdf FILE [X commits ago] [Y commits ago]\e[0m\n\n"
    printf "Example: to see changes of a file between previous revision and current committed revision:\ngdf FILE 1 0\n\n"
    printf "Example: to see changes of a file between four commits ago and previous revision:\ngdf FILE 3 1\n\n"
    printf "Example: to use a wildcard, put it in single quotes:\ngdf 'customer*' 1 0\n\n"
    printf "Note: If X and Y values are ommitted, it will default to diff of previous version and current version.\n"
    printf "Note: It is recommended to be consistent between older commits for the X value and newer commits for\n"
    printf "      the Y value. Otherwise, it will appear as if the code written was deleted.\n\n"
    return
  fi
  local start end
  test -z "$2" && start=1 || start="$2"
  test -z "$3" && end=1 || end="$3"
  git diff HEAD~$2 HEAD~$3 "$1"
}


# Set up or Fix a git flow directory
gitflow() {
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


# Display Alias Menu
display_git_aliases() {

  repeat_string() {
    printf "%0.s$1" $(seq $2)
  }

  # Include the Git Prompt functions
  script_path="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"

  # Get Aliases from .md file passed in
  local title="Git Shortcuts Menu"
  local output="$(/bin/cat "$script_path/git-menu.md" | grep -E '^\|')"
  local first_line="$(echo "$output" | head -n1)"
  local width=$((${#first_line}+2))
  local padding=$((($width / 2) - 10))
  local bar="$(repeat_string '-' $width)"
  local header='\e[38;5;15m'
  local N='\e[0m'

  local help="$(echo "$output" | awk '{
    gsub("^\\| ([a-z\\[\\]][^ ]*)", "| \033[36m"$2"\033[37m");
    gsub("\\| Alias Name", "| \033[1;37mAlias Name\033[0;37m");
    gsub("\\| Description", "| \033[1;37mDescription\033[0;37m");
    gsub("\\|", " | ");
    print $0
  }')"

  printf "\n$(repeat_string ' ' $padding)$header$title$N\n"
  printf " +%s+\n%s\n +%s+\n\n" "$bar" "$help" "$bar"
}
