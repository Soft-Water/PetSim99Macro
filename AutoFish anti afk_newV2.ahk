; Requires it to run on AHK V2
#Requires Autohotkey v2.0

; Environment variables
; REMOVED: #NoEnv  
#Warn
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)

; Initialise script variables
global workerActive, initialised, currentAction, filePath, guiPosX, guiPosY, hasClanBoost, multiplier, fishingZone, whitePixel_xCord, whitePixel_yCord, lbPixel_xCord, lbPixel_yCord, lbHexCode, lastarea_xCord, lastarea_yCord, forest_xCord, forest_yCord, tp_xCord, tp_yCord, lastareaScrollCount, ForestScrollCount, topLeft_greenPlay_xCord, topLeft_greenPlay_yCord, bottomRight_greenPlay_xCord, bottomRight_greenPlay_yCord, macroState
workerActive := "No"
initialised := false
currentAction := "Deactivated"
filePath := A_ScriptDir "\config.txt"
guiPosX := 0
guiPosY := 0
multiplier := "1"
lbHexCode := 0x1D1B19 


; â­ set these preferences, if you are not in a clan, put false
; â­ Put 1 if you want to go the 1st fishing zone, or 2 if you want to go to the 2nd fishing zone, this will tell the script where to go
; â­ don't put any of the changes in quotation marks
hasClanBoost := "true"
fishingZone := "1"

; â­ go the the pet simulator 99 game page, and use F6 to get the coordinates of the green play button
; â­ You'll need to do this twice, once to capture the top left of the button, once to capture bottom right of the button
topLeft_greenPlay_xCord := 1181
topLeft_greenPlay_yCord := 506
bottomRight_greenPlay_xCord := 1315
bottomRight_greenPlay_yCord := 560

; Helps with using both fishing and farming
macroState := 1

; â­ use F6 to get coordinates of a white pixel on the "Keep tapping to reel" text and put them here if the reeling is slow
whitePixel_xCord := 774 
whitePixel_yCord := 659

; â­ use F6 to get coordinates of the top of the server leaderboard, this is to check if you have rejoined the server after a disconnect
lbPixel_xCord := 1682
lbPixel_yCord := 55

; â­ use F6 to get coordinates of the teleporter icon on the left of the screen
tp_xCord := 183
tp_yCord := 430

; â­ F8 allows you to scroll through the teleporter map, the number of times it will scroll will be here
; â­ While scrolling through the teleporter, count how many times it moves until the place shows clearly and put here
lastareaScrollCount := "22"
ForestScrollCount := "21"

; â­ use F6 to get coordinates of the center of the desired area teleport icon when it comes into view after using F8
lastarea_xCord := 746
lastarea_yCord := 827

; â­ and the same for "cloud forest" if you have it unlocked
forest_xCord := 745
forest_yCord := 780


; Create GUI
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.Opt("+AlwaysOnTop")
myGui.BackColor := "FFFFFF"
myGui.SetFont("s14")
Tab := myGui.Add("Tab2", "w370 h200 Choose3", ["Status", "Commands", "Credits"])
myGui.Add("Text", "x23 y48", "Script Enabled:")
ogcWorkerText := myGui.Add("Text", "x153 y48 w100 h30 Left vWorkerText", workerActive)
myGui.Add("Text", "x23 y78", "Current Action:")
ogcActionText := myGui.Add("Text", "x153 y78 w250 h60 Left vActionText", currentAction)

; tab 2, commands/keystrokes
Tab.UseTab(2)
myGui.Add("Text", "x23 y48", "F1 to activate fishing macro")
myGui.Add("Text", "x23 y78", "F2 to deactivate fishing macro")
myGui.Add("Text", "x23 y108", "F6 to get coordinates of mouse position")
myGui.Add("Text", "x23 y138 w400 h60", "F7 to rejoin")
myGui.Add("Text", "x23 y168", "F8 to navigate teleporter map")

; tab 3, Credits
Tab.UseTab(3)
myGui.SetFont("s10")
myGui.Add("Text", "x23 y48", "The base for the macro was made by itscollector on Discord")
myGui.Add("Text", "x23 y70", "and Github.  I only edited it to my desire.")
ogcButtonHisGitHubpage := myGui.Add("Button", , "His GitHub page")
ogcButtonHisGitHubpage.OnEvent("Click", Githubpage.Bind("Normal"))
ogcButtonHisDiscordserver := myGui.Add("Button", , "His Discord server")
ogcButtonHisDiscordserver.OnEvent("Click", Discordserver.Bind("Normal"))

tab.choose(1) ; sets the default tab. 1 is for status, 2 is for commands, 3 is for credits.

FileObj := FileOpen(filePath, "r")

if (FileObj)
{
    content := FileObj.read()
    FileObj.Close()
    lines := StrSplit(content, ",")
    guiPosX := lines[1]
    guiPosY := lines[2]
; bug fix where value saved is -32k, -32k. Not sure why its happening but this will reset positon
if (guiPosX = -32000 || guiPosY = -32000) 
{
    guiPosX := 0
    guiPosY := 0 
}
    myGui.Title := "Soft Water's PS99 Macro"
    myGui.Show("x" guiPosX " y" guiPosY " w" 440 " h" 230)
}
else 
{
    myGui.Title := "Soft Water's PS99 Macro"
    myGui.Show("w350 h170")
}

F1::
{ ; V1toV2: Added bracket
    MainLoop()
} ; Added bracket before function

MainLoop()
{
    ; this is to allow the rod to be cast into the water, if there is no bobber icon on the cursor then the rod can't be cast
    if (initialised = false) 
    {
        ogcActionText.Value := "Initialising"
        ogcWorkerText.Value := "Yes"

        Loop 3
            {
                MouseMove(A_ScreenWidth - (A_ScreenWidth / 3), A_ScreenHeight - (A_ScreenHeight * 0.6))
                Sleep(100)
                MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight * 0.6))
                Sleep(100)
            }
        
        if (hasClanBoost) ; No need for == true
        {
            multiplier1 := 1
        }
        else 
        {
            multiplier2 := 1.2
        }

        MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2))
        initialised1 := true
    }

    ; Responsible for farming
    while (true)
    { 
        if (macroState=1)
        {
            whiteHexCode := 0xFFFFFF
            blackHexCode := 0x000000

            ; Searching for white pixel on the "Keep tapping to reel" text
            ErrorLevel := PixelSearch(&OutputVarX, &OutputVarY, whitePixel_xCord, whitePixel_yCord, whitePixel_xCord, whitePixel_yCord, whiteHexCode, , ) ;V1toV2: Switched from BGR to RGB values

            if (ErrorLevel = 0) ; fish has bitten the rod
            {
                ogcActionText.Value := "Reeling fish"

                Loop 5 ; reels in fish
                {
                    Click("A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)")
                    Sleep(10)
                }  
            }
            
            if (ErrorLevel = 1) ; fish has not bitten the rod
            {   
                ogcActionText.Value := "Casting line"

                Sleep(500) ; delay for after reeling in fish 
                Click("A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)") ; this click does two jobs, casts the line and starts the mini-game if a fish has bitten
                Sleep(500) ; delay to check if fish has bitten first

                ErrorLevel := PixelSearch(&OutputVarX, &OutputVarY, whitePixel_xCord, whitePixel_yCord, whitePixel_xCord, whitePixel_yCord, whiteHexCode, , ) ;V1toV2: Switched from BGR to RGB values

                if (ErrorLevel = 1) ; fish has not bitten straight away, delays to make fish bite
                {
                    Sleep(2600)
                }
            }
        }
        ; put else if for fishing part, leave disconnection part under it
        else
        {
            Sleep(500)
        }
        ; Check if you disconnected from the server 
        ErrorLevel := ImageSearch(&FoundX, &FoundY, A_ScreenWidth * 0.25, A_ScreenHeight * 0.25, A_ScreenWidth * 0.5, A_ScreenHeight * 0.5, "*10 *Trans10 " A_ScriptDir "\Images\disconnect.png")

        if (ErrorLevel = 0)
        {
            ogcActionText.Value := "Detected disconnection, rejoining"
            Rejoin()
        }

        ; Check if instance of roblox is open
        ErrorLevel := ProcessExist("RobloxPlayerBeta.exe")

        if (ErrorLevel = 0)
        {
            ogcActionText.Value := "Detected disconnection, rejoining"
            Rejoin()
        }
    }

    return
}

; Saves position of GUI to config file
SaveGuiPos(filePath)
{
    WinGetPos(&OutX, &OutY, &OutWidth, &OutHeight, "Soft Water's PS99 Macro")
    cordfile := FileOpen(filePath, "w")

    if (cordfile) 
    {
        cordfile.Write(OutX "," OutY)
        cordfile.Close()
    } 
    else 
    {
        MsgBox("Failed to open the file for writing.")
    }

    return
}

Rejoin()
{
    Run("roblox://placeID=8737899170")
    Sleep(10000)

    ogcActionText.Value := "Loading in"
    Sleep(500)

    loaded := false
    
    while (loaded = false)
    {
        ErrorLevel := PixelSearch(&OutX, &OutY, lbPixel_xCord, lbPixel_yCord, lbPixel_xCord, lbPixel_yCord, lbHexCode, , ) ;V1toV2: Switched from BGR to RGB values
        
        ; Checks leaderboard pixel in top right 
        if (ErrorLevel = 0)
        {
            ;GuiControl,, ActionText, Loaded in
            loaded := true
            Sleep(5000)
        }
        else if (ErrorLevel = 1)
        {
            Sleep(5000)
        }
        else if (ErrorLevel = 2)
        {
            MsgBox("Failed to begin search for pixel")
        }
    }

    GoToFishingZone1()

    return
}

; Path to fishing zone 1
GoToFishingZone1()
{

    {
        ogcActionText.Value := "Looking for last area on map"
        ; Open map
        MouseMove(tp_xCord, tp_yCord)
        Sleep(100)
        MouseMove(tp_xCord + 2, tp_yCord)
        Sleep(100)
        Click()
        MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2))
        Sleep(10)
        MouseMove(A_ScreenWidth - (A_ScreenWidth / 2) + 2, A_ScreenHeight - (A_ScreenHeight / 2))
        Sleep(10)

        ; Scroll down map
        Loop lastareaScrollCount
        {
            Click("WheelDown")
            Sleep(500)
        }

        ; Enable last area buttons
        MouseMove(lastarea_xCord, lastarea_yCord)
        Sleep(10)
        MouseMove(lastarea_xCord + 2, lastarea_yCord)
        Sleep(10)
        Click()

        ogcActionText.Value := "Walking to middle"
        ; Walk to area 
        Sleep(multiplier * 8000)
        Send("{d Down}")
        Sleep(2790)
        Send("{d Up}")
    }
   
    ; Angle camera
    MouseMove(A_ScreenWidth * 0.5, A_ScreenHeight * 0.5)
    Sleep(10)
    Click("right down")
    Sleep(70)
    MouseMove(A_ScreenWidth * 0.5, A_ScreenHeight * 0.6)
    Sleep(50)
    
    Loop (6)
    {
        Click("WheelDown")
        Sleep(500)
    }

    ; Start fishing
    MainLoop()
    return
}

; Path for fishing zone 2
GoToFishingZone2(kickedType)
{
    if (kickedType = 1)
    {
        ogcActionText.Value := "Looking for Cloud Forest on map"
        ; Open map
        MouseMove(tp_xCord, tp_yCord)
        Sleep(100)
        MouseMove(tp_xCord + 2, tp_yCord)
        Sleep(100)
        Click()
        MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2))
        Sleep(10)
        MouseMove(A_ScreenWidth - (A_ScreenWidth / 2) + 2, A_ScreenHeight - (A_ScreenHeight / 2))
        Sleep(10)

        ; Scroll down map
        Loop ForestScrollCount
        {
            Click("WheelDown")
            Sleep(1000)
        }

        ; Enable cloud forest buttons
        MouseMove(forest_xCord, forest_yCord)
        Sleep(10)
        MouseMove(forest_xCord + 2, forest_yCord)
        Sleep(10)
        Click()

        ogcActionText.Value := "Walking to portal"
        ; Walk to portal
        Sleep(multiplier * 8000)
        Send("{s Down}")
        Sleep(multiplier * 7000)
        Send("{s Up}")
        Sleep(10)
        Send("{d down}")
        Sleep(multiplier * 3000)
        Send("{d up}")
        Sleep(10)
        Send("{s down}")
        Sleep(multiplier * 1000)
        Send("{s up}")
        Sleep(5000)
    }
    else if (kickedType = 2)
    {
        ogcActionText.Value := "Walking to portal"
        ; Goes back through portal
        Send("{s Down}")
        Sleep(multiplier * 2000)
        Send("{s Up}")
        Sleep(5000)
    }

    ogcActionText.Value := "Walking to ocean"
    ; Walk to ocean
    Send("{w Down}")
    Sleep(multiplier * 8000)
    Send("{w Up}")
    
    ; Angle camera
    MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2))
    Sleep(10)
    Click("right down")
    Sleep(10)
    MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 - 1))
    Sleep(10)
    Click("right up")
    Sleep(10)

    ; Start fishing
    MainLoop()
    return
}

F8::
{ ; V1toV2: Added bracket
    ogcWorkerText.Value := "Yes"
    ogcActionText.Value := "Scrolling down teleporter map"
    ; Open map
    MouseMove(tp_xCord, tp_yCord)
    Sleep(100)
    MouseMove(tp_xCord + 2, tp_yCord)
    Sleep(100)
    Click()
    MouseMove(A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2))
    Sleep(10)
    MouseMove(A_ScreenWidth - (A_ScreenWidth / 2) + 2, A_ScreenHeight - (A_ScreenHeight / 2))
    Sleep(10)

    if (fishingZone = 1)
    {
        Loop lastareaScrollCount
        {
            Click("WheelDown")
            Sleep(1000)
        }
    }
    else if (fishingZone = 2)
    {
        Loop ForestScrollCount
        {
            Click("WheelDown")
            Sleep(1000)
        }
    }

    ogcWorkerText.Value := "No"
    ogcActionText.Value := "Deactivated"

    MsgBox("if it scrolled past the target location teleport icon, you will need to edit the ScrollCount value in the script near the top, it will have a â­ on it")
    MsgBox("if the scrolling revealed the target location teleport icon as you expected, use F6 to get the coordinates of the button and add them to the script after closing this message.")
    SaveGuiPos(filePath)
    Reload()
} ; Added bracket before function

GuiClose(*) ; Closes the script if you click on the X button on the GUI
{ ; V1toV2: Added bracket
    SaveGuiPos(filePath)
    ExitApp()
    return
} ; V1toV2: Added Bracket before hotkey or Hotstring

F2:: ; Reloads script, use when you want to stop the macro without closing it
{ ; V1toV2: Added bracket
    SaveGuiPos(filePath)
    Reload()
    return
} 

F6:: ; F6 to grab coordinates of mouse position, use if you need to change any of the coordinates
{ 
    MouseGetPos(&MouseX, &MouseY)
    MsgBox("Mouse Coordinates:`nX: " MouseX "`nY: " MouseY)
    return
} 
F7::
{ 
  Rejoin()
  return
} 
Githubpage(A_GuiEvent, GuiCtrlObj, Info, *) ; opens github page
{ 
    Run("https://github.com/ItsCollector")
    return
} 
Discordserver(A_GuiEvent, GuiCtrlObj, Info, *) ; opens discord server
{ 
    Run("https://discord.gg/zfyme4d7qE")
    return
}
