#!/usr/bin/env bats
# Tests for git_prompt() and _git_display_branch() in git-prompt.sh
#
# Run:  bats tests/git_prompt.bats
#       bats tests/           (run all test files)

load 'test_helper'

setup() {
  source "$SCRIPT_DIR/git-prompt.sh"
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  cd / 2>/dev/null
  rm -rf "$TEST_DIR" "${TEST_DIR}"* 2>/dev/null
}

# Run git_prompt from a specific directory and return its output.
prompt_in() { (cd "$1" && git_prompt); }

# Color-code helpers (match against the ANSI codes embedded in PS1 output).
is_clean()   { [[ "$1" == *"38;5;46"*  ]]; }  # green  fg 46
is_dirty()   { [[ "$1" == *"38;5;196"* ]]; }  # red    fg 196
is_ignored() { [[ "$1" == *"38;5;240"* ]]; }  # gray   fg 240

# ---------------------------------------------------------------------------
# Basic repo states
# ---------------------------------------------------------------------------

@test "no git repo: produces no output" {
  make_no_repo "$TEST_DIR/plain"
  result="$(prompt_in "$TEST_DIR/plain")"
  [[ -z "$result" ]] || fail "Expected empty output outside any git repo, got: $result"
}

@test "clean repo: shows branch name" {
  make_clean_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"master"* ]] || fail "Expected 'master' in: $result"
}

@test "clean repo: shows green color" {
  make_clean_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  is_clean "$result" || fail "Expected green (clean) color in: $result"
}

@test "dirty repo (unstaged): shows red color" {
  make_dirty_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  is_dirty "$result" || fail "Expected red (dirty) color in: $result"
}

@test "dirty repo (staged): shows red color" {
  make_staged_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  is_dirty "$result" || fail "Expected red (dirty) color for staged changes in: $result"
}

@test "dirty repo (untracked file): shows red color" {
  make_untracked_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  is_dirty "$result" || fail "Expected red (dirty) color for untracked file in: $result"
}

# ---------------------------------------------------------------------------
# Remote / upstream states
# ---------------------------------------------------------------------------

@test "no remote defined: shows no-remote marker ¤" {
  make_no_remote_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"¤"* ]] || fail "Expected ¤ (no-remote marker) in: $result"
}

@test "ahead of remote: shows ↑ with count" {
  make_ahead_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"↑1"* ]] || fail "Expected ↑1 (ahead indicator) in: $result"
}

@test "behind remote: shows ↓ with count" {
  make_behind_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"↓1"* ]] || fail "Expected ↓1 (behind indicator) in: $result"
}

@test "diverged from remote: shows both ↓ and ↑" {
  make_diverged_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"↓"* ]] || fail "Expected ↓ (behind) in diverged prompt: $result"
  [[ "$result" == *"↑"* ]] || fail "Expected ↑ (ahead) in diverged prompt: $result"
}

# ---------------------------------------------------------------------------
# Stash
# ---------------------------------------------------------------------------

@test "stashed changes: shows § marker" {
  make_stashed_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"§"* ]] || fail "Expected § (stash marker) in: $result"
}

@test "stashed changes: working tree is clean so shows green" {
  make_stashed_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  is_clean "$result" || fail "Expected green color after stash (clean worktree) in: $result"
}

# ---------------------------------------------------------------------------
# Detached HEAD / tags
# ---------------------------------------------------------------------------

@test "detached HEAD: shows HEAD° prefix" {
  make_detached_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"HEAD°"* ]] || fail "Expected HEAD° prefix in detached state: $result"
}

@test "checked-out tag: shows TAG: prefix" {
  make_tagged_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"TAG:v1.0"* ]] || fail "Expected TAG:v1.0 in: $result"
}

# ---------------------------------------------------------------------------
# Special repository types
# ---------------------------------------------------------------------------

@test "inside .git directory: shows !GIT DIR" {
  local git_dir
  git_dir="$(make_inside_git_dir "$TEST_DIR/repo")"
  result="$(prompt_in "$git_dir")"
  [[ "$result" == *"!GIT DIR"* ]] || fail "Expected '!GIT DIR' when inside .git dir, got: $result"
}

@test "bare repository: shows !BARE REPO" {
  make_bare_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"!BARE REPO"* ]] || fail "Expected '!BARE REPO' for bare repo, got: $result"
}

@test "ignored directory: shows gray color" {
  local ignored_dir
  ignored_dir="$(make_ignored_repo "$TEST_DIR/repo")"
  result="$(prompt_in "$ignored_dir")"
  is_ignored "$result" || fail "Expected gray (ignored) color in: $result"
}

# ---------------------------------------------------------------------------
# In-progress operations
# ---------------------------------------------------------------------------

@test "merge in progress: shows |MERGING" {
  make_merging_repo "$TEST_DIR/repo"
  [[ -f "$TEST_DIR/repo/.git/MERGE_HEAD" ]] || skip "merge conflict did not produce MERGE_HEAD"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"|MERGING"* ]] || fail "Expected '|MERGING' in: $result"
}

@test "rebase in progress: shows |REBASING" {
  make_rebasing_repo "$TEST_DIR/repo"
  local gd="$TEST_DIR/repo/.git"
  [[ -f "$gd/REBASE_HEAD" || -d "$gd/rebase-apply" || -d "$gd/rebase-merge" ]] \
    || skip "rebase conflict did not produce expected state files"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"|REBASING"* ]] || fail "Expected '|REBASING' in: $result"
}

@test "revert in progress: shows |REVERTING" {
  make_reverting_repo "$TEST_DIR/repo"
  [[ -f "$TEST_DIR/repo/.git/REVERT_HEAD" ]] || skip "revert did not produce REVERT_HEAD"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"|REVERTING"* ]] || fail "Expected '|REVERTING' in: $result"
}

@test "cherry-pick in progress: shows |CHERRY-PICKING" {
  make_cherry_picking_repo "$TEST_DIR/repo"
  [[ -f "$TEST_DIR/repo/.git/CHERRY_PICK_HEAD" ]] || skip "cherry-pick did not produce CHERRY_PICK_HEAD"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"|CHERRY-PICKING"* ]] || fail "Expected '|CHERRY-PICKING' in: $result"
}

@test "bisect in progress: shows |BISECTING" {
  make_bisecting_repo "$TEST_DIR/repo"
  [[ -f "$TEST_DIR/repo/.git/BISECT_LOG" ]] || skip "bisect did not produce BISECT_LOG"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" == *"|BISECTING"* ]] || fail "Expected '|BISECTING' in: $result"
}

# ---------------------------------------------------------------------------
# Subtrees
# ---------------------------------------------------------------------------

@test "inside subtree directory: shows ⊂ with path" {
  make_subtree_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo/vendor/ext")"
  [[ "$result" == *"⊂vendor/ext"* ]] || fail "Expected ⊂vendor/ext in: $result"
}

@test "at repo root with subtree present: no ⊂ indicator" {
  make_subtree_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo")"
  [[ "$result" != *"⊂"* ]] || fail "Expected no ⊂ at repo root, got: $result"
}

@test "inside nested subtree: shows most-specific ⊂ path" {
  make_nested_subtree_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo/vendor/ext/lib")"
  [[ "$result" == *"⊂vendor/ext/lib"* ]] \
    || fail "Expected ⊂vendor/ext/lib (deepest match), got: $result"
}

@test "inside outer subtree with nested subtree present: shows outer ⊂ path" {
  make_nested_subtree_repo "$TEST_DIR/repo"
  result="$(prompt_in "$TEST_DIR/repo/vendor/ext")"
  [[ "$result" == *"⊂vendor/ext"* ]] \
    || fail "Expected ⊂vendor/ext when in outer subtree, got: $result"
  [[ "$result" != *"⊂vendor/ext/lib"* ]] \
    || fail "Expected no inner subtree path when not inside it, got: $result"
}

# ---------------------------------------------------------------------------
# Submodules
# ---------------------------------------------------------------------------

@test "submodule setup: git submodule status shows populated submodule" {
  make_submodule_repo "$TEST_DIR/parent"
  # Verify the submodule is actually registered and its working tree is present
  status_out="$(git -C "$TEST_DIR/parent" submodule status 2>&1)"
  [[ "$status_out" == *"sub"* ]] \
    || fail "Expected 'sub' in git submodule status output: $status_out"
  [[ -f "$TEST_DIR/parent/sub/sub.txt" ]] \
    || fail "Expected sub/sub.txt to exist — submodule working tree not populated"
}

@test "inside submodule: shows parent and sub repo names with ↠ separator" {
  make_submodule_repo "$TEST_DIR/parent"
  result="$(prompt_in "$TEST_DIR/parent/sub")"
  [[ "$result" == *"↠"*     ]] || fail "Expected ↠ separator in submodule prompt: $result"
  [[ "$result" == *"parent"* ]] || fail "Expected parent repo name in: $result"
  [[ "$result" == *"sub"*    ]] || fail "Expected submodule name in: $result"
}

@test "inside submodule: shows branch name for each repo" {
  make_submodule_repo "$TEST_DIR/parent"
  result="$(prompt_in "$TEST_DIR/parent/sub")"
  branch_count="$(grep -o 'master' <<< "$result" | wc -l)"
  [[ "$branch_count" -ge 2 ]] \
    || fail "Expected at least 2 'master' branch names (one per repo) in: $result"
}

@test "nested submodule setup: git submodule status --recursive shows all levels" {
  make_nested_submodule_repo "$TEST_DIR/parent"
  status_out="$(git -C "$TEST_DIR/parent" submodule status --recursive 2>&1)"
  [[ "$status_out" == *"sub"*    ]] || fail "Expected 'sub' in recursive status: $status_out"
  [[ "$status_out" == *"subsub"* ]] || fail "Expected 'subsub' in recursive status: $status_out"
  [[ -f "$TEST_DIR/parent/sub/subsub/subsub.txt" ]] \
    || fail "Expected sub/subsub/subsub.txt — nested working tree not populated"
}

@test "inside nested submodule (3 levels): shows full chain with 2 ↠ separators" {
  make_nested_submodule_repo "$TEST_DIR/parent"
  result="$(prompt_in "$TEST_DIR/parent/sub/subsub")"
  separator_count="$(grep -o '↠' <<< "$result" | wc -l)"
  [[ "$separator_count" -ge 2 ]] \
    || fail "Expected at least 2 ↠ separators for 3-level nesting, got: $result"
  [[ "$result" == *"parent"* ]] || fail "Expected top-level repo name in: $result"
  [[ "$result" == *"sub"*    ]] || fail "Expected middle repo name in: $result"
  [[ "$result" == *"subsub"* ]] || fail "Expected deepest repo name in: $result"
}

@test "inside nested submodule (3 levels): shows branch info for all three repos" {
  make_nested_submodule_repo "$TEST_DIR/parent"
  result="$(prompt_in "$TEST_DIR/parent/sub/subsub")"
  # Each repo entry is wrapped in ( branch-info ) — count opening parens as a
  # proxy for "branch info was displayed for each repo in the chain".
  paren_count="$(grep -o '(' <<< "$result" | wc -l)"
  [[ "$paren_count" -ge 3 ]] \
    || fail "Expected branch info (in parens) for all 3 repos in chain, got: $result"
}
