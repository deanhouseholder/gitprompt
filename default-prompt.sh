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
  test ${#PWD} -gt 40 && pwd | awk -F/ '{print "/"$2"/["(NF-4)"]/"$(NF-1)"/"$NF}' || pwd
}

# Display the git prompt
function show_prompt {
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
  test $UID -eq 0 && bg_color="$root_bg" || bg_color="$user_bg"

  # Get username
  test -z "$USER" && user="$(whoami)" || user="$USER"

  # Determine if prompt is in a subshell from within vim
  local vim=$(test ! -z "$VIMRUNTIME" && printf "$vim_bg [in vim] ")

  # Set prompt
  export PS1="$fgr$bg_color $user $fgr$host_bg $prompt_host $fgr$vim$dir_bg $(shorten_pwd) $(git_prompt)➤ $N"

  # Restore "set -x" status if set
  if [[ $set_x == Y ]]; then
    set -x
  fi
}

# Run this function every time the prompt is displayed to update the variables
if [[ -z "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="show_prompt"
elif [[ ! "$PROMPT_COMMAND" =~ show_prompt ]]; then
  PROMPT_COMMAND="$PROMPT_COMMAND; show_prompt"
fi

# Run the function once to pre-load variables
show_prompt
