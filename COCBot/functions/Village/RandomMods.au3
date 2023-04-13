; #FUNCTION# ====================================================================================================================
; Name ..........: Random Mods
; Description ...: this file will store unused functions/mods, if a function/mod will be used it will be moved in EndzyMod.au3
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: Endzy (2023), created in april 12, 2023
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func DL0() ;Donate Loop
	If $g_abDonateOnly[$g_iCurAccount] Then
		SetLog("-- DONATE ONLY ENABLED --")
		ZoomOut()
		checkMainScreen(True, $g_bStayOnBuilderBase, "FirstCheck")
		VillageReport(True, True)
		Local $loopcount = 1
		While 1
			If Not $g_bRunState Then Return
			$loopcount += 1
			If _Sleep(1000) Then Return
			Setlog("Loop:[" & $loopcount & "] -- DONATE MODE --", $COLOR_SUCCESS)

			If Not $g_bRunState Then Return
			If _Sleep(1000) Then Return
			VillageReport()
			If _Sleep(1000) Then Return
			If Not $g_bRunState Then Return

			Local $aRndFuncList = ['Collect', 'FstReq', 'CleanYard']
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(1000) Then Return
				If $g_bRestart Then Return
			Next

			If Not $g_bRunState Then Return
			If _Sleep(3000) Then Return
			_RunFunction('DonateCC,Train')
			If Not $g_bRunState Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "FirstCheckRoutine")

			If $loopcount > 1 Then
				Local $aRndFuncList = ['AutoUpgradeCC', 'ForgeClanCapitalGold', 'CollectCCGold']
				For $Index In $aRndFuncList
					If Not $g_bRunState Then Return
					_RunFunction($Index)
					If _Sleep(5000) Then Return
					If $g_bRestart Then Return
				Next
			EndIf

			If Not $g_bRunState Then Return

			If $loopcount > 2 Then
				Local $aRndFuncList = ['CleanYard', 'BuilderBase', 'AutoUpgradeCC', 'ForgeClanCapitalGold', 'CollectCCGold']
				For $Index In $aRndFuncList
					If Not $g_bRunState Then Return
					_RunFunction($Index)
					If _Sleep(5000) Then Return
					If $g_bRestart Then Return
				Next
				If _Sleep(2000) Then Return
				checkMainScreen(True, $g_bStayOnBuilderBase, "FirstCheckRoutine")
				If _Sleep(2000) Then Return
			EndIf

			If Not $g_bRunState Then Return

			If $loopcount > 3 Then
				SetLog("Looped 3 times, exiting donate loop now!", $COLOR_INFO)
				If Not $g_bRunState Then Return
				If _Sleep(2000) Then Return
				ExitLoop
			EndIf

			If Not $g_bRunState Then Return
		WEnd
		If Not $g_bRunState Then Return
		SetLog("Attack one time before switching account", $COLOR_INFO)
		_RunFunction('DonateModeAtk')
		If Not $g_bRunState Then Return
		Laboratory()
		If Not $g_bRunState Then Return
		checkSwitchAcc() ;switch to next account
	EndIf
EndFunc  ;===>DL0()

Func DMA0() ; DonateModeAtk
	If Not $g_bRunState Then Return
	If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
		; VERIFY THE TROOPS AND ATTACK IF IS FULL
		SetLog("-- FirstCheck on Train --", $COLOR_DEBUG)
		SetLog("-- DONATE MODE --", $COLOR_DEBUG)
		If Not $g_bRunState Then Return
		RequestCC() ; only type CC text req here
		TrainSystem()
		SetLog("Are you ready? " & String($g_bIsFullArmywithHeroesAndSpells), $COLOR_INFO)
		If $g_bIsFullArmywithHeroesAndSpells Then
			;Idle() ; if army is not ready amd close while training enabled
			; Now the bot can attack
			If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
				Setlog("Before any other routine let's attack!", $COLOR_INFO)
				Local $loopcount = 1
				While True
					$g_bRestart = False
					If Not $g_bRunState Then Return
					If AttackMain($g_bSkipDT) Then
						Setlog("[" & $loopcount & "] 1st Attack Loop Success", $COLOR_SUCCESS)
						If checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheckRoutine") Then ZoomOut()
						ExitLoop
					Else
						If $g_bForceSwitch Then ExitLoop ;exit here
						$loopcount += 1
						If $loopcount > 5 Then
							Setlog("1st Attack Loop, Already Try 5 times... Exit", $COLOR_ERROR)
							ExitLoop
						Else
							Setlog("[" & $loopcount & "] 1st Attack Loop, Failed", $COLOR_INFO)
						EndIf
						If Not $g_bRunState Then Return
					EndIf
				Wend
				If $g_bIsCGEventRunning And $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
					SetLog("Because running CG Event is BB Challenges", $COLOR_INFO)
					GotoBBTodoCG() ;force go to bb todo event
				EndIf
				If $g_bOutOfGold Then
					SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
					$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
					Return
				EndIf
				If _Sleep($DELAYRUNBOT1) Then Return
			EndIf
		EndIf
	EndIf
    If Not $g_bRunState Then Return
	TrainSystem()
	_RunFunction('DonateCC,Train')
	If Not $g_bRunState Then Return
EndFunc  ;===> DMA0

Func BBRTN0() ; BB routine for cg - do upgrades - lab - ClockTower boost etc. before switch acc

	SetLog("Do BB routine before account switch...", $COLOR_INFO)
	If SwitchBetweenBases("BB") Then
		$g_bStayOnBuilderBase = True
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		ZoomOut()
		BuilderBaseReport()
		CollectBuilderBase()
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")

		If $g_bElixirStorageFullBB Then StartClockTowerBoost()

		CleanBBYard()
		If _Sleep($DELAYRUNBOT1) Then Return
		checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")

		If isGoldFullBB() Or isElixirFullBB() Then
			AutoUpgradeBB()
			If _Sleep($DELAYRUNBOT1) Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		EndIf

		If isElixirFullBB() Then
			StarLaboratory()
			If _Sleep($DELAYRUNBOT1) Then Return
			checkMainScreen(True, $g_bStayOnBuilderBase, "BuilderBase")
		EndIf

		ZoomOut(True) ;directly zoom
		StartClockTowerBoost()
		If _Sleep($DELAYRUNBOT3) Then Return
		BuilderBaseReport(False, True, False)
		If _Sleep($DELAYRUNBOT3) Then Return
		; switch back to normal village
		ZoomOut(True) ;directly zoom
		$g_bStayOnBuilderBase = False
		SwitchBetweenBases("Main")
		$g_bStayOnBuilderBase = False
	EndIf

	If Not $g_bStayOnBuilderBase And IsOnBuilderBase() Then SwitchBetweenBases("Main")
EndFunc ;===> BBRTN0()

#cs
Func CheckLeague() ;little humanization
; No gui, hardcoded humanization
	If IsMainPage() Then
		If QuickMIS("BC1", $g_sImgChkLeague, 49, 64, 65, 83, True, $g_bDebugImageSave) Then ;QuickMIS("BC1", $g_sImgChkLeague, 19, 68, 64, 110, True, $g_bDebugImageSave) Then
			SetLog("You are in a New League!", $COLOR_INFO)
			SetLog("Checking League now!", $COLOR_INFO)
			;Click Trophy symbol/logo
			Click(Random(20, 55, 1), Random(90, 105, 1), 1, 0, "Endzy is still learning") ;Exact click is Click(36,95)
			; Wait for Okay button
			If _Wait4Pixel(443, 559, 0xDFF885, 25, 3000) Then
				; Click Okay
				Click(Random(400, 500, 1), Random(560, 590, 1), 1, 0, "#0222") ;Exact click is Click(460,570)
				If _Sleep(2000) Then Return
				; Click [X] close
				Click(Random(810, 840, 1), Random(45, 55, 1), 1, 0, "#0223") ;Exact click is Click(810,40)
				If _Sleep(500) Then Return
				; ClickAway just to make sure
				ClickAway()
			Else
				If _Sleep(Random(1500,2500,1)) Then Return
				Click(Random(810, 840, 1), Random(45, 55, 1), 1, 0, "#0223") ;Exact click is Click(810,40)
				If _Sleep(500) Then Return
				ClickAway()
			EndIf
		Else
			SetLog("Not in a new league, skipping", $COLOR_INFO)
		EndIf
	EndIf
EndFunc  ;==>CheckLeague

#Region - Search NoLeague for DeadBase - Endzy
Func TestCheckDeadBase()
	Local $dbBase
	;_CaptureRegion2()
	If QuickMIS("BC1", $g_sImgChkLeague, 10, 15, 44, 47, True, $g_bDebugImageSave) Then
		If $g_bChkNoLeague[$DB] Then
			If SearchNoLeague() Then
				SetLog("Dead Base is in No League, match found !", $COLOR_SUCCESS)
				$dbBase = True
			ElseIf $g_iSearchCount > 50 Then
				$dbBase = checkDeadBase()
			Else
				SetLog("Dead Base is in a League, skipping search !", $COLOR_INFO)
				$dbBase = False
			EndIf
		Else
			$dbBase = checkDeadBase()
		EndIf
	EndIf

	Return $dbBase
EndFunc   ;==>TestCheckDeadBase

Func SearchNoLeague($bCheckOneTime = False)
	If _Sleep($DELAYSPECIALCLICK1) Then Return False

	Local $bReturn = False

	$bReturn = _WaitForCheckImg($g_sImgNoLeague, "3,4,47,53", Default, ($bCheckOneTime = False) ? (500) : (0))

	If $g_bDebugSetlog Then
		SetDebugLog("SearchNoLeague: Is no league? " & $bReturn, $COLOR_DEBUG)
	EndIf

	Return $bReturn
EndFunc   ;==>SearchNoLeague

Func chkDBNoLeague()
	$g_bChkNoLeague[$DB] = GUICtrlRead($g_hChkDBNoLeague) = $GUI_CHECKED
EndFunc   ;==>chkDBNoLeague
#EndRegion - Search NoLeague for DeadBase - Endzy
#ce

; ======= A COPY/BACKUP OF THE ORIGINAL FSTDONATE() FUNCTION ========
#cs
Func Donate1n2($btest = False)
;	Local $DonBtnRnd1 = g_iQuickMISX + 30 ;, $DonBtnRnd2 = g_iQuickMISY + 20
;	Local $DonBtnRnd2 = g_iQuickMISY + 20
;	Local $DonLoonRnd1 = g_iQuickMISX + 20 ;, $DonLoonRnd2 = g_iQuickMISY + 40
;	Local $DonLoonRnd2 = g_iQuickMISY + 40
;	Local $DonSiegeRnd1 = g_iQuickMISX + 20 ;, $DonSiegeRnd2 = g_iQuickMISY + 30
;	Local $DonSiegeRnd2 = g_iQuickMISY + 30
;	Local $DonSpellRnd1 = g_iQuickMISX + 20 ;, $DonSpellRnd2 = g_iQuickMISY + 30
;	Local $DonSiegeRnd2 = g_iQuickMISY + 30
	
	If QuickMIS("BC1", $g_sImgDonateCC, 210, 510, 300, 600, True, $g_bDebugImageSave) Then ; 200, 540, 300, 600
		SetLog("Found Donate button", $COLOR_INFO)
		;$TroopVisible = True
		;Click(Random($g_iQuickMISX, $DonBtnRnd1, 1), Random($g_iQuickMISY, $DonBtnRnd2, 1)) ; Click donate button		
		Click(Random($g_iQuickMISX, $g_iQuickMISX + 10, 1), Random($g_iQuickMISY, $g_iQuickMISY + 20, 1)) ; Click donate button		

		If _Sleep(1500) Then Return
		
		If QuickMIS("BC1", $g_sImgLoonDonMod, 350, 235, 400, 265, True) Then
			SetLog("Found loons to donate", $COLOR_INFO)
			If Not $btest Then
				;Click($g_iQuickMISX, $g_iQuickMISY, 9, 150) ;Click(378, 75, 7, 100, "Donating...") ; CLick Troops - Balloon
				For $i = 1 To 9
					;Click(Random($g_iQuickMISX - 20, $DonLoonRnd1, 1), Random($g_iQuickMISY - 20, $DonLoonRnd2, 1))
					Click(Random($g_iQuickMISX - 20, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 20, $g_iQuickMISY + 20, 1))
					;SetLog("Simulate click " & $g_iQuickMISX & ", " & $g_iQuickMISY)
				Next
			Else
				SetLog("Simulate Clicking Loons", $COLOR_INFO)
				For $i = 1 To 9
					SetLog($g_iQuickMISX & ", " & $g_iQuickMISY)
				Next
			EndIf
			_Sleep(500)
		Else
			SetLog("Already donaed troops!", $COLOR_ERROR)
		EndIf
		
		If QuickMIS("BC1", $g_sImgSiegeDonMod, 350, 315, 400, 450, True) Then
			SetLog("Found Siege to donate", $COLOR_INFO)
			;Click($g_iQuickMISX, $g_iQuickMISY)
			;Click(Random($g_iQuickMISX - 30, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 15, $g_iQuickMISY + 20, 1))
			If Not $btest Then
				;Click(Random($g_iQuickMISX - 30, $DonSiegeRnd1, 1), Random($g_iQuickMISY - 15, $DonSiegeRnd2, 1))
				Click(Random($g_iQuickMISX-30, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY-15, $g_iQuickMISY + 15, 1))
			Else
				SetLog("Simulate Clicking Stone Slammer", $COLOR_INFO)
				SetLog($g_iQuickMISX & ", " & $g_iQuickMISY)
			EndIf
			_Sleep(500)
		Else
			SetLog("Already donated siege!", $COLOR_ERROR)
		EndIf
		
		If QuickMIS("BC1", $g_sImgSpellDonMod, 352, 433, 400, 475, True) Then
			SetLog("Found Spells to donate", $COLOR_INFO)
			;For $i = 1 to 3
			;Click($g_iQuickMISX, $g_iQuickMISY, 3, 150)
			;Click(Random($g_iQuickMISX - 10, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 10, $g_iQuickMISY + 20, 1))
			If Not $btest Then
				;Click(Random($g_iQuickMISX - 10, $DonSpellRnd1 + 30, 1), Random($g_iQuickMISY - 10, $DonSpellRnd2 + 20, 1))
				For $i = 1 to 3
					Click(Random($g_iQuickMISX - 10, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 10, $g_iQuickMISY + 20, 1))
				Next
			Else
				SetLog("Simulate Clicking Lightning Spell", $COLOR_INFO)
				For $i = 1 to 3
					SetLog($g_iQuickMISX & ", " & $g_iQuickMISY)
				Next
			EndIf
			_Sleep(500)
		Else
			SetLog("Already donated spells!", $COLOR_ERROR)
		EndIf
		If _Sleep(500) Then Return
		ClickAway("Right")
		If _Sleep(1000) Then Return
		;ClickDrag(100, 75, 100, 180) ; go up and search for more donate button
	Else
		SetLog("No Donate button found", $COLOR_ERROR)
	EndIf
	
	If QuickMIS("BC1", $g_sImgDonateCC, 200, 420, 300, 510, True, $g_bDebugImageSave) Then ; 200, 540, 300, 600
		SetLog("Found Donate button", $COLOR_INFO)
		;$TroopVisible = True
		;Click($g_iQuickMISX, $g_iQuickMISY) ; Click donate button
		Click(Random($g_iQuickMISX, $g_iQuickMISX + 10, 1), Random($g_iQuickMISY, $g_iQuickMISY + 20, 1))
		
		If _Sleep(1500) Then Return
		
		If QuickMIS("BC1", $g_sImgLoonDonMod, 350, 235, 400, 265, True) Then
			SetLog("Found loons to donate", $COLOR_INFO)
			If Not $btest Then
				;Click($g_iQuickMISX, $g_iQuickMISY, 9, 150) ;Click(378, 75, 7, 100, "Donating...") ; CLick Troops - Balloon
				For $i = 1 To 9
					;Click(Random($g_iQuickMISX - 20, $DonLoonRnd1, 1), Random($g_iQuickMISY - 20, $DonLoonRnd2, 1))
					Click(Random($g_iQuickMISX - 20, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 20, $g_iQuickMISY + 20, 1))
					;SetLog("Simulate click " & $g_iQuickMISX & ", " & $g_iQuickMISY)
				Next
			Else
				SetLog("Simulate Clicking Loons", $COLOR_INFO)
				For $i = 1 To 9
					SetLog($g_iQuickMISX & ", " & $g_iQuickMISY)
				Next
			EndIf
			_Sleep(500)
		Else
			SetLog("Already donaed troops!", $COLOR_ERROR)
		EndIf
		
		If QuickMIS("BC1", $g_sImgSiegeDonMod, 350, 315, 400, 450, True) Then
			SetLog("Found Siege to donate", $COLOR_INFO)
			;Click($g_iQuickMISX, $g_iQuickMISY)
			;Click(Random($g_iQuickMISX - 30, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 15, $g_iQuickMISY + 20, 1))
			If Not $btest Then
				;Click(Random($g_iQuickMISX - 30, $DonSiegeRnd1, 1), Random($g_iQuickMISY - 15, $DonSiegeRnd2, 1))
				Click(Random($g_iQuickMISX-30, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY-15, $g_iQuickMISY + 15, 1))
			Else
				SetLog("Simulate Clicking Stone Slammer", $COLOR_INFO)
				SetLog($g_iQuickMISX & ", " & $g_iQuickMISY)
			EndIf
			_Sleep(500)
		Else
			SetLog("Already donated siege!", $COLOR_ERROR)
		EndIf
		
		If QuickMIS("BC1", $g_sImgSpellDonMod, 352, 433, 400, 475, True) Then
			SetLog("Found Spells to donate", $COLOR_INFO)
			;For $i = 1 to 3
			;Click($g_iQuickMISX, $g_iQuickMISY, 3, 150)
			;Click(Random($g_iQuickMISX - 10, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 10, $g_iQuickMISY + 20, 1))
			If Not $btest Then
				;Click(Random($g_iQuickMISX - 10, $DonSpellRnd1 + 30, 1), Random($g_iQuickMISY - 10, $DonSpellRnd2 + 20, 1))
				For $i = 1 to 3
					Click(Random($g_iQuickMISX - 10, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 10, $g_iQuickMISY + 20, 1))
				Next
			Else
				SetLog("Simulate Clicking Lightning Spell", $COLOR_INFO)
				For $i = 1 to 3
					SetLog($g_iQuickMISX & ", " & $g_iQuickMISY)
				Next
			EndIf
			_Sleep(500)
		Else
			SetLog("Already donated spells!", $COLOR_ERROR)
		EndIf
		If _Sleep(1000) Then Return
		ClickAway("Right")
		If _Sleep(1000) Then Return
		;ClickDrag(100, 75, 100, 180) ; go up and search for more donate button
	Else
		SetLog("No Donate button found", $COLOR_ERROR)
	EndIf
	
EndFunc  ;==> Donate1n2
	;make a while loop that check the donate button in the 3rd donate Button
	; if there is no donate button at the 3rd then exit donate Loop
	; make a variable that is set to true, it will set to false if no more 3rd donate button 
	;ClickDrag($g_iQuickMISX, $g_iQuickMISY, $g_iQuickMISX, $g_iQuickMISY + 100) ; orig
	; ClickDrag($g_iQuickMISX, $g_iQuickMISY, $g_iQuickMISX + 20, $g_iQuickMISY + 100) ; it clickdrags like a human
	; ClickDrag($g_iQuickMISX - 70, $g_iQuickMISY, $g_iQuickMISX, $g_iQuickMISY + 100) ; it does not touch the donate btn when dragging
	;ClickDrag($g_iQuickMISX - 70, $g_iQuickMISY, $g_iQuickMISX, $g_iQuickMISY + 100)
Func FastDonate()
	
	Local $bKeepDonating = False

	If _Sleep($DELAYDONATECC2) Then Return
	If checkChatTabPixel() Then
		$bKeepDonating = True
		Click(Random(5,30,1), Random(318,385,1)) ;Click ClanChatOpen
		If _Sleep(2000) Then return
	EndIf

	While $bKeepDonating
		$bKeepDonating = False
		If Not $g_bRunState Then Return
		Donate1n2(True) ; donate troops/siege/spells
		; checks if there is still donate button or 3rd donate btn if not then exitloop
		If QuickMIS("BC1", $g_sImgDonateCC, 210, 310, 300, 400, True, $g_bDebugImageSave) Then ; 200, 540, 300, 600
			SetLog("Found Donate button at 3rd level", $COLOR_INFO)
			ClickDrag($g_iQuickMISX - 70, $g_iQuickMISY, $g_iQuickMISX, $g_iQuickMISY + 205)
			$bKeepDonating = True
		Else
			SetLog("No Donate button found at 3rd level! exiting donate loop now!", $COLOR_INFO)
			$bKeepDonating = False
		EndIf
		;ClickDrag(100, 75, 100, 280)
		If _Sleep(1000) Then return
		If Not $g_bRunState Then Return
	WEnd
	
	Click(Random(325,340,1), Random(324,380,1))
	ClickAway()

EndFunc  ;==>FastDonate

Func FindDonateBtn()

	;While 1
	
	For $i = 0 To 2
	
		If QuickMIS("BC1", $g_sImgDonateCC, 210, 510, 300, 600, True, $g_bDebugImageSave) Then ; 200, 540, 300, 600
			SetLog("Found Donate button", $COLOR_INFO)
			;$TroopVisible = True
			Click($g_iQuickMISX, $g_iQuickMISY) ; Click donate button
			If _Sleep(1500) Then Return
			
			If QuickMIS("BC1", $g_sImgLoonDonMod, 350, 235, 400, 265, True, $g_bDebugImageSave) Then
				SetLog("Found loons to donate", $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY, 9, 100) ;Click(378, 75, 7, 100, "Donating...") ; CLick Troops - Balloon
				;SetLog("Simulate Clicking Troops", $COLOR_INFO)
				_Sleep(500)
			EndIf
			
			If QuickMIS("BC1", $g_sImgSiegeDonMod, 350, 315, 400, 450, True, $g_bDebugImageSave) Then
				SetLog("Found Siege to donate", $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY)
				;SetLog("Simulate Clicking Siege", $COLOR_INFO)
				_Sleep(500)
			EndIf
			
			If QuickMIS("BC1", $g_sImgSpellDonMod, 352, 433, 400, 475, True, $g_bDebugImageSave) Then
				SetLog("Found Spells to donate", $COLOR_INFO)
				Click($g_iQuickMISX, $g_iQuickMISY, 3, 100)
				;SetLog("Simulate Clicking spells", $COLOR_INFO)
				_Sleep(500)
			EndIf
			
			ClickAway()
			If _Sleep(1000) Then Return
			;ExitLoop
		;Else
		;	ClickDrag(100, 75, 100, 180) ; go up and search for more donate button
		EndIf
		ClickDrag(100, 75, 100, 180)
	Next

	;WEnd

EndFunc

Func FastDonate()
	
	Local $bKeepDonating = False
	Local $iCount = 0

	For $i = 0 To 9
		If $bKeepDonating = True Then
			SetLog("Done donating", $COLOR_INFO)
			ExitLoop
		EndIf
		$bKeepDonating = False
		
		$sSearchArea = GetDiamondFromArray($aiSearchArray)
		$aiDonateButton = decodeSingleCoord(findImage("Donate Button", $g_sImgDonateCC & "DonateButton*", $sSearchArea, 1, True, Default))
	
		If IsArray($aiDonateButton) And UBound($aiDonateButton, 1) >= 2 Then
			$iCount += 1
			If $iCount == 1 Then ; Donate troops
				For $x = 0 To 5
					 _Sleep(500)
					If QuickMIS("BC1", $g_sImgLoonDonMod, 344, 37, 400, 84, True, $g_bDebugImageSave) Then
						SetLog("Found loons to donate", $COLOR_INFO)
						;$TroopVisible = True
						Click(378, 75, 7, 100, "Donating...") ; CLick Troops - Balloon
						_Sleep(100)
						ExitLoop 2
					EndIf
				Next
			EndIf

			If $iCount > 2 Then
				For $x = 0 To 5
					 _Sleep(500)
					If QuickMIS("BC1", $g_sImgLoonDonMod, 357, 47, 400, 84, True, $g_bDebugImageSave) Then
						SetLog("Found loons to donate, donate 2 more times", $COLOR_INFO)
						;$TroopVisible = True
						Click(378, 75, 2, 75, "Donating...")
						_Sleep(100)
						ExitLoop 2
					Else
						SetLog("Reached max donate cap", $COLOR_INFO)
						_Sleep(100)
						ExitLoop
					EndIf
				Next
			EndIf
			;$bKeepDonating = True
			$aiSearchArray[1] = $aiDonateButton[1] + 20

			ClickAway("Left")
			If _Sleep(3000) Then Return
		EndIf
		
		$sSearchArea = GetDiamondFromArray($aiSearchArray)
		$aiDonateButton = decodeSingleCoord(findImage("Donate Button", $g_sImgDonateCC & "DonateButton*", $sSearchArea, 1, True, Default))

		SetDebugLog("Get more donate buttons in " & StringFormat("%.2f", TimerDiff($iTimer)) & "'ms", $COLOR_DEBUG)
		If IsArray($aiDonateButton) And UBound($aiDonateButton, 1) >= 2 Then
			SetDebugLog("More Donate buttons found, new $aiDonateButton: (" & $aiDonateButton[0] & "," & $aiDonateButton[1] & ")") ;, $COLOR_DEBUG)
			ContinueLoop
		Else
			SetDebugLog("No more Donate buttons found, closing chat", $COLOR_DEBUG)
			$bDonate = False
		EndIf
	Next

EndFunc
#ce

; ------------------- OTHER MODS -------------------
; #FUNCTION# ====================================================================================================================
; Name ..........: RandomArmyComp
; Description ...: New and complete RandomArmyComp using quick train. Will ONLY work if Quick Train is ENABLED.
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Lilmeeee (09-2021), xbebenk (09-2021)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#cs
Func RandomArmyComp()
	If Not $g_bRandomArmyComp Then Return False
    If Not OpenQuickTrainTab(False, "RandomArmyComp()") Then Return
    If _Sleep(750) Then Return

	Local $Available_Comps[0] = [], $Result = 0
	Local $Army_Coords[4] = ["783,324", "798,434", "801,540", "777,177"]

	If _ColorCheck(_GetPixelColor(752, 309, True), Hex(0xBDE98D, 6), 1) Then
        _ArrayAdd($Available_Comps, 1)
	EndIf
	If _ColorCheck(_GetPixelColor(752, 456, True), Hex(0xE8E8E0, 6), 1) Then
        _ArrayAdd($Available_Comps, 2)
	EndIf
	If _ColorCheck(_GetPixelColor(751, 567, True), Hex(0xE8E8E0, 6), 1) Then
        _ArrayAdd($Available_Comps, 3)
	EndIf
	If _ColorCheck(_GetPixelColor(777, 177, True), Hex(0xBDE98D, 6), 1) Then
		_ArrayAdd($Available_Comps, 4)
	EndIf

	If UBound($Available_Comps) = 0 Then
		SetLog("There is no available QuickTrain Army! Skipped!", $COLOR_WARNING)
		Return False
	Else
		_ArrayShuffle($Available_Comps)
	EndIf

	SetLog("Training QuickTrain Army " & $Available_Comps[0], $COLOR_INFO)
	Execute("PureClick(" & $Army_Coords[$Available_Comps[0]-1] & ")")

	Return True
EndFunc ;==>RandomArmyComp

Func OpenArmyOverview($bCheckMain = True, $sWhereFrom = "Undefined")

	If $bCheckMain Then
		If Not IsMainPage() Then ; check for main page, avoid random troop drop
			If Not $g_bRunState Then Return
			SetLog("Cannot open Army Overview window", $COLOR_ERROR)
			Return False
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	If _Sleep(Random(2500,3500,1)) Then Return
	Click(Random(24,52,1),Random(510,545,1)) ; Cllick(38,529)
	If _Sleep(Random(2500,3500,1)) Then Return
	;For $i = 0 To 2 ;try 3 time to OpenArmyOverview 
	;	If WaitforPixel(23, 520, 53, 525, Hex(0xFFFFE4, 6), 5, 5) Then
	;		If $g_bDebugSetlogTrain Then SetLog("Click $aArmyTrainButton" & " (Called from " & $sWhereFrom & ")", $COLOR_SUCCESS)
	;		;ClickP($aArmyTrainButton, 1, 0, "#0293") ; Button Army Overview
	;		Click(Random(24,52,1),Random(510,545,1)) ; Cllick(38,529)
	;	EndIf
	;	For $z = 0 To 3
	;		If _Sleep(500) Then Return
	;		If _ColorCheck(_GetPixelColor(40, 580, True), Hex(0xE8E8E0, 6), 1) Then Return True
	;	Next
	;Next
	Return True
EndFunc   ;==>OpenArmyOverview
#ce