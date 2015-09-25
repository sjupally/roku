'******************************************************
'Authenticate User
'******************************************************
Function authenticateURL() As String
	url = "https://accounts-aus.snapfish.com/v1/oauth2"
	return url
End Function

Function getAlbumUrl() As String
    url = "http://assets.snapfish.com/pict/v2/collection/list?sortOrder=descending"
    return url
End Function

Function getProjectUrl() As String
    url = "http://projects.snapfish.com/v1/project?queryLimit=0&accountId="
    return url
End Function

Function getAssetsurl() As String
    url = "http://assets.snapfish.com/pict/v2/asset/assetsFromIds?ids="
    return url
End Function

Function getThumbnailURL()
    return "http://tnl.snapfish.com/assetrenderer/v2/thumbnail/stream/"
End Function

Function authenticateBODY() As Object
	' associativeBODYArray = CreateObject("roAssociativeArray")
	associativeBODYArray = { email : userName, password : password }
	return associativeBODYArray
End Function

Function restClientPostUserAuth(url As String, param As Object)
	roUrlTransfer = CreateObject("roUrlTransfer")
	port = CreateObject("roMessagePort")
	roUrlTransfer.SetMessagePort(port)
	roUrlTransfer.SetUrl(url)	
	roUrlTransfer.AddHeader("Content-Type", "application/x-www-form-urlencoded")	
    roUrlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    roUrlTransfer.InitClientCertificates()    
    'roUrlTransfer.AddHeader("X-Roku-Reserved-Dev-Id", param)
    'roUrlTransfer.EnableFreshConnection(true)
	
	print "Posting to " + roUrlTransfer.GetUrl() + ": " + param
	
	if (roUrlTransfer.AsyncPostFromString(param))
        while (true)
            msg = wait(0, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                response = msg.GetFailureReason()
				print "code: "; code
				print "response: "; response
                if (code = 200)
                    json = ParseJSON(msg.GetString())
					print "json: "; json
                    token = json.access_token
                    userId = json.userid
					SetJSONResponseCode("200")
					SetToken(token)      
					SetUserId(userId)               
					return out
                else if (code = 401)
					print "json: "; json
					SetJSONResponseCode("401")
					return out
				else if (code = 400)
					print "json: "; json
					SetJSONResponseCode("400")
					return out
				else if (code = 500)
					print "json: "; json
					SetJSONResponseCode("500")
					return out
				endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif
End Function
