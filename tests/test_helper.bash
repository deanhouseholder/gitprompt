#!/usr/bin/env bash
# Shared helpers for the gitprompt test suite.
#
# Requirements: bats-core >= 1.5
#   Install: git clone https://github.com/bats-core/bats-core ~/.bats && ~/.bats/install.sh /usr/local
#   Or via apt (may be an older version): sudo apt install bats

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# Resolve a path to absolute (file:// URLs require absolute paths).
_abspath() { [[ "$1" = /* ]] && printf '%s' "$1" || printf '%s/%s' "$PWD" "$1"; }

# Initialise a git repo with a stable test identity and force branch=master.
_git_init() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.name  "Test User"
  git -C "$dir" config user.email "test@example.com"
  # Force branch name to master regardless of global init.defaultBranch setting.
  git -C "$dir" symbolic-ref HEAD refs/heads/master
}

# Stage and commit a file in an existing repo.
_git_commit() {
  local dir="$1" msg="${2:-Initial commit}"
  printf 'content\n' > "$dir/file.txt"
  git -C "$dir" add file.txt
  git -C "$dir" commit -q -m "$msg"
}

# Create a bare remote + a local clone with the first commit already pushed
# and the upstream tracking branch configured.
_make_remote_setup() {
  local local_dir remote_dir
  local_dir="$(_abspath "$1")"
  remote_dir="$(_abspath "$2")"
  git init -q --bare "$remote_dir"
  _git_init "$local_dir"
  git -C "$local_dir" remote add origin "file://$remote_dir"
  _git_commit "$local_dir"
  git -C "$local_dir" push -q origin master
  git -C "$local_dir" branch --set-upstream-to=origin/master master 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Repo factory functions
# Each function takes a target directory path as $1.
# Functions that need to return a sub-path print it to stdout.
# ---------------------------------------------------------------------------

make_clean_repo() {
  _git_init "$1"
  _git_commit "$1"
}

make_dirty_repo() {
  make_clean_repo "$1"
  printf 'dirty\n' >> "$1/file.txt"        # unstaged modification
}

make_staged_repo() {
  make_clean_repo "$1"
  printf 'staged\n' >> "$1/file.txt"
  git -C "$1" add file.txt
}

make_untracked_repo() {
  make_clean_repo "$1"
  printf 'untracked\n' > "$1/new_file.txt" # untracked file
}

make_no_remote_repo() {
  _git_init "$1"
  _git_commit "$1"
  # Intentionally no remote added.
}

make_ahead_repo() {
  _make_remote_setup "$1" "${1}.remote"
  printf 'local\n' >> "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Local commit not yet pushed"
}

make_behind_repo() {
  _make_remote_setup "$1" "${1}.remote"
  # Push an extra commit via a second clone, then fetch (without pulling) in the first.
  local other="${1}.other"
  git clone -q "file://${1}.remote" "$other" 2>/dev/null
  git -C "$other" config user.name  "Other User"
  git -C "$other" config user.email "other@example.com"
  printf 'remote\n' >> "$other/file.txt"
  git -C "$other" add file.txt
  git -C "$other" commit -q -m "Remote commit"
  git -C "$other" push -q origin master
  git -C "$1" fetch -q origin
}

make_diverged_repo() {
  make_behind_repo "$1"
  # Also add a local commit — now ahead AND behind.
  printf 'local diverge\n' >> "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Local diverging commit"
}

make_stashed_repo() {
  make_clean_repo "$1"
  printf 'unstaged\n' >> "$1/file.txt"
  git -C "$1" stash push -q -m "test stash"
}

make_detached_repo() {
  make_clean_repo "$1"
  local sha
  sha="$(git -C "$1" rev-parse HEAD)"
  git -C "$1" checkout -q "$sha" 2>/dev/null
}

make_tagged_repo() {
  make_clean_repo "$1"
  git -C "$1" tag v1.0
  git -C "$1" checkout -q v1.0 2>/dev/null
}

make_no_repo() {
  mkdir -p "$1"
}

# Prints the path to the ignored subdirectory (caller should cd there).
make_ignored_repo() {
  make_clean_repo "$1"
  mkdir -p "$1/ignored"
  printf 'ignored/\n' > "$1/.gitignore"
  git -C "$1" add .gitignore
  git -C "$1" commit -q -m "Add gitignore"
  printf '%s/ignored' "$1"
}

make_bare_repo() {
  git init -q --bare "$1"
}

# Prints the path to the .git directory (caller should cd there).
make_inside_git_dir() {
  make_clean_repo "$1"
  printf '%s/.git' "$1"
}

make_merging_repo() {
  _git_init "$1"
  printf 'original\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Initial"
  git -C "$1" checkout -q -b branch-a
  printf 'branch-a\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Branch A"
  git -C "$1" checkout -q master
  printf 'master\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Master change"
  # Conflicting merge leaves MERGE_HEAD.
  git -C "$1" merge --no-commit branch-a 2>/dev/null || true
}

make_rebasing_repo() {
  _git_init "$1"
  printf 'base\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Base"
  git -C "$1" checkout -q -b feature
  printf 'feature\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Feature"
  git -C "$1" checkout -q master
  printf 'master-conflict\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Master conflict"
  git -C "$1" checkout -q feature
  # Rebase onto master conflicts, leaving REBASE_HEAD / rebase-merge.
  git -C "$1" rebase master 2>/dev/null || true
}

make_reverting_repo() {
  _git_init "$1"
  printf 'v1\n' > "$1/file.txt"; git -C "$1" add file.txt; git -C "$1" commit -q -m "v1"
  printf 'v2\n' > "$1/file.txt"; git -C "$1" add file.txt; git -C "$1" commit -q -m "v2"
  printf 'v3\n' > "$1/file.txt"; git -C "$1" add file.txt; git -C "$1" commit -q -m "v3"
  # Reverting HEAD~1 (v2) conflicts with the v3 state, leaving REVERT_HEAD.
  git -C "$1" revert --no-commit HEAD~1 2>/dev/null || true
}

make_cherry_picking_repo() {
  _git_init "$1"
  printf 'base\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Base"
  git -C "$1" checkout -q -b source
  printf 'cherry\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Cherry"
  local cherry_sha
  cherry_sha="$(git -C "$1" rev-parse HEAD)"
  git -C "$1" checkout -q master
  printf 'conflict\n' > "$1/file.txt"
  git -C "$1" add file.txt
  git -C "$1" commit -q -m "Conflicting master change"
  # Cherry-pick conflicts, leaving CHERRY_PICK_HEAD.
  git -C "$1" cherry-pick "$cherry_sha" 2>/dev/null || true
}

make_bisecting_repo() {
  _git_init "$1"
  local i
  for i in 1 2 3 4 5; do
    printf 'content %s\n' "$i" > "$1/file.txt"
    git -C "$1" add file.txt
    git -C "$1" commit -q -m "Commit $i"
  done
  local first_sha
  first_sha="$(git -C "$1" rev-list --max-parents=0 HEAD)"
  # Start bisect — creates BISECT_LOG and checks out the midpoint commit.
  git -C "$1" bisect start  2>/dev/null
  git -C "$1" bisect bad HEAD 2>/dev/null
  git -C "$1" bisect good "$first_sha" 2>/dev/null
}

make_subtree_repo() {
  local dir="$1"
  _git_init "$dir"
  printf 'main\n' > "$dir/main.txt"
  git -C "$dir" add main.txt
  git -C "$dir" commit -q -m "Initial commit"
  local mainline_sha
  mainline_sha="$(git -C "$dir" rev-parse HEAD)"

  # Orphan branch simulates unrelated external history (what git subtree imports)
  git -C "$dir" checkout -q --orphan subtree-import
  git -C "$dir" rm -q -rf . 2>/dev/null
  mkdir -p "$dir/vendor/ext"
  printf 'external\n' > "$dir/vendor/ext/ext.txt"
  git -C "$dir" add .
  git -C "$dir" commit -q -m "External source"
  local split_sha
  split_sha="$(git -C "$dir" rev-parse HEAD)"

  # Merge back into master with the git-subtree trailer format
  git -C "$dir" checkout -q master
  git -C "$dir" merge --allow-unrelated-histories -q subtree-import \
    -m "$(printf 'Add vendor/ext\n\ngit-subtree-dir: vendor/ext\ngit-subtree-mainline: %s\ngit-subtree-split: %s\n' "$mainline_sha" "$split_sha")"
  git -C "$dir" branch -q -d subtree-import
}

make_submodule_repo() {
  local parent sub
  parent="$(_abspath "$1")"
  sub="${parent}_sub"

  # Create the standalone repo that will become the submodule
  _git_init "$sub"
  printf 'sub\n' > "$sub/sub.txt"
  git -C "$sub" add sub.txt
  git -C "$sub" commit -q -m "Sub initial"

  # Create the parent repo and register the submodule
  _git_init "$parent"
  printf 'parent\n' > "$parent/parent.txt"
  git -C "$parent" add parent.txt
  git -C "$parent" commit -q -m "Parent initial"
  git -c protocol.file.allow=always -C "$parent" submodule add "file://$sub" sub
  git -C "$parent" commit -q -m "Add submodule"

  # Populate the submodule working tree — mirrors what a fresh clone requires
  git -c protocol.file.allow=always -C "$parent" submodule update --init
}

make_nested_submodule_repo() {
  local parent sub subsub
  parent="$(_abspath "$1")"
  sub="${parent}_sub"
  subsub="${parent}_subsub"

  # Innermost standalone repo
  _git_init "$subsub"
  printf 'subsub\n' > "$subsub/subsub.txt"
  git -C "$subsub" add subsub.txt
  git -C "$subsub" commit -q -m "Subsub initial"

  # Middle repo — registers subsub as its submodule
  _git_init "$sub"
  printf 'sub\n' > "$sub/sub.txt"
  git -C "$sub" add sub.txt
  git -C "$sub" commit -q -m "Sub initial"
  git -c protocol.file.allow=always -C "$sub" submodule add "file://$subsub" subsub
  git -C "$sub" commit -q -m "Add subsub"
  git -c protocol.file.allow=always -C "$sub" submodule update --init

  # Top-level repo — registers sub (with its nested submodule) as its submodule
  _git_init "$parent"
  printf 'parent\n' > "$parent/parent.txt"
  git -C "$parent" add parent.txt
  git -C "$parent" commit -q -m "Parent initial"
  git -c protocol.file.allow=always -C "$parent" submodule add "file://$sub" sub
  git -C "$parent" commit -q -m "Add sub"
  git -c protocol.file.allow=always -C "$parent" submodule update --init --recursive
}

make_nested_subtree_repo() {
  local dir="$1"

  # Build the outer subtree first (vendor/ext)
  make_subtree_repo "$dir"
  local mainline_sha
  mainline_sha="$(git -C "$dir" rev-parse HEAD)"

  # Add an inner subtree at vendor/ext/lib using the same orphan-merge technique
  git -C "$dir" checkout -q --orphan inner-subtree-import
  git -C "$dir" rm -q -rf . 2>/dev/null
  mkdir -p "$dir/vendor/ext/lib"
  printf 'lib\n' > "$dir/vendor/ext/lib/lib.txt"
  git -C "$dir" add .
  git -C "$dir" commit -q -m "Inner lib source"
  local lib_split_sha
  lib_split_sha="$(git -C "$dir" rev-parse HEAD)"

  git -C "$dir" checkout -q master
  git -C "$dir" merge --allow-unrelated-histories -q inner-subtree-import \
    -m "$(printf 'Add vendor/ext/lib\n\ngit-subtree-dir: vendor/ext/lib\ngit-subtree-mainline: %s\ngit-subtree-split: %s\n' "$mainline_sha" "$lib_split_sha")"
  git -C "$dir" branch -q -d inner-subtree-import
}
