# GitHub API Smoke Monitor

A lightweight API smoke test project using Bash, curl and jq.

This project validates real GitHub REST API responses for a public repository.
It checks HTTP status codes, selected JSON fields, basic response headers and a negative scenario.

## What this project tests

- Existing GitHub repository returns HTTP 200
- Missing repository returns HTTP 404
- Response body contains expected JSON fields
- Repository name and full name match expected values
- Repository visibility is public
- Default branch exists
- Rate limit headers are present
- Requests include a short delay to avoid unnecessary API load

## Tested API

GitHub REST API endpoints:

- GET https://api.github.com/repos/darkdatastream/nyc-yellow-taxi-cleanup
- GET https://api.github.com/repos/darkdatastream/this-repo-should-not-exist-123456

## Tools used

- Bash
- curl
- jq
- GitHub REST API

## How to run

Run:

    chmod +x run_tests.sh
    ./run_tests.sh

## Example result

    === Summary ===
    Passed: 9
    Failed: 0
    RESULT: ALL TESTS PASSED

## Why this project exists

This project is part of an API QA portfolio.

It demonstrates basic API smoke testing, response validation, negative testing and responsible handling of public API requests.

## QA notes

The project includes a real learning point from development:

A JSON boolean value `false` is valid data and should not be treated as missing or empty.

This mattered when validating the GitHub API field:

    "private": false

The test was fixed to read the boolean value directly instead of using fallback logic that treated `false` as empty.
