// handles all comms with google.

Class constructor  // ({connectionMethod : text } )
	
	This:C1470.connectionMethod:=$1
	
	
	// ===============================================================================================================
	
	
Function parseError  //()
	// parses an error object and returns the contents
	var $oError : Object
	$cr:=Char:C90(Carriage return:K15:38)
	$oError:=This:C1470.sheetData.error
	$0:=""
	If ($oError#Null:C1517)
		$0:="Code: "+String:C10($oError.code)+$cr+\
			"Status: "+$oError.status+$cr+\
			"Message: "+$oError.message
	End if 
	// _______________________________________________________________________________________________________________
	
	
	
Function _http  // (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	// returns an object with properties  status:TEXT ; value:TEXT
	var $1;$2;$3 : Text
	var $4 : Object
	var $0;$oReturnValue : Object
	
	Case of 
		: (This:C1470.connectionMethod="native")
			ARRAY TEXT:C222($aHeaderNames;1)
			ARRAY TEXT:C222($aHeaderValues;1)
			$aHeaderNames{1}:=$4.name
			$aHeaderValues{1}:=$4.value
			
			$0:=New object:C1471()
			$0.status:=HTTP Request:C1158($1;$2;$3;$oReturnValue;$aHeaderNames;$aHeaderValues)
			$0.value:=$oReturnValue
		: (This:C1470.connectionMethod="curl")  // not implemented yet
			$header:=$4.name+": "+$4.value
			$0:=Null:C1517
		: (This:C1470.connectionMethod="ntk")  //not implemented yet
			$0:=Null:C1517
		Else   // error
			$0:=Null:C1517
	End case 
	// _______________________________________________________________________________________________________________
	
	
Function _URL_Escape
	var $1;$0;$escaped : Text
	var $i;Integer
	var $shouldEscape : Boolean
	var $data : Blob
	
	For ($i;1;Length:C16($1))
		
		$char:=Substring:C12($1;$i;1)
		$code:=Character code:C91($char)
		
		$shouldEscape:=False:C215
		
		Case of 
			: ($code=45)
			: ($code=46)
			: ($code>47) & ($code<58)
			: ($code>63) & ($code<91)
			: ($code=95)
			: ($code>96) & ($code<123)
			: ($code=126)
			Else 
				$shouldEscape:=True:C214
		End case 
		
		If ($shouldEscape)
			CONVERT FROM TEXT:C1011($char;"utf-8";$data)
			For ($j;0;BLOB size:C605($data)-1)
				$hex:=String:C10($data{$j};"&x")
				$escaped:=$escaped+"%"+Substring:C12($hex;Length:C16($hex)-1)
			End for 
		Else 
			$escaped:=$escaped+$char
		End if 
		
	End for 
	
	$0:=$escaped
	// _______________________________________________________________________________________________________________
	