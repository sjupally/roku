'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowProjectScreen(style as string) As Object

    m.port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(m.port)
    screen.SetDisplayMode("best-fit")
    screen.SetUpBehaviorAtTopRow("exit")
    'screen.SetDisplayMode("scale-to-fill")

    screen.SetGridStyle(style)
    return screen

End Function


'******************************************************
'** Display the gird screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************
Function showProjectScreen(screen As Object, gridstyle as string) As string

    print "enter showGridScreen"
    
    slides = CreateObject("roArray", 100, true) 
    categoryList = CreateObject("roArray", 1000, true)
    assetList = CreateObject("roArray", 1000, true)
    print "getProjectUrl() --> ";getProjectUrl()+getUserId()
    dailog = ShowPleaseWait("Please wait its connecting to Server", "")
    strLieral = box(",")
    
    json = restClientGetAlbums(getProjectUrl()+getUserId())
        
    count = 0
    For Each obj In json.resources        
        if obj.resource.photoWell <> invalid then
            print "resource " obj.resource.projectName
            assets = CreateObject("roString")
            For i = 0 to obj.resource.photoWell.count()-1
                if i = 0 then
                    assets.SetString(box(obj.resource.photoWell[i]))
                else    
                    assets.AppendString(box(obj.resource.photoWell[i]), assets.Len())
                end if                
                assets.AppendString(box(","), assets.Len())
            End For
            print "assets " assets
            categoryList[count] = obj.resource.projectName
            assetList[count] = assets
            count = count + 1
        End if        
    End For    
    
    print "categoryList  ";categoryList
    listStyles = ["landscape","portrait", "portrait", "portrait"]
    screen.SetGridStyle("mixed-aspect-ratio")
    screen.SetListPosterStyles(listStyles)
    screen.setupLists(categoryList.Count())
    screen.SetListNames(categoryList)     
    screen.SetDescriptionVisible(false)
    showCount = 0
    For i = 0 to assetList.count()-1
        print "assetList " assetList[i]
        if assetList[i] <> invalid then
            assets = restClientGetAlbums(getAssetsurl()+assetList[i])
            slides[showCount] = iterateOverAssetList(assets)
            screen.SetContentList(showCount, slides[showCount])
            showCount = showCount + 1            
        End if
   End For
   
    screen.Show()
    m.curCategory = 0
    m.curShow     = 0
    while true
        msg = wait(0, m.port)
        print "Waiting for message --> " msg       
        if type(msg) = "roGridScreenEvent" then            
            if msg.isListItemFocused() then
                print"list item focused | current show = "; msg.GetIndex()
            else if msg.isListItemSelected() then
                print"list item selected | current selection = "; msg.GetIndex()
                DisplayImageSet(slides[msg.GetIndex()])
            end if
        else
            print "Unexpected message class: "; type(msg)            
        end if
    end while
End Function

Function iterateOverAssetList(assets As Object) As Object
    shows = CreateObject("roArray", 100, true)
    For Each entitie In assets.entities
        thumbNailURL = getThumbnailURL()+entitie.files[1].url
        arrayShow = {               
            HDPosterUrl : thumbNailURL
            SDPosterUrl : thumbNailURL
            url : entitie.files[0].url
         }               
        shows.push(arrayShow)
    End For       
    return shows
End Function
