# Class cGoogleComms



## Description

Handles all the comms with google.  This is intended to be a private library for use by those classes.  All other google classes extend this one.



### Usage Quota And Rate Limiting

There are usage limits for the frequency of calls to the apis.  [In spreadsheets, for example, you can by default make 100 API calls in 100 seconds per user, with a default max of 500 total calls in 100 seconds](https://developers.google.com/sheets/api/limits).  You can request a quota increase, but there is no guarantee you will receive it.  As a result, the API will attempt to cope by using [exponential-backoff](https://en.wikipedia.org/wiki/Exponential_backoff).  

Attempt | Wait Before Sending
--|--
1 | 0 sec.
2| 1 tick (1/60 second)
3| 3 ticks (1/20 second)
4| 7 ticks (1/8 second)
5| 15 ticks (1/4 second)
6| 31 ticks (1/2 second)
7| 63 ticks (1 second)
8| 127 ticks (2 seconds)
9| 255 ticks (4-1/4 seconds)
10| 511 ticks (8.5 seconds)
11 | 1023 ticks (17 seconds)
12 | **429 error returned** 

Note that because we are dealing with a rate limit, instead of making the wait random, we increase it from 0 for each attempt.

* [Spreadsheet Quota](https://developers.google.com/sheets/api/limits)



## Constructor Parameters

|Name|Datatype|Required|Default|Description|
|--|--|--|--|--|
| Connection Method<br/>***Not Implemented Yet*** | Text | No | **native** | **native** - use 4D's HTTP methods<br/>**curl** - use [libCurl plugin](https://github.com/miyako/4d-plugin-curl-v2)<br/>**ntk** - use [ntk plugin](https://www.pluggers.nl/product/ntk-plugin/) |



## Constructor Example

```4d
C_OBJECT(oComms)
If (OB Is empty (oComms))
	oComms:=cs.cGoogleComms.new("native")
End if
```


## Internal API
As this is inended to be private and extended by other google classes, the API is also "internal", i.e. not intended for use outside of the google library

### \_http ( httpMethod:longint ; url:TEXT ; body: text header:object) -> Object
Executes an http call and returns an object containing the server's response and the status returned from the server.  The idea is to enable support for libCurl, ntk, or native 4D http calls by wrapping all of it.

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|httpMethod|Yes|String|Required|One of 4D's *http* constants, e.g.<br>*HTTP DELETE method*<br>*HTTP GET method*<br>*HTTP HEAD method*<br>*HTTP OPTIONS method*<br>*HTTP POST method*<br>*HTTP PUT method*<br>*HTTP TRACE method*|
|url|Yes|Text|Required|URL to use|
|body|No|Text|(empty)|The body of the request.|
|header|Yes|Object|Required|The *auth.access.header* object obtained from *getAccess()* from a *cGoogleComms* object|



### Return Object

```
.request: text <http method> <url> <body>
.status : numeric code returned
.value  : message returned
```

If there is an error, **.value** will contain an error object

```
.request			 : string <http method> <url> <body>
.status        : integer (e.g. 404)
.value
   .error
      .code    : integer (e.g. 404)
      .message : text response from the server
      .status  : interprets the code
```

In some cases, **.error** might also contain a collection, **.details** (e.g. when you have a syntax error).  Then the object looks something like this:

```
.request			 								 : string <http method> <url> <body>
.value
   .error
      .code                    : integer (e.g. 400)
      .details                 : (collection)
         [0..n]
            .@type :           : text describing the error, (e.g. type.googleapis.com/google.rpc.BadRequest)
            .fieldViolations   : (collection)
               [0..n]
                  .description : text message describing the error
                  .field       : the field, e.g. requests[0]
      .message                 : text response from the server
      .status                  : interprets the code
```



### \_URL_Escape ( textToEscape : TEXT ) -> TEXT

url-escapes text that will be used in a url that might contain special characters that will break the url, like `/`, `<`, `%`, etc.



#### Example

```4d
$x := Super._URL_Escape ($sheetName)
```



## Reference

https://developers.google.com/sheets/api/limits

https://en.wikipedia.org/wiki/Exponential_backoff