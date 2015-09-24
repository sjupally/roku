Function showVideoScreen(episode As Object)
    
    print "entered into video screen"
    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to showVideoScreen"
        return -1
    endif

    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.SetMessagePort(port)
    screen.ShowSubtitle(true)
    screen.Show()
    screen.SetPositionNotificationPeriod(3)
    screen.SetContent(episode)
    screen.Show()
    nowpos = 0
    while true        
        msg = wait(0, port)
        print "entered into video screen while "; msg
        if type(msg) = "roVideoScreenEvent" then
            print "showHomeScreen | msg = "; msg.getMessage() " | index = "; msg.GetIndex()
            nowpos = nowpos + msg.GetIndex()
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRequestFailed()
                print "Video request failure: "; msg.GetIndex(); " " msg.GetData() 
            else if msg.isStatusMessage()
                print "Video status: "; msg.GetIndex(); " " msg.GetData() 
            else if msg.isButtonPressed()
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()                
                RegWrite(episode.ContentId.ToStr(), nowpos.toStr())                
            else if msg.isRemoteKeyPressed() then
                print"Remote Key pressed "; msg.GetIndex()                
            else
                print "Unexpected event type: "; msg.GetType()
                RegWrite(episode.ContentId.ToStr(), nowpos.toStr())
                associativeArray = { movie_id : episode.ContentId, resume_time : nowpos }         
                restClientPostResumeTime(resumeTimeRecord(), associativeArray)
            end if
        else
            print "Unexpected message class: "; type(msg)            
        end if
    end while

End Function

Function resumeTimeRecord() As String
    JSONToken = box(GetToken())
    url = "http://stream.livingscriptures.com/api/v2/users/profile/resume_time?token="+JSONToken
    
    
    return url
End Function

Function restClientPostResumeTime(url As String, associativeArray As Object)
    roUrlTransfer = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    roUrlTransfer.SetMessagePort(port)
    roUrlTransfer.SetUrl(url)
    roUrlTransfer.AddHeader("Content-Type", "application/json")
    json = rdSerialize(associativeArray, "JSON")
    print "Posting to " + roUrlTransfer.GetUrl() + " -P " + json
    
    if (roUrlTransfer.AsyncPostFromString(json))
        while (true)
            msg = wait(0, port)
            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()
                print "code: "; code
                if (code = 200)
                    json = ParseJSON(msg.GetString())
                    print "json: "; json                    
                    return out
                else if (code = 401)
                    print "json: "; json
                    return out
                else if (code = 400)
                    print "json: "; json
                    return out
                else if (code = 501)
                    json = ParseJSON(msg.GetString())
                    print "json: "; json
                    return out
                endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif
End Function


