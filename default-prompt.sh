# Include the Git Prompt functions and aliases
script_path="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
. "$script_path/git-prompt.sh"
. "$script_path/git-shortcuts.sh"
. "$script_path/git-completion.bash"

# To customize the hostname, run: echo my-custom-hostname > ~/.displayname
if [[ -f ~/.displayname ]]; then
  export prompt_host="$(cat ~/.displayname)"
else
  export prompt_host="$(hostname)"
fi

# Function to shorten the directory
function shorten_pwd {
  [[ ${#PWD} -gt 40 ]] && pwd | awk -F/ '{print "/"$2"/["(NF-4)"]/"$(NF-1)"/"$NF}' || pwd
}

# Display the git prompt
function show_prompt {
  # Only in interactive terminals
  [[ -t 1 ]] || return

  # Check status of "set -x" xtrace mode
  # If xtrace mode is set, disable it for the prompt, and re-enable it afterwards
  [[ ${-//[^x]/} == "x" ]] && set_x=Y && set +x || set_x=N

  # Define colors for non-git part of prompt
  local fgr="$(gp_fg 253)"      # FG: White
  local root_bg="$(gp_bg 130)"  # BG: Orange
  local user_bg="$(gp_bg 24)"   # BG: Blue
  local dir_bg="$(gp_bg 236)"   # BG: Dark Gray
  local host_bg="$(gp_bg 30)"   # BG: Blue-Green
  local vim_bg="$(gp_bg 90)"    # BG: Purple
  local N="$(gp_norm)"          # Reset styles
  local bg_color user

  # Determine if user is root or not
  [[ $UID -eq 0 ]] && bg_color="$root_bg" || bg_color="$user_bg"

  # Get username
  [[ -z "$USER" ]] && user="$(whoami)" || user="$USER"

  # Determine if prompt is in a subshell from within vim
  local vim=$(test ! -z "$VIMRUNTIME" && printf "$vim_bg [in vim] ")

  # If previous command didn't include a new line, add one now
  # This command determines the current column and if it is not 1, then it prints a new line
  [[ $(IFS='[;' read -p $'\e[6n' -d R -rs _ ROW COL _ && echo "$COL") -ne 1 ]] && printf "\n"

  # Set prompt
  export PS1="$fgr$bg_color $user $fgr$host_bg $prompt_host $fgr$vim$dir_bg $(shorten_pwd) $(git_prompt)➤ $N"

  # Restore "set -x" status if set
  [[ $set_x == Y ]] && set -x
}

# Run this function every time the prompt is displayed to update the variables
if [[ -z "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="show_prompt"
elif [[ ! "$PROMPT_COMMAND" =~ show_prompt ]]; then
  PROMPT_COMMAND="$PROMPT_COMMAND; show_prompt"
fi

# Run the function once to pre-load variables
show_prompt
