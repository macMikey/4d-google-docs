Class extends cGoogleComms


Class constructor  // oGoogleAuth:object ; spreadsheet_url:text
	
	var $1 : Object
	var $2 : Text
	
	Super:C1705("native")  //comms type
	This:C1470._auth:=$1
	This:C1470.spreadsheetId:=This:C1470._getSSIdFromURL($2)
	
	//<initialize other values>
	This:C1470.endpoint:="https://sheets.googleapis.com/v4/spreadsheets/"
	//</initialize other values>
	
	// ===============================================================================================================
	
	//                                         P U B L I C   F U N C T I O N S
	
	// ===============================================================================================================
	
Function duplicateSheet  // ( sourceSheetId:INTEGER ; insertSheetIndex:INTEGER ; {newSheetId:INTEGER} ; {newSheetName:Text} ) -> object
	//POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate
/*
the request body is
{
  "requests": [
    {
      "duplicateSheet":
         {
           "sourceSheetId": integer,
           "insertSheetIndex": integer,
           "newSheetId": integer,
           "newSheetName": string
         }
    }
  ],
  "includeSpreadsheetInResponse": boolean,
  "responseRanges": [
    string
  ],
  "responseIncludeGridData": boolean
}
*/
	
	var $1;$2;$3 : Integer
	var $4 : Text
	var $requestBody;$duplicateSheetRequest;$requests;$batchUpdate : Object
	
	//<build the duplicateSheetRequest object>
	$duplicateSheetRequest:=New object:C1471()
	$duplicateSheetRequest.sourceSheetId:=$1
	
	If (Count parameters:C259>=2)
		$duplicateSheetRequest.insertSheetIndex:=$2
	End if   //count parameters>=2
	
	If (Count parameters:C259>=3)
		If (Not:C34(Undefined:C82($3))
			If ($3#0)  // 0 means nope
				$duplicateSheetRequest.newSheetId:=$3
			End if 
		End if   //not(undefined($3))
	End if   //count parameters>=3
	
	If (Count parameters:C259)>=4)
		$duplicateSheetRequest.newSheetName:=$4
	End if   // count parameters>=4
	
	$requests:=New object:C1471()
	$requests.duplicateSheet:=$duplicateSheetRequest
	//</build the duplicateSheetRequest object>
	
	$batchUpdate:=New object:C1471()
	$batchUpdate.requests:=New collection:C1472($requests)
	
	//try adding $requestBody.includeSpreadsheetInResponse:=true, too to see if that means we don't need to reload the spreadsheet //debugx
	
	$url:=This:C1470.endpoint+This:C1470.spreadsheetId+":batchUpdate"
	
	var $0;$oResult : Object
	
	$oResult:=This:C1470._http(HTTP POST method:K71:2;$url;JSON Stringify:C1217($batchUpdate);This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status  //however, if we have it return the spreadsheet, set the sheetData property, too //debugx
	
	
	$0:=New object:C1471()
	
	If (This:C1470.status=200)
		// still need to rename it, though xxx
		$0.success:=True:C214
		$0.message:=""
		$0.result:=$oResult
	Else   //$status=200
		$0.success:=False:C215
		$0.message:=$oResult.status+" "+$oResult.value
		$0.result:=$oResult
	End if   //status=200
	// _______________________________________________________________________________________________________________
	
	
Function findSheetWithName  // sheetName:text -> collection
	// used to search this.sheetData.Sheets[] for .properties.title = sheetName
	// returns a collection with all of the sheets sharing that name
	var $1;$sheetName : Text
	var $0 : Collection
	
	$sheetName:=$1
	$0:=New collection:C1472()
	
	For each ($sheet;This:C1470.sheetData.sheets)
		If $sheet.properties.title=$sheetName
			$0.push($sheet)
		End if 
	End for each   //($sheet;This.sheetData.sheets)
	// _______________________________________________________________________________________________________________
	
	
Function getSheetNames  //  -> sheetNameList: collection
	// optionally reloads the sheet, first
	
	
	var $sheetNames : Collection
	$sheetNames:=New collection:C1472
	
	This:C1470._loadIfNotLoaded()
	
	If (This:C1470.status#200)
		$0:=Null:C1517
	Else 
		For ($i;0;This:C1470.sheetData.sheets.length-1)
			$sheetNames[$i]:=This:C1470.sheetData.sheets[$i].properties.title
		End for 
		
		$0:=$sheetNames
	End if 
	// _______________________________________________________________________________________________________________
	
	
Function getValues  //(range:TEXT {; majorDimension:Text ; valueRenderOption:Text ; dateTimeRenderOption:Text} )
	// Returns a range of values from a spreadsheet. The caller must specify the spreadsheet Id and a range.
	
	//<handle params>
	var $1;$2;$3;$4 : Text
	var $oResult : Object
	$queryString:=This:C1470._queryRange($1)  //e.g. 28d738fdhd3v83a/values/Sheet1!A1:B2
	
	$majorDimension:="DIMENSION_UNSPECIFIED"
	$valueRenderOption:="FORMATTED_VALUE"
	$dateTimeRenderOption:="SERIAL_NUMBER"
	
	If (Count parameters:C259>=2
		$majorDimension:=$2
	End if 
	
	If (Count parameters:C259>=3)
		$valueRenderOption:=$3
	End if 
	
	If (Count parameters:C259>=4)
		$dateTimeRenderOption:=$4
	End if 
	
	$queryString:=$queryString+"?"+\
		"majorDimension="+$majorDimension+"&"+\
		"valueRenderOption="+$valueRenderOption+"&"+\
		"dateTimeRenderOption="+$dateTimeRenderOption
	
	$url:=This:C1470.endpoint+This:C1470.spreadsheetId+"/values/"+$queryString
	$oResult:=This:C1470._http(HTTP GET method:K71:1;$url;"";This:C1470._auth.getHeader())
	//<debugx> need to come up with a more general way to do this b/c otherwise every call to _http will need to repeat this code.
	If (OB Is defined:C1231($oResult.value;"error"))  // error occurred
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=This:C1470._http(HTTP GET method:K71:1;$url;"";This:C1470._auth.getHeader(True:C214))
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	//</debugx>
	
	If (This:C1470.status#200)
		$0:=Null:C1517
	Else 
		$0:=This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
Function load  // {(rangeString:text , includeGridData:boolean)}
	// loads all spreadsheet data
	// optional params:
	
	//<handle params>
	var $1 : Text
	var $2 : Boolean
	var $oResult : Object
	
	$rangeString:=""
	$includeGridData:="false"
	
	If (Count parameters:C259>=2)
		$includeGridData:=Lowercase:C14(String:C10($2))
	End if 
	//</handle params>
	
	
	$queryString:="?"+\
		This:C1470._queryRange($1)+"&"+\
		"includeGridData="+$includeGridData
	
	
	$url:=This:C1470.endpoint+This:C1470.spreadsheetId+$queryString
	$oResult:=This:C1470._http(HTTP GET method:K71:1;$url;"";This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	
	If (This:C1470.status#200)
		$0:=Null:C1517
	Else   //fail
		$0:=This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function setValues  //(range:TEXT ; valuesObject: Object ; valueInputOption:Text {; includeValuesInResponse: Boolean ; responseValueRenderOption: Text ; responseDateTimeRenderOption:Text})
	// PUT https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}
	//Sets values in a range of a spreadsheet.
	
	
	//<handle params>
	var $1;$3;$5;$6 : Text
	var $2 : Object
	var $4 : Boolean
	var $oResult : Object
	
	//<mandatory parameters>
	$rangeString:=This:C1470._queryRange($1)
	$2.range:=$rangeString  // has to match the query range
	$queryString:="?valueInputOption="+$3  // going to have at least one query parameter, the valuesInputOption
	//</mandatory parameters>
	
	
	$appendSymbol:=""  // only append with ampersand if both params are defined
	
	
	$includeValuesInResponse:="false"
	If (Count parameters:C259>=4)
		$includeValuesInResponse:=Lowercase:C14(String:C10($4))
	End if 
	
	$responseValueRenderOption:="FORMATTED_VALUE"
	If (Count parameters:C259>=5)
		$includeValuesInResponse:=$5
	End if 
	
	$responseDateTimeRenderOption:="SERIAL_NUMBER"
	If (Count parameters:C259>=6)
		$responseDateTimeRenderOption:=$6
	End if 
	
	
	$queryString:=$queryString+\
		"&includeValuesInResponse="+$includeValuesInResponse+"&"+\
		"&responseValueRenderOption="+$responseValueRenderOption+"&"+\
		"&responseDateTimeRenderOption="+$responseDateTimeRenderOption
	
	//</handle params>
	
	$url:=This:C1470.endpoint+This:C1470.spreadsheetId+"/values/"+$rangeString+$queryString
	$oResult:=This:C1470._http(HTTP PUT method:K71:6;$url;JSON Stringify:C1217($2);This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	If (This:C1470.status#200)  // fail
		$0:=Null:C1517
	Else   //ok
		$0:=This:C1470.sheetData
	End if   //$status#200
	
	// ===============================================================================================================
	
	//                                        P R I V A T E   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function _http  // (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	// returns an object with properties  status:TEXT ; value:TEXT
	//tries the cGoogleComms._http.  If it fails, it checks to see if that is because the token expired, and if so, tries again.
	var $1;$2;$3 : Text
	var $4;$oResult;$0 : Object
	$oResult:=Super:C1706._http($1;$2;$3;$4)
	If (OB Is defined:C1231($oResult;"value.error"))  // error occurred"
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=Super:C1706._http($1;$2;$3;This:C1470._auth.getHeader(True:C214))  // $4 should be this._auth.getHeader()
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	$0:=$oResult
	// _______________________________________________________________________________________________________________
	
	
Function _ss_batchUpdate  // (request:object ; includeSpreadsheetInResponse:boolean ; responseRanges:string ; responseIncludeGridData:boolean) -> object
	//POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate
	//The request body contains data with the following structure:
/*
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
*/
	$url:=This:C1470.endpoint+This:C1470.spreadsheetId+":batchUpdate"
	
	// _______________________________________________________________________________________________________________
	
	
Function _getSheetIdFromURL  //url:text
	// accepts a url and extracts the Id of the sheet from that
	$found:=Match regex:C1019("(?<=[#&]gid=)([0-9]+)";$1;1;$foundAt;$length)
	If (Not:C34($found))
		$0:=""
	Else 
		$0:=Substring:C12($1;$foundAt;$length)
	End if   //(not($found))
	// _______________________________________________________________________________________________________________
	
	
Function _getSSIdFromURL  //url:text
	// accepts a url and extracts the Id of the sheet from that
	var $1 : Text
	
	$found:=Match regex:C1019("(?<=/spreadsheets/d/)([a-zA-Z0-9-_]+)";$1;1;$foundAt;$length)
	If (Not:C34($found)
		$0:=""
	Else 
		$0:=Substring:C12($1;$foundAt;$length)
	End if   //(not($found))
	// _______________________________________________________________________________________________________________
	
	
Function _loadIfNotLoaded  //   ( )  -> sheetWasNotLoaded :boolean
	// make sure sheet has been loaded for operations that just use already-loaded data.
	// return whether or not the sheet was already loaded
	
	$0:=False:C215  //reloaded
	If (This:C1470.sheetData=Null:C1517)
		$0:=True:C214  //reloaded
		This:C1470.load()
	End if 
	// _______________________________________________________________________________________________________________
	
	
Function _queryRange  //(rangeString:text)
	//turns a range string into a query-capable string
	// 1. replaces colons with %3A
	// 2. quotes all sheet names
	// 3. handles comma-separated compound ranges
	var $1;$0;$sheetPart;$cellsPart : Text
	var $bangPos : Integer
	$0:=""
	If ($1#"")
		$0:=$1
		//debugx when setting ranges, this breaks the range string comparison google does.  $0:=Replace string($0;":";"%3A")  //url encode
		$0:=Replace string:C233($0;",";"&ranges=")  // A1:B1,C1 becomes ranges=A1:B1&ranges=C1
		//<quote the sheet name so names with spaces will be ok>
		$bang:="!"  // for searching and then for appending, later, if it's actually in the string
		$bangPos:=Position:C15($bang;$0)
		If ($bangPos=0)
			$bang:=""  // not in the string, so don't append it, later
			$bangPos:=Length:C16($0)+1
		End if   //$bangPos=0
		$sheetPart:=Substring:C12($0;1;($bangPos-1))  // beginning until just before the bang
		$cellsPart:=Substring:C12($0;($bangPos+1);Length:C16($0))
		If (($sheetPart[[1]]#"'") & ($sheetPart[[Length:C16($sheetPart)]]#"'"))  // sheet name isn't already quoted
			$sheetPart:="'"+Super:C1706._URL_Escape($sheetPart)+"'"  // surround the sheet name with single quotes so we don't have to worry about spaces
		End if 
		$0:=$sheetPart+$bang+$cellsPart  // put it back together
		//</quote the sheet name so names with spaces will be ok>
	End if 
	
	
	// ===============================================================================================================
	
	//                         G O O G L E    S H E E T S    A P I    T O    I M P L E M E N T
	
	// ===============================================================================================================
	
	
Function _developerMetadata_get
	//GET/v4/spreadsheets/{spreadsheetId}/developerMetadata/{metadataId}
	//Returns the developer metadata with the specified Id.
	// _______________________________________________________________________________________________________________
	
Function _developerMetadata_search
	//POST/v4/spreadsheets/{spreadsheetId}/developerMetadata:search
	//Returns all developer metadata matching the specified DataFilter.
	// _______________________________________________________________________________________________________________
	
Function _ss_create
	//POST/v4/spreadsheets
	//Creates a spreadsheet, returning the newly created spreadsheet.
	// _______________________________________________________________________________________________________________
	
	
Function _ss_getByDataFilter
	//POST/v4/spreadsheets/{spreadsheetId}:getByDataFilter
	//Returns the spreadsheet at the given Id.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_append
	//POST/v4/spreadsheets/{spreadsheetId}/values/{range}:append
	//Appends values to a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_batchClear
	// POST/v4/spreadsheets/{spreadsheetId}/values:batchClear
	//Clears one or more ranges of values from a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_batchClearByDataFilter
	//POST/v4/spreadsheets/{spreadsheetId}/values:batchClearByDataFilter
	//Clears one or more ranges of values from a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_batchGet
	// GET/v4/spreadsheets/{spreadsheetId}/values:batchGet
	//Returns one or more ranges of values from a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_batchGetByDataFilter
	//POST/v4/spreadsheets/{spreadsheetId}/values:batchGetByDataFilter
	//Returns one or more ranges of values that match the specified data filters.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_batchUpdate
	//POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdate
	//Sets values in one or more ranges of a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_batchUpdateByDataFilter
	//POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdateByDataFilter
	//Sets values in one or more ranges of a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_clear
	//POST/v4/spreadsheets/{spreadsheetId}/values/{range}:clear
	//Clears values from a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
	
	// ===============================================================================================================
	