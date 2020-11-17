//%attributes = {}
$username:=getPrivateData("testuser.txt")
$key:=getPrivateData("google-key.json")
$scopes:=getPrivateData("scopes.txt")

$testURL:=getPrivateData("testsheet.txt")

$cr:=Char:C90(Carriage return:K15:38)

//<initialize google auth object>
C_OBJECT:C1216(<>a)  //define interprocess b/c otherwise doesn't survive exiting the execution (IKR?)
If (OB Is empty:C1297(<>a))
	<>a:=cs:C1710.cGoogleAuth.new($username;$scopes;$key;"native")  //"native" isn't implemented, yet, though.
End if 
//</initialize google auth object>



//<setup a spreadsheet>
C_OBJECT:C1216($s)
$s:=Null:C1517
$s:=cs:C1710.cGoogleSpreadsheet.new(<>a;$testURL)
//</setup a spreadsheet>



//<EXAMPLE: get sheet names>
C_COLLECTION:C1488($sheetNames)
$sheetNames:=$s.getSheetNames()
If ($sheetNames=Null:C1517)
	ALERT:C41("getSheetNames("+$range+")"+$cr+$s.parseError())
	ABORT:C156
End if 

//</EXAMPLE: get sheet names>



//<EXAMPLE: Replace Cell Values>
C_OBJECT:C1216($values)
$values:=$s.getValues("Sheet1")
If ($values=Null:C1517)
	ALERT:C41("getValues("+$range+")"+$cr+$s.parseError())
	ABORT:C156
End if 

//<in all occupied cells, replace contents with a sequential number>
$counter:=0
For ($i;0;($values.values.length-1))
	For ($j;0;($values.values[$i].length-1))
		$values.values[$i][$j]:=String:C10(100-$counter)
		$counter:=$counter+1
	End for 
End for 

C_OBJECT:C1216($result)
$result:=$s.setValues($s.sheetData.range;$values;"USER_ENTERED")  // fun fact: can get the full range of the sheet from the sheetData.range property
If ($result=Null:C1517)
	ALERT:C41("setValues("+$range+")"+$cr+$s.parseError())
	ABORT:C156
End if 

//</in all occupied cells, replace contents with a sequential number>

//</EXAMPLE: Replace Cell Values>

TRACE:C157