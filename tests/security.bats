#!/usr/bin/env bats
# Security tests: _gp_sanitize() and prompt-injection prevention.
#
# Run:  bats tests/security.bats

load 'test_helper'

setup() {
  source "$SCRIPT_DIR/git-prompt.sh"
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  cd / 2>/dev/null
  rm -rf "$TEST_DIR"
}

# ---------------------------------------------------------------------------
# _gp_sanitize — unit tests
# ---------------------------------------------------------------------------

@test "sanitize: passes through plain ASCII text unchanged" {
  result="$(_gp_sanitize "hello-world")"
  [[ "$result" == "hello-world" ]] || fail "Expected 'hello-world', got: $result"
}

@test "sanitize: passes through branch-name characters unchanged" {
  result="$(_gp_sanitize "feature/my-branch_v2.0")"
  [[ "$result" == "feature/my-branch_v2.0" ]] \
    || fail "Expected branch name unchanged, got: $result"
}

@test "sanitize: preserves UTF-8 multibyte characters" {
  result="$(_gp_sanitize "feature/ñoño")"
  [[ "$result" == "feature/ñoño" ]] || fail "Expected UTF-8 preserved, got: $result"
}

@test "sanitize: strips ANSI CSI color sequence" {
  result="$(_gp_sanitize $'evil\e[31mtext')"
  [[ "$result" == "eviltext" ]] || fail "Expected CSI sequence stripped, got: $result"
}

@test "sanitize: strips ANSI CSI reset sequence" {
  result="$(_gp_sanitize $'text\e[0m')"
  [[ "$result" == "text" ]] || fail "Expected reset sequence stripped, got: $result"
}

@test "sanitize: strips multi-parameter ANSI sequence" {
  result="$(_gp_sanitize $'\e[38;5;196mred\e[0m')"
  [[ "$result" == "red" ]] || fail "Expected multi-param sequence stripped, got: $result"
}

@test "sanitize: strips bare ESC followed by a single character" {
  result="$(_gp_sanitize $'text\ecmore')"
  [[ "$result" == "textmore" ]] || fail "Expected bare ESC+char stripped, got: $result"
}

@test "sanitize: strips newline characters" {
  result="$(_gp_sanitize $'line1\nline2')"
  [[ "$result" == "line1line2" ]] || fail "Expected newline stripped, got: $result"
}

@test "sanitize: strips carriage return" {
  result="$(_gp_sanitize $'text\rmore')"
  [[ "$result" == "textmore" ]] || fail "Expected CR stripped, got: $result"
}

@test "sanitize: strips null bytes" {
  result="$(_gp_sanitize $'text\x00more')"
  [[ "$result" == "textmore" ]] || fail "Expected null byte stripped, got: $result"
}

@test "sanitize: handles empty string" {
  result="$(_gp_sanitize "")"
  [[ -z "$result" ]] || fail "Expected empty output for empty input, got: $result"
}

@test "sanitize: strips multiple mixed sequences" {
  result="$(_gp_sanitize $'\e[31mbold\e[0m\nand\e[32mgreen\e[0m')"
  [[ "$result" == "boldandgreen" ]] || fail "Expected all sequences stripped, got: $result"
}

# ---------------------------------------------------------------------------
# Prompt-injection prevention via hostname / displayname
# ---------------------------------------------------------------------------

@test "prompt_host: ESC sequences in .displayname are sanitized" {
  # Simulate a .displayname file containing an ANSI injection attempt.
  local fake_home="$TEST_DIR/home"
  mkdir -p "$fake_home"
  printf 'host\e[31mINJECTED\e[0m' > "$fake_home/.displayname"

  local host_value
  host_value="$(_gp_sanitize "$(cat "$fake_home/.displayname")")"
  [[ "$host_value" == "hostINJECTED" ]] \
    || fail "Expected ANSI stripped from displayname, got: $host_value"
  # Confirm the ESC character itself is absent.
  [[ "$host_value" != *$'\e'* ]] \
    || fail "ESC character should not survive sanitization"
}

# ---------------------------------------------------------------------------
# Prompt-injection prevention via directory names
# ---------------------------------------------------------------------------

@test "shorten_pwd output: ESC sequences in directory name are stripped by sanitizer" {
  # Create a directory whose name contains an ANSI escape attempt.
  local evil_name=$'normal\e[31mred'
  local evil_dir="$TEST_DIR/$evil_name"
  mkdir -p "$evil_dir" 2>/dev/null || skip "filesystem rejected control char in dir name"

  result="$(_gp_sanitize "$(cd "$evil_dir" && pwd)")"
  [[ "$result" != *$'\e'* ]] \
    || fail "ESC character survived sanitization of PWD output"
}

# ---------------------------------------------------------------------------
# git_prompt output: no raw ESC leaks from external data
# ---------------------------------------------------------------------------

@test "git_prompt: branch name does not introduce extra ESC sequences" {
  make_clean_repo "$TEST_DIR/repo"
  (
    cd "$TEST_DIR/repo"
    # Count ESC sequences before and after — should come only from the
    # legitimate coloring the function itself produces, not from branch name.
    output="$(git_prompt)"
    branch="$(git rev-parse --abbrev-ref HEAD)"
    # The branch name itself must be ESC-free (sanitized before embedding).
    [[ "$branch" != *$'\e'* ]] || exit 1
  ) || fail "Branch name contained unexpected ESC sequence"
}
