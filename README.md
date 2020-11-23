# 4d-google-workspace
A 4D project for accessing and working on your google workspace services.
This library assumes that you are using the [Service Account method of accessing Google Docs](https://developers.google.com/identity/protocols/oauth2#serviceaccount).  This technique allows your app to operate from a server, and have access to all google services for all accounds for your domain.
If you are trying to set up an app that will be for individual users and not an entire domain, you would use [one of several other configurations](https://developers.google.com/identity/protocols/oauth2#scenarios).

## Steps
1. [Setup your app in Google](https://github.com/macMikey/4d-google-docs/blob/master/README/1.%20Setup%20Google.md)
2. Download and install the [JWT plugin](https://github.com/miyako/4d-plugin-jwt) into your *Plugins* folder.  See the [README](https://github.com/miyako/4d-plugin-jwt/blob/master/README.md) for installation instructions.
3. Check out the `aTest` method for a very basic sample.


## Reference
- [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)
- [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/oauth2/service-account#httprest)
- [Control G Suite API access with domain-wide delegation](https://support.google.com/a/answer/162106)
- [API Quotas](https://developers.google.com/sheets/api/limits)

