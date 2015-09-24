Function ShowLoginFailedMessageDialog(failedType As String) As Void
	port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
	
	if failedType = "401"
		dialog.SetTitle("Login failed")
		dialog.SetText("Invalid user name / Password.")
	else if failedType = "400"
		dialog.SetTitle("Login failed")
		dialog.SetText("Login failed - Bad Request.")	
	else if failedType = "500"
		dialog.SetTitle("Login failed")
		dialog.SetText("Internal server error.")	
	else if failedType = "email"
		dialog.SetTitle("Blank email address")
		dialog.SetText("Please enter email address.")
	else if failedType = "password"
		dialog.SetTitle("Blank password")
		dialog.SetText("Please enter password.")		
	end if
    
    dialog.AddButton(1, "OK")
    
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                print "dlgMsg.GetIndex()  ";dlgMsg.GetIndex() = 1
                if dlgMsg.GetIndex() = 1
                    screen=preShowLoginScreen("", "")
                    if screen=invalid then
                        print "unexpected error in preShowHomeScreen"
                        return
                    end if
                
                    'set to go, time to get started
                    showLoginScreen(screen)
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
End Function

Function showNodataFound() As Void   
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    
    dialog.SetTitle("No Data Found")
    dialog.SetText("Invalid search criteria. Please try again")
    dialog.AddButton(1, "OK")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                print "dlgMsg.GetIndex()  ";dlgMsg.GetIndex() = 1
                if dlgMsg.GetIndex() = 1
                    posterScreen=preShowPosterScreen("", "")
                    showPosterScreen(posterScreen)
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while    
End Function

Function showTermsAndConditionsDlg() As Void 
    port = CreateObject("roMessagePort")
    screen = CreateObject("roTextScreen")
    screen.SetMessagePort(port)    
    screen.SetTitle(getApplicationversion())
    screen.SetHeaderText("Terms and Conditions")
    screen.AddText("Welcome to Snapfish! Snapfish provides members a fun, safe, and easy way to process, print, digitize, store, share and otherwise use (collectively Process) photographs. However, before you use or access the Snapfish Service, as defined below, you must carefully review the Terms and Conditions set out below (the Terms). In addition, specific pages on the Site may set out additional terms and conditions, all of which are incorporated by reference into these Terms. These Terms may be changed or updated at any time, but you can always find the most recent version here. In the case of inconsistencies between these Terms and information included in off-line materials (for example, promotional materials and mailers), these Terms will always control. You should periodically check this page to make sure you are up to date.")   
    screen.AddButton(1, "Agree")
    'screen.EnableBackButton(true)
    screen.Show()
    While True
        dlgMsg = wait(0, screen.GetMessagePort())
        If type(dlgMsg) = "roTextScreenEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 1
                    print "Terms button pressed " ;  dlgMsg.GetIndex()
                    posterScreen=preShowPosterScreen("", "")
                    showPosterScreen(posterScreen)
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while
End Function

'******************************************************
'Show basic message dialog without buttons
'Dialog remains up until caller releases the returned object
'******************************************************
Function ShowPleaseWait(title As dynamic, text As dynamic) As Object
    
    port = CreateObject("roMessagePort")
    dialog = invalid

    'the OneLineDialog renders a single line of text better
    'than the MessageDialog.
    if text = ""
        dialog = CreateObject("roOneLineDialog")
    else
        dialog = CreateObject("roMessageDialog")
        dialog.SetText(text)
    endif

    dialog.SetMessagePort(port)

    dialog.SetTitle(title)
    dialog.ShowBusyAnimation()
    dialog.Show()
    return dialog
End Function

Function showLanguageList() As String   
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port)
    list = getLanguagesOfMovie()
    dialog.SetTitle("Select Language")
    i = 0
    for each language in list
        dialog.AddButton(i, language)
        i = i + 1
    end for
    'dialog.AddButton(1, "OK")
    dialog.EnableBackButton(true)
    dialog.Show()
    While True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                print "Selected language  ";list[dlgMsg.GetIndex()]
                return list[dlgMsg.GetIndex()]
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while    
End Function