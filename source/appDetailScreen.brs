Function preShowDetailScreen() As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video") 
    screen.SetMessagePort(port)
    
    return screen
End Function

Function showDetailScreen(screen As Object) As Integer

    print "entered into detailed screen"
      
    episode = getDetaisForMovie()
    screen.ClearButtons()
    screen.AddButton(1, "Play")
    screen.AddButton(2, "Resume")
    screen.AddButton(3, "Back")
    screen.SetContent(episode)
    screen.SetTitle(getApplicationversion())
    screen.SetTitle("generic")
    screen.SetPosterStyle("rounded-square-generic")
    screen.SetAdDisplayMode("scale-to-fit")
    screen.SetStaticRatingEnabled(false)
    screen.Show()    
    
    while true
        msg = wait(0, screen.GetMessagePort())

        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed()
                print "Screen closed"
                exit while      
            else if msg.isButtonPressed() 
                print "Play ButtonPressed"
                if msg.GetIndex() = 1
                    language = showLanguageList()
                    print "returned language " language
                    episode = getPlayer(language)
                    episode.PlayStart = 0       
                    showVideoScreen(episode)
                endif
                if msg.GetIndex() = 2
                    print "episode.ContentId ";episode.ContentId
                    PlayStart = RegRead(episode.ContentId.ToStr())
                    if PlayStart <> invalid then
                        episode.PlayStart = PlayStart.ToInt()
                    endif
                    showVideoScreen(episode)
                endif
                if msg.GetIndex() = 3                    
                    screen.Close() 
                endif
            else if msg.isRemoteKeyPressed() then
                print"Remote Key pressed "; msg.GetIndex()            
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while    
    return 0

End Function