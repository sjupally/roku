'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowSearchGridScreen(style as string) As Object

    m.port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(m.port)
'    screen.SetDisplayMode("best-fit")
    screen.SetDisplayMode("scale-to-fill")

    screen.SetGridStyle(style)
    return screen

End Function


'******************************************************
'** Display the gird screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************
Function showSearchGridScreen(screen As Object, gridstyle as string, searchText as String) As string

        print "enter showSearchScreen"
        dailog = ShowPleaseWait("Please wait its connecting to Server", "")
        json = restClientGetSearch(searchText)  
        seriesArray = CreateObject("roArray")
        seriesArray = json.series
        print seriesArray.Count()       
        categoryList = CreateObject("roArray", seriesArray.Count(), true)   
        movieIdList = CreateObject("roArray", seriesArray.Count(), true)
        count = 0
        if seriesArray.Count() = 0            
            showNodataFound()        
        end if 
        For Each series In json.series        
            categoryList[count] = series.name
            movieIdList[count]  = mapMovieIdForDetailScreen(series)
            count = count + 1
        End For 
        screen.setupLists(categoryList.Count())
        screen.SetListNames(categoryList)
        showCount = 0
        For Each series In json.series             
            screen.SetContentList(showCount, iterateOverSeriesList(series))
            showCount = showCount + 1
        End For   
        print "Debug categoryList: "; categoryList
        print "movieIdList: "; movieIdList
        
        
        screen.Show()
        m.curCategory = 0
        m.curShow     = 0
        while true
            print "Waiting for message"
            msg = wait(0, m.port)
            
            if type(msg) = "roGridScreenEvent" then
                print "Category Id= "; msg.GetIndex(); " Movie Id= "; msg.getData()
                if msg.isListItemFocused() then
                    print"list item focused | current show = "; msg.GetIndex()
                else if msg.isListItemSelected() then                
                    categorySelected = movieIdList[msg.GetIndex()]
                    print "categorySelected selected = "; categorySelected
                    strMovieId = CreateObject("roString")           
                    strMovieId = categorySelected[msg.getData()]   
                    print "Movie selected = "; strMovieId
                    setDetailScreenURL(strMovieId)
                    detailScreen = preShowDetailScreen()
                    m.curShow = showDetailScreen(detailScreen)
                    screen.SetFocusedListItem(msg.GetIndex(), msg.getData())         
                end if
            end If
        end while 
End Function