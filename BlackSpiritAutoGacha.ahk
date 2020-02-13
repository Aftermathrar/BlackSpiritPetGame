;Scripted poorly by Aftermath, version 0.5

;Use Alt + D to start and pause the script
;Alt + F will rerun the Gacha setup
;It very simply activates the discord window and pastes in a message, make sure to be in #black-desert-law when using

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force ; Makes sure the script only runs one at a time

isFarmingActive = 0
mySilver = 0
slowModeTimer = 0
farmMessageTimer = 0

iniCheck := FileExist("BlackSpiritAutoGacha.ini")
if (iniCheck != "")
{
	;Read sections of file into arrays
	ParseIniFile("BlackSpiritAutoGacha.ini")
}
else
{
	;Initialize gacha tracking variables
	Global BaseIncome = 100
	Global gachaBet = 1
	Global loopCount = 0
	Global timeBetweenRolls = 61000
	Global gachaString = 100
	Global gachaListboxSelect = 1
	Global StartHotKey = "!d"
	Global MenuHotKey = "!f"

	AssignHotKeys(StartHotKey, MenuHotKey)
	AutoGachaSetup()

	;Create and initialize ini file
	CreateIniFile("BlackSpiritAutoGacha.ini")
}
return

ShowMenu:
AutoGachaSetup()
return

StartPause:
if (isFarmingActive == 0)
{
	global timeBetweenRolls
	isFarmingActive = 1

	SendFarmMessage()
	SetTimer, SendFarmMessage, 61000

	SetTimer, RollGacha, %timeBetweenRolls%
}
else
{
	MsgBox, Pausing script
	isFarmingActive = 0
	SetTimer, SendFarmMessage, Off
	SetTimer, RollGacha, Off
}
return

IncomeSetupButtonExitScript:
MsgBox, Exiting script.
iniCheck := FileExist("BlackSpiritAutoGacha.ini")
if (iniCheck != "")
{
	SaveSettings()
}
ExitApp

; F4::
; 	Reload
; 	Sleep 1000
; return

SendFarmMessage()
{
	global flavorText
	global zoneNames
	Random, messageType, 1, 4

	if (messageType == 1)
	{	
		Random, i, 1, zoneNames.MaxIndex()
		randomZone := zoneNames[i]
		farmString := "Farmed " loopCount " silver in " randomZone
	}
	else
	{
		Random, i, 1, flavorText.MaxIndex()
		Transform, farmString, Deref, % flavorText[i]
	}

	global slowModeTimer
	
	if (WinExist("ahk_exe Discord.exe") && (A_TickCount - slowModeTimer > 6500))
	{
		WinActivate
		Send, %farmString% {Enter}	

		global BaseIncome
		global mySilver += BaseIncome
		loopCount := ++loopCount

		slowModeTimer := A_TickCount

		global farmMessageTimer := A_TickCount

		Sleep 3000
		LootBoxCheck()
	}

	return
}

LootBoxCheck()
{
	IfExist, ImageReact1.PNG
	{
		ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, ImageReact1.PNG
		If (ErrorLevel = 0) 
		{
			MouseClick, Left, %FoundX%, %FoundY%
		}
	}
}

RollGacha()
{
	global gachaListboxSelect
	global gachaBetStr

	for index, element in gachaListboxSelect
	{
		silver := RemainingSilver(element)
		if (silver >= 0)
		{
			global gachaString
			gachaString := gachaBetStr[element]
			break
		}
	}
	if (WinExist("ahk_exe Discord.exe") && silver >= 0)
	{
		global slowModeTimer
		global farmMessageTimer
	

		if(A_TickCount - slowModeTimer > 6500 && A_TickCount - farmMessageTimer <= 54000)
		{
			WinActivate
			global gachaString
			Send, {!}gacha %gachaString% {enter}
			slowModeTimer := A_TickCount
			global mySilver := silver
		}
	}
	return
}

RemainingSilver(i)
{
	global mySilver
	global gachaAmount

	silver := mySilver - gachaAmount[i]
	return silver
}

AutoGachaSetup()
{
	global gachaAmount
	global mySilver
	global txtRollTimer
	global timerSlider
	rollTimer := Round(timeBetweenRolls/1000, 1)

	Gui, IncomeSetup:New, , Setup Auto-Gacha
	Gui, Add, Text,, Silver Income:
	Gui, Add, Text, , Gacha Amount:
	Gui, Add, Slider, vtimerSlider gSliderChange Range7-31 TickInterval6 w80, %rollTimer%
	Gui, Add, Text, vtxtRollTimer r2.5, Gacha roll every`n%rollTimer% seconds
	Gui, Add, Text,, Start/Pause:
	Gui, Add, Text,, Show Menu:
	Gui, Add, Edit, vBaseIncome w100 ym, %BaseIncome% 
	Gui, Add, ListBox, 8 r7 vGachaBet +AltSubmit, 100|1k|5k|25k|100k|500k|1m
	Gui, Add, HotKey, vStartHotKey, %StartHotKey%
	Gui, Add, HotKey, vMenuHotKey, %MenuHotKey%
	Gui, Add, Button, default w80, OK 
	Gui, Add, Button, ym, Exit Script
	Gui, Add, Button, , Add New Message
	Gui, Add, Button, , View Pet
	Gui, Add, Text, , Silver
	Gui, Add, Edit, vmySilver
	Gui, Show,, Setup Auto-Gacha
	HotKey, %StartHotKey%, Off
	HotKey, %MenuHotKey%, Off

	for index, element in gachaListboxSelect
	{
		GuiControl, Choose, Listbox1, %element%
	}
	GuiControl, , Edit2, %mySilver%

	return
	
IncomeSetupButtonOK:
	Gui, Submit

	if BaseIncome is integer
		myIncome = %BaseIncome%
	else
	{
		MsgBox, Invalid silver income entry, using 100 as default
		myIncome = 100
		BaseIncome = %myIncome%
	}

	if (gachaBet == "")
	{
		gachaBet := 1
	}

	Sort gachaBet, R D|

	global gachaListboxSelect := []
	Loop, Parse, gachaBet, |
	{
		gachaListboxSelect.Push(A_LoopField)
	}

	ManualSetTimeBetweenRolls(timerSlider*1000)
	
	;Check if farming is active, update timer if so
	global isFarmingActive
	if (isFarmingActive == 1)
	{
		SetTimer, RollGacha, %timeBetweenRolls%
	}

	AssignHotKeys(StartHotKey, MenuHotKey)

IncomeSetupGuiClose:
	Gui, Hide
	HotKey, %StartHotKey%, On
	HotKey, %MenuHotKey%, On
	return

IncomeSetupButtonAddNewMessage:
	;Gui, Hide
	CreateNewMessage()
	return

SliderChange:
	GuiControl, , txtRollTimer, Gacha roll every`n%timerSlider% seconds
	return
}

SetTimeBetweenRolls(bet, income)
{
	;Get seconds between rolls by dividing 61 seconds by possible rolls per minute
	global timeBetweenRolls := Ceil(61000 * bet / income)

	if (timeBetweenRolls < 6100)
	{
		timeBetweenRolls = 6100
	}
	return
}

ManualSetTimeBetweenRolls(t)
{
	global timeBetweenRolls := t

	if (timeBetweenRolls < 6100)
	{
		timeBetweenRolls = 6100
	}
	return
}

CreateNewMessage()
{
	global newFlavorText

	Gui, NewMessage:New, , NewFlavorText
	Gui, Add, Text, , New message to add. Select variables to add.`nMath not supported currently.
	Gui, Add, Button, section, Loop Count
	Gui, Add, Button, ys, Gacha Bet
	Gui, Add, Button, ys, Income
	Gui, Add, Button, section ys, Silver
	Gui, Add, Edit, xm w260 vnewFlavorText
	Gui, Add, Button, default w80, OK
	Gui, Show

	return

NewMessageButtonOK:
	Gui, Submit, NoHide
	Transform, sPreview, DeRef, %newFlavorText%
	PreviewNewMessage(sPreview)
	return

NewMessageButtonLoopCount:
	AppendVariable("%loopCount% ")
	Return
	
NewMessageButtonGachaBet:
	AppendVariable("%gachaString% ")
	Return
	
NewMessageButtonIncome:
	AppendVariable("%BaseIncome% ")
	Return

NewMessageButtonSilver:
	AppendVariable("%mySilver% ")
	Return
}

AppendVariable(sVariable)
{
	GuiControlGet, sTemp, , Edit1
	GuiControl, , Edit1, % sTemp . sVariable
	GuiControl, Focus, Edit1
	SendMessage, 0xB1, -2, -1, Edit1
	Return
}

PreviewNewMessage(sPreview)
{
	global newFlavorText
	Gui, StringPreview:New, , PreviewMessage
	Gui, Add, Text, , Preview:`n%sPreview%
	Gui, Add, Button, section default w80, Confirm
	Gui, Add, Button, ys w80, Cancel
	Gui, Show
	Gui +LastFound
	WinWaitClose
	return

StringPreviewButtonConfirm:
	global flavorText
	flavorText.Push(newFlavorText)
	Gui, Submit
	Gui, NewMessage:Hide
	return

StringPreviewButtonCancel:
StringPreviewGuiClose:
	Gui, StringPreview:Destroy
	Return 
}

IncomeSetupButtonViewPet:
{
	MsgBox, Not implemented yet
	return
}

AssignHotKeys(hkStart, hkMenu)
{
	HotKey, %hkStart%, StartPause
	HotKey, %hkMenu%, ShowMenu
}

CreateIniFile(destFileStr)
{
	SaveSettings()

	global gachaAmount := []
	GetGachaAmounts()
	srcStrTemp := ""
	
	for index, element in gachaAmount
	{
		srcStrTemp .= index "=" element "`n"
	}
	IniWrite, %srcStrTemp%, %destFileStr%, GachaAmounts

	global gachaBetStr := []
	GetGachaBets()
	srcStrTemp := ""
	
	for index, element in gachaBetStr
	{
		srcStrTemp .= index "=" element "`n"
	}
	IniWrite, %srcStrTemp%, %destFileStr%, GachaBets

	global flavorText := []
	GetFlavorText()
	srcStrTemp := ""

	for index, element in flavorText
	{
		srcStrTemp .= index "=" element "`n"
	}
	IniWrite, %srcStrTemp%, %destFileStr%, Messages

	global zoneNames := []
	GetZoneNames()
	srcStrTemp := ""

	for index, element in zoneNames
	{
		srcStrTemp .= index "=" element "`n"
	}
	IniWrite, %srcStrTemp%, %destFileStr%, Zones
	
	global petNames := []
	GetPetNames()
	srcStrTemp := ""

	for index, element in petNames
	{
		srcStrTemp .= index "=" element "`n"
	}
	IniWrite, %srcStrTemp%, %destFileStr%, Pets
}

ParseIniFile(srcFileStr)
{
	global loopCount
	global BaseIncome
	global mySilver
	global timeBetweenRolls
	global gachaString
	global gachaBet
	global StartHotKey
	global MenuHotKey

	iniStrArray := []

	IniRead, iniStrOut, %srcFileStr%, UserSettings
	iniStrArray := StrSplit(iniStrOut, "`n")

	loopCount := SubStr(iniStrArray[1], instr(iniStrArray[1], "=") + 1)
	BaseIncome := SubStr(iniStrArray[2], instr(iniStrArray[2], "=") + 1)
	mySilver := SubStr(iniStrArray[3], instr(iniStrArray[3], "=") + 1)
	timeBetweenRolls := SubStr(iniStrArray[4], instr(iniStrArray[4], "=") + 1)
	gachaString  := SubStr(iniStrArray[5], instr(iniStrArray[5], "=") + 1)
	gachaBet := SubStr(iniStrArray[6], instr(iniStrArray[6], "=") + 1)
	StartHotKey  := SubStr(iniStrArray[7], instr(iniStrArray[7], "=") + 1)
	MenuHotKey  := SubStr(iniStrArray[8], instr(iniStrArray[8], "=") + 1)

	global gachaListboxSelect := []
	Loop, Parse, gachaBet, |
	{
		gachaListboxSelect.Push(A_LoopField)
	}
	
	AssignHotKeys(StartHotKey, MenuHotKey)

	IniRead, iniStrOut, %srcFileStr%, GachaAmounts
	iniStrArray := StrSplit(iniStrOut, "`n")

	Global gachaAmount := []
	for index, element in iniStrArray
	{
		gachaAmount.Push(SubStr(element, InStr(element, "=") + 1))
	}

	IniRead, iniStrOut, %srcFileStr%, GachaBets
	iniStrArray := StrSplit(iniStrOut, "`n")

	Global gachaBetStr := []
	for index, element in iniStrArray
	{
		gachaBetStr.Push(SubStr(element, InStr(element, "=") + 1))
	}

	IniRead, iniStrOut, %srcFileStr%, Messages
	iniStrArray := StrSplit(iniStrOut, "`n")

	Global flavorText := []
	for index, element in iniStrArray
	{
		flavorText.Push(SubStr(element, InStr(element, "=") + 1))
	}

	IniRead, iniStrOut, %srcFileStr%, Zones
	iniStrArray := StrSplit(iniStrOut, "`n")

	Global zoneNames := []
	for index, element in iniStrArray
	{
		zoneNames.Push(SubStr(element, InStr(element, "=") + 1))
	}

	IniRead, iniStrOut, %srcFileStr%, Pets
	iniStrArray := StrSplit(iniStrOut, "`n")

	Global petNames := []
	for index, element in iniStrArray
	{
		petNames.Push(SubStr(element, InStr(element, "=") + 1))
	}
}

SaveSettings()
{
	global loopCount
	global BaseIncome
	global mySilver
	global timeBetweenRolls
	global gachaString
	global gachaListboxSelect
	global StartHotKey
	global MenuHotKey

	srcStrTemp := "LoopCount=" loopCount "`nIncome=" BaseIncome "`nSilverBalance=" mySilver "`nGachaTimer=" timeBetweenRolls "`nGachaString=" gachaString "`nGachaListBox=" gachaBet "`nStartPause=" StartHotKey "`nMenu=" MenuHotKey
	IniWrite, %srcStrTemp%, BlackSpiritAutoGacha.ini, UserSettings

	srcStrTemp := ""
	global flavorText
	if (flavorText = "")
	{
		GetFlavorText()
	}
	for index, element in flavorText
	{
		srcStrTemp .= index "=" element "`n"
	}
	IniWrite, %srcStrTemp%, BlackSpiritAutoGacha.ini, Messages
}

GetGachaAmounts()
{
	global gachaAmount

	gachaAmount.Push(100)
	gachaAmount.Push(1000)
	gachaAmount.Push(5000)
	gachaAmount.Push(25000)
	gachaAmount.Push(100000)
	gachaAmount.Push(500000)
	gachaAmount.Push(1000000)
}

GetGachaBets()
{
	global gachaBetStr

	gachaBetStr.Push("100")
	gachaBetStr.Push("1k")
	gachaBetStr.Push("5k")
	gachaBetStr.Push("25k")
	gachaBetStr.Push("100k")
	gachaBetStr.Push("500k")
	gachaBetStr.Push("1m")
}

GetFlavorText()
{
	global FlavorText

	flavorText.Push("On move %loopCount% trying to complete this 3x3 puzzle")
	flavorText.Push("Looted %loopCount% silver from other users")
	flavorText.Push("Found %loopCount% silver on an alt")
	flavorText.Push("Acquired %loopCount% silver through illegal means")
	flavorText.Push("Guys, I think the Black Spirit status message affects the gacha odds :blabtinfoil:")
	flavorText.Push("Died %loopCount% times to Kzarka flame breath")
	flavorText.Push("Traded %loopCount% Black Pearls from an alt account")
	flavorText.Push("Fused %loopCount% weapon outfits without success")
	flavorText.Push("%loopCount% outlaw kills while afk")
	flavorText.Push("%loopCount% silver(s) please :BSThbptGIF:")
	flavorText.Push("Asking mommy to borrow $%loopCount% for shakatu coins")
	flavorText.Push("Cheated out of %loopCount% pets by the Black Spirit")
	flavorText.Push("Failed %loopCount% times on force enhances")
	flavorText.Push("Using %loopCount% potions per hour on my Sorceress")
	flavorText.Push("%loopCount% loss streak in arena")
	flavorText.Push("When is the next maintenance?")
	flavorText.Push("Spent %loopCount%k coins at Shakatu, no oranges REEEEE")
	flavorText.Push(":SangGotYa:")
	flavorText.Push("afk for %loopCount% minutes")
	flavorText.Push("%loopCount% hours since someone rolled a pet")
	flavorText.Push("{!}gatcha %gachaString%")
}

GetZoneNames() 
{
	Global zoneNames

	zoneNames.Push("Cron Castle Entrance")
	zoneNames.Push("Hexe Sanctuary")
	zoneNames.Push("Witch's Chapel")
	zoneNames.Push("Phoniel's Cabin")
	zoneNames.Push("Cron Castle Patrol")
	zoneNames.Push("Marni's Second Lab")
	zoneNames.Push("Marni's Underground")
	zoneNames.Push("Cron Castle")
	zoneNames.Push("Wandering Rogues' Camp")
	zoneNames.Push("Wandering Rogues' Den")
	zoneNames.Push("Omar Lava Fields")
	zoneNames.Push("Manes Cave")
	zoneNames.Push("Manes' Hideout")
	zoneNames.Push("Omar Lava Cave")
	zoneNames.Push("Soldier's Grave")
	zoneNames.Push("Soldier's Grave Depths")
	zoneNames.Push("Hasrah Ruins Entrance")
	zoneNames.Push("Hasrah Ancient Ruins")
	zoneNames.Push("Nightmare Witch's Chapel")
	zoneNames.Push("Velia Farmlands")
}

GetPetNames()
{
	Global petNames

	petNames.Push("Brown Cat")
	petNames.Push("Mischievous Dog")
	petNames.Push("Black Cat")
	petNames.Push("Brown Guide Hawk")
	petNames.Push("Sky Hawk")
	petNames.Push("Snow Wolfdog")
}