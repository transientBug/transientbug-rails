transientBug API Documentation
=====================

## Authentication

The transientBug v1 API uses HTTPS and provides two methods to authenticate:

 - HTTP Basic Auth: `https://<email>:<password>@transientbug.ninja/api/v1/<method>`
 - Auth Tokens: `https://transientbug.ninja/api/v1/<method>?auth_token=<email>:<auth_token>`

You can find your API token on your [profile](/profile) page. Through this page
you can also regenerate your token, however this will invalidate your previous
API token.

Third Party tools should not be storing users passwords, and as such they
should only use the password to request the users API token through the profile
endpoint.

# Issues
Issues with the API should be reported on [Github](https://github.com/transientBug/transientbug-rails/issues).
