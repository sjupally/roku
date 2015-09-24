'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowGridScreen(style as string) As Object

    m.port=CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(m.port)
    screen.SetDisplayMode("best-fit")
    'screen.SetDisplayMode("scale-to-fill")

    screen.SetGridStyle(style)
    return screen

End Function


'******************************************************
'** Display the gird screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************
Function showGridScreen(screen As Object, gridstyle as string) As string

    print "enter showGridScreen"
    
    slides = CreateObject("roArray", 100, true) 
    categoryList = CreateObject("roArray", 100, true)
    
    print "getAlbumUrl() --> ";getAlbumUrl()
    dailog = ShowPleaseWait("Please wait its connecting to Server", "")    
    
    json = restClientGetAlbums(getAlbumUrl())
    print "json response :" json
    count = 0
    For Each entitie In json.entities        
        categoryList[count] = entitie.userTags[0].value        
        count = count + 1
    End For
    
    print "categoryList  ";categoryList
    listStyles = ["landscape","portrait", "portrait", "portrait"]
    screen.SetGridStyle("mixed-aspect-ratio")
    screen.SetListPosterStyles(listStyles)
    screen.setupLists(categoryList.Count())
    screen.SetListNames(categoryList)     
    screen.SetDescriptionVisible(false)
    showCount = 0
    For Each entitie In json.entities
      slides[showCount] = iterateOverSeriesList(entitie)
      screen.SetContentList(showCount, slides[showCount])
      showCount = showCount + 1
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

'********************************************************************
'** Given the category from the filter banner, return an array 
'** of ContentMetaData objects (roAssociativeArray's) representing 
'** the shows for the category. For this example, we just cheat and
'** create and return a static array with just the minimal items
'** set, but ideally, you'd go to a feed service, fetch and parse
'** this data dynamically, so content for each category is dynamic
'********************************************************************
Function iterateOverSeriesList(entitie As Object) As Object
        shows = CreateObject("roArray", 100, true)
        for each asset in entitie.assetIdList
        thumbNailURL = getThumbnailURL()+asset.thumbnailEncryption
            arrayShow = {               
                HDPosterUrl : thumbNailURL
                SDPosterUrl : thumbNailURL
                url : thumbNailURL
            }               
            shows.push(arrayShow)
        end for  
    return shows
End Function

function mapMovieIdForDetailScreen(series As Object) as Object
        movies = CreateObject("roArray", 100, true)
        movieCount = 0
        for each movie in series.movies
            movies[movieCount] = movie.id
            movieCount = movieCount + 1
        end for             
     return movies
End Function

Function setSeriesList(seriesList As Object) As Void
    secToken = CreateObject("roRegistrySection", "seriesList")
    secToken.Write("seriesList", seriesList)
    secToken.Flush()
End Function
Function getSeriesList() As Dynamic
     secToken = CreateObject("roRegistrySection", "seriesList")
     if secToken.Exists("seriesList")
         return secToken.Read("seriesList")
     endif
     return invalid
End Function

Function setDetailScreenURL(movieId As Object) As Void
    JSONToken = box(GetToken())
    RESTUrl = box("http://stream.livingscriptures.com/api/v2/movies/{id}?token=")
    r1 = CreateObject("roRegex", "{id}", "")
    movieIdAppndedRestUrl =  r1.ReplaceAll(RESTUrl, Str(movieId).Trim())
    
    movieIdAppndedRestUrl.AppendString(JSONToken, JSONToken.Len())    
    print "Moview details URL  --> ";movieIdAppndedRestUrl
    secRESTUrl = CreateObject("roRegistrySection", "movieIdAppndedRestUrl")
    secRESTUrl.Write("movieIdAppndedRestUrl", movieIdAppndedRestUrl)
    secRESTUrl.Flush()
End Function

Function getDetailScreenURL() As Dynamic
     movieIdAppndedRestUrl = CreateObject("roRegistrySection", "movieIdAppndedRestUrl")
     if movieIdAppndedRestUrl.Exists("movieIdAppndedRestUrl")
         return movieIdAppndedRestUrl.Read("movieIdAppndedRestUrl")
     endif
     return invalid
End Function

function getGridControlButtons() as object
        buttons = [
            {
              Title: "Search",
              Description:"Here you can search movies",
              HDPosterUrl:"pkg:/images/icon_search.png",
              SDPosterUrl:"pkg:/images/icon_search.png"
            }
            { 
              Title: "Logout",
              HDPosterUrl:"pkg:/images/icon_logout.png",
              SDPosterUrl:"pkg:/images/icon_logout.png"
            }                       
       ]
       return buttons
End Function

Function getCategoryList() As Object

    categoryList = [ "Nature", "India", "Downtowm"]
    return categoryList

End Function