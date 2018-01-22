transientBug API Documentation
=====================

# v1 API

## Introduction

The v1 API tries to conform to [JSON-API v1.0](http://jsonapi.org/format/1.0/) format.

Exceptions:

 * [Sparse fieldsets](http://jsonapi.org/format/1.0/#fetching-sparse-fieldsets) are not supported

Additionally, this document is generated from acceptance tests using
[JSON Schemas](http://json-schema.org/) so it should always be up to date with
the current API.

## Authentication

The transientBug v1 API uses HTTPS and provides two methods to authenticate,
modeled off of the [Pinboard v1 API](https://pinboard.in/api/) with the
intention of trying to be easy to use and develop against:

 - [HTTP Basic
   Auth](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme):
   `https://<email>:<password>@transientbug.ninja/api/v1/<method>`
 - Query String Auth Tokens:
   `https://transientbug.ninja/api/v1/<method>?auth_token=<email>:<auth_token>`

The query string auth token can also be sent along in the JSON body for `POST`,
`PATCH` and `PUT` requests.

You can find your API token on your [profile](/profile) page. Through this page
you can also regenerate your token, however this will invalidate your previous
API token.

Third Party tools **should not** be storing users passwords, and as such they
should only use the password to request the users API token through the [profile
endpoint](/api/docs/#profiles-get).

# Issues
Issues with the API should be reported on
[Github](https://github.com/transientBug/transientbug-rails/issues). Please
check to make sure that the issue you are reporting does not already have an
issue created, as to help my sanity when managing them.
