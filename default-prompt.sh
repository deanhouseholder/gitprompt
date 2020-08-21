# Include the Git Prompt functions and aliases
script_path="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
. "$script_path/git-prompt.sh"
. "$script_path/git-shortcuts.sh"
. "$script_path/git-completion.bash"

# Function to shorten the directory
function shorten_pwd {
  test ${#PWD} -gt 40 && pwd | awk -F/ '{print "/"$2"/["(NF-4)"]/"$(NF-1)"/"$NF}' || pwd
}

function show_prompt {
  # Define Colors for non-git part of prompt
  local fgr="$(fg 253)"      # FG: White
  local root_bg="$(bg 130)"  # BG: Orange
  local user_bg="$(bg 24)"   # BG: Blue
  local dir_bg="$(bg 236)"   # BG: Dark Gray
  local host_bg="$(bg 30)"   # BG: Blue-Green
  local N="$(norm)"          # Reset styles
  local bg_color user

  # To customize the hostname, run: echo my-custom-hostname > ~/.displayname
  test -f ~/.displayname && host="$(cat ~/.displayname)" || host="$(hostname)"

  # Determine if user is root or not
  test $UID -eq 0 && bg_color="$root_bg" || bg_color="$user_bg"

  # Get username
  test -z "$USER" && user="$(whoami)" || user="$USER"

  # Set prompt
  export PS1="$fgr$bg_color $user $fgr$host_bg $host $fgr$dir_bg \$(shorten_pwd) $(git_prompt)➤ $N"
}

# Run this function every time the prompt is displayed to update the variables
PROMPT_COMMAND="show_prompt"

# Run the function once to pre-load variables
show_prompt
