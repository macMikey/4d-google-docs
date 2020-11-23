# Class cGoogleSpreadsheet



## Description
Class for accessing and updating google sheets.

Extends *cGoogleComms*, **but** there should be at least one *cGoogleComms* object created separately that will be the "master".  Authorization header data should be copied from that object to the others.  Authorization headers should be checked periodically to see if they have expired or have been revoked, and then the new data shared after the authorization is renewed.



## Constructor Parameters

|Name|Datatype|Description|
|--|--|--|
|cGoogleAuth|object|Object obtained from a *cGoogleComms* class via **getAuthAccess** |
|URL|Text|The URL of the spreadsheet you want to work with|



## Constructor Example

```4d
C_OBJECT(s)
If (OB Is empty (s))
  s:=cs.cGoogleSpreadsheet.new(oGoogleComms;$url)
End if
```



## API

### duplicateSheet ( sourceSheetID:INTEGER ; insertSheetIndex:INTEGER ; {newSheetID:INTEGER} ; {newSheetName:Text} ) -> object

Implements [Batch Update](https://developers.google.com/sheets/api/guides/batchupdate) with a [Duplicate Sheet Request](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#duplicatesheetrequest) to duplicate a sheet

|Parameters|Required?|Datatype|Description|
|--|--|--|--|
|sourceSheetId|Yes|Integer|The sheet to duplicate.|
|insertSheetIndex|Yes|Integer|The zero-based index where the new sheet should be inserted. The index of all sheets after this are incremented.|
|newSheetId|No|Integer|If set, the ID of the new sheet. If not set, an ID is chosen. If set, the ID must not conflict with any existing sheet ID. If set, it must be non-negative.|
|newSheetName|No|Text|The name of the new sheet. If empty, a new name is chosen for you.|



#### Return object:

* If no matches are found for *sheetName*, **$0** will have the following structure:

  ```
  .success : False
  .message : "No match."
  .matches : Null
  ```

* If one match is found, the sheet will be duplicated, and **$0** will have the following structure, [including a sheetsProperties object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties):
 ```
  .success 										          : True
  .message 										          : ""
  .result 										          : (Object)
  	.status										          : http status (200)
  	.value									          	: (Object)
  		.replies							          	: (Collection)
  		   [0..n]
  		      .duplicateSheet	    	      : (Object)
  		         .properties	    	      : (Object)
  		            .gridProperties       : (Object)
  		               .columnCount       : integer
  		               .frozenColumnCount : integer
  		               .rowCount          : integer
  		            .index                : integer
  		            .sheetID							: integer
  		            .sheetType						: text (e.g. "GRID")
  		            .title								: text
  		.spreadsheetID                    : text
 ```


#### Example:

```4d
$s.duplicateSheet($sheetID;$index;;$part.Part_Number)
```



### findSheetWithName (sheetName:TEXT) -> collection

Returns a collection of sheet (tab) objects that have the name *sheetName*
[with the following properties](https://developers.google.com/sheets/api/samples/sheet#determine_sheet_id_and_other_properties)

```
.gridProperties    : object
   .rowCount       : number of rows
   .columnCount    : number of columns
   .frozenRowCount : number of frozen rows
.index             : integer - position of the sheet (tab) in the spreadsheet
.sheetID           : id used to reference the sheet
.sheetType         : (add when you find out)
.title             : name of the sheet
```



### getSheetNames () -> sheetNames : collection

1. Reloads all sheet data
2. Returns a collection with the names of the sheets (tabs) in the spreadsheet.

|Property|Description|
|--|--|
|length|0..n - number of values in the collection|
|0..(length-1)|Collection indicies start at 0 and run to `length-1`.  Each element in the collection is the name of a sheet (tab)|



### <a name="getValues"></a>getValues (range:TEXT {; majorDimension:TEXT ; valueRenderOption:TEXT ; dateTimeRenderOption:TEXT}) -> object

Implements [Spreadsheet.values.get](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get)

1. Reloads all cell values
2. Returns an object containing a [valueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange) from a spreadsheet. The caller must specify the spreadsheet ID and a range.

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|rangeString|Yes|Text|Yes|A range, in A1 format.  Only a single range may be entered.|
|majorDimension|No|Text|*DIMENSION_UNSPECIFIED*|*DIMENSION_UNSPECIFIED* - The default value, do not use.<br>*ROWS* - Operates on the rows of a sheet.<br>*COLUMNS* - Operates on the columns of a sheet *(as if it is transposed)*.|
|valueRenderOption|No|Text|*FORMATTED_VALUE*|*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return "$1.23".<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return the number 1.23.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return "=A1".|
|dateTimeRenderOption|No|Text|*SERIAL_NUMBER*| Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale).|

#### Return object:
The object contains a [valueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange)

|Field|Contents|Description|
|--|--|--|
|"range"|String|The range the values cover, in A1 notation. For output, this range indicates the entire requested range, even though the values will exclude trailing rows and columns. When appending values, this field represents the range to search for a table, after which values will be appended.|
|"majorDimension"|**ROWS**<br>**COLUMNS**|The major dimension of the values.  For output, if the spreadsheet data is: A1=1,B1=2,A2=3,B2=4, then requesting range=A1:B2,majorDimension=ROWS will return [[1,2],[3,4]], whereas requesting range=A1:B2,majorDimension=COLUMNS will return [[1,3],[2,4]].|
|"values"|array ([ListValue](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.ListValue) format)|The data that was read or to be written. This is an array of arrays, the outer array representing all the data and each inner array representing a major dimension. Each item in the inner array corresponds with one cell. For output, empty trailing rows and columns will not be included.|


#### Examples:
```4d
$oValues:=$ss.getValues("Sheet1!A1:B4")
```
```4d
$oValues:=$ss.getValues("Sheet1!A1:B2";"ROWS";"UNFORMATTED_VALUE";"FORMATTED_STRING")
```



### load ( { range:TEXT ; includeGridData:Boolean } ) -> Object

Implements [Spreadsheets.get](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get#body.QUERY_PARAMETERS.ranges)

Returns the spreadsheet at the given ID. The caller must specify the spreadsheet ID.
By default, data within grids will not be returned. You can include grid data one of two ways:
  1. Specify a field mask listing your desired fields using the fields URL parameter in HTTP
  2. Set the includeGridData URL parameter to true. If a field mask is set, the includeGridData parameter is ignored
For large spreadsheets, it is recommended to retrieve only the specific fields of the spreadsheet that you want.
To retrieve only subsets of the spreadsheet, use the ranges URL parameter. Multiple ranges can be specified. Limiting the range will return only the portions of the spreadsheet that intersect the requested ranges. Ranges are specified using A1 notation.

#### Parameters

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|range|No|Text|Null|A range, in A1 format.  Multiple ranges can be separated with commas|
|includeGridData|No|Boolean|False|Specify whether to include grid data|

#### Return Object
An object with the following fields:

|Fieldname|Description|
|--|--|
|status|http status.  *200* means success|
|value|If successful, the response body contains an instance of [Spreadsheet](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet).<br> If unsuccessful/error it will contain an error object.|

**value subfields (assuming success)**

|*value.*Fieldname|Type|Description|
|--|--|--|
|value.*spreadsheetId*|string|The ID of the spreadsheet.|
|value.*properties*|object|[Overall properties of a spreadsheet.](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#SpreadsheetProperties)|
|value.*sheets*|object|[The sheets that are part of a spreadsheet.](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#Sheet)|
|value.*namedRanges*|object|[The named ranges defined in a spreadsheet.](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#NamedRange)|
|value.*spreadsheetUrl*|string|The url of the spreadsheet.|
|value.*developerMetadata*|object|[The developer metadata associated with a spreadsheet.](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata#DeveloperMetadata)|

#### Examples
```4d
$oSheetData:=$ss.load("Sheet1") `This is a valid range for loading, but not for updating.
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```
```4d
$oResult:=$ss.load("Sheet1!A1:B2, Sheet2!B:B")
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If

```
```4d
$oResult:=$ss.load(;True)`This is a valid range for loading, but not for updating.
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If

```


### parseError()

Parses an (undocumented) Error Object as a multiple-line text variable

Currently, those lines are:
**Code:**
**Status:**
**Message:**

#### Example:
```4d
$oResult:=$ss.load("Sheet1")
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```



### setValues (range:TEXT ;  values:Object {;valueInputOption:TEXT ; includeValuesInResponse: Boolean ; responseValueRenderOption:TEXT; responseDateTimeRenderOption:TEXT}) -> Object
Implements [Spreadsheet.values.update](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update)

1. Updates the range with the *valuesObject* provided.  ***NOTE:  Existing values are not overwritten unless you specify a new value for a cell.***
2. If successful, the response body contains an instance of [UpdateValuesResponse](https://developers.google.com/sheets/api/reference/rest/v4/UpdateValuesResponse).

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|range|Yes|Text|Required|A range, in A1 format.  Only a single range may be entered.|
|valuesObject|Yes|Object|Required|*All fields in the value object are optional*<br>{<br>  "range": string,<br>  "majorDimension":  [Dimension](https://developers.google.com/sheets/api/reference/rest/v4/Dimension),<br>  "values": [array]<br>}|
|valueInputOption|Yes|Text|Required|How the input data should be interpreted. <br>*RAW* - The values the user has entered will not be parsed and will be stored as-is.<br>*USER_ENTERED* - The values will be parsed as if the user typed them into the UI. Numbers will stay as numbers, but strings may be converted to numbers, dates, etc. following the same rules that are applied when entering text into a cell via the Google Sheets UI.|
|includeValuesInResponse|No|Boolean|False|Determines if the update response should include the values of the cells that were updated. By default, responses do not include the updated values. If the range to write was larger than the range actually written, the response includes all values in the requested range (excluding trailing empty rows and columns).|
|responseValueRenderOption|No|Text|*FORMATTED_VALUE*|Determines how values in the response should be rendered.<br>*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return `"$1.23"`.<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return the number `1.23`.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then A2 would return `"=A1"`.|
|responseDateTimeRenderOption|No|Text|*SERIAL_NUMBER*| Determines how dates, times, and durations in the response should be rendered.  Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale).|

The *majorDimension* is specified in the body

#### Return Object
An object with the following fields:

|Fieldname|Description|
|--|--|
|status|http status.  *200* means success|
|value|If successful, it will contain an instance of [UpdateValuesResponse](https://developers.google.com/sheets/api/reference/rest/v4/UpdateValuesResponse) (see below).<br> If unsuccessful/error it will contain an error object.|

**value subfields (assuming success)**

|*value.*Fieldname|Type|Description|
|--|--|--|
|value.*spreadsheetId*|String|The spreadsheet the updates were applied to.|
|value.*updatedRange*|String|The range (in A1 notation) that updates were applied to.|
|value.*updatedRows*|Integer|The number of rows where at least one cell in the row was updated.|
|value.*updatedColumns*|Integer|The number of columns where at least one cell in the column was updated.|
|value.*updatedCells*|Integer|The number of cells updated.|
|value.*updatedData*|object ([ValueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange))|The values of the cells after updates were applied. This is only included if the request's includeValuesInResponse field was true.|

#### Examples
```4d
$oResult:=$ss.setValues("Sheet1!A1:B4";$oValues)
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```
```4d
$oResult:=$ss.setValues("Sheet1!A1:B2";$oValues;"USER_ENTERED";True;"UNFORMATTED_VALUE";"FORMATTED_STRING")
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```

```4d
$oResult:=$ss.setValues($ss.sheetData.range;$oValues;"USER_ENTERED";True;"UNFORMATTED_VALUE";"FORMATTED_STRING")  // can get the range from the sheetData.range property.
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```



## Internal Structure

#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### Internal Properties

|Field|Description|
|--|--|
|spreadsheetID|The part of the URL after /spreadsheets/d/|
|endpoint|the base url for the API to use|
|status|http status of the request|
|sheetData|the object returned from google|



## Internal API



### _batchUpdate (request:object ; includeSpreadsheetInResponse:boolean ; responseRanges:string ; responseIncludeGridData:boolean) -> object

***NOTE:  At this time, only the request parameter is implemented***

Sends

`POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate`

The request body contains data with the following structure:

```
		{
		 "requests": [
		  {
		   object (Request)
		  }
		 ],
		 "includeSpreadsheetInResponse": boolean,
		 "responseRanges": [
		  string
		 ],
		 "responseIncludeGridData": boolean
		}
```

#### References

* https://developers.google.com/sheets/api/guides/batchupdate

* https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/batchUpdate

* https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request

  

### _getSheetIDFromURL ( url:TEXT ) -> Text

Grabs the part of the url where the ID of the current sheet (tab) lives



### \_getSpreadsheetIDFromURL ( url:TEXT ) -> Text
Grabs the part of the url where the current spreadsheet lives.  I'm not sure why we have this any longer, since none of the API requires it.

###\_loadIfNotLoaded () -> Boolean
Loads the spreadsheet data with default options if the spreadsheet has not been loaded yet.



### _http ( http_method:TEXT ; url:TEXT; body:TEXT; header:object )

Overrides to ***cGoogleComms._http***: if it gets a specific error that makes it suspect that the token has expired, it force-refreshes the token and then tries again.



### \_queryRange (range:TEXT) -> Text
Builds a range query string in A1 format for use in calls from the class



## References
https://developers.google.com/sheets/api/reference/rest
