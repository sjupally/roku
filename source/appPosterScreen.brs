'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowPosterScreen(breadA=invalid, breadB=invalid) As Object

    port=CreateObject("roMessagePort")
    posterScreen = CreateObject("roPosterScreen")
    posterScreen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        posterScreen.SetBreadcrumbText(breadA, breadB)
    end if

    posterScreen.SetListStyle("flat-category")
    return posterScreen

End Function


'******************************************************
'** Display the poster screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************
Function showPosterScreen(posterScreen As Object) As Integer
    
    posterScreen.SetContentList(getShowsHomeList())
    posterScreen.SetFocusedListItem(0)
    posterScreen.Show()

    while true
        message = wait(0, posterScreen.GetMessagePort())      
            if message.isListFocused() then                
                posterScreen.SetContentList(getShowsHomeList())
            else if message.isListItemFocused() then                
                print"list item focused and current show is "; message.GetIndex()
            else if message.isButtonPressed() then
                print"button pressed"; message.GetIndex()
            else if message.isListItemSelected() then
                print "List item selected "; message.GetIndex()
                if message.GetIndex() = 0 then                    
                    gridstyle = "Flat-Movie"
                    gridScreen = preShowGridScreen(gridstyle)
                    showGridScreen(gridScreen, gridstyle)
                else if message.GetIndex() = 1 then
                    gridstyle = "Flat-Movie"
                    gridScreen = preShowProjectScreen(gridstyle)
                    showProjectScreen(gridScreen, gridstyle)                                   
                end if
            else if message.isScreenClosed() then
                return -1
            end if
    end while

End Function

Function getShowsHomeList() As Object
    
     homeList = [
        {
            ShortDescriptionLine1:"Movie Albums",
            HDPosterUrl:"pkg:/images/x1x-4x6-print-category-page.jpg",
            SDPosterUrl:"pkg:/images/x1x-4x6-print-category-page.jpg"
        }
        {
            ShortDescriptionLine1:"Movie Projects"
            HDPosterUrl:"pkg:/images/x1x-4x6-print-category-page.jpg",
            SDPosterUrl:"pkg:/images/x1x-4x6-print-category-page.jpg"                        
        }
    ]   
    return homeList      

End Function

Function showLogoutDialog() As Void 
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port) 
    dialog.SetTitle("Are you sure you wish to Logout?")
    dialog.SetText("Click the button below to Logout")
 
    dialog.AddButton(1, "LOGOUT")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    screen=preShowLoginScreen("", "")
                    showLoginScreen(screen)
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                print "screen closed"
                exit while
            end if
        end if
    end while 
    dialog.Close()
End Function

Function showSearchScreen() As Void 
     screen = CreateObject("roKeyboardScreen")
     port = CreateObject("roMessagePort")
     screen.SetMessagePort(port)
     screen.SetTitle(getApplicationversion())
     screen.SetText("Tree of Life")
     screen.SetTitle("Search Screen")     
     screen.SetDisplayText("enter text to search")
     screen.SetMaxLength(25)
     screen.AddButton(1, "SEARCH")
     screen.AddButton(2, "BACK")
     screen.Show()
  
     while true
         msg = wait(0, screen.GetMessagePort())
         print "message received"
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isScreenClosed()
                 print "is screen closed clicked "; searchText
                 return
             else if msg.isButtonPressed() then
                 print "Evt:"; msg.GetMessage ();" idx:"; msg.GetIndex()
                 if msg.GetIndex() = 1
                     searchText = screen.GetText()                     
                     gridstyle = "Flat-Movie"
                     gridScreen = preShowSearchGridScreen(gridstyle)
                     showSearchGridScreen(gridScreen, gridstyle, searchText)
                     return
                 endif
                 if msg.GetIndex() = 2
                     print "press back"
                     return
                 endif
             endif
         endif
     end while
End Function

Function HttpEncode(str As String) As String
    o = CreateObject("roUrlTransfer")
    o.EnableEncodings(true)
    return o.Escape(str)
End Function