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

## Issues

Issues with the API should be reported on
[Github](https://github.com/transientBug/transientbug-rails/issues). Please
check to make sure that the issue you are reporting does not already have an
issue created, as to help my sanity when managing them.

## Authentication

The transientBug v1 API uses HTTPS and provides several methods of
authentication, depending on the use case: Third Party Clients and Personal
Tools.

### Third Party Client OAuth2

Third Party Clients are defined as mass distributed clients, such as native
applications, browser extensions and web apps. For these clients, OAuth2
[Authorization Code Grant
flow](https://tools.ietf.org/html/rfc6749#section-4.1) is provided.

Developers can register new OAuth2 applications [here](/oauth/applications),
for now you'll need a minumum of a `name` and `redirect url` and will be
provided a `CLIENT_ID` and `CLIENT_SECRET` which you will use below.

To obtain an access token, first make a `GET` request to `/oauth/authorize`:

<pre>
/oauth/authorize?client_id=CLIENT_ID
  &redirect_uri=REDIRECT_URL
  &response_type=code
</pre>

where `CLIENT_ID` is the client ID provided when registering
the application, and `REDIRECT_URL` is the same redirect url you used when
registering the application.

On a successful call, this will redirect to the `REDIRECT_URL` with a `code` in
the query string. With that `code`, issue a `POST` to `/oauth/token`:

<pre>
/oauth/token?client_id=CLIENT_ID
  &client_secret=CLIENT_SECRET
  &code=RETURNED_CODE
  &grant_type=authorization_code
  &redirect_uri=REDIRECT_URL
</pre>

where `CLIENT_SECRET` is the value provided after registering your app, and
`RETURNED_CODE` is the `code` from the first requests redirect. A successful
request will return a JSON payload with an `access_token` key.

After this, you can begin using the API, with all requests containing the
`access_token` in an [Authorization
Bearer](https://tools.ietf.org/html/rfc6750) header: `Authorization: Bearer <access_token>`


### Personal Tools

For Personal Tools, small scale applications and other utilities developed for
personal use, two simple methods are provided, modeled off of the [Pinboard v1
API](https://pinboard.in/api/) with the intention of trying to be easy to use
and develop against:

 - [HTTP Basic
   Auth](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme):
   `https://<email>:<password>@transientbug.ninja/api/v1/<method>`
 - Query String API Tokens:
   `https://transientbug.ninja/api/v1/<method>?auth_token=<email>:<auth_token>`

The query string API token can also be sent along in the JSON body for `POST`,
`PATCH` and `PUT` requests.

You are encouraged to only use Basic Auth to grab the API token through the
profile endpoint, and should prefer to use the API token method everywhere
to avoid storing your password.

You can find your API token on your [profile](/profile) page. Through this page
you can also regenerate your token, however this will invalidate your previous
API token.


## Changes

### July, 2019
As of late July, 2019 the Bookmarks create endpoint no longer overwrites
existing bookmark data and will now respond with a 302 to the found bookmark.
