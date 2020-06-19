﻿# Class cGoogleAuth

## Description
Manages the authorization and ongoing access with Google.
Extends the cGoogleComms class.
There should be a single *cGoogleAuth* object for your app, which will then be passed to other classes such as spreadsheets.

## Constructor Parameters


|Name|Datatype|Required|Default|Description|
|--|--|--|--|--|
|Username|Text|X|Required|Username to act on behalf of|
|Scopes|Text|X|Required|**Space-Delimited** scopes to use|
|Key|Text|X|Required|The text of the API key granted by Google|
|Connection Method|Text|**NOT IMPLEMENTED**|**native**|**native** - use 4D's HTTP methods<br>**curl** - use [libCurl plugin](https://github.com/miyako/4d-plugin-curl-v2)<br>**ntk** - use [ntk plugin](https://www.pluggers.nl/product/ntk-plugin/)

## Constructor Example

```4d
C_OBJECT(oGoogleAuth)
If (OB Is empty ($oGoogleAuth))
	$oGoogleAuth:=cs.cGoogleAuth.new($username;$scopes;$key;"native")
End if
```
## [Using Comms Across Multiple Objects Simultaneously](#using-comms-across-multiple-objects-simultaneously)
The *cGoogleComms* object is designed to be independent of other objects.  Before you create your other objects, you will create the cGoogleAuth object, and then pass it to each of your other objects.
When those objects wish to send a request to Google, they will obtain the current authorization information from the *cGoogleAuth* class to send with the request.  If the authorization/access information is stale or has expired, the object will refresh it before processing your request.
In the event that an access token expires unexpectedly, you can force the *cGoogleAuth* object to refresh the token.
To pass the authorization/access information to a class, simply use the name of the *cGoogleAuth* object.

#### Example: ####
```4d
$oGoogleAuth:=cs.cGoogleAuth.new($username;$scopes;$key;"native")
$oGoogleSpreadsheet:=cs.cGoogleSpreadsheet.new($oGoogleAuth;$url)
```


## API

### getHeader  ( {forceRefresh : boolean}) -> object
You should generally not need to call this function.  This is designed to be used inside of other Google objects.  Returns an object containing the authorization token information/header.  This is designed to be called as part of an *http* call to provide this information to Google.  If the token has expired or if **forceRefresh** is **true** then the function will refresh the token and the header with google.

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|forceRefresh|No|Boolean|False|Whether to force refresh even if the token has not expired (e.g. when an authorization error is returned by google|

## Internal Structure
#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### Internal Properties
Everything in parentheses is description
```raw
	access (object containing the access token data - what your code will use to talk to google)
		expiresAt: the seconds when the token will expire
		header (object containing the header information that will be sent with your calls to google)
			name:  "Authorization"
			value: "Bearer " + the encoded access token
		token (object containing the access token information as originally sent by google)
			access_token: the token data, used the suffix in auth.access.header.value
			expires_in:   seconds after token was issued that it will expire
			token_type:   the type of token, used as the prefix in auth.access.header.value
	bodyPrefix: encoded information sent to google when requesting the access token.  Held for future use/token renewal
	googleKey (object containg the google API key that was granted to the developer when the service account IAM was created)
		asString:                    raw value of the contents of the key, kept this way for easy sending and assignment to other objects
		auth_provider_x509_cert_url: url that generated the certs
		auth_url:                    url called to obtain the token
		client_email:                the iam for the service account
		client_id:                   the id of the service account
		client_x509_cert_url:        the certificate provider
		private_key:                 the private key assigned to the service account for the API
		private_key_id:              the id of the private key
		project_id:                  the id of the google cloud project
		token_url:                   URL used to generate the token
		type:                        usually "service_account" - type of account that is being used to access the API
	jwt (object describing the header being sent with the jwt when requesting the access token)
		header (object containing the fields in the header)
			name:  "Content-Type"
			value: "application/x-www-form-urlencoded"
	oHead (object containing the header information for the token request.  Stored this way so key renewal is easier)
		alg: "RS256"
		typ: "JWT"
	scoopes:  scopes the app is requesting to use
	url:		 url to call for the oauth2 request
```