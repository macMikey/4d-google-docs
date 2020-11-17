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

//<get list of calendars>
$c:=cs:C1710.cGoogleCalendar.new(<>a;$apiKey)
$calendarList:=$c.getCalendarList()
//</get list of calendars>


TRACE:C157