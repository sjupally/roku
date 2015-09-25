Function init_show_feed_item() As Object
    o = CreateObject("roAssociativeArray")

    o.ContentId        = ""
    o.Title            = ""
    o.ContentType      = ""
    o.ContentQuality   = ""
    o.Synopsis         = ""
    o.Genre            = ""
    o.Runtime          = ""
    o.StreamQualities  = CreateObject("roArray", 5, true) 
    o.StreamBitrates   = CreateObject("roArray", 5, true)
    o.StreamUrls       = CreateObject("roArray", 5, true)

    return o
End Function

Function getDetaisForMovie() As Object
    json = restClientGetSeries(getDetailScreenURL())
    r = CreateObject("roRegex", "https", "")
    strHDposterUrl =  r.ReplaceAll(json.movie.cover_art, "http")
    strSDPosterUrl =  r.ReplaceAll(json.movie.cover_art, "http")
    item = init_show_feed_item()
    strLength = 0
            if json.movie.duration <> ""           
                strToken  =  box(json.movie.duration).tokenize(":")
                if strToken.Count() = 3               
                    strLength = strToken[0].toint()*60*60+strToken[1].toint()*60+strToken[2].toint()
                else if  strToken.Count() = 2     
                    strLength = strToken[0].toint()*60+strToken[1].toint()
                else 
                    strLength = strToken[1].toint()
                end if
            end if
    'fetch all values from the json for the current show
    item.hdImg            = strHDposterUrl
    item.sdImg            = strHDposterUrl    
    item.ContentId        = json.movie.id
    item.Title            = json.movie.title
    item.Description      = json.movie.description     
    item.ContentType      = "episode"
    item.ContentQuality   = "SD"
    item.Synopsis         = json.movie.description
    item.Runtime          = strLength
    item.HDBifUrl         = ""
    item.SDBifUrl         = ""
    item.StreamFormat     = "mp4"
    item.ShortDescriptionLine1 = json.movie.title
    item.ShortDescriptionLine2 = ""
    item.HDPosterUrl      = strHDposterUrl
    item.SDPosterUrl      = strHDposterUrl
    item.Length           = strLength
    item.HDBranded        = json.movie.supports_hd
    item.IsHD             = json.movie.supports_hd
    languageArray = CreateObject("roArray", 100, true)
    subLanguageArray = CreateObject("roArray", 100, true)
    videoUrlArray = CreateObject("roArray", 100, true)
    languageArray = json.movie.languages
    subLanguageArray = languageArray["en-US"]
    videoUrlArray = subLanguageArray["video_urls"]
    if videoUrlArray["720p HD"] <> invalid then 
        streamUrl = videoUrlArray["720p HD"]
        parsedStreamUrl = r.ReplaceAll(streamUrl, "http") 
        item.StreamBitrates.Push("1500")
        item.StreamQualities.Push("SD")
        item.StreamUrls.Push(parsedStreamUrl)
        print "Stream url --> " parsedStreamUrl
    else
        print "Stream url Not found in service"
    end if
    
    if subLanguageArray["subtitle_file"] <> invalid then  
        print "Subtitle url --> " subLanguageArray["subtitle_file"]
        item.SubtitleUrl = r.ReplaceAll(subLanguageArray["subtitle_file"], "http")    
    end if   
   return item
End Function

Function getPlayer(language As String) As Object
    
    json = restClientGetSeries(getDetailScreenURL())
    r = CreateObject("roRegex", "https", "")
    strHDposterUrl =  r.ReplaceAll(json.movie.cover_art, "http")
    strSDPosterUrl =  r.ReplaceAll(json.movie.cover_art, "http")
    item = init_show_feed_item()
    strLength = 0
            if json.movie.duration <> ""           
                strToken  =  box(json.movie.duration).tokenize(":")
                if strToken.Count() = 3               
                    strLength = strToken[0].toint()*60*60+strToken[1].toint()*60+strToken[2].toint()
                else if  strToken.Count() = 2     
                    strLength = strToken[0].toint()*60+strToken[1].toint()
                else 
                    strLength = strToken[1].toint()
                end if
            end if
    'fetch all values from the json for the current show
    item.hdImg            = strHDposterUrl
    item.sdImg            = strHDposterUrl    
    item.ContentId        = json.movie.id
    item.Title            = json.movie.title
    item.Description      = json.movie.description     
    item.ContentType      = "episode"
    item.ContentQuality   = "SD"
    item.Synopsis         = json.movie.description
    item.Runtime          = strLength
    item.HDBifUrl         = ""
    item.SDBifUrl         = ""
    item.StreamFormat     = "mp4"
    item.ShortDescriptionLine1 = json.movie.title
    item.ShortDescriptionLine2 = ""
    item.HDPosterUrl      = strHDposterUrl
    item.SDPosterUrl      = strHDposterUrl
    item.Length           = strLength
    item.HDBranded        = json.movie.supports_hd
    item.IsHD             = json.movie.supports_hd
    languageArray = CreateObject("roArray", 100, true)
    subLanguageArray = CreateObject("roArray", 100, true)
    videoUrlArray = CreateObject("roArray", 100, true)
    languageArray = json.movie.languages
    subLanguageArray = languageArray[language]
    videoUrlArray = subLanguageArray["video_urls"]
    if videoUrlArray["720p HD"] <> invalid then 
        streamUrl = videoUrlArray["720p HD"]
        parsedStreamUrl = r.ReplaceAll(streamUrl, "http") 
        item.StreamBitrates.Push("1500")
        item.StreamQualities.Push("SD")
        item.StreamUrls.Push(parsedStreamUrl)
        print "Stream url --> " parsedStreamUrl
    else
        print "Stream url Not found in service"
    end if
    
    if subLanguageArray["subtitle_file"] <> invalid then  
        print "Subtitle url --> " subLanguageArray["subtitle_file"]
        item.SubtitleUrl = r.ReplaceAll(subLanguageArray["subtitle_file"], "http")    
    end if   
   return item

End Function


Function getLanguagesOfMovie() As Object
    json = restClientGetSeries(getDetailScreenURL())
    
    languageArray = CreateObject("roArray", 100, true)
    
    for each language in json.movie.languages
        languageArray.push(language)
    end for       
    return languageArray

End Function

Function restClientGetAlbums(url As String) As Object
    roUrlTransfer = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    roUrlTransfer.SetMessagePort(port)
    roUrlTransfer.AddHeader("Authorization", "OAuth "+GetToken())
    roUrlTransfer.SetUrl(url)
    
    print "getting from " + roUrlTransfer.GetUrl()
    
    if (roUrlTransfer.AsyncGetToString())
        while (true)
            msg = wait(0, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                print "code: "; code
                if (code = 200)
                    json = ParseJSON(msg.GetString())
                    return json
                else if (code = 401)
                    print "json: "; json
                    SetJSONResponseCode("401")
                    return json
                else if (code = 400)
                    print "json: "; json
                    SetJSONResponseCode("400")
                    return json
                else if (code = 500)
                    print "json: "; json
                    SetJSONResponseCode("500")
                    return json
                endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif
End Function

Function restClientGetSearch(searchText As String) As Object
    m.UrlBase = "http://stream.livingscriptures.com/api/v2/movies/search"
    m.Token = "?token="+GetToken()
    m.Query = "&query="
    rhttp = NewHttp(m.UrlBase + m.Token + m.Query + HttpEncode(searchText))
    print "URL:::::"rhttp.Http.GetUrl()
    if (rhttp.Http.AsyncGetToString())
        while (true)
            msg = wait(0, rhttp.Http.GetMessagePort())
            print "msg ";msg
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                print "Search Reposne code: "; code
                print "Search FailureReason"; msg.GetFailureReason()
                if (code = 200)
                    json = ParseJSON(msg.GetString())
                    print "json: "; json                                        
                    return json
                else if (code = 401)
                    print "json: "; json
                    SetJSONResponseCode("401")
                    return json
                else if (code = 400)
                    print "json: "; json
                    SetJSONResponseCode("400")
                    return json
                else if (code = 500)
                    print "json: "; json
                    SetJSONResponseCode("500")
                    return json
                endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif
End Function

Function getStreamURL(videoUrlArray As Object) As String
    If videoUrlArray.DoesExist("480p SD")
        return videoUrlArray.Lookup("480p SD")
    Else if videoUrlArray.DoesExist("432p SD")
        return videoUrlArray.Lookup("432p SD")   
    End if
End Function

Function NewHttp(url As String) as Object
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject(url)
    return obj
End Function

Function CreateURLTransferObject(url As String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.AddHeader("Content-Type", "application/x-www-form-urlencoded")
    obj.EnableEncodings(true)
    return obj
End Function