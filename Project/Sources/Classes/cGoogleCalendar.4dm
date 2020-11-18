Class extends cGoogleComms


Class constructor  // oGoogleAuth:object ; apiKey:text {; calendar_url:text}
	
	var $1 : Object
	var $2;$3 : Text
	
	
	
	Super:C1705("native")  //comms type
	This:C1470._auth:=$1
	
	This:C1470._apiKey:=$2
	
	This:C1470.endpoint:="https://www.googleapis.com/calendar/v3/"  // need to do this before call this.setID
	
	
	If (Count parameters:C259>=3)  // url for calendar specified
		This:C1470.setID($3)
	Else 
		This:C1470.id:=Null:C1517
	End if 
	
	
	// ===============================================================================================================
	
	//                                         P U B L I C   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function createCalendar  //( name:text ) -> boolean
	//POST https://www.googleapis.com/calendar/v3/calendars
	
/*
the body is
{
  "summary": ""
}
*/
	
	var $oResult : Object
	var $1 : Text
	var $oSummaryBody : Object
	var $0 : Boolean
	
	
	$url:=This:C1470.endpoint+"calendars"
	$oSummaryBody:=New object:C1471("summary";$1)
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP POST method:K71:2;$url;JSON Stringify:C1217($oSummaryBody);This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		$0:=False:C215
		This:C1470.error:=$oResult.status
	Else   //ok
		This:C1470._properties:=OB Copy:C1225($oResult.value)
		$0:=True:C214
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
Function eventDelete  // (eventID:text) -> boolean
	//DELETE https://www.googleapis.com/calendar/v3/calendars/<calendarId>/events/<eventId>
/*
does not implement any optional parameters
*/
	var $oResult : Object
	var $1 : Text
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470._properties.id+"/events/"+$1
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP DELETE method:K71:5;$url;"";This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#204)  //fail
		$0:=False:C215
		This:C1470.error:=$oResult.value
	Else   //ok
		$0:=True:C214
		//<remove from collection>
		$row:=-1
		For each ($event;This:C1470._events) Until ($event.id=$1)
			$row:=$row+1
		End for each 
		If ($row#This:C1470._events.length)  //found it
			This:C1470._events.remove($row)
		End if 
		
/*
as of r4 you can't use findIndex with a class function or a super class function.  this code is here for the day when we can.
$row:=This._events.findIndex("_findRowForValue";"id";$1)
If ($row>=0)
This._events.remove($row)
End if 
*/
		//</remove from collection>
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function getCalendarList  // () -> Collection
	//GET https://www.googleapis.com/calendar/v3/users/me/calendarList
/*
does not implement any of the optional parameters
*/
	
	var $oResult;$0 : Object
	
	
	$url:=This:C1470.endpoint+"users/me/calendarList"
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP GET method:K71:1;$url;"";This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		$0:=Null:C1517
		This:C1470.error:=$oResult.value
	Else   //ok
		$0:=$oResult.value
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
Function getEvents()->boolean
	//GET https://www.googleapis.com/calendar/v3/calendars/<calendarId>/events
/*
Does not implement any optional parameters
*/
	var $oResult : Object
	var $0;$done : Boolean
	var $url;$urlThisPass;$nextPageToken : Text
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470._properties.id+"/events"
	This:C1470.error:=Null:C1517
	This:C1470._events:=New collection:C1472()
	$urlThisPass:=$url  // first pass we don't have a page to retrieve
	$done:=False:C215  // multiple passes to get all the events
	$pass:=0  //debugx
	
	While (Not:C34($done))
		$pass:=$pass+1  //debugx
		$oResult:=This:C1470._http(HTTP GET method:K71:1;$urlThisPass;"";This:C1470._auth.getHeader())
		This:C1470.status:=$oResult.status
		
		If (This:C1470.status#200)  //fail
			$0:=False:C215
			This:C1470.error:=$oResult.value
			This:C1470._events.clear()  // in case any have been assigned, already
		Else   //ok
			$0:=True:C214
			This:C1470._events:=This:C1470._events.concat($oResult.value.items)
		End if   //$status#200
		
		$nextPageToken:=$oResult.value.nextPageToken
		If ($nextPageToken="")  //done
			$done:=True:C214
		Else   // more to come
			$urlThisPass:=$url+"?pageToken="+$nextPageToken
		End if   //$nextPageToken=""
	End while   // not ($done)
	// _______________________________________________________________________________________________________________
	
	
	
Function setID  // (id:text) -> boolean
	// sets the id of the object to the calendar id specified in id and tries to load the calendar metadata
	// returns whether the id is valid or not based on the load result
	var $1 : Text
	var $0 : Boolean
	
	This:C1470._properties:=New object:C1471()
	This:C1470._properties.id:=$1
	$0:=This:C1470._get()
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	
	//                                        P R I V A T E   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function _get()->boolean
	// GET https://www.googleapis.com/calendar/v3/calendars/<calendarId>
	// loads the metadata for this._properties.id and returns whether the result is valid or not.
	var $oResult : Object
	var $0 : Boolean
	
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470._properties.id
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP GET method:K71:1;$url;"";This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		$0:=False:C215
		This:C1470.error:=$oResult.value
	Else   //ok
		$0:=True:C214
		This:C1470._properties:=OB Copy:C1225($oResult.value)
	End if   //$status#200
	// _______________________________________________________________________________________________________________ 
	
	
Function _http  // (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	// returns an object with properties  status:TEXT ; value:TEXT
	//tries the cGoogleComms._http.  If it fails, it checks to see if that is because the token expired, and if so, tries again.
	var $1;$2;$3 : Text
	var $4;$oResult;$0 : Object
	If (Position:C15("?";$2)>0)  // contains "?", can't use it again
		$connector:="&"
	Else   // doesn't contain "?"
		$connector:="?"
	End if 
	$2:=$2+$connector+"key="+This:C1470._apiKey
	$oResult:=Super:C1706._http($1;$2;$3;$4)
	If (OB Is defined:C1231($oResult;"value.error"))  // error occurred"
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=Super:C1706._http($1;$2;$3;This:C1470._auth.getHeader(True:C214))  // $4 should be this._auth.getHeader()
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	$0:=$oResult
	// _______________________________________________________________________________________________________________ 