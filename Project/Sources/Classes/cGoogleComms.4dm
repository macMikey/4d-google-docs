// handles all comms with google.

Class constructor  // ({connectionMethod : text } )
	
	This:C1470.connectionMethod:=$1
	
	
	// ===============================================================================================================
	
Function _http  // (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	// returns an object with properties  status:TEXT ; value:TEXT
	C_TEXT:C284($1;$2;$3)
	C_OBJECT:C1216($4)
	
	Case of 
		: (This:C1470.connectionMethod="native")
			ARRAY TEXT:C222($aHeaderNames;1)
			ARRAY TEXT:C222($aHeaderValues;1)
			$aHeaderNames{1}:=$4.name
			$aHeaderValues{1}:=$4.value
			C_OBJECT:C1216($0;$oReturnValue)
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