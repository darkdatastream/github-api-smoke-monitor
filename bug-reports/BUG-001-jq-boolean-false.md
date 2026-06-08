# BUG-001: Boolean false was incorrectly treated as an empty value

## Environment

- Tool: Bash script
- API: GitHub REST API
- JSON parser: jq
- Endpoint: GET /repos/darkdatastream/nyc-yellow-taxi-cleanup

## Summary

The test initially failed when validating whether the repository was public.

The API returned:

    "private": false

However, the script treated this value as empty.

## Steps to reproduce

1. Send a GET request to the GitHub repository endpoint.
2. Read the `private` field from the JSON response.
3. Use jq fallback logic with `// empty`.
4. Compare the result with the expected value `false`.

## Expected result

The script should read:

    false

and pass the repository visibility test.

## Actual result

The script returned an empty value:

    private=

and failed the test.

## Root cause

The jq fallback operator `// empty` treated the boolean value `false` as a fallback case.

Original logic:

    repo_private="$(jq -r '.private // empty' "$BODY_FILE")"

## Fix

Read the boolean value directly:

    repo_private="$(jq -r '.private' "$BODY_FILE")"

## Result after fix

The repository visibility test passed correctly.

## QA lesson

A boolean `false` is valid data, not missing data.

API tests should handle booleans carefully and should not confuse `false`, `null`, empty strings and missing fields.
