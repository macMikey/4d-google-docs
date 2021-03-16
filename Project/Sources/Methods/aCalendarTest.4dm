//%attributes = {}
$username:=getPrivateData("testuser.txt")
$key:=getPrivateData("google-key.json")
$scopes:=getPrivateData("scopes.txt")
$apiKey:=getPrivateData("calendar-apikey.txt")

$cr:=Char:C90(Carriage return:K15:38)

//<initialize google auth object>
C_OBJECT:C1216(<>a)  //define interprocess b/c otherwise doesn't survive exiting the execution (IKR?)
If (OB Is empty:C1297(<>a))
	<>a:=cs:C1710.cGoogleAuth.new($username;$scopes;$key;"native")  //"native" isn't implemented, yet, though.
End if 
//</initialize google auth object>


var $c : cs:C1710.cGoogleCalendar


$c:=cs:C1710.cGoogleCalendar.new(<>a;$apiKey)


// get the list of calendars
TRACE:C157
$calendarList:=$c.getCalendarList()
$id:=$calendarList.items[0].id

// assign the calendar we are going to work with to the first calendar in the list
TRACE:C157
$success:=$c.setID($id)  // assign the calendar to the id of the first calendar


// grab all the events for the calendar
TRACE:C157
$success:=$c.eventsGet()  // get the events for the default calendar


// create a new calendar called 'test'?
$createCalendar:=CONFIRM:C162("Create a new calendar named 'test'?")
If (ok=1)
	TRACE:C157
	$success:=$c.createCalendar("test")  // create a new calendar called "test"
	ALERT:C41("test is the current calendar.")
	// Now $c.metadata is assigned to the new calendar
End if 


// create a new event
TRACE:C157
$tz:="America/New_York"
$d:=Current date:C33
$ds:=String:C10(Year of:C25($d);"0000")+"-"+String:C10(Month of:C24($d);"00")+"-"+String:C10(Day of:C23($d);"00")  //YYYY-MM-DD

var $event : Object
$event:=New object:C1471()
$event.start:=New object:C1471()
$event.start.dateTime:=$ds+"T09:00:00"
$event.start.timeZone:=$tz
$event.end:=New object:C1471()
$event.end.dateTime:=$ds+"T10:00:00"
$event.end.timeZone:=$tz
$event.summary:="Test Event"
$event.description:=$event.summary+". Should run from "+$event.start.dateTime+" "+$event.start.timeZone+" to "+$event.end.dateTime+" "+$event.end.timeZone+"."

$success:=$c.eventInsert($event)
TRACE:C157
