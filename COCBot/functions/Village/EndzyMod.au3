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
#EndRegion - For MainLoop - Endzy

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

Func ROM(); Request Only Mode
	ClickAway()
	SetLog("======= REQUEST ONLY MODE =======", $COLOR_ACTION)
	_RunFunction("FstReq")
	Local $aRndFuncList = ['Collect', 'DailyChallenge', 'PetHouse', 'CollectAchievements', 'CollectBB', 'Laboratory', 'CollectCCGold', 'ForgeClanCapitalGold']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		ClickAway()
		If _Sleep(50) Then Return
		If $g_bRestart Then Return
	Next

	checkSwitchAcc()

EndFunc  ;==> ROM

Func DOM() ; Donate Only Mode
	ClickAway()
	SetLog("======= DONATE ONLY MODE =======", $COLOR_ACTION)
	Local $count = 0

	Collect()
	_RunFunction("FstReq")
	For $i = 0 to 3

		$count += 1
		SetLog("Donate loop: !" & $count, $COLOR_SUCCESS)
		;_RunFunction("DonateCC,Train")
		TrainSystem()
		If _Sleep(1000) Then Return
		ClickAway()
		If _Sleep(1000) Then Return
		FastDonate()
		If Not $g_bRunState Then Return
		If _Sleep(1000) Then Return

		If $count < 2 Then
			Local $aRndFuncList = ['Collect', 'CollectBB', 'Laboratory', 'CollectCCGold', 'ForgeClanCapitalGold']
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				ClickAway()
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next
		EndIf

		ClickAway()

		If $count < 3 Then
			Local $aRndFuncList = ['Collect', 'CollectBB', 'Laboratory', 'CollectCCGold', 'ForgeClanCapitalGold']
			_ArrayShuffle($aRndFuncList)
			For $Index In $aRndFuncList
				If Not $g_bRunState Then Return
				_RunFunction($Index)
				ClickAway()
				If _Sleep(50) Then Return
				If $g_bRestart Then Return
			Next
		EndIf

	Next

	SetLog("Donate loop complete! Swtiching Account now.", $COLOR_SUCCESS)
	checkSwitchAcc()

EndFunc  ;==> DOM

Func AOM() ; Attack Only Mode
	ClickAway()
	Local $b_SuccessAttack = False
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
	ClickAway()
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
	ClickAway()
	Local $aRndFuncList = ['CollectCCGold', 'ForgeClanCapitalGold', 'BuilderBase', 'FstReq']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		ClickAway()
		If _Sleep(50) Then Return
		If $g_bRestart Then Return
	Next

	checkSwitchAcc()

EndFunc   ;==> BBAOM

Func MVAOM() ; Main Village Attack Only Mode
	ClickAway()
	Local $b_SuccessAttack = False
	SetLog("======= MAIN VILLAGE ATTACK ONLY MODE =======", $COLOR_ACTION)
	Local $aRndFuncList = ['Collect', 'CollectCCGold', 'ForgeClanCapitalGold', 'FstReq']
	_ArrayShuffle($aRndFuncList)
	For $Index In $aRndFuncList
		If Not $g_bRunState Then Return
		_RunFunction($Index)
		ClickAway()
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
	ClickAway()
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
	ClickAway()
	Local $b_SuccessAttack = False
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
	ClickAway()
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
#cs
	SetLog("======= ROUTINE MODE =======", $COLOR_ACTION)
	_RunFunction("CollectCCGold")
	CommonRoutine("FirstCheckRoutine")
	_RunFunction("DonateCC,Train")
	If $g_bDonated = True then
		SetLog("Setlog 1: THE VARIABLE $g_bDonated IS: " & $g_bDonated)
	EndIf
	$g_bDonated = False
	If $g_bDonated = False then
		SetLog("Setlog 2: THE VARIABLE $g_bDonated IS: " & $g_bDonated)
	EndIf
	_RunFunction("DonateCC,Train")
	checkSwitchAcc() ;switch to next account
#ce	
	ClickAway()
	SetLog("======= ROUTINE MODE =======", $COLOR_ACTION)
	CommonRoutine("RoutineMode")
	_RunFunction("DonateCC,Train")
	ClickAway()
	CommonRoutine("RB4Switch")
	
	checkSwitchAcc() ;switch to next account

EndFunc  ;==> RM

Func CGM() ; Clan  Games Mode
	ClickAway()
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
	ClickAway()
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
	ClickAway()
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
	ClickAway()
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
	ClickAway()
EndFunc ; ==> ChkTHlvl

Func LC1() ; Leave Clan version 1.0

	ClickAway()
	Click(Random(5,30,1), Random(318,385,1)) ; Click open clan chat	;Click(17,352)
	If _Sleep(Random(1500,3000,1)) Then Return
	Click(Random(10,200,1), Random(10,40,1)) ; Click open clan info at top	;Click(118,26)
	If _Sleep(Random(1500,3000,1)) Then Return
	Click(Random(699,825,1), Random(370,395,1)) ;Click Leave button	;Click(767,391)
	If _Sleep(Random(1500,3000,1)) Then Return
	Click(Random(480,575,1), Random(380,420,1)) ; Click Okay button	;Click(517,400)
	If _Sleep(Random(1000,3000,1)) Then Return
	Click(Random(325,340,1), Random(324,380,1)) ; Click close clan chat	;Click(333,354)
	ClickAway()
	
EndFunc  ;==> LC1

;Func PCM1() ; Promote Clan mate to elder or co-leader
;EndFunc

;	For $x = 0 To 5
;		 _Sleep(1000)
;		If QuickMIS("BC1", $g_sImgFCsurr, 14, 520, 129, 560, True, $g_bDebugImageSave) Then ; top left (14, 520) bottom right (129,560)
;			SetLog("Found Surrender Button, PrepareAttack now!", $COLOR_INFO)
;			PrepareAttack($g_iMatchMode)
;			_Sleep(1000)
;			ExitLoop
;		EndIf
;	Next

Func Donate1n2($btest = False)
	
	If QuickMIS("BC1", $g_sImgDonateCC, 210, 510, 300, 600, True, $g_bDebugImageSave) Then ; 200, 540, 300, 600
		SetLog("Found Donate button", $COLOR_INFO)	
		Click(Random($g_iQuickMISX, $g_iQuickMISX + 10, 1), Random($g_iQuickMISY, $g_iQuickMISY + 20, 1)) ; Click donate button		

		If _Sleep(1500) Then Return
		
		If QuickMIS("BC1", $g_sImgLoonDonMod, 350, 235, 400, 265, True) Then
			SetLog("Found loons to donate", $COLOR_INFO)
			If Not $btest Then
				;Click($g_iQuickMISX, $g_iQuickMISY, 9, 150) ;Click(378, 75, 7, 100, "Donating...") ; CLick Troops - Balloon
				For $i = 1 To 9
					Click(Random($g_iQuickMISX - 20, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 20, $g_iQuickMISY + 20, 1))
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
	Else
		SetLog("No Donate button found", $COLOR_ERROR)
	EndIf
	
	If QuickMIS("BC1", $g_sImgDonateCC, 200, 420, 300, 510, True, $g_bDebugImageSave) Then ; 200, 540, 300, 600
		SetLog("Found Donate button", $COLOR_INFO)
		Click(Random($g_iQuickMISX, $g_iQuickMISX + 10, 1), Random($g_iQuickMISY, $g_iQuickMISY + 20, 1))
		
		If _Sleep(1500) Then Return
		
		If QuickMIS("BC1", $g_sImgLoonDonMod, 350, 235, 400, 265, True) Then
			SetLog("Found loons to donate", $COLOR_INFO)
			If Not $btest Then
				;Click($g_iQuickMISX, $g_iQuickMISY, 9, 150) ;Click(378, 75, 7, 100, "Donating...") ; CLick Troops - Balloon
				For $i = 1 To 9
					Click(Random($g_iQuickMISX - 20, $g_iQuickMISX + 30, 1), Random($g_iQuickMISY - 20, $g_iQuickMISY + 20, 1))
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
	Else
		SetLog("No Donate button found", $COLOR_ERROR)
	EndIf

EndFunc  ;==> Donate1n2

Func FastDonate()
	ClickAway()
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
		;Donate1n2(True) ; donate troops/siege/spells
		Donate1n2()
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

#Region ; Mod Clicks
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

Func DonateClick($x, $y, $times = 1, $speed = 0, $debugtxt = "")
	Local $txt = "", $aPrevCoor[2] = [$x, $y]
	If $g_bUseRandomClick Then
		$x = Random($x - 10, $x + 10, 1)
		$y = Random($y - 10, $y + 10, 1)
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
				;checkMainScreen(False, $g_bStayOnBuilderBase, "Click")
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
			; checkMainScreen(False, $g_bStayOnBuilderBase, "Click")
			SuspendAndroid($SuspendMode)
			Return ; if need to clear screen do not click
		EndIf
		MoveMouseOutBS()
		_ControlClick($x, $y)
	EndIf
	SuspendAndroid($SuspendMode)
EndFunc   ;==>Click
#EndRegion ;Mod Clicks

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

