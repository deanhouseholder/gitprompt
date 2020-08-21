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
| ↠             | Submodule: `/ParentDir (BranchName)` ↠ `/SubmoduleDir (BranchName)` |
| °              | Working copy is a detached head  `master°77d0149`                   |
| !GIT DIR       | In the `/.git/` directory                                           |
| !BARE REPO     | In a bare git repo                                                  |
| MERGING        | Repo in Merging status                                              |
| REBASING       | Repo in Rebasing status                                             |
| REVERTING      | Repo in Reverting status                                            |
| CHERRY-PICKING | Repo in Cherry-Picking status                                       |
| BISECTING      | Repo in Bisecting status                                            |



## Install

1) Clone the gitprompt repository under your home directory (typically ~/gitprompt)

2) Source the file once to test it out:

```shell
source ~/gitprompt/default-prompt.sh
```

3) If you're happy with the defaults, add this to one of your bash startup files: (`.bashrc`, `.bash_profile`, `.profile`)

```shell
echo "source ~/gitprompt/default-prompt.sh" >> ~/.bashrc
```

This will allow it to persist between logins.

4) If you prefer to modify the colors or appearance, copy the default-prompt.sh to custom-prompt.sh and edit that copy

```shell
cp ~/gitprompt/default-prompt.sh ~/gitprompt/custom-prompt.sh
```



## To-Do

- Support git subtrees
