// handles all the authentication...stuff.
// Should be instantiated as a process object and therefore shared b/c tokens will periodically expire

Class extends cGoogleComms

Class constructor  //(username:text, scopes:text, googleKey:text; connectionMethod:text)
	
	C_TEXT:C284($1;$2;$3;$4)
	Super:C1705($4)
	
	//<constants>
	//<auth>
	This:C1470.expiresIn:=3600  //seconds
	This:C1470.oHead:=New object:C1471("alg";"RS256";"typ";"JWT")
	This:C1470.url:="https://oauth2.googleapis.com/token"
	This:C1470.bodyPrefix:="grant_type="+This:C1470._URL_Escape("urn:ietf:params:oauth:grant-type:jwt-bearer")+"&assertion="  //xxx
	This:C1470.access:=New object:C1471()
	This:C1470.access.header:=New object:C1471()
	This:C1470.access.header.name:="Authorization"
	This:C1470.access.header.value:=""  //gets assigned later.  this is just a placeholder
	//</auth>
	
	//<JWT>
	This:C1470.jwt:=New object:C1471()
	This:C1470.jwt.endpoint:="https://oauth2.googleapis.com/token"
	This:C1470.jwt.grantType:="urn:ietf:params:oauth:grant-type:jwt-bearer"
	This:C1470.jwt.header:=New object:C1471()
	This:C1470.jwt.header.name:="Content-Type"
	This:C1470.jwt.header.value:="application/x-www-form-urlencoded"
	//</JWT>
	//</constants>
	
	
	//<handle params>
	This:C1470.username:=$1
	This:C1470.scopes:=$2
	This:C1470.googleKey:=JSON Parse:C1218($3)
	//</handle params>
	
	
	//<initialize properties>
	This:C1470.createdAtTicks:=0  // will be corrected when we create the header, below
	This:C1470.access.token:=New object:C1471()
	//</initialize properties>
	
	
	This:C1470.getHeader(True:C214)  //initialize and force refresh
	// ===============================================================================================================
	
	
Function getHeader  //{forceRefresh:boolean}
	// returns header object to be used on subsequent calls or null
	// retrieves a fresh access token if old one expired
	
	C_BOOLEAN:C305($1)  // force refresh
	$forceRefresh:=False:C215
	If (Count parameters:C259>0)
		$forceRefresh:=$1
	End if 
	
	
	//<see if the token has expired>
	$now:=Tickcount:C458
	$then:=This:C1470.createdAtTicks
	Case of 
		: (($now>0 & $then>0) | ($now<0 & $then<0))  // signs the same on both
			$diff:=$now-$then
		: (($now>0) & ($then<0))
			$diff:=Abs:C99((MAXLONG:K35:2-$now)+($then-MAXLONG:K35:2))
		Else   // $now<0 and $end>0
			$diff:=($now-MAXLONG:K35:2)+(MAXLONG:K35:2-$then)
	End case 
	
	If ($diff>=(This:C1470.expiresIn*60))
		$forceRefresh:=True:C214
	End if   //$diff>=(This.access.expiresIn*60)
	//</see if the token has expired>
	
	
	If (Not:C34($forceRefresh))  //token is still current
		$0:=This:C1470.access.header
	Else   // request another token
		
		
		//<build jwt/assertion>
		C_OBJECT:C1216($ojwt)
		$ojwt:=New object:C1471()
		
		//<build jwt>
		$ojwt.iss:=This:C1470.googleKey.client_email
		$ojwt.scope:=This:C1470.scopes
		$ojwt.aud:=This:C1470.googleKey.token_uri
		$ojwt.iat:=This:C1470._Unix_Timestamp()  // epoch seconds
		$ojwt.exp:=$ojwt.iat+This:C1470.expiresIn  // an hour from now
		$ojwt.sub:=This:C1470.username
		$ojwt.endpoint:=This:C1470.jwt.endpoint
		$ojwt.grantType:=This:C1470.jwt.grantType
		$ojwt.kid:=This:C1470.googleKey.private_key_id
		//</build jwt>
		
		$assertion:=JWT Sign(JSON Stringify:C1217(This:C1470.oHead);JSON Stringify:C1217($ojwt);This:C1470.googleKey.private_key)
		//</build jwt/assertion>
		
		
		$body:=This:C1470.bodyPrefix+$assertion
		
		//<get the access token>
		C_OBJECT:C1216($oResult)
		$oResult:=This:C1470._http(HTTP POST method:K71:2;This:C1470.url;$body;This:C1470.jwt.header)
		This:C1470.status:=$oResult.status
		This:C1470.access.token:=$oResult.value
		//</get the access token>
		
		
		//<headers to be used in subsequent calls.  token is embedded in the header>
		This:C1470.access.header.value:=This:C1470.access.token.token_type+" "+This:C1470.access.token.access_token
		//</headers to be used in subsequent calls.  token is embedded in the header>
		
		C_OBJECT:C1216($0)
		
		If (This:C1470.status#200)
			$0:=Null:C1517
		Else   //$status=200
			$0:=This:C1470.access.header  //return the entire object
			This:C1470.createdAtTicks:=Tickcount:C458-600  //just to be safe, force refresh token 10 seconds before we think it's going to expire by aging it by 10 seconds.
		End if   //status#200
	End if   //(not($forceRefresh))
	// _______________________________________________________________________________________________________________
	
	
Function _Unix_Timestamp
	C_LONGINT:C283($0;$time)
	
	$timestamp:=Timestamp:C1445
	
	ARRAY LONGINT:C221($pos;0)
	ARRAY LONGINT:C221($len;0)
	
	If (Match regex:C1019("((\\d{4})-(\\d{2})-(\\d{2}))T(\\d{2}:\\d{2}:\\d{2})\\.(\\d{3})Z";$timestamp;1;$pos;$len))
		
		C_DATE:C307($date)
		$date:=Date:C102(Substring:C12($timestamp;$pos{1};$len{1}))
		
		C_LONGINT:C283($yyyy;$mm;$dd)
		$yyyy:=Num:C11(Substring:C12($timestamp;$pos{2};$len{2}))
		$mm:=Num:C11(Substring:C12($timestamp;$pos{3};$len{3}))
		$dd:=Num:C11(Substring:C12($timestamp;$pos{4};$len{4}))  //eventually will be number of days since Jan 1 this year
		
		$daysInFeb:=Day of:C23(Add to date:C393(Add to date:C393(!00-00-00!;$yyyy;3;1);0;0;-1))
		Case of 
			: ($mm=1)
				
			: ($mm=2)
				$dd:=$dd+31  //daysInJan
			: ($mm=3)
				$dd:=$dd+31+$daysInFeb
			: ($mm=4)
				$dd:=$dd+62+$daysInFeb  //daysInMar
			: ($mm=5)
				$dd:=$dd+92+$daysInFeb  //daysInApr
			: ($mm=6)
				$dd:=$dd+123+$daysInFeb  //daysInMay
			: ($mm=7)
				$dd:=$dd+153+$daysInFeb  //daysInJun
			: ($mm=8)
				$dd:=$dd+184+$daysInFeb  //daysInJul
			: ($mm=9)
				$dd:=$dd+215+$daysInFeb  //daysInAug
			: ($mm=10)
				$dd:=$dd+245+$daysInFeb  //daysInSep
			: ($mm=11)
				$dd:=$dd+276+$daysInFeb  //daysInOct
			: ($mm=12)
				$dd:=$dd+306+$daysInFeb  //daysInNov
		End case 
		
		$time:=(0+Time:C179(Substring:C12($timestamp;$pos{5};$len{5})))  //seconds so far since 00:00 ZULU today
		$time:=$time+(($dd-1)*86400)  //seconds YTD through yesterday
		$time:=$time+(($yyyy-1970)*31536000)  //seconds through all non-leap years since 1970 through the beginning of the year
		$time:=$time+((($yyyy-1-1968)\4)*86400)  //seconds for leap years since 1970
	End if 
	
	$0:=$time
	// _______________________________________________________________________________________________________________
	
	
Function _URL_Escape
	C_TEXT:C284($1;$0;$escaped)
	
	C_LONGINT:C283($i)
	C_BOOLEAN:C305($shouldEscape)
	C_BLOB:C604($data)
	
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