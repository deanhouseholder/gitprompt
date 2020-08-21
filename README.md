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

1) Clone the gitprompt repository under your home directory (typically `~/gitprompt`)

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

## Also Included:

### Git Shortcuts

Also included are a great collection of Git Shortcuts. See the [git-menu.md](git-menu.md) to see the full list. You can run `gm` at any time to see the full list of git shortcuts on your terminal.


### Bash Git Completion

This allows you to use the `tab` key to auto-fill many git options. For example you can type `git ` and press tab twice to display:
```
add               describe          mv                send-email
am                diff              notes             shortlog
apply             difftool          prune             show
archive           fetch             pull              show-branch
bisect            format-patch      push              sparse-checkout
blame             fsck              range-diff        stage
branch            gc                rebase            stash
bundle            gitk              reflog            status
checkout          grep              remote            submodule
cherry            gui               repack            switch
cherry-pick       help              replace           tag
citool            init              request-pull      whatchanged
clean             instaweb          reset             worktree
clone             log               restore
commit            merge             revert
config            mergetool         rm
```

And then if type `git remote ` and press tab twice to display:
```
add            get-url        prune          remove         rename
set-branches   set-head       set-url        show           update
```

And finally you can type `git remote add ` and press tab twice to autofill `origin`.


## To-Do

- Support git subtrees
