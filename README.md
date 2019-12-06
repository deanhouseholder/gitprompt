# BASH Git Prompt

## Description

BASH prompt function to support display of git branch name along with:
- 256 color support for both background and foreground
- Display branch name in different colors for dirty/clean statuses
- Display additional indicators for various git statuses:
  - Detects if you are in a git repo
  - Detects stashed code
  - Detects if you are ahead or behind the remote repo
  - Detects if no remotes defined
  - Detects submodule directories
  - Detects if in an ignored directory
  - Detects if you are in the .git directory
  - Detects Bare repo



## Symbol Key

| Symbol         | Key                                                                 |
|----------------|---------------------------------------------------------------------|
| §              | Stashed code exists in this working copy                            |
| «              | Working copy is currently behind remote repo                        |
| »              | Working copy is currently ahead of remote repo                      |
| ¤              | There are no remotes defined                                        |
| ↠              | Submodule: `/ParentDir (BranchName)` ↠ `/SubmoduleDir (BranchName)` |
| °              | Working copy is a detached head                                     |
| !GIT DIR       | In the `/.git/` directory                                           |
| !BARE REPO     | In a bare git repo                                                  |
| MERGING        | Repo in Merging status                                              |
| REBASING       | Repo in Rebasing status                                             |
| REVERTING      | Repo in Reverting status                                            |
| CHERRY-PICKING | Repo in Cherry-Picking status                                       |
| BISECTING      | Repo in Bisecting status                                            |



## Install

1) Download gitprompt.sh to your home directory

2) Add this to one of your bash startup files: (`.bashrc`, `.bash_profile`, `.profile`)

```bash
# Include the Git Prompt functions
. ~/gitprompt.sh

function show_prompt {
  export PS1="\u@\h \w $(git_prompt)> \[\e[0m\] "
}

# Run this function every time the prompt is displayed to update the variables
PROMPT_COMMAND="show_prompt"

# Run the function once to pre-load variables
show_prompt
```

3) Customize your prompt to your liking on the `export` line above.



## To-Do

- Support git subtrees
