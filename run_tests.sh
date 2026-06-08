#!/usr/bin/env bash

set -u

OWNER="darkdatastream"
REPO="nyc-yellow-taxi-cleanup"
API_BASE="https://api.github.com"

PASS_COUNT=0
FAIL_COUNT=0

TMP_DIR="$(mktemp -d)"
BODY_FILE="$TMP_DIR/body.json"
HEADERS_FILE="$TMP_DIR/headers.txt"

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

request() {
  local url="$1"

  curl -s \
    -D "$HEADERS_FILE" \
    -o "$BODY_FILE" \
    -w "%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "User-Agent: github-api-smoke-monitor" \
    "$url"
}

get_header() {
  local header_name="$1"

  grep -i "^$header_name:" "$HEADERS_FILE" | head -n 1 | awk -F': ' '{print $2}' | tr -d '\r'
}

echo "=== GitHub API Smoke Monitor ==="
echo
echo "Testing existing repository: $OWNER/$REPO"
echo

status="$(request "$API_BASE/repos/$OWNER/$REPO")"

if [ "$status" -eq 200 ]; then
  pass "existing repository returned HTTP 200"
else
  fail "expected HTTP 200 for existing repository, got $status"
fi

repo_name="$(jq -r '.name // empty' "$BODY_FILE")"
repo_full_name="$(jq -r '.full_name // empty' "$BODY_FILE")"
repo_private="$(jq -r '.private' "$BODY_FILE")"
default_branch="$(jq -r '.default_branch // empty' "$BODY_FILE")"

if [ "$repo_name" = "$REPO" ]; then
  pass "repo name is $REPO"
else
  fail "expected repo name $REPO, got $repo_name"
fi

if [ "$repo_full_name" = "$OWNER/$REPO" ]; then
  pass "full_name is $OWNER/$REPO"
else
  fail "expected full_name $OWNER/$REPO, got $repo_full_name"
fi

if [ "$repo_private" = "false" ]; then
  pass "repository is public"
else
  fail "expected repository to be public, got private=$repo_private"
fi

if [ -n "$default_branch" ]; then
  pass "default_branch exists: $default_branch"
else
  fail "missing default_branch"
fi

rate_limit="$(get_header "x-ratelimit-limit")"
rate_remaining="$(get_header "x-ratelimit-remaining")"

if [ -n "$rate_limit" ]; then
  pass "rate limit header exists: x-ratelimit-limit=$rate_limit"
else
  fail "missing x-ratelimit-limit header"
fi

if [ -n "$rate_remaining" ]; then
  pass "rate remaining header exists: x-ratelimit-remaining=$rate_remaining"
else
  fail "missing x-ratelimit-remaining header"
fi

sleep 1

echo
echo "Testing missing repository negative case"
echo

missing_status="$(request "$API_BASE/repos/$OWNER/this-repo-should-not-exist-123456")"

if [ "$missing_status" -eq 404 ]; then
  pass "missing repository returned HTTP 404"
else
  fail "expected HTTP 404 for missing repository, got $missing_status"
fi

message="$(jq -r '.message // empty' "$BODY_FILE")"

if [ "$message" = "Not Found" ]; then
  pass "missing repository response message is Not Found"
else
  fail "expected message 'Not Found', got '$message'"
fi

echo
echo "=== Summary ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"

rm -rf "$TMP_DIR"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "RESULT: ALL TESTS PASSED"
  exit 0
else
  echo "RESULT: SOME TESTS FAILED"
  exit 1
fi
