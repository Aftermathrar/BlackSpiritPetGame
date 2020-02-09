;Scripted poorly by Aftermath, version 0.3

;Use Alt + Q to start the script and Ctrl + Q to stop it
;Alt + G will rerun the silver setup
;It very simply activates the discord window and pastes in a message, make sure to be in #black-desert-law when using

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force ; Makes sure the script only runs one at a time

;Check if script has run and saved settings previously, otherwise run setup
saveFile := FileOpen("BotCounter.txt", "r")
if saveFile
{	
	saveString := saveFile.Read()
	saveFile.close()
	GetStats(saveString)
	return
}
else
{
	;Initialize gacha tracking variables
	Global BaseIncome = 100
	Global GachaBet = 100
	Global loopCount = 0

	AutoGachaSetup()
	return 
}

!g::
AutoGachaSetup()
return

!q::
Loop
{
	Random, randInt, 1, 20

	farmString := FlavorText(randInt)
	
	if WinExist("ahk_exe Discord.exe")
	{
		WinActivate
		Send, %farmString% {Enter}		

		gachaTimer = % Mod(Round(loopCount), minutesBetweenRolls)
		if (gachaTimer == 0)
		{
			Sleep 200
			Send, {!}gacha %gachaString% {enter}
		}

		loopCount := ++loopCount
	}

Sleep 61000

}

^q::
MsgBox Leaving script
file := FileOpen("BotCounter.txt", "rw")
global loopCount
global BaseIncome
global minutesBetweenRolls
global gachaString
file.Write(loopCount "," BaseIncome "," minutesBetweenRolls "," gachaString)
file.Close()
ExitApp

GetStats(s)
{
	global LoopCount
	global BaseIncome
	global minutesBetweenRolls
	global gachaString

	;Read loop count
	startPos = 1
	endPos := InStr(s, ",")
	loopCount := SubStr(s, startPos, endPos - startPos)

	;Read base income
	startPos := endPos + 1
	endPos:= InStr(s, ",", , , 2)
	BaseIncome := SubStr(s, startPos, endPos - startPos)

	;Read gacha timer
	startPos := endPos + 1
	endPos:= InStr(s, ",", , , 3)
	minutesBetweenRolls := SubStr(s, startPos, endPos - startPos)

	;Read gacha string
	startPos := endPos + 1
	endPos:= StrLen(s)
	gachaString := SubStr(s, startPos - endPos)	
}

AutoGachaSetup()
{
	Gui, Add, Text,, Silver Income:
	Gui, Add, Text,, Gacha Amount:
	Gui, Add, Edit, vBaseIncome w100 ym, %BaseIncome%  ; The ym option starts a new column of controls.
	Gui, Add, ListBox, r7 vGachaBet, 100||1k|5k|25k|100k|500k|1m
	Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
	Gui, Show,, Setup Auto-Gacha
	return  ; End of auto-execute section. The script is idle until the user does something.
	
ButtonOK:
	Gui, Submit  ; Save the input from the user to each control's associated variable.

	if BaseIncome is integer
		myIncome = %BaseIncome%
	else
	{
		MsgBox, Invalid silver income entry, using 100 as default
		myIncome = 100
		BaseIncome = %myIncome%
	}

	global gachaString
	gachaString = %GachaBet%

	switch gachaString
	{
		case "100":
			gachaAmount = 100
		case "1k": 
			gachaAmount = 1000
		case "5k": 
			gachaAmount = 5000
		case "25k": 
			gachaAmount = 25000
		case "100k": 
			gachaAmount = 100000
		case "500k": 
			gachaAmount = 500000
		case "1m": 
			gachaAmount = 1000000
	}
	global minutesBetweenRolls := Ceil(gachaAmount/myIncome)

GuiClose:
	Gui, Destroy
	return
}

FlavorText(i)
{
	global loopCount
	s = 

	switch i
	{
	case 1:
		randomZone := ZoneName()
		s = Farmed %loopCount% silver in %randomZone%
	case 2:
		s = Looted %loopCount% silver from other users
	case 3:
		s = Found %loopCount% silver on an alt
	case 4:
		s = Acquired %loopCount% silver from illegal means
	case 5:
		s = :RIGGED64: WHERE PET?{!}
	case 6:
		s = Died %loopCount% times to Kzarka flame breath
	case 7:
		s = Traded %loopCount% Black Pearls from an alt account
	case 8:
		s = Fused %loopCount% weapon outfits without success
	case 9:
		s = %loopCount% outlaw kills while afk
	case 10:
		s = %loopCount% silver(s) please :BSThbptGIF:
	case 11:
		s = Asking mommy to borrow $%loopCount% for shakatu coins
	case 12:
		s = Cheated out of %loopCount% pets by the Black Spirit
	case 13:
		s = Failed %loopCount% times on force enhances
	case 14:
		s = Using %loopCount% potions per hour on my Sorceress
	case 15:
		s = %loopCount% loss streak in arena
	case 16:
		s = When is the next maintenance?
	case 17:
		s = Spent %loopCount%k coins at Shakatu, no oranges REEEEE
	case 18:
		s = :SangGotYa:
	case 19:
		s = afk for %loopCount% minutes
	case 20:
		s = %loopCount% hours since someone rolled a pet
	default: 
		s = Farmed %i% silver somewhere
	}

	return s
}

ZoneName() 
{
	Random, myZone, 1, 20

	switch myZone
	{
		case 1:
			myZone = Cron Castle Entrance
		case 2:
			myZone = Hexe Sanctuary
		case 3:
			myZone = Witch's Chapel
		case 4:
			myZone = Phoniel's Cabin
		case 5:
			myZone = Cron Castle Patrol
		case 6:
			myZone = Marni's Second Lab
		case 7:
			myZone = Marni's Underground
		case 8:
			myZone = Cron Castle
		case 9:
			myZone = Wandering Rogues' Camp
		case 10:
			myZone = Wandering Rogues' Den
		case 11:
			myZone = Omar Lava Fields
		case 12:
			myZone = Manes Cave
		case 13:
			myZone = Manes' Hideout
		case 14:
			myZone = Omar Lava Cave
		case 15:
			myZone = Soldier's Grave
		case 16:
			myZone = Soldier's Grave Depths
		case 17:
			myZone = Hasrah Ruins Entrance
		case 18:
			myZone = Hasrah Ancient Ruins
		case 19:
			myZone = Nightmare Witch's Chapel
		case 20:
			myZone = Velia Farmlands
		default:
			myZone = Calpheon
	}

	return myZone

}