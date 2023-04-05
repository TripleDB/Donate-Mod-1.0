; #FUNCTION# ====================================================================================================================
; Name ..........: EndzyMod
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: Endzy (2022)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================


Func TestAttack() ;Endzy
	If _Sleep(300) Then Return
	PureClick(20,350)
	If _Sleep(1000) Then Return
	PureClick(230,580)
	If _Sleep(1000) Then Return
	PureClick(680,430)
	If _Sleep(1000) Then Return
	For $x = 0 To 5
		_Sleep(1000)
		If QuickMIS("BC1", $g_sImgFCsurr, 14, 520, 129, 560, True, $g_bDebugImageSave) Then
			SetLog("Found Surrender Button, PrepareAttack now!", $COLOR_INFO)
			PrepareAttack($g_iMatchMode)
			_Sleep(1000)
			ExitLoop
		EndIf
	Next
	If _Sleep(1000) Then Return
	$g_bAttackActive = True
	SetLog(" ====== Start Attack ====== ", $COLOR_SUCCESS)
	If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
		SetDebugLog("start scripted attack", $COLOR_ERROR)
		Algorithm_AttackCSV()
		If Not $g_bRunState Then Return
		If _Sleep(20000) Then Return
		PureClick(70,540)
		If _Sleep(1200) Then Return
		PureClick(530,400)
		If _Sleep(2000) Then Return
		PureClick(440,480)
		If _Sleep(1000) Then Return
	ElseIf $g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 2 Then
		SetDebugLog("start smart farm attack", $COLOR_ERROR)
		; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
		Local $Nside = ChkSmartFarm()
		If Not $g_bRunState Then Return
		AttackSmartFarm($Nside[1], $Nside[2])
	Else
		SetDebugLog("start standard attack", $COLOR_ERROR)
		algorithm_AllTroops()
		If Not $g_bRunState Then Return
		If _Sleep(15000) Then Return
		PureClick(70,540)
		If _Sleep(1200) Then Return
		PureClick(530,400)
		If _Sleep(2000) Then Return
		PureClick(440,480)
		If _Sleep(1000) Then Return
	EndIf
	$g_bAttackActive = False
EndFunc ;==>TestAttack

#Region - For MainLoop - Endzy
Func EU0() ; Early Upgrades
	RequestCC() ; only type CC text req here]
	ClickAway()
	_SLeep(500)
	ClickAway()
	;If $g_bChkOnlyAttack Then
	;	SetLog("On EarlyUpgChk, OnlyAttack enabled, skipping some routines", $COLOR_INFO)
	;Else
	If _ColorCheck(_GetPixelColor(702, 83, True), Hex(0xC027C0, 6), 1) Then
		Laboratory()
		VillageReport(True, True)
	EndIf
	Setlog("Early upgrades enabled", $COLOR_INFO)
	;If $g_iFreeBuilderCount > 0 And (_ColorCheck(_GetPixelColor(709, 29, True), Hex(0xF4DD72, 6), 1) Or _ColorCheck(_GetPixelColor(702, 83, True), Hex(0xC027C0, 6), 1)) Then
	If $g_iFreeBuilderCount <= 1 Then
		Setlog("Your account have only 1 builder, Only do UpgradeWall", $COLOR_INFO)
		SetLog("Check Upgrade Wall Early", $COLOR_INFO)
		_RunFunction('UpgradeWall') ;UpgradeWall()
		ZoomOut()
		If Not $g_bRunState Then Return
		CheckTombs()
		CleanYard()
		_Sleep(8000) ;add wait after clean yard
		UpgradeHeroes() ;Early Hero Upgrade
		ZoomOut()
	ElseIf $g_iFreeBuilderCount >=1 Then
		If _ColorCheck(_GetPixelColor(709, 29, True), Hex(0xF4DD72, 6), 1) Or _ColorCheck(_GetPixelColor(702, 83, True), Hex(0xC027C0, 6), 1) Then
			Setlog("Your account have more than 1 builder, doing AutoUpgrade now", $COLOR_INFO)
			If Not $g_bRunState Then Return
			If $g_bAutoUpgradeEarly Then
				SetLog("Check Auto Upgrade Early", $COLOR_INFO)
				checkArmyCamp(True, True) ;need to check reserved builder for heroes
				AutoUpgrade()
			EndIf
			VillageReport()
			ZoomOut()

			UpgradeHeroes() ;Early Hero Upgrade
			ZoomOut()
		EndIf
	Else
		;SetLog("Your acc doesn't have a builder available or storages are not 70% full", $COLOR_INFO)
		SetLog("Your acc doesn't have a builder available", $COLOR_INFO)
		SetLog("Skipping Early Upgrades", $COLOR_INFO)
	EndIf
	;EndIf
EndFunc  ;===>EU0

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

#EndRegion - For MainLoop - Endzy

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
#ce

; Endzy - randomSleep function
Func randomSleep($iSleepTime, $iRange = Default)
	If Not $g_bRunState Or $g_bRestart Then Return
	If $iRange = Default Then $iRange = $iSleepTime * 0.20
	Local $iSleepTimeF = Abs(Round($iSleepTime + Random( -Abs($iRange), Abs($iRange))))
	If $g_bDebugClick Or $g_bDebugSetlog Then SetLog("Default sleep : " & $iSleepTime & " - Random sleep : " & $iSleepTimeF, $COLOR_ACTION)
	Return _Sleep($iSleepTimeF)
EndFunc   ;==>randomSleep

Func _GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle = -1, $vExStyle = -1)
	Local $hReturn = GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle, $vExStyle)
	GUICtrlSetBkColor($hReturn, 0xD1DFE7)
	Return $hReturn
EndFunc   ;==>_GUICtrlCreateInput

#cs
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

#Region - GUI Control

Func chkUseSmartFarmAndRandomQuant()
	If $g_iGuiMode <> 1 Then Return
	If GUICtrlRead($g_hChkSmartFarmAndRandomQuant) = $GUI_CHECKED And $g_abAttackTypeEnable[$DB] And $g_aiAttackAlgorithm[$DB] = 2 And Not $g_abAttackTypeEnable[$LB] Then
		$g_bUseSmartFarmAndRandomQuant = True
	Else
		GUICtrlSetState($g_hChkSmartFarmAndRandomQuant, $GUI_UNCHECKED)
		$g_bUseSmartFarmAndRandomQuant = False
	EndIf
EndFunc   ;==>chkUseSmartFarmAndRandomQuant

#EndRegion - GUI Control


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

Func ROM(); Request Only Mode
	SetLog("======= REQUEST ONLY MODE =======", $COLOR_ACTION)
	_RunFunction("FstReq")
	Local $aRndFuncList = ['Collect', 'CollectBB', 'Laboratory', 'CollectCCGold', 'ForgeClanCapitalGold']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		If _Sleep(50) Then Return
		If $g_bRestart Then Return
	Next
	
	checkSwitchAcc()

EndFunc  ;==> ROM

Func DOM() ; Donate Only Mode
	SetLog("======= DONATE ONLY MODE =======", $COLOR_ACTION)
	Local $count = 0
	
	Collect()
	_RunFunction("FstReq")
	For $i = 0 to 4

		$count += 1
		
		_RunFunction("DonateCC,Train")
		If Not $g_bRunState Then Return
		If _Sleep(1000) Then Return
		
		If $count < 2 Then
			Local $aRndFuncList = ['Collect', 'CollectBB', 'Laboratory', 'CollectCCGold', 'ForgeClanCapitalGold']
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next
		EndIf
			
		ClickAway()
		
		If $count < 4 Then
			Local $aRndFuncList = ['Collect', 'CollectBB', 'Laboratory', 'CollectCCGold', 'ForgeClanCapitalGold']
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next
		EndIf
		
	Next

	SetLog("Donate loop complete! Swtiching Account now.", $COLOR_SUCCESS)
	checkSwitchAcc()
	
EndFunc  ;==> DOM 

Func AOM() ; Attack Only Mode
	SetLog("======= ATTACK ONLY MODE =======", $COLOR_ACTION)
	Local $aRndFuncList = ['Collect', 'CollectCCGold', 'ForgeClanCapitalGold', 'FstReq']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		If _Sleep(50) Then Return
		If $g_bRestart Then Return
	Next
	; ------------------ F I R S T  A T T A C K ------------------
	If Not $g_bRunState Then Return
	If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
		; VERIFY THE TROOPS AND ATTACK IF IS FULL
		SetLog("-- FirstCheck on Train --", $COLOR_DEBUG)
		If Not $g_bRunState Then Return
		CheckIfArmyIsReady()
		ClickAway()
		If $g_bIsFullArmywithHeroesAndSpells Then
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
						$g_bIsFullArmywithHeroesAndSpells = False
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
				If $g_bOutOfGold Then
					SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
					$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
					Return
				EndIf
				If _Sleep($DELAYRUNBOT1) Then Return
			EndIf
		Else
			If Not $g_bDonateEarly Then TrainSystem()
		EndIf
	EndIf
	TrainSystem()

	If Not $g_bRunState Then Return
	;VillageReport()
	If ProfileSwitchAccountEnabled() And $g_bChkFastSwitchAcc Then ; Allow immediate Second Attack on FastSwitchAcc enabled
		If _Sleep($DELAYRUNBOT2) Then Return
		If BotCommand() Then btnStop()
		If Not $g_bRunState Then Return
		If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
			; VERIFY THE TROOPS AND ATTACK IF IS FULL
			SetLog("-- SecondCheck on Train --", $COLOR_DEBUG)
			SetLog("Fast Switch Account Enabled", $COLOR_DEBUG)
			If Not $g_bIsFullArmywithHeroesAndSpells Then TrainSystem()
			If $g_bIsFullArmywithHeroesAndSpells Then
				If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
					Setlog("Before any other routine let's attack!", $COLOR_INFO)
					$g_bRestart = False ;idk this flag make sometimes bot cannot attack on second time
					Local $loopcount = 1
					While True
						$g_bRestart = False
						If Not $g_bRunState Then Return
						If AttackMain($g_bSkipDT) Then
							Setlog("[" & $loopcount & "] 2nd Attack Loop Success", $COLOR_SUCCESS)
							$b_SuccessAttack = True
							If checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheckRoutine") Then ZoomOut()
							ExitLoop
						Else
							If $g_bForceSwitch Then ExitLoop ;exit here
							$loopcount += 1
							If $loopcount > 5 Then
								Setlog("2nd Attack Loop, Already Try 5 times... Exit", $COLOR_ERROR)
								ExitLoop
							Else
								Setlog("[" & $loopcount & "] 2nd Attack Loop, Failed", $COLOR_INFO)
							EndIf
							If Not $g_bRunState Then Return
						EndIf
					Wend
					If $g_bOutOfGold Then
						SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
						$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
						Return
					EndIf
					If _Sleep($DELAYRUNBOT1) Then Return
				EndIf
			EndIf
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	;If CheckNeedOpenTrain() Then TrainSystem()
	TrainSystem()
	If _Sleep(1000) Then Return
	ClickAway()
	If Not $g_bRunState Then Return
	_RunFunction("AttackBB")
	If _Sleep(1000) Then Return
	;_RunFunction("DonateCC,Train")
	;CheckIfArmyIsReady()
	ClickAway()
	If _Sleep(1000) Then Return
	;_ClanGames(False, False, True) ; Do Only Purge
	checkSwitchAcc() ;switch to next account

EndFunc  ;==> AOM

Func BBAOM() ; BB Attack Only Mode

	Local $aRndFuncList = ['CollectCCGold', 'ForgeClanCapitalGold', 'BuilderBase', 'FstReq']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		If _Sleep(50) Then Return
		If $g_bRestart Then Return
	Next

	checkSwitchAcc()

EndFunc   ;==> BBAOM

Func MVAOM() ; Main Village Attack Only Mode
	SetLog("======= MAIN VILLAGE ATTACK ONLY MODE =======", $COLOR_ACTION)
	Local $aRndFuncList = ['Collect', 'CollectCCGold', 'ForgeClanCapitalGold', 'FstReq']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		If _Sleep(50) Then Return
		If $g_bRestart Then Return
	Next
	; ------------------ F I R S T  A T T A C K ------------------
	If Not $g_bRunState Then Return
	If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
		; VERIFY THE TROOPS AND ATTACK IF IS FULL
		SetLog("-- FirstCheck on Train --", $COLOR_DEBUG)
		If Not $g_bRunState Then Return
		CheckIfArmyIsReady()
		ClickAway()
		If $g_bIsFullArmywithHeroesAndSpells Then
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
						$g_bIsFullArmywithHeroesAndSpells = False
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
				If $g_bOutOfGold Then
					SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
					$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
					Return
				EndIf
				If _Sleep($DELAYRUNBOT1) Then Return
			EndIf
		Else
			If Not $g_bDonateEarly Then TrainSystem()
		EndIf
	EndIf
	TrainSystem()

	If Not $g_bRunState Then Return
	;VillageReport()
	If ProfileSwitchAccountEnabled() And $g_bChkFastSwitchAcc Then ; Allow immediate Second Attack on FastSwitchAcc enabled
		If _Sleep($DELAYRUNBOT2) Then Return
		If BotCommand() Then btnStop()
		If Not $g_bRunState Then Return
		If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
			; VERIFY THE TROOPS AND ATTACK IF IS FULL
			SetLog("-- SecondCheck on Train --", $COLOR_DEBUG)
			SetLog("Fast Switch Account Enabled", $COLOR_DEBUG)
			If Not $g_bIsFullArmywithHeroesAndSpells Then TrainSystem()
			If $g_bIsFullArmywithHeroesAndSpells Then
				If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
					Setlog("Before any other routine let's attack!", $COLOR_INFO)
					$g_bRestart = False ;idk this flag make sometimes bot cannot attack on second time
					Local $loopcount = 1
					While True
						$g_bRestart = False
						If Not $g_bRunState Then Return
						If AttackMain($g_bSkipDT) Then
							Setlog("[" & $loopcount & "] 2nd Attack Loop Success", $COLOR_SUCCESS)
							$b_SuccessAttack = True
							If checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheckRoutine") Then ZoomOut()
							ExitLoop
						Else
							If $g_bForceSwitch Then ExitLoop ;exit here
							$loopcount += 1
							If $loopcount > 5 Then
								Setlog("2nd Attack Loop, Already Try 5 times... Exit", $COLOR_ERROR)
								ExitLoop
							Else
								Setlog("[" & $loopcount & "] 2nd Attack Loop, Failed", $COLOR_INFO)
							EndIf
							If Not $g_bRunState Then Return
						EndIf
					Wend
					If $g_bOutOfGold Then
						SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
						$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
						Return
					EndIf
					If _Sleep($DELAYRUNBOT1) Then Return
				EndIf
			EndIf
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	;If CheckNeedOpenTrain() Then TrainSystem()
	TrainSystem()
	If _Sleep(1000) Then Return
	ClickAway()
	If _Sleep(1000) Then Return
	_RunFunction("DonateCC,Train")
	CheckIfArmyIsReady()
	ClickAway()
	If _Sleep(1000) Then Return
	;_ClanGames(False, False, True) ; Do Only Purge
	checkSwitchAcc() ;switch to next account

EndFunc  ;==> NVAOM

Func NM() ; Normal Mode
	SetLog("======= NORMAL MODE =======", $COLOR_ACTION)
	_RunFunction('EarlyUpgChk')
	; ------------------ F I R S T  A T T A C K ------------------
	If Not $g_bRunState Then Return
	If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
		; VERIFY THE TROOPS AND ATTACK IF IS FULL
		SetLog("-- FirstCheck on Train --", $COLOR_DEBUG)
		If Not $g_bRunState Then Return
		CheckIfArmyIsReady()
		ClickAway()
		If $g_bIsFullArmywithHeroesAndSpells Then
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
						$g_bIsFullArmywithHeroesAndSpells = False
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
				If $g_bOutOfGold Then
					SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
					$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
					Return
				EndIf
				If _Sleep($DELAYRUNBOT1) Then Return
			EndIf
		Else
			If Not $g_bDonateEarly Then TrainSystem()
		EndIf
	EndIf
	TrainSystem()

	If Not $g_bRunState Then Return
	;VillageReport()
	If ProfileSwitchAccountEnabled() And $g_bChkFastSwitchAcc Then ; Allow immediate Second Attack on FastSwitchAcc enabled
		If _Sleep($DELAYRUNBOT2) Then Return
		If BotCommand() Then btnStop()
		If Not $g_bRunState Then Return
		If $g_iCommandStop <> 3 And $g_iCommandStop <> 0 Then
			; VERIFY THE TROOPS AND ATTACK IF IS FULL
			SetLog("-- SecondCheck on Train --", $COLOR_DEBUG)
			SetLog("Fast Switch Account Enabled", $COLOR_DEBUG)
			If Not $g_bIsFullArmywithHeroesAndSpells Then TrainSystem()
			If $g_bIsFullArmywithHeroesAndSpells Then
				If $g_iCommandStop <> 0 And $g_iCommandStop <> 3 Then
					Setlog("Before any other routine let's attack!", $COLOR_INFO)
					$g_bRestart = False ;idk this flag make sometimes bot cannot attack on second time
					Local $loopcount = 1
					While True
						$g_bRestart = False
						If Not $g_bRunState Then Return
						If AttackMain($g_bSkipDT) Then
							Setlog("[" & $loopcount & "] 2nd Attack Loop Success", $COLOR_SUCCESS)
							$b_SuccessAttack = True
							If checkMainScreen(False, $g_bStayOnBuilderBase, "FirstCheckRoutine") Then ZoomOut()
							ExitLoop
						Else
							If $g_bForceSwitch Then ExitLoop ;exit here
							$loopcount += 1
							If $loopcount > 5 Then
								Setlog("2nd Attack Loop, Already Try 5 times... Exit", $COLOR_ERROR)
								ExitLoop
							Else
								Setlog("[" & $loopcount & "] 2nd Attack Loop, Failed", $COLOR_INFO)
							EndIf
							If Not $g_bRunState Then Return
						EndIf
					Wend
					If $g_bOutOfGold Then
						SetLog("Switching to Halt Attack, Stay Online/Collect mode", $COLOR_ERROR)
						$g_bFirstStart = True ; reset First time flag to ensure army balancing when returns to training
						Return
					EndIf
					If _Sleep($DELAYRUNBOT1) Then Return
				EndIf
			EndIf
		EndIf
	EndIf
	If Not $g_bRunState Then Return
	;If CheckNeedOpenTrain() Then TrainSystem()
	TrainSystem()
	If Not $g_bRunState Then Return
	CommonRoutine("FirstCheckRoutine")
	If ProfileSwitchAccountEnabled() And ($g_bForceSwitch Or $g_bChkFastSwitchAcc) Then
		CommonRoutine("Switch")
		_RunFunction("DonateCC,Train")
		CheckIfArmyIsReady()
		ClickAway()
		If _Sleep(1000) Then Return
		;_ClanGames(False, False, True) ; Do Only Purge
		checkSwitchAcc() ;switch to next account
	EndIf

EndFunc  ;==> NM

Func RM() ; Routine Mode
	
	SetLog("======= ROUTINE MODE =======", $COLOR_ACTION)
	CommonRoutine("FirstCheckRoutine")
	CommonRoutine("Switch")
	_RunFunction("DonateCC,Train")
	checkSwitchAcc() ;switch to next account
	
EndFunc  ;==> RM

Func CGM() ; Clan  Games Mode

	Local $b_SuccessAttack = False
	SetLog("======== FirstCheckRoutine ========", $COLOR_ACTION)
	If Not $g_bRunState Then Return
	checkMainScreen(True, $g_bStayOnBuilderBase, "FirstCheckRoutine")
	SetLog("test 69420", $COLOR_INFO)
	If $g_bChkCGBBAttackOnly Then
		SetLog("Enabled Do Only BB Challenges", $COLOR_INFO)
		For $count = 1 to 11
			If Not $g_bRunState Then Return
			If $count > 10 Then
				SetLog("Something maybe wrong, exiting to MainLoop!", $COLOR_INFO)
				ExitLoop
			EndIf

			If _ClanGames(False, $g_bChkForceBBAttackOnClanGames) Then
				If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
					SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
					SetLog("[" & $count & "] Trying to complete BB Challenges", $COLOR_INFO)
					GotoBBTodoCG()
				Else
					ExitLoop ;should be will never get here, but
				EndIf
			Else
				If $g_bIsCGPointMaxed Then ExitLoop ; If point is max then continue to main loop
				If Not $g_bIsCGEventRunning Then ExitLoop ; No Running Event after calling ClanGames
				If $g_bChkClanGamesStopBeforeReachAndPurge and $g_bIsCGPointAlmostMax Then ExitLoop ; Exit loop if want to purge near max point
			EndIf
			If isOnMainVillage() Then ZoomOut()	; Verify is on main village and zoom out
		Next
	Else
		If $g_bCheckCGEarly And $g_bChkClanGamesEnabled Then
			SetLog("Check ClanGames Early", $COLOR_INFO)
			_ClanGames(False, $g_bChkForceBBAttackOnClanGames)
			If Not $g_bRunState Then Return
			If $g_bChkForceBBAttackOnClanGames And $g_bIsBBevent Then
				SetLog("Forced BB Attack On ClanGames", $COLOR_INFO)
				GotoBBTodoCG()
			EndIf
		EndIf
	EndIf

	Local $bSwitch = True

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And $g_bForceSwitchifNoCGEvent And Number($g_aiCurrentLoot[$eLootTrophy]) < 4900 And $bSwitch Then
		_ClanGames(False, False, True) ; Do Only Purge
		SetLog("No Event on ClanGames, Forced switch account!", $COLOR_SUCCESS)
		_RunFunction("DonateCC,Train")
		CommonRoutine("NoClanGamesEvent")
		$g_bForceSwitchifNoCGEvent = True
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And ($g_bIsCGPointAlmostMax Or $g_bIsCGPointMaxed) And $g_bChkForceSwitchifNoCGEvent Then ; forced switch after first attack if cg point is almost max
		_RunFunction('UpgradeWall')
		SetLog("ClanGames point almost max/maxed, Forced switch account!", $COLOR_SUCCESS)
		If Not $g_bIsFullArmywithHeroesAndSpells Then TrainSystem()
		;CommonRoutine("NoClanGamesEvent")
		$g_bForceSwitchifNoCGEvent = True
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	If ProfileSwitchAccountEnabled() And ($g_bForceSwitch Or $g_bForceSwitchifNoCGEvent) Then
		_ClanGames(False, False, True) ; Do Only Purge
		_RunFunction("DonateCC,Train")
		CommonRoutine("Switch")
		checkSwitchAcc() ;switch to next account
	EndIf

	If Not $g_bRunState Then Return
	Local $aRndFuncList = ['Collect', 'ForgeClanCapitalGold', 'Laboratory', 'CollectCCGold', 'AutoUpgradeCC']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		If _Sleep(50) Then Return
		ClickAway()
		If $g_bRestart Then Return
		If Not $g_bRunState Then Return
	Next
	If ProfileSwitchAccountEnabled() And ($g_bForceSwitch Or $g_bChkFastSwitchAcc) Then
		CommonRoutine("Switch")
		CheckIfArmyIsReady()
		ClickAway()
		If _Sleep(1000) Then Return
		_ClanGames(False, False, True) ; Do Only Purge
		checkSwitchAcc() ;switch to next account
	EndIf
	
EndFunc  ; ==> CGM

Func ChkTHlvl()
	;Check Town Hall level
	ClickAway()
	Local $iTownHallLevel = $g_iTownHallLevel
	Local $bLocateTH = False
	SetLog("Detecting Town Hall level", $COLOR_INFO)
	SetLog("Town Hall level is currently saved as " &  $g_iTownHallLevel, $COLOR_INFO)
	Collect(False) ;only collect from mine and collector
	If $g_aiTownHallPos[0] > -1 Then
		Click($g_aiTownHallPos[0], $g_aiTownHallPos[1])
		If _Sleep(800) Then Return
		Local $BuildingInfo = BuildingInfo(245, 494)
		If $BuildingInfo[1] = "Town Hall" Then
			$g_iTownHallLevel =  $BuildingInfo[2]
		Else
			$bLocateTH = True
		EndIf
	EndIf

	If $g_iTownHallLevel = 0 Or $bLocateTH Then
		imglocTHSearch(False, True, True) ;Sets $g_iTownHallLevel
	EndIf

	SetLog("Detected Town Hall level is " &  $g_iTownHallLevel, $COLOR_INFO)
	If $g_iTownHallLevel = $iTownHallLevel Then
		SetLog("Town Hall level has not changed", $COLOR_INFO)
	Else
		SetLog("Town Hall level has changed!", $COLOR_INFO)
		SetLog("New Town hall level detected as " &  $g_iTownHallLevel, $COLOR_INFO)
		applyConfig()
		saveConfig()
	EndIf
	setupProfile()
	
	If Not $g_bRunState Then Return
	VillageReport()
	chkShieldStatus()
	If $g_bOutOfGold And (Number($g_aiCurrentLoot[$eLootGold]) >= Number($g_iTxtRestartGold)) Then ; check if enough gold to begin searching again
		$g_bOutOfGold = False ; reset out of gold flag
		SetLog("Switching back to normal after no gold to search ...", $COLOR_SUCCESS)
		Return ; Restart bot loop to reset $g_iCommandStop & $g_bTrainEnabled + $g_bDonationEnabled via BotCommand()
	EndIf

	If $g_bOutOfElixir And (Number($g_aiCurrentLoot[$eLootElixir]) >= Number($g_iTxtRestartElixir)) And (Number($g_aiCurrentLoot[$eLootDarkElixir]) >= Number($g_iTxtRestartDark)) Then ; check if enough elixir to begin searching again
		$g_bOutOfElixir = False ; reset out of gold flag
		SetLog("Switching back to normal setting after no elixir to train ...", $COLOR_SUCCESS)
		Return ; Restart bot loop to reset $g_iCommandStop & $g_bTrainEnabled + $g_bDonationEnabled via BotCommand()
	EndIf

	If BotCommand() Then btnStop()

EndFunc ; ==> ChkTHlvl

Func NotRndmClick($x, $y, $times = 1, $speed = 0, $debugtxt = "")
	Local $txt = "", $aPrevCoor[2] = [$x, $y]
	If Not $g_bUseRandomClick Then
		$x = Random($x - 2, $x + 2, 1)
		$y = Random($y - 2, $y + 2, 1)
		If $g_bDebugClick Then
			$txt = _DecodeDebug($debugtxt)
			SetLog("Random Click X: " & $aPrevCoor[0] & " To " & $x & ", Y: " & $aPrevCoor[1] & " To " & $y & ", Times: " & $times & ", Speed: " & $speed & " " & $debugtxt & $txt, $COLOR_ACTION, "Verdana", "7.5", 0)
		EndIf
    Else
		If $g_bDebugClick Or TestCapture() Then
			$txt = _DecodeDebug($debugtxt)
			SetLog("Click " & $x & "," & $y & "," & $times & "," & $speed & " " & $debugtxt & $txt, $COLOR_ACTION, "Verdana", "7.5", 0)
        EndIf
	EndIf

	If TestCapture() Then Return

	If $g_bAndroidAdbClick = True Then
		AndroidClick($x, $y, $times, $speed)
		Return
	EndIf

	Local $SuspendMode = ResumeAndroid()
	If $times <> 1 Then
		For $i = 0 To ($times - 1)
			If isProblemAffectBeforeClick($i) Then
				If $g_bDebugClick Then SetLog("VOIDED Click " & $x & "," & $y & "," & $times & "," & $speed & " " & $debugtxt & $txt, $COLOR_ERROR, "Verdana", "7.5", 0)
				checkMainScreen(False, $g_bStayOnBuilderBase, "Click")
				SuspendAndroid($SuspendMode)
				Return ; if need to clear screen do not click
			EndIf
			MoveMouseOutBS()
			_ControlClick($x, $y)
			If _Sleep($speed, False) Then ExitLoop
		Next
	Else
		If isProblemAffectBeforeClick() Then
			If $g_bDebugClick Then SetLog("VOIDED Click " & $x & "," & $y & "," & $times & "," & $speed & " " & $debugtxt & $txt, $COLOR_ERROR, "Verdana", "7.5", 0)
			checkMainScreen(False, $g_bStayOnBuilderBase, "Click")
			SuspendAndroid($SuspendMode)
			Return ; if need to clear screen do not click
		EndIf
		MoveMouseOutBS()
		_ControlClick($x, $y)
	EndIf
	SuspendAndroid($SuspendMode)
EndFunc   ;==>Click