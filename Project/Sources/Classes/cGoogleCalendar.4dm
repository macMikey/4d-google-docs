Class extends cGoogleComms


Class constructor  // oGoogleAuth:object {; calendar_url:text}
	
	var $1 : Object
	var $2 : Text
	
	Super:C1705("native")  //comms type
	This:C1470._auth:=$1
	
	This:C1470._apiKey:=$2
	
	If (Count parameters:C259>=3)  // url for calendar specified
		This:C1470.ID:=This:C1470._getIDFromURL($3)
	Else 
		This:C1470.id:=Null:C1517
	End if 
	
	//<initialize other values>
	This:C1470.endpoint:="https://www.googleapis.com/calendar/v3/"
	//</initialize other values>
	
	// ===============================================================================================================
	
	//                                         P U B L I C   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function createCalendar  //( name:text )
	//POST https://www.googleapis.com/calendar/v3/calendars
	
/*
the body is
{
  "summary": ""
}
*/
	
	var $oResult;$0 : Object
	var $1 : Text
	var $oSummaryBody : Object
	
	
	$url:=This:C1470.endpoint+"calendars"
	$oSummaryBody:=New object:C1471("summary";$1)
	$oResult:=This:C1470._http(HTTP POST method:K71:2;$url;JSON Stringify:C1217($oSummaryBody);This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	
	If (This:C1470.status#200)
		$0:=Null:C1517
	Else   //fail
		$0:=This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
Function getCalendarList  // () -> Collection
	//GET https://www.googleapis.com/calendar/v3/users/me/calendarList
/*
does not implement any of the optional parameters
*/
	
	var $oResult;$0 : Object
	
	
	$url:=This:C1470.endpoint+"users/me/calendarList"
	$oResult:=This:C1470._http(HTTP GET method:K71:1;$url;"";This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	
	If (This:C1470.status#200)
		$0:=Null:C1517
	Else   //fail
		$0:=This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	// ===============================================================================================================
	
	//                                        P R I V A T E   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function _http  // (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	// returns an object with properties  status:TEXT ; value:TEXT
	//tries the cGoogleComms._http.  If it fails, it checks to see if that is because the token expired, and if so, tries again.
	var $1;$2;$3 : Text
	var $4;$oResult;$0 : Object
	$2:=$2+"?key="+This:C1470._apiKey
	$oResult:=Super:C1706._http($1;$2;$3;$4)
	If (OB Is defined:C1231($oResult;"value.error"))  // error occurred"
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=Super:C1706._http($1;$2;$3;This:C1470._auth.getHeader(True:C214))  // $4 should be this._auth.getHeader()
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	$0:=$oResult
	// _______________________________________________________________________________________________________________ 