'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowLoginScreen(breadA=invalid, breadB=invalid) As Object

    screen = CreateObject("roKeyboardScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    return screen

End Function


'******************************************************
'** Display the login screen
'******************************************************
Function showLoginScreen(screen) As Integer
     print"login started"
     screen = CreateObject("roKeyboardScreen")
     port = CreateObject("roMessagePort")
     screen.SetMessagePort(port)
     emailScreen = keyBoardScreenObjectCreation("Email", screen, false)
     emailScreen.Show()
     actionPerformedAfterDetailsEnteredOnKeyBoard(emailScreen)
     
     print"password started"
     passwordScreen = CreateObject("roKeyboardScreen")
     passwordPort = CreateObject("roMessagePort")
     passwordScreen.SetMessagePort(port)
     passwordScreen = keyBoardScreenObjectCreation("Password", passwordScreen, false)
     passwordScreen.Show()
     actionPerformedAfterDetailsEnteredOnKeyBoard(passwordScreen)
     return 0

End Function

Function keyBoardScreenObjectCreation(event as String, screen as Object, flag as boolean) as Object
    if event = "Email"
        screen.SetTitle(getApplicationversion())
        'screen.SetText("Email address")
        screen.SetText("sfregression2.0+20082015@gmail.com")
        screen.SetDisplayText("Enter a valid Email ID ")
        screen.SetMaxLength(100)        
        screen.AddButton(1, "CONTINUE")
    else if event = "Password"
        screen.SetTitle(getApplicationversion())
        'screen.SetText("Password")
        screen.AddButton(2, "LOGIN")
        screen.AddButton(3, "BACK")
        screen.SetText("sfqatest12345")
        screen.SetSecureText(true)
        screen.SetDisplayText("Enter password")
        screen.SetMaxLength(30)
    end if

    return screen
End Function 

Function actionPerformedAfterDetailsEnteredOnKeyBoard(screen as Object) as Void
    while true
        message = wait(0, screen.GetMessagePort())
        LoggOrDbg("Message received", "")
        if type(message) = "roKeyboardScreenEvent"
            if message.isScreenClosed()
                return
            else if message.isButtonPressed() then
                LoggOrDbg("Event: ", message.GetMessage())
                LoggOrDbgStrInt(" id: ", message.GetIndex())
                if message.GetIndex() = 1
                    userName = screen.GetText()
                    userName = strTrim(userName)
                    
                    if userName.Len() = 0
                        ShowLoginFailedMessageDialog("email")
                    else
                        SetUserName(userName)
                        return
                    end if
                end if

				if message.GetIndex() = 3
					screenlogin = preShowLoginScreen("", "")
                    showLoginScreen(screenlogin)
				end if
                
                if message.GetIndex() = 2
                    password = screen.GetText()
                    username = GetUserName()
                    
                    if password.Len() = 0
                        ShowLoginFailedMessageDialog("password")
                    else
                        'associativeArray = grant_type=password&username=srikanth.jupally%40valuelabs.com&password=snappy&client_id=dac9e38c76b111e4925e68b599f571ed&client_secret=e61f818876b111e4994b68b599f571ed&context=%2Fhp%2Fsf%2Fsf-us%2Fsnapfish-us
                        param = "grant_type=password&username=" + Encode(userName) + "&password=" + password + "&client_id=dac9e38c76b111e4925e68b599f571ed&client_secret=e61f818876b111e4994b68b599f571ed&context=/hp/sf/sf-us/snapfish-us"
                        restClientPostUserAuth(authenticateURL(), param)

                        JSONRespCode = GetJSONResponseCode()
                        LoggOrDbg("JSON Response: ", JSONRespCode)

                        if JSONRespCode = "200"
                            LoggOrDbg("Success...", "")
                            setTermsURL()
                            showTermsAndConditionsDlg()
                        else if JSONRespCode = "401"
                            LoggOrDbg("Unauthorized User", "")
                            ShowLoginFailedMessageDialog("401")
                            keyBoardScreenObjectCreation("Email", screen, true)
                        else if JSONRespCode = "400"
                            LoggOrDbg("Bad Request", "")
                            ShowLoginFailedMessageDialog("400")
                        else if JSONRespCode = "500"
                            LoggOrDbg("Internal Server Error", "")
                            ShowLoginFailedMessageDialog("500")
                        end if
                    end if               
                end if
            end if
        end if
    end while
End Function

Function Encode(str As String) As String
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
End Function