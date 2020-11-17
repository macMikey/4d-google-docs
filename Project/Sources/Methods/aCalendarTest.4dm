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

TRACE:C157
$calendarList:=$c.getCalendarList()
$id:=$calendarList.items[0].id

TRACE:C157
$success:=$c.setID($id)  // assign the calendar to the id of the first calendar

TRACE:C157
$success:=$c.getEvents()

TRACE:C157
$success:=$c.createCalendar("test")  // create a new calendar called "test"

TRACE:C157