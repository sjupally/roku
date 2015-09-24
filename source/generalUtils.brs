'******************************************************
'Registry Helper Functions
'******************************************************
Function GetUserName() As Dynamic
	sec = CreateObject("roRegistrySection", "Authentication")
	if sec.Exists("UserName")
		return sec.Read("UserName")
	endif
	return invalid
End Function
  
Function SetUserName(userName As String) As Void
	sec = CreateObject("roRegistrySection", "Authentication")
	sec.Write("UserName", userName)
	sec.Flush()
End Function

Function GetJSONResponseCode() As Dynamic
	secJSON = CreateObject("roRegistrySection", "JSONResp")
	if secJSON.Exists("JSONRespCode")
		return secJSON.Read("JSONRespCode")
	endif
	return invalid
End Function
  
Function SetJSONResponseCode(JSONResponseCode As String) As Void
	print "i am in SetJSONResponseCode..."
    secJSON = CreateObject("roRegistrySection", "JSONResp")
    secJSON.Write("JSONRespCode", JSONResponseCode)
    secJSON.Flush()
End Function

Function SetToken(Token As String) As Void   
    secToken = CreateObject("roRegistrySection", "Token")
    secToken.Write("token", Token)
    secToken.Flush()
End Function

Function SetUserId(userId As String) As Void    
    secToken = CreateObject("roRegistrySection", "userId")
    secToken.Write("userId", userId)
    secToken.Flush()
End Function

Function GetToken() As Dynamic
     secToken = CreateObject("roRegistrySection", "Token")
     if secToken.Exists("token")
         return secToken.Read("token")
     endif
     return invalid
End Function

Function getUserId() As Dynamic
     secToken = CreateObject("roRegistrySection", "userId")
     if secToken.Exists("userId")
         return secToken.Read("userId")
     endif
     return invalid
End Function
  

'******************************************************
'Utilities
'******************************************************
Function rdSerialize(v as dynamic, outformat="BRS" as string) as string
	kq = "" ' for BRS
	if outformat = "JSON" then kq = chr(34)
		out = ""
		v = box(v)
		vType = type(v)
		if (vType = "roString" or vType = "String")
			re = CreateObject("roRegex",chr(34),"")
			v = re.replaceall(v, chr(34)+"+chr(34)+"+chr(34) )
			out = out + chr(34) + v + chr(34)
		else if vType = "roInt"
			out = out + v.tostr()
			else if vType = "roFloat"
			out = out + str(v)
		else if vType = "roBoolean"
			bool = "false"
			if v then bool = "true"
			out = out + bool
		else if vType = "roList" or vType = "roArray"
			out = out + "["
			sep = ""
			for each child in v
				out = out + sep + rdSerialize(child, outformat)
				sep = ","
			end for
			out = out + "]"
		else if vType = "roAssociativeArray"
			out = out + "{"
			sep = ""
			for each key in v
				out = out + sep + kq + key + kq + ":"
				out = out + rdSerialize(v[key], outformat)
				sep = ","
			end for
			out = out + "}"
		else if vType = "roFunction"
			out = out + "(Function)"
			else
			out = out + chr(34) + vType + chr(34)
	end if
	return out
End Function

'******************************************************
'Trim a string
'******************************************************
Function strTrim(str As String) As String
    st = CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function

'*********************************************************
'Print required statement for logging / debugging purpose.
'*********************************************************
Sub LoggOrDbg(printString As String, printStringValue As String)
	printString = strTrim(printString)
	printStringValue = strTrim(printStringValue)
	if printString.Len() > 0
		print "LOGGER / DEBUG STATEMENT PARAM / KEY:: "; printString
	end if
	if printStringValue.Len() > 0
		print "LOGGER / DEBUG STATEMENT VALUE:: "; printStringValue
	end if
End Sub

Sub LoggOrDbgStrInt(printString As String, printStringValue As Integer)
	printString = strTrim(printString)
	printStringValue = printStringValue
	if printString.Len() > 0
		print "LOGGER / DEBUG STATEMENT PARAM / KEY:: "; printString
	end if
	if printStringValue > 0
		print "LOGGER / DEBUG STATEMENT VALUE:: "; printStringValue
	end if
End Sub

Function RegRead(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key)
         return sec.Read(key)
    endif
    return invalid
End Function

Function RegWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
End Function

Function SetSeriesURL() As Void
    print "in setseries URL"
    JSONToken = box(GetToken())
    
    print "JSONToken: "; JSONToken

    ' http://stream.livingscriptures.com/api/v2/series?token=42233344d172ee67374377cba4882aa8bfae6334&page=1&per_page=1

    RESTUrl = box("http://pict-sf-prod.tnt4-zone1.aus1/pict/v2/collection/list?sortOrder=descending")
    'RESTUrl.AppendString(JSONToken, JSONToken.Len())

    secRESTUrl = CreateObject("roRegistrySection", "RESTUrl")
    secRESTUrl.Write("RESTURL", RESTUrl)
    secRESTUrl.Flush()
End Function

Function GetSeriesURL() As Dynamic
     secRESTUrl = CreateObject("roRegistrySection", "RESTUrl")
     if secRESTUrl.Exists("RESTURL")
         return secRESTUrl.Read("RESTURL")
     endif
     return invalid
End Function

Function setTermsURL() As Void
    print "in setseries URL"
    JSONToken = box(GetToken())
    
    print "JSONToken: "; JSONToken

    ' http://stream.livingscriptures.com/api/v2/series?token=42233344d172ee67374377cba4882aa8bfae6334&page=1&per_page=1

    termsURL = box("http://stream.livingscriptures.com/api/v2/terms.json?token=")
    termsURL.AppendString(JSONToken, JSONToken.Len())

    secRESTUrl = CreateObject("roRegistrySection", "termsURL")
    secRESTUrl.Write("termsURL", termsURL)
    secRESTUrl.Flush()
End Function

Function getTermsURL() As Dynamic
     secRESTUrl = CreateObject("roRegistrySection", "termsURL")
     if secRESTUrl.Exists("termsURL")
         return secRESTUrl.Read("termsURL")
     endif
     return invalid
End Function

Function GetNewArrivalURL() As Dynamic
    JSONToken = box(GetToken())
    
    RESTUrl = box("http://stream.livingscriptures.com/api/v2/users/profile/new_arrivals.json?token=")
    RESTUrl.AppendString(JSONToken, JSONToken.Len())
    
    return RESTUrl
End Function

Function GetRecentlyWatchedURL() As Dynamic
    JSONToken = box(GetToken())

    RESTUrl = box("http://stream.livingscriptures.com//api/v2/users/profile/recently_watched?token=")
    RESTUrl.AppendString(JSONToken, JSONToken.Len())
    
    return RESTUrl
End Function
