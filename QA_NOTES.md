# QA Notes

## Project goal

The goal of this project is to verify selected GitHub REST API responses using a small smoke test suite.

The test suite checks both positive and negative API scenarios.

## Positive scenario

Endpoint:

GET /repos/darkdatastream/nyc-yellow-taxi-cleanup

Expected result:

- HTTP status code is 200
- JSON field `name` equals `nyc-yellow-taxi-cleanup`
- JSON field `full_name` equals `darkdatastream/nyc-yellow-taxi-cleanup`
- JSON field `private` equals `false`
- JSON field `default_branch` exists
- Rate limit headers are present

## Negative scenario

Endpoint:

GET /repos/darkdatastream/this-repo-should-not-exist-123456

Expected result:

- HTTP status code is 404
- JSON field `message` equals `Not Found`

## Important learning point

A JSON boolean value `false` is valid data.

It should not be treated as missing or empty.

This was important when validating the GitHub API field:

    "private": false

## Rate limit handling

The script checks GitHub rate limit headers:

- `x-ratelimit-limit`
- `x-ratelimit-remaining`

The script also uses a delay between requests to avoid unnecessary load on the public API.
