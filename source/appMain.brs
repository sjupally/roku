Sub Main()

    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    'prepare the screen for display and get ready to begin
    screen=preShowLoginScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowHomeScreen"
        return
    end if

    'set to go, time to get started
    showLoginScreen(screen)

End Sub


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"
    theme.OverhangLogoSD  = "pkg:/images/Overhang_Logo_SD.png"

    theme.OverhangOffsetHD_X = "128"
    theme.OverhangOffsetHD_Y = "63"
    theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"
    theme.OverhangLogoHD  = "pkg:/images/Overhang_Logo_HD.png"
    
    theme.GridScreenLogoOffsetSD_X  = "66"
    theme.GridScreenLogoOffsetSD_Y  = "40"
    theme.GridScreenOverhangSliceSD = "pkg:/images/GridScreenOverhangSliceSD.png"    
    theme.GridScreenLogoSD = "pkg:/images/GridScreenLogoSD.png"
    
    theme.GridScreenLogoOffsetHD_X  = "64"
    theme.GridScreenLogoOffsetHD_Y  = "25"
    theme.GridScreenOverhangSliceHD = "pkg:/images/GridScreenOverhangSliceHD.png"
    theme.GridScreenLogoHD = "pkg:/images/GridScreenLogoHD.png"
    
    theme.GridScreenBackgroundColor = "#D8D8D8"
    theme.GridScreenMessageColor    = "#424242"
    theme.GridScreenRetrievingColor = "#424242"
    theme.GridScreenListNameColor   = "#424242"
    
    ' Color values work here
    theme.GridScreenDescriptionTitl343434eColor    = "#343434"
    theme.GridScreenDescriptionDateColor     = "#343434"
    theme.GridScreenDescriptionRuntimeColor  = "#343434"
    theme.GridScreenDescriptionSynopsisColor = "#343434"
    
    'used in the Grid Screen
    theme.CounterTextLeft           = "#424242"
    theme.CounterSeparator          = "#424242"
    theme.CounterTextRight          = "#424242"
    
    app.SetTheme(theme)

End Sub
