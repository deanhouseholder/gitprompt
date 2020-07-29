## Bash Prompt Start

# Include the Git Prompt functions
script_path="$(cd $(dirname $BASH_SOURCE) && echo $(pwd))"
. "$script_path/gitprompt.sh"

# Customize the hostname if you prefer
host=$(hostname)

# Function to shorten the directory
function shorten_pwd {
  test ${#PWD} -gt 40 && pwd | awk -F/ '{print "/"$2"/["(NF-4)"]/"$(NF-1)"/"$NF}' || pwd
}

function show_prompt {
  ## Define Colors
  local fgr="$(fg 253)"                       # FG: White
  local root_bg="$(bg 130)"                   # BG: Orange
  local user_bg="$(bg 24)"                    # BG: Blue
  local dir_bg="$(bg 236)"                    # BG: Dark Gray
  local host_bg="$(bg 30)"                    # BG: Blue-Green
  local N="\[\e[0m\]"                         # Reset styles

  ## Determine if user is root or not
  test $UID -eq 0 && bg_color='root_bg' || bg_color='user_bg'

  test -z "$USER" && export USER=$(whoami)
  export prefix="$fgr${!bg_color} $USER $fgr"
  if [[ "$host" != "" ]]; then
    prefix+="$host_bg $host $fgr"
  fi
  prefix+="$dir_bg "
  export suffix="> $N"
  export PS1="$prefix\$(shorten_pwd) $(git_prompt)$suffix"
}

# Run this function every time the prompt is displayed to update the variables
PROMPT_COMMAND="show_prompt"

# Run the function once to pre-load variables
show_prompt

## Bash Prompt End

