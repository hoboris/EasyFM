#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=EasyFM\images\EasyFM.ico
#AutoIt3Wrapper_outfile=EasyFM.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Language=1036
#AutoIt3Wrapper_Res_Field=Nom (short)|EasyFM
#AutoIt3Wrapper_Res_Field=Nom (long)|EasyFM
#AutoIt3Wrapper_Res_Field=Version (short)|1.5.0.0
#AutoIt3Wrapper_Res_Field=Version (long)|1.5.0.0
#AutoIt3Wrapper_Res_Field=Description (short)|Module de simulation de forgemagie
#AutoIt3Wrapper_Res_Field=Description (long)|Module de simulation de forgemagie
#AutoIt3Wrapper_Res_Field=Type|Module
#AutoIt3Wrapper_Res_Field=Auteur|ExiTeD [Equipe nAiO]
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Entête du module
Global Const _
	$MODULE_NOM = "EasyFM", $MODULE_AUTEUR = "ExiTeD", $MODULE_VERSION = "1.5.0.0", _
	$LAUNCH_PARAMETER = "-launch", $DEBUG_MODE = (FileExists("debug.txt")=1)
If StringLower($cmdLine[$cmdLine[0]]) <> $LAUNCH_PARAMETER Then ; Lancement parallèle
	Local $ligne = ""
	If $cmdLineRaw<>"" Then $ligne = $cmdLineRaw&" "
	If Not @Compiled Then
		Run(@AutoItExe&' "'&@ScriptFullPath&'" '&$ligne&$LAUNCH_PARAMETER, @ScriptDir)
	Else
		ShellExecute(@ScriptFullPath, $ligne&$LAUNCH_PARAMETER, @ScriptDir)
	EndIf
	Exit
ElseIf $DEBUG_MODE Then ; Notification du Debug Mode
	MsgBox(0, $MODULE_NOM&" v"&$MODULE_VERSION, "Debug mode activé", 1)
EndIf
#Region Librairies AutoIt
#Include <ComboConstants.au3>
#Include <StaticConstants.au3>
#Include <Array.au3>
#Include <File.au3>
#Include <GDIPlus.au3>
#Include <TreeViewConstants.au3>
#Include <ButtonConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WindowsConstants.au3>
#Include <GuiComboBox.au3>
#EndRegion

#EndRegion Librairies personnelles
#Include "EasyFM\Array2D.au3"
#EndRegion

HotKeySet("{F3}", "ExitScript")
HotKeySet("{F8}", "ShowArray")
TraySetIcon(@ScriptDir & "\EasyFM\images\EasyFM.ico")
Global $hImage, $hGraphic, $Puits, $Rune, $NbJets, $LabelPoids, $LabelType, $LabelEffet, $Fusion, $Iindex, $RIndex, $PwrPerte, $LabelPuits, $PwrPerteOrigin, $HomeBG
Global $MenuNouveau, $SubMenuNouveau1, $SubMenuNouveau2, $SubMenuNouveau3, $MenuAffichage, $SubMenuAffichage1, $SubMenuAffichage1, $ButtonRAZ, $ButtonFusionner, $LvlItem
Global $ResItem, $SpecItem, $AutreItem, $DoItem, $NouveauItem, $ListRune, $GUIGlobal, $Res, $color, $CaracItem, $IndexRune, $LabelPWRGActuel, $LabelPWRGmax, $ItemLevel
Global $PercentSN, $PercentSC, $PercentEC, $Random, $Treeview, $ItemBackUP
Global $sFileMap = @ScriptDir & "\EasyFM\bin\Configuration.csv"
Global $sFileCore = @ScriptDir & "\EasyFM\images\core\"
Global $NbRunes = _FileCountLines($sFileMap)
Global $Rune[$NbRunes + 1][6]
Global $RuneLog[$NbRunes - 1][2]
Global $Filtre = False
_FileReadToArray2D($sFileMap, $Rune, ",")

Global $DisplayItem, $Item, $Resulat, $Annexe, $DisplayRune, $ItemBackUP, $CompareItem
Global $Annexe[9] ;Création des Labels Annexe
Global $Resultat[4] ;Création des Labels Résultats
Global $DisplayRune[3] ;Création des Labels Runes
Global $DisplayItem[18][3] ; Création des Labels Jets
Global $CompareItem[18]
Global $Item[1][9]

Global Enum $Dofus, $DofusTouch

GUI()
Func GUI()
	$GUIGlobal = GUICreate("EasyFM - Service Forgemagie", 585, 540)
	GUISetIcon(@ScriptDir & "\EasyFM\images\easyFM.ico")
	GUISetFont(10, 400, 0, "Tahoma")
	GUISetBkColor(0xBBAE98)
	$MenuNouveau = GUICtrlCreateMenu("Fichier")
	$SubMenuNouveau1 = GUICtrlCreateMenuItem("Nouveau Objet", $MenuNouveau)
	$SubMenuNouveau3 = GUICtrlCreateMenuItem("Charger Objet...", $MenuNouveau)
	$SubMenuNouveau2 = GUICtrlCreateMenuItem("Sauvegarder Objet...", $MenuNouveau)
	$SubMenuNouveau4 = GUICtrlCreateMenuItem("Quitter", $MenuNouveau)
	$MenuAffichage = GUICtrlCreateMenu("Session")
	$SubMenuAffichage1 = GUICtrlCreateMenuItem("Objet en cours", $MenuAffichage)
	$SubMenuAffichage2 = GUICtrlCreateMenuItem("Runes Utilisées", $MenuAffichage)
	$MenuPlateforme = GUICtrlCreateMenu("Plateforme")
	$SubMenuPlateforme1 = GUICtrlCreateMenuItem("Dofus", $MenuPlateforme)
	$SubMenuPlateforme2 = GUICtrlCreateMenuItem("Dofus Touch", $MenuPlateforme)
;~	$MenuLangue = GUICtrlCreateMenu("Langue")
;~	$SubMenuLangue1 = GUICtrlCreateMenuItem("Français", $MenuLangue)
;~	$SubMenuLangue2 = GUICtrlCreateMenuItem("Anglais", $MenuLangue)
	$MenuAide = GUICtrlCreateMenu("Aide")
;~ 	$SubMenuAide1 = GUICtrlCreateMenuItem("Aide en Ligne", $MenuAide)
	$SubMenuAide2 = GUICtrlCreateMenuItem("Signaler un Bug", $MenuAide)
	$SubMenuAide3 = GUICtrlCreateMenuItem("A propos de EasyFM", $MenuAide)

	$ButtonFusionner = GUICtrlCreateButton("Fusionner", 300, 255, 100, 30, $BS_DEFPUSHBUTTON)
	$ButtonRAZ = GUICtrlCreateButton("Reset", 330, 310, 40, 20)
	GUICtrlSetState($ButtonFusionner, $GUI_DISABLE)
	GUICtrlSetState($ButtonRAZ, $GUI_DISABLE)
	$Treeview = GUICtrlCreateTreeView(290, 50, 160, 90, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetColor($Treeview, 0xa06000)
	GUICtrlSetFont($Treeview, 9.5, 800)
	$LabelCat = GUICtrlCreatePic($sFileCore & "Listcat.bmp", 320, 20, 100, 26)
	$LabelRune = GUICtrlCreatePic($sFileCore & "Listrune.bmp", 460, 20, 100, 26)
	GUICtrlSetColor($LabelRune, 0x006020)
	GUICtrlSetFont($LabelRune, 11, 800)
	$CaracItem = GUICtrlCreateTreeViewItem("Caractéristiques", $Treeview)
	GUICtrlSetImage(-1, $sFileCore & "CaracTreeView.bmp")
	$DoItem = GUICtrlCreateTreeViewItem("Dommages", $Treeview)
	GUICtrlSetImage(-1, $sFileCore & "NotUsedTreeView.bmp")
	$ResItem = GUICtrlCreateTreeViewItem("Résistances", $Treeview)
	GUICtrlSetImage(-1, $sFileCore & "ResTreeView.bmp")
	$SpecItem = GUICtrlCreateTreeViewItem("Spéciales", $Treeview)
	GUICtrlSetImage(-1, $sFileCore & "SpecialTreeView.bmp")
	$AutreItem = GUICtrlCreateTreeViewItem("Autres", $Treeview)
	GUICtrlSetImage(-1, $sFileCore & "AutresTreeView.bmp")
	$NouveauItem = GUICtrlCreateTreeViewItem("Nouveau", $Treeview)
	GUICtrlSetImage(-1, $sFileCore & "NotUsedTreeView.bmp")
	$ListRune = GUICtrlCreateList("", 460, 50, 110, 290, "", $WS_EX_CLIENTEDGE)
	GUICtrlSetFont($ListRune, 9.5, 800)
	GUICtrlCreateGroup("Objet - Bonus", 4, 0, 270, 360)
	GUICtrlCreateGroup("Rune", 290, 150, 164, 100)
	GUICtrlCreateGroup("Atelier", 280, 0, 300, 340)
	GUICtrlCreateGroup("Informations Annexes", 280, 340, 300, 144)
	GUICtrlCreateGroup("Puits", 280, 290, 100, 50)
	GUICtrlCreateGroup("Résultat", 4, 360, 270, 100)
	GUICtrlCreateGroup("Probabilités", 280, 430, 300, 54)
	$FiltreRune = GUICtrlCreateCheckbox("Masquer Runes Exo.", 340, 140, 110, 16)
	GUICtrlSetFont($FiltreRune, 8, 400)
	$Marks = GUICtrlCreatePic($sFileCore & "bannière.jpg", 3, 462, 274, 40)
	$Copyrights = GUICtrlCreateLabel("Certaines illustrations sont la priopriété d'Ankama Studio et de Dofus. Tous droits réservés. ExiTeD© 2009-2010. ", 290, 490, 300, 23)
	GUICtrlSetFont($Copyrights, 7, 400)
	$Enclume = GUICtrlCreatePic($sFileCore & "enclume.bmp", 200, 390, 70, 63)
	$Levier = GUICtrlCreatePic($sFileCore & "levier.bmp", 400, 270, 52, 66)
	$ExiPic = GUICtrlCreatePic($sFileCore & "iop.bmp", 550, 444, 24, 36)
	$HomeBG = GUICtrlCreatePic($sFileCore & "accueil.bmp", 6, 16, 264, 328)

	$Annexe[0] = GUICtrlCreateLabel("", 300, 360, 140, 20) ;PWRGActuel
	$Annexe[1] = GUICtrlCreateLabel("", 309, 385, 140, 20) ;PWRGmax
	$Annexe[4] = GUICtrlCreateLabel("", 307, 410, 140, 20) ;Etat du PWRG
	$Annexe[2] = GUICtrlCreateLabel("", 444, 360, 130, 20) ;PWR dujetdelarune
	$Annexe[3] = GUICtrlCreateLabel("", 453, 385, 100, 20) ;PWRmax dujetdelarune
	$Annexe[5] = GUICtrlCreateLabel("", 461, 410, 110, 20) ;Etat du PWR
	$Annexe[6] = GUICtrlCreateLabel("", 320, 456, 80, 20) ;%SC
	$Annexe[7] = GUICtrlCreateLabel("", 390, 456, 80, 20) ;%SN
	$Annexe[8] = GUICtrlCreateLabel("", 460, 456, 80, 20) ;%EC
	GUICtrlSetColor($Annexe[0], "0x3333CC")
	GUICtrlSetColor($Annexe[1], "0x000099")
	GUICtrlSetColor($Annexe[2], "0x990066")
	GUICtrlSetColor($Annexe[3], "0x660033")
	GUICtrlSetColor($Annexe[4], "0x000033")
	GUICtrlSetColor($Annexe[5], "0x330033")
	GUICtrlSetColor($Annexe[6], "0x006600")
	GUICtrlSetColor($Annexe[7], "0xFF3300")
	GUICtrlSetColor($Annexe[8], "0xFF0000")

	For $x = 0 To UBound($Annexe) - 1
		GUICtrlSetFont($Annexe[$x], 9, 800)
	Next

	$Resultat[0] = GUICtrlCreateLabel("", 20, 378, 180, 26) ; Rune n°
	$Resultat[1] = GUICtrlCreateLabel("", 20, 406, 180, 18) ; Résultat de la rune
	$Resultat[2] = GUICtrlCreateLabel("", 20, 420, 180, 18) ; Le puits absorbe
	$Resultat[3] = GUICtrlCreateLabel("", 20, 440, 180, 18) ; Puits remit à zéro
	GUICtrlSetFont($Resultat[0], 9, 800)
	GUICtrlSetFont($Resultat[1], 9, 800)
	GUICtrlSetColor($Resultat[2], "0x0131B4")
	GUICtrlSetFont($Resultat[3], 9, 800)
	GUICtrlSetColor($Resultat[3], 0xFF0000)

	$DisplayRune[0] = GUICtrlCreateLabel("", 300, 166, 140, 20) ; Nom de la rune
	$DisplayRune[1] = GUICtrlCreateLabel("", 350, 194, 61, 20) ; Poids de la rune
	$DisplayRune[2] = GUICtrlCreateLabel("", 350, 214, 90, 20) ; Effet de la rune
	GUICtrlSetColor($DisplayRune[0], 0x200040)
	GUICtrlSetFont($DisplayRune[0], 11, 800)
	GUICtrlSetColor($DisplayRune[1], 0x200040)
	GUICtrlSetColor($DisplayRune[2], 0x004060)

	$LabelPuits = GUICtrlCreateLabel("", 300, 310, 30, 20) ;Création du Label Puits
	GUICtrlSetFont($LabelPuits, 12, 800)

;~ 	LoadItem(@ScriptDir & "/Gelano.txt")
	GUISetState(@SW_SHOW, $GUIGlobal)

	While 1
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				Exit
			Case $msg = $ListRune
				$ReadRune = GUICtrlRead($ListRune)
				$IndexRune = _ArraySearch($Rune, $ReadRune, 1, 0, 0, 0, 1, 0)
				If $IndexRune <> -1 Then
					DisplayRuneDesc($ReadRune)
					DisplayAnnexe($ReadRune)
				EndIf
			Case $msg = $FiltreRune
				If GUICtrlRead($FiltreRune) = 1 Then ; Coché
					$Filtre = True
				Else
					$Filtre = False
				EndIf
				SetDataList(GUICtrlRead($Treeview) - 18)
			Case $msg = $CaracItem
				SetDataList(1)
			Case $msg = $DoItem
				SetDataList(2)
			Case $msg = $ResItem
				SetDataList(3)
			Case $msg = $SpecItem
				SetDataList(4)
			Case $msg = $AutreItem
				SetDataList(5)
			Case $msg = $NouveauItem
				SetDataList(6)
			Case $msg = $ButtonFusionner
				Forgemagie(GUICtrlRead($ListRune))
			Case $msg = $SubMenuNouveau1
				NewItem()
			Case $msg = $SubMenuNouveau2
				SaveItem()
			Case $msg = $SubMenuNouveau3
				Local $File = FileSaveDialog("Selectionnez votre objet", @ScriptDir, "Text files (*.txt)")
				If Not @error Then
					LoadItem($File)
				EndIf
			Case $msg = $SubMenuNouveau4
				$AskQuit = MsgBox(3, "Fermer L'application", "Êtes vous sûr de vouloir Quitter ?")
				If $AskQuit = 6 Then Exit
			Case $msg = $SubMenuAide2
				ShellExecute("https://github.com/hoboris/EasyFM/issues")
			Case $msg = $SubMenuAide3
				MsgBox(0, "A propos de EasyFM", "EasyFM v" & FileGetVersion(@ScriptName) & " Beta")
			Case $msg = $SubMenuAffichage1
				_ArrayDisplay($Item, "Objet")
			Case $msg = $SubMenuAffichage2
				_ArraySort($RuneLog, 1, 0, 0, 1)
				_ArrayDisplay($RuneLog, "Runes Utilisées")
			Case $msg = $SubMenuPlateforme1
				LoadPlatform($Dofus)
			Case $msg = $SubMenuPlateforme2
				LoadPlatform($DofusTouch)
;~			Case $msg = $SubMenuLangue1
;~				MsgBox(0, "TODO", "TODO")
;~			Case $msg = $SubMenuLangue2
;~				MsgBox(0, "TODO", "TODO")
			Case $msg = $ButtonRAZ
				ResetPuits()
		EndSelect
	WEnd
EndFunc   ;==>GUI

Func Forgemagie($tmp)
	$Iindex = _ArraySearch($Rune, $tmp, 0, 0, 1, 0, 1, 0) ;Recherche indice de la rune
	If $Iindex = -1 Then
		GUICtrlSetData($Resultat[0], "En séléctionnant une rune c'est mieux !")
		GUICtrlSetData($Resultat[1], "")
		GUICtrlSetData($Resultat[2], "")
		GUICtrlSetData($Resultat[3], "")
		Return -1
	EndIf
	$RIndex = _ArraySearch($Item, $Rune[$Iindex][5], 0, 0, 1, 0, 1, 6) ;Recherche de la ligne du jet correspondant à la rune
	If $RIndex = -1 Then ; Si le jet est exotique
		$RIndex = UBound($Item) - 1
		If $Item[UBound($Item) - 1][0] = 0 Then CreateExotique($Iindex)
		If $Rune[$Iindex][5] <> $Item[UBound($Item) - 1][6] Then
			GUICtrlSetData($Resultat[0], "Impossible d'ajouter 2 Exotique")
			GUICtrlSetData($Resultat[1], "")
			GUICtrlSetData($Resultat[2], "")
			GUICtrlSetData($Resultat[3], "")
			Return -1
		EndIf
	EndIf

	For $x = 1 To UBound($Item) - 1 ;Reset de l'affichage des jets en vert
		$Item[$x][7] = "0x006600"
	Next
	$ItemBackUP = $Item
	GUICtrlSetData($Resultat[2], "") ; Effacer le message 'Puits absorbe'
	CalculResultat(True, $RIndex, $Iindex) ;Param : Assigner la valeur au Résultat Calculer le Résultat

	Select
		Case $Random = 1 ;SC
			Gain()
			$Res = "Succès Critique !"
			$color = "0x006600"
		Case $Random = 2 ;SN
			Gain()
			Perte()
			$Res = "Succès Neutre !"
			$color = "0xAD4F09"
		Case $Random = 3 ;EC
			Perte()
			$Res = "Echec Critique !"
			$color = "0x960018"
	EndSelect
	$Fusion = $Fusion + 1

	UpdateLogRune($Iindex)
	SetPWR()
	DisplayAnnexe(GUICtrlRead($ListRune))
	DisplayResultat()
	ComparerLesItems()
	DisplayItem()
	Return -1
EndFunc   ;==>Forgemagie

;~ ################ Gestion des jets #################

Func CreateExotique($Runeindex)
	Local $x = UBound($Item) - 1
	$Item[$x][0] = 0 ;Jet_Actuel
	$Item[$x][1] = 0 ;PWR_ACTUEL
	$Item[$x][2] = 0 ;Jet_min
	$Item[$x][3] = Floor(100 / $Rune[$Runeindex][1]) ;Jet_max
	$Item[$x][6] = $Rune[$Runeindex][5] ;Nom du Jet
	$Index = _ArraySearch($Rune, $Item[$x][6], 0, 0, 0, 0, 1, 5) ; Index de la rune correspondant au Jet
	$Item[$x][4] = Round($Rune[$Index][1] / $Rune[$Runeindex][2], 2) ;PWR pour 1
	$Item[$x][5] = $Item[$x][3] * $Item[$x][4] ;PWR_MAX
	$Item[$x][7] = "0x006600" ;Couleur d'affichage
	$Item[$x][8] = 1
EndFunc   ;==>CreateExotique

Func DeleteExotique() ; Supprime la ligne du Jet Exotique
	For $x = 0 To UBound($Item, 2) - 1
		$Item[UBound($Item) - 1][$x] = 0
	Next
	Return -1
EndFunc   ;==>DeleteExotique

Func CheckExotique($IndexJ) ; Retourne True si Exotique Déjà présent ou si la rune créerait un overmax
	If $Item[UBound($Item) - 1][0] <> 0 Then Return True
	If $IndexJ = UBound($Item) - 1 Then Return True
	Return False
EndFunc   ;==>CheckExotique

Func CheckOvermax($IndexJ, $IndexR) ; Retourne True si Overmax Déjà présent ou si la rune créer un overmax
	For $x = 1 To UBound($Item) - 1
		If Number($Item[$x][0]) > Number($Item[$x][3]) Then Return True
	Next
	If Number($Item[$IndexJ][0]) + Number($Rune[$IndexR][2]) > Number($Item[$IndexJ][3]) Then Return True
	Return False
EndFunc   ;==>CheckOvermax

Func Gain()
	ConsoleWrite("caca")
	$Item[$RIndex][0] = Number($Item[$RIndex][0]) + Number($Rune[$Iindex][2]) ; mise à jour du jetactuel
	$Item[$RIndex][7] = "0x40a000" ; Colorisation du jet en vert clair
	Return -1
EndFunc   ;==>Gain

Func Perte()
	ConsoleWrite("caca2")
	$PwrPerte = Number($Rune[$Iindex][1]) ;calcul du poids à perdre
	If $Puits >= $PwrPerte And $Puits > 0 Then ; Si le puits est supérieur à la perte et s'il y a du puits
		GUICtrlSetData($Resultat[2], "...Le puits absorbe la perte...")
		$Puits = $Puits - $PwrPerte ; Le puits diminue
		Return 1
	Else
		$PwrPerteOrigin = $PwrPerte
		$PwrPerte = $PwrPerte - $Puits ; La perte diminue si le puits ne vaut pas 0
		$Puits = 0
	EndIf

	If $PwrPerte > GetPWRGactuel(True) Then $PwrPerte = 0
	While $PwrPerte > 0
;~ 		Msg(" PWR Perte = " & $PwrPerte)
		$JetDown = ChercherLeJetQuiBaisse() ; Recherche du jet qui baisse
;~ 		Msg(" Jet Qui Baisse = " & $JetDown)
		$Y = Floor($PwrPerte / Number($Item[$JetDown][4])) ; Le jet peut baisser de
		If $Y - Number($Item[$JetDown][0]) > 0 Then ; Si la perte est supérieur au jet actuel
			$Y = Number($Item[$JetDown][0]) ; Le perte devient le jet actuel
		EndIf
		If $Y < 1 Then ; Debug Ex: 1/20 = 0 = 1
			$Y = 1
		EndIf
;~ 		msg(" Y = " & $Y)
		$Perte = Random(0, $Y, 1)
;~ 		Msg(" Perte = " & $Perte)
		If $Perte <> 0 Then ; s'il la perte n'est pas nulle
			$Item[$JetDown][0] = Number($Item[$JetDown][0]) - $Perte ; mise à jour du jetactuel
			$PwrPerte = $PwrPerte - Ceiling($Perte * Number($Item[$JetDown][4]))

			If $PwrPerte < 0 Then ; si perte trop importante , création du puits
				$Puits = $Puits - $PwrPerte
			EndIf
			If $Item[$JetDown][7] <> "0x40a000" Then $Item[$JetDown][7] = "0xc00000"; Colorisation du Jet en rouge
		EndIf
	WEnd
	ConsoleWrite("caca3")
	If $Item[UBound($Item) - 1][0] = 0 Then DeleteExotique()
	Return -1
EndFunc   ;==>Perte

Func GetPWRGoveretExo() ; Calcul du PWRG Exotique + PWRG Overmax
	Local $PWRGover = 0
	For $x = 1 To UBound($Item) - 1 ; Calcul Du PWRG des Jets en Overmax
		If Number($Item[$x][0]) > Number($Item[$x][3]) Then
			$PWRGover = $PWRGover + ((Number($Item[$x][0]) - Number($Item[$x][3])) * Number($Item[$x][4]))
		EndIf
	Next
;~ 	ConsoleWrite( "PWR en OVER = " & $PWRGover + ( Number($Item[UBound($Item)-1][0]) * Number($Item[UBound($Item)-1][4]) ) & @cRLF )
	Return $PWRGover + (Number($Item[UBound($Item) - 1][0]) * Number($Item[UBound($Item) - 1][4])) ; On ajoute le PWR de l'exo car il n'est pas considéré comme over
EndFunc   ;==>GetPWRGoveretExo

Func CalculResultat($SelectionResutat, $IndexJet, $IndexRune) ; Param : Choisis un Résultat ou Non | Calcul des probabilités
	$CheckOverMax = CheckOvermax($IndexJet, $IndexRune)
	$CheckExotique = CheckExotique($IndexJet)


	If $CheckExotique Then
		$EtatPWR = 2
	Else
		$EtatPWR = (Number($Item[$IndexJet][0]) + $Rune[$IndexJet][2] - Number($Item[$IndexJet][2])) / (Number($Item[$IndexJet][3]) - Number($Item[$IndexJet][2])) ; Calcul PWR du jet
	EndIf
	$EtatPWRG = (GetPWRGactuel(True) / (GetPWRGmax() - $Item[$IndexJet][5])) ; Calcul PWRG moins le PWR du jet en cours de modification
	$InfluencePWRG = 30
	If $Item[$IndexJet][3] = 1 Then ; Le Calcul du PWR ne compte pas pour les objets dont le jet max est 1 (PA,PO,PM,etc...)
		$InfluencePWR = 0
	Else
		$InfluencePWR = 20
	EndIf

;~ 	FI(x) (-0.5) * ( ( Abs($i-80) - ($i-80) ) / ( $i-80 ) )
;~  FS(x) (0.5) * ( ( Abs($i-80) - ($i-80) ) / ( $i-80 ) ) + 1
;~   G(x) ( -(0/50)*($i - 50) ) + 66
;~   H(x) ( -(50/50)*($i - 50) ) + 66

	$i = $EtatPWR * 100
	$FI1 = (-0.5) * ((Abs($i - 50) - ($i - 50)) / ($i - 50))
	$FS1 = (0.5) * ((Abs($i - 50) - ($i - 50)) / ($i - 50)) + 1
	$G1 = (-(0 / 50) * ($i - 50)) + 66
	$H1 = (-(50 / 50) * ($i - 50)) + 66
	$tmp = ($FI1 * $G1) + ($FS1 * $H1)

	$j = $EtatPWRG * 100
	$FI2 = (-0.5) * ((Abs($j - 80) - ($j - 80)) / ($j - 80))
	$FS2 = (0.5) * ((Abs($j - 80) - ($j - 80)) / ($j - 80)) + 1
	$G2 = (-(23 / 80) * ($j - 80)) + 43
	$H2 = (-(108 / 80) * ($j - 80)) + 43
	$TMP2 = ($FI2 * $G2) + ($FS2 * $H2)

	$Moy = ((3 * $TMP2) + (2 * $tmp)) / 5
	$Moy2 = Sqrt(((3 * $tmp / 5) * (3 * $tmp / 5)) + ((2 * $TMP2 / 5) * (2 * $TMP2 / 5)))

	ConsoleWrite("PWR: " & $tmp & " | PWRG : " & $TMP2 & " |Moyenne1 : " & $Moy & " | Moyenne2 : " & $Moy2 & @CRLF)

	If $EtatPWR * 100 < 1 Then $EtatPWR = 0
	If $EtatPWRG * 100 < 1 Then $EtatPWRG = 0
;~ 	ConsoleWrite( "Etat PWR : " & $EtatPWR & " | Etat PWRG : " & $EtatPWRG & @CRLF )

	Select
		Case $CheckExotique Or $CheckOverMax
			ConsoleWrite("1" & @CRLF)
			$CoefOvermax = (1 - ((GetPWRGoveretExo() + Number($Rune[$IndexRune][1])) / 100)) / 2
			$PercentSN = Floor(50 - (16 * ($EtatPWR + $EtatPWRG) / 2))
		Case $EtatPWR * 100 > 80 And GetPWRGactuel(True) > 50
			ConsoleWrite("2" & @CRLF)
			$CoefOvermax = 1 * (($EtatPWR + $EtatPWRG) / 2)
			$PercentSN = Floor(50 - (8 * ($EtatPWR + $EtatPWRG) / 2))
		Case $EtatPWRG * 100 > 50
			ConsoleWrite("3" & @CRLF)
			$CoefOvermax = 1 * $EtatPWRG
			$PercentSN = 50
		Case $EtatPWR * 100 > 80
			ConsoleWrite("4" & @CRLF)
			$CoefOvermax = 1 * $EtatPWR
			$PercentSN = 50
		Case Else
			ConsoleWrite("5" & @CRLF)
			$CoefOvermax = 1
			$PercentSN = 50
	EndSelect


	$CoefRune = 1 - ($Rune[$IndexRune][1] / 200)
	$CoefLvl = 1 - (($LvlItem / 200) / 6)

	$PercentSC = Ceiling(80 - (($InfluencePWR * $EtatPWR) + ($InfluencePWRG * $EtatPWRG)))
	$PercentSC = Floor($PercentSC * $CoefLvl * $CoefRune * $CoefOvermax)

	If Not $CheckExotique And Not $CheckOverMax And $PercentSC < 15 Then
		ConsoleWrite("Pas d'exo et pas d'over max , SC inférieur à 15%" & @CRLF)
		$PercentSN = $PercentSN - (15 - $PercentSC)
		$PercentSC = 15
	EndIf
	$PercentEC = 100 - ($PercentSC + $PercentSN)
	If Not $CheckExotique And Not $CheckOverMax And $PercentEC > 35 Then
		ConsoleWrite("Pas d'exo et pas d'over max , EC supérieur à 35%" & @CRLF)
		$PercentSN = $PercentSN - ($PercentEC - 35)
		$PercentEC = 35
	EndIf

	If $CheckExotique And $Rune[$IndexRune][1] > 50 Then
		ConsoleWrite("Tentative à 1% exotique" & @CRLF)
		$PercentEC = 99
		$PercentSC = 1
		$PercentSN = 0
	EndIf

	If GetPWRGoveretExo() + $Rune[$IndexRune][1] > 100 Then
		ConsoleWrite("Trop d'exotique ou d'overmax présent sur l'objet" & @CRLF)
		$PercentEC = 100
		$PercentSC = 0
		$PercentSN = 0
	EndIf

	If Number($Item[$IndexJet][0]) + Number($Rune[$IndexRune][2]) > Number($Item[$IndexJet][3]) Then
		If Number($Item[$IndexJet][0]) + Number($Rune[$IndexRune][2]) > (100 - Number($Item[$IndexJet][3]) * Number($Item[$IndexJet][4])) / (Number($Item[$IndexJet][4] * 2)) + Number($Item[$IndexJet][3]) Then
			ConsoleWrite("Tentative d'overmax trop haute" & @CRLF)
			$PercentEC = 100
			$PercentSC = 0
			$PercentSN = 0
		EndIf
	EndIf
	If $PercentSN < 0 Then
		$PercentEC = 0
		$PercentSC = 0
		$PercentSN = 0
	EndIf

	ConsoleWrite("CheckOver = " & $CheckOverMax & " | CheckExo = " & $CheckExotique & " | CoefOvermax = " & $CoefOvermax & " | CoefRune = " & $CoefRune & " | CoefLvl = " & $CoefLvl & " | SC = " & $PercentSC & " | SN = " & $PercentSN & " | EC = " & $PercentEC & @CRLF & @CRLF)
	If $SelectionResutat Then SelectionResultat()
	Return -1
EndFunc   ;==>CalculResultat

Func SelectionResultat()
	$tmp = Random(1, 100, 1)
	$Random = 0
	Select
		Case $tmp <= $PercentSC
			$Random = 1
		Case $tmp <= ($PercentSN + $PercentSC)
			If $tmp > $PercentSC Then
				$Random = 2
			Else
				$Random = 1
			EndIf
		Case Else
			$Random = 3
	EndSelect
	Return -1
EndFunc   ;==>SelectionResultat

Func ChercherLeJetQuiBaisse(); Retourne l'index du jet qui baisse
	If $Item[UBound($Item) - 1][0] <> 0 And $Random = 3 Then Return UBound($Item) - 1
	If $Item[UBound($Item) - 1][0] <> 0 And $Rune[$Iindex][5] <> $Item[UBound($Item) - 1][6] Then Return UBound($Item) - 1 ; Si exotique retourn le dernier jet ( ligne exotique )
	For $x = 1 To UBound($Item) - 1 ; Recherche d'un jet overmax
		If Number($Item[$x][0]) > Number($Item[$x][3]) And $Random = 3 Then Return $x
		If Number($Item[$x][0]) > Number($Item[$x][3]) And $x <> $RIndex Then Return $x ; Retourne le jet overax
	Next
	If $NbJets = 1 Then Return 1
	While 1
		$RdmJet = Random(1, $NbJets, 1) ; un jet choisit aléatoirement.
		If Number($Item[$RdmJet][0]) = 0 Or $RdmJet = $RIndex Then ContinueLoop ; Si le jet vaut 0 alors on l'exclus
		If Number($Item[$RdmJet][4]) >= $PwrPerteOrigin Then ; si le pwr pour 1 de l'effet est supérieur à la baisse, alors
			$Epargne = Random(1, 100, 1)
			If $Epargne <= ($PwrPerteOrigin / Number($Item[$RdmJet][4])) * 100 Then ; s'il n'est pas épagné
				Return $RdmJet
			EndIf
		Else
			Return $RdmJet
		EndIf
	WEnd
EndFunc   ;==>ChercherLeJetQuiBaisse
;~ ################ Gestion de L'affichage #################

Func DisplayResultat()
	GUICtrlSetData($Resultat[3], "") ; Effacer le message 'Puits remit à zéro'
	GUICtrlSetData($Resultat[0], "Rune n° " & $Fusion)
	GUICtrlSetData($Resultat[1], $Res)
	GUICtrlSetColor($Resultat[1], $color)
	Return -1
EndFunc   ;==>DisplayResultat

Func DisplayAnnexe($tmp)
	Local $Oindex = _ArraySearch($Rune, $tmp, 0, 0, 0, 0, 1, 0) ;Recherche indice de la rune
	If $Oindex = -1 Then Return Msg("Selectionnez une rune")
	Local $ZIndex = _ArraySearch($Item, $Rune[$Oindex][5], 0, 0, 1, 0, 1, 6) ;Recherche de la ligne du jet correspondant à la rune
	If $ZIndex = -1 Then $ZIndex = UBound($Item) - 1

	CalculResultat(False, $ZIndex, $Oindex)
	GUICtrlSetData($Annexe[2], "PWRactuel : " & Round(Number($Item[$ZIndex][1])))
	GUICtrlSetData($Annexe[3], "PWRmaxi : " & Number($Item[$ZIndex][3]) * Number($Item[$ZIndex][4]))
	If $Item[$ZIndex][0] <> 0 Then
		GUICtrlSetData($Annexe[5], "Etat Jet : " & Round((Number($Item[$ZIndex][0]) - Number($Item[$ZIndex][2])) / (Number($Item[$ZIndex][3]) - Number($Item[$ZIndex][2])) * 100) & "%")
		GUICtrlSetData($Annexe[4], "Etat PWRG : " & Round(GetPWRGactuel(False) / GetPWRGmax() * 100) & "%")
	Else
		GUICtrlSetData($Annexe[4], "Etat PWRG : 0%")
		GUICtrlSetData($Annexe[5], "Etat Jet : 0%")
	EndIf
	GUICtrlSetData($Annexe[6], "SC : " & $PercentSC & "%")
	GUICtrlSetData($Annexe[7], "SN : " & $PercentSN & "%")
	GUICtrlSetData($Annexe[8], "EC : " & $PercentEC & "%")
	GUICtrlSetData($Annexe[0], "PWRGactuel : " & Round(GetPWRGactuel(False)))
	Return -1
EndFunc   ;==>DisplayAnnexe

Func DisplayItem()
	For $x = 1 To UBound($Item, 1) - 1 Step 1 ;Affichage des jets dans $DisplayItem depuis $Item
		GUICtrlSetColor($DisplayItem[$x][0], $Item[$x][7])
		If $CompareItem[$x] = 0 And $CompareItem[$x] <> -1 Then ContinueLoop
		GUICtrlSetData($DisplayItem[$x][0], "+ " & $Item[$x][0] & " " & $Item[$x][6]) ; Label Jet Actuel
		GUICtrlSetData($DisplayItem[$x][1], $Item[$x][3]) ; Label Max

		If Number($Item[$x][0]) >= Number($Item[$x][3]) Then
			GUICtrlSetColor($DisplayItem[$x][1], 0xBB0B0B) ; Si overmax le Label Jetmax Passe en Rouge
		Else
			GUICtrlSetColor($DisplayItem[$x][1], 0x000000) ; Sinon le Label passe Noir
		EndIf

		If Mod($x, 2) = 0 Then ;Colirisation des fonts
			GUICtrlSetBkColor($DisplayItem[$x][0], 0xB4AC8D)
			GUICtrlSetBkColor($DisplayItem[$x][1], 0xB4AC8D)
		Else
			GUICtrlSetBkColor($DisplayItem[$x][0], 0xC9BF9D)
			GUICtrlSetBkColor($DisplayItem[$x][1], 0xC9BF9D)
		EndIf

		If $Item[$x][0] = 0 And $x = UBound($Item) - 1 Then
			GUICtrlSetState($DisplayItem[$x][0], $GUI_HIDE)
			GUICtrlSetState($DisplayItem[$x][1], $GUI_HIDE)
		Else
			GUICtrlSetState($DisplayItem[$x][0], $GUI_SHOW)
			GUICtrlSetState($DisplayItem[$x][1], $GUI_SHOW)
		EndIf

	Next
	DisplayPuits()
	Return -1
EndFunc   ;==>DisplayItem

Func DisplayPuits()
	GUICtrlSetData($LabelPuits, $Puits)
	Return -1
EndFunc   ;==>DisplayPuits

Func DisplayRuneDesc($tmp)
	GUICtrlSetData($DisplayRune[0], "Rune " & $tmp)
	GUICtrlSetData($DisplayRune[1], "PWR : " & $Rune[$IndexRune][1])
	GUICtrlSetData($DisplayRune[2], "Bonus : +" & $Rune[$IndexRune][2])

	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\EasyFM\images\runes\None.png")
	If FileExists(@ScriptDir & "\EasyFM\images\runes\" & $tmp & ".png") = 1 Then ;Chargement de l'image de la Rune
		$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\EasyFM\images\runes\" & $tmp & ".png")
	EndIf
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUIGlobal)
	GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
	GUISetState(@SW_UNLOCK, $GUIGlobal)
	; Clean up resources
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()
	Return -1
EndFunc   ;==>DisplayRuneDesc

Func DisplayCreate()
	For $x = 1 To UBound($Item, 1) - 1
		$DisplayItem[$x][0] = GUICtrlCreateLabel("", 6, 30 + (($x - 1) * 20), 230, 20, $SS_CENTERIMAGE) ; Label des jets
		$DisplayItem[$x][1] = GUICtrlCreateLabel("", 240, 30 + (($x - 1) * 20), 30, 20, BitOR($SS_CENTER, $SS_CENTERIMAGE)); Label des jets max
		GUICtrlSetFont($DisplayItem[$x][1], 9, 800) ;Changement de polices des labels jetsmax
		GUICtrlSetFont($DisplayItem[$x][0], 9, 800) ;Changement de polices des label jets
	Next
	Return -1
EndFunc   ;==>DisplayCreate

Func DisplayDelete()
	For $x = 0 To UBound($DisplayItem) - 1
		For $Y = 0 To UBound($DisplayItem, 2) - 1
			GUICtrlDelete($DisplayItem[$x][$Y])
			$DisplayItem[$x][$Y] = 0
		Next
	Next
	Return -1
EndFunc   ;==>DisplayDelete

;~ ################ Gestion de L'objet #################

Func SetPWR()
	For $x = 1 To UBound($Item) - 1
		$Item[$x][1] = Floor($Item[$x][0] * $Item[$x][4])
	Next
	Return -1
EndFunc   ;==>SetPWR

Func ResetComparerObjet()
	For $x = 0 To UBound($CompareItem) - 1
		$CompareItem[$x] = -1
	Next
EndFunc   ;==>ResetComparerObjet

Func ComparerLesItems()
	Global $CompareItem[UBound($Item)]
	For $x = 0 To UBound($CompareItem) - 1
		$CompareItem[$x] = 0
	Next
	For $x = 1 To UBound($Item) - 1
		If $ItemBackUP[$x][0] <> $Item[$x][0] Then
			$CompareItem[$x] = $x
		EndIf
	Next
	Return -1
EndFunc   ;==>ComparerLesItems

Func ResetPuits()
	$Puits = 0
	GUICtrlSetData($Resultat[3], "Puits remit à Zéro !")
	DisplayPuits()
	Return -1
EndFunc   ;==>ResetPuits

Func GetPWRGmax() ; Retourne le PWRGmax
	Local $PWRGmax = 0
	For $x = 1 To UBound($Item) - 1
		$PWRGmax = $PWRGmax + ($Item[$x][3] * $Item[$x][4])
	Next
	Return $PWRGmax
EndFunc   ;==>GetPWRGmax

Func GetPWRGactuel($Inclure_Le_Jet_Actuel) ; Param : Prendre en compte le PWR du jet remonté | Retourne le PWRG
	Local $PWRGactuel = 0
	For $x = 1 To UBound($Item, 1) - 1 Step 1 ; Calcul du PWRGactuel
		If $Inclure_Le_Jet_Actuel And $x = $RIndex Then ContinueLoop
		$PWRGactuel = $PWRGactuel + ($Item[$x][0] * $Item[$x][4])
	Next
	Return $PWRGactuel
EndFunc   ;==>GetPWRGactuel

Func NewItem()
	$DisplayBuilder = 0
	Local $DisplayBuilder[62][5]
	#Region ### START Koda GUI section ### Form=
	$Form1 = GUICreate("Création d'un Objet", 600, 450)
	GUISetIcon(@ScriptDir & "\EasyFM\images\easyFM.ico")
	GUISetFont(10, 400, 0, "Tahoma")
	$Group1 = GUICtrlCreateGroup("Réglages de L'objet", 408, 8, 189, 130)
	$Input2 = GUICtrlCreateInput("0", 530, 78, 57, 21)
	$Checkbox = GUICtrlCreateCheckbox("J'ai tout bien rempli", 430, 110, 200, 17)
	$Label1 = GUICtrlCreateLabel("Nombre de Jets", 424, 40, 90, 17)
	$Label2 = GUICtrlCreateLabel("Niveau de L'objet", 424, 80, 100, 17)

	Local $NBJ = GUICtrlCreateCombo("1", 520, 38, 65, 25, $CBS_DROPDOWNLIST)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$Group2 = GUICtrlCreateGroup("Réglages des Jets", 8, 8, 390, 433)
	$Label4 = GUICtrlCreateLabel("Type de Jet", 85, 32, 80, 17)
	GUICtrlSetColor(-1, 0x200040)
	GUICtrlSetFont(-1, 9, 800)
	$Label5 = GUICtrlCreateLabel("MIN", 240, 32, 45, 17)
	GUICtrlSetColor(-1, 0x200040)
	GUICtrlSetFont(-1, 9, 800)
	$Label6 = GUICtrlCreateLabel("MAX", 284, 32, 45, 17)
	GUICtrlSetColor(-1, 0x200040)
	GUICtrlSetFont(-1, 9, 800)
	$Label7 = GUICtrlCreateLabel("Actuel", 330, 32, 45, 17)
	GUICtrlSetColor(-1, 0x200040)
	GUICtrlSetFont(-1, 9, 800)
	$Label8 = GUICtrlCreateLabel("Pour les jets dont le maximum " & @CRLF & "est 1 laisser Min = 0 Max = 1 ", 420, 320)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$MyButton1 = GUICtrlCreateButton("Valider", 448, 150, 52, 30, $BS_FLAT)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUISetState(@SW_SHOW)
	ControlFocus("", "", $NBJ)
	#EndRegion ### END Koda GUI section ###

	For $x = 1 To 16 ; Envois des données 1 à 16 de le combo box du nombre de jet
		GUICtrlSetData($NBJ, $x)
	Next

	For $x = 0 To 16 - 1
		$DisplayBuilder[$x + 1][0] = GUICtrlCreateCombo("", 35, 50 + 24 * $x, 185, 25, BitOr($CBS_DROPDOWNLIST, $WS_VSCROLL)) ; Choix du Jet
		GUICtrlSetState(-1, $GUI_HIDE)
		For $i = 2 To $NbRunes Step 1 ; Envois des données des différents types de jets dans le choix du Jet
			GUICtrlSetData($DisplayBuilder[$x + 1][0], $Rune[$i][5])
		Next
		_GUICtrlComboBox_SetCurSel($DisplayBuilder[$x + 1][0], 0)
		$DisplayBuilder[$x + 1][1] = GUICtrlCreateInput("0", 230, 52 + 24 * $x, 40, 20); Input du jet Minimum
		GUICtrlSetState(-1, $GUI_HIDE)
		$DisplayBuilder[$x + 1][2] = GUICtrlCreateInput("1", 280, 52 + 24 * $x, 40, 20) ; Input du jet Maximum
		GUICtrlSetState(-1, $GUI_HIDE)
		$DisplayBuilder[$x + 1][3] = GUICtrlCreateLabel($x + 1, 14, 52 + 24 * $x, 14, 20, $SS_RIGHT) ; Label numéro du Jet
		GUICtrlSetState(-1, $GUI_HIDE)
		$DisplayBuilder[$x + 1][4] = GUICtrlCreateInput("0", 330, 52 + 24 * $x, 40, 20) ; Input du jet actuel
		GUICtrlSetState(-1, $GUI_HIDE)
	Next

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUIDelete($Form1)
				ExitLoop
			Case $NBJ
				For $x = 0 To UBound($DisplayBuilder) - 1
					For $Y = 0 To UBound($DisplayBuilder, 2) - 1
						GUICtrlSetState($DisplayBuilder[$x][$Y], $GUI_HIDE)
					Next
				Next
				For $x = 0 To GUICtrlRead($NBJ) ;suppression du choix déjà existant
					For $Y = 0 To UBound($DisplayBuilder, 2) - 1
						GUICtrlSetState($DisplayBuilder[$x][$Y], $GUI_SHOW)
						If $Y = 2 Or $Y = 1 Then GUICtrlSetData($DisplayBuilder[$x][$Y], ($Y - 1))
					Next
				Next
			Case $Checkbox
				If GUICtrlRead($Checkbox) = $GUI_CHECKED Then
					GUICtrlSetState($MyButton1, $GUI_ENABLE)
				Else
					GUICtrlSetState($MyButton1, $GUI_DISABLE)
				EndIf
			Case $MyButton1
				Global $Item[GUICtrlRead($NBJ) + 2][9] ;Création du Tableau qui contiendra l'objet

				For $x = 1 To UBound($Item, 1) - 1 Step 1 ;sauvegarde des données de l'objet
					$Item[$x][2] = GUICtrlRead($DisplayBuilder[$x][1]) ; Jet_min
					$Item[$x][3] = GUICtrlRead($DisplayBuilder[$x][2]) ; Jet_max
					$Item[$x][6] = GUICtrlRead($DisplayBuilder[$x][0]) ; Nom
					$Item[$x][0] = GUICtrlRead($DisplayBuilder[$x][4]) ;Jet_Actuel
					$Index = _ArraySearch($Rune, $Item[$x][6], 0, 0, 0, 0, 1, 5) ; Index de la rune correspondant au Jet
					$Item[$x][4] = Round($Rune[$Index][1] / $Rune[$Index][2], 2) ;PWR pour 1
					$Item[$x][1] = Floor($Item[$x][0] * $Item[$x][4]) ;PWR_ACTUEL
					$Item[$x][5] = $Item[$x][3] * $Item[$x][4] ;PWR_MAX
					$Item[$x][7] = "0x006600" ;Couleur d'affichage
					$Item[$x][8] = 1
				Next
				DeleteExotique()
				$LvlItem = GUICtrlRead($Input2)
				$Puits = 0 ;Initialisation du puits
				$Fusion = 0
				$NbJets = GUICtrlRead($NBJ)
				GUICtrlDelete($HomeBG)
				GUICtrlSetData($Annexe[0], "PWRGactuel : " & Round(GetPWRGactuel(False)))
				GUICtrlSetData($Annexe[1], "PWRGmaximal : " & Round(GetPWRGmax()))
				GUICtrlSetData($Annexe[4], "Etat PWRG : " & Round(GetPWRGactuel(False) / GetPWRGmax() * 100) & "%")
				GUICtrlSetState($ButtonFusionner, $GUI_ENABLE)
				GUICtrlSetState($ButtonRAZ, $GUI_ENABLE)
				GUIDelete($Form1)
				ResetComparerObjet()
				ResetRuneLog()
				DisplayDelete()
				DisplayCreate()
				DisplayItem()
				ExitLoop 1
		EndSwitch
	WEnd
	Return -1
EndFunc   ;==>NewItem

Func SaveItem()
	Local $SaveDir = FileSaveDialog("Nommez votre objet", @ScriptDir, "Text files (*.txt)", 2, "Item.txt")
	If Not @error Then
		$Item[UBound($Item, 1) - 1][UBound($Item, 2) - 1] = $LvlItem
		_FileWriteFromArray2D($SaveDir, $Item, 1)
	EndIf
	Return -1
EndFunc   ;==>SaveItem

Func LoadItem($LoadDir)
	Global $Item[_FileCountLines($LoadDir) + 1][9]
	_FileReadToArray2D($LoadDir, $Item, ",")
	$LvlItem = $Item[UBound($Item, 1) - 1][UBound($Item, 2) - 1]
	$NbJets = _FileCountLines($LoadDir)
	$Fusion = 0
	$Puits = 0
	GUICtrlDelete($HomeBG)
	GUICtrlSetData($Annexe[0], "PWRGactuel : " & Round(GetPWRGactuel(False)))
	GUICtrlSetData($Annexe[1], "PWRGmaxi : " & Round(GetPWRGmax()))
	GUICtrlSetData($Annexe[4], "Etat PWRG : " & Round(GetPWRGactuel(False) / GetPWRGmax() * 100) & "%")
	GUICtrlSetState($ButtonFusionner, $GUI_ENABLE)
	GUICtrlSetState($ButtonRAZ, $GUI_ENABLE)
	ResetComparerObjet()
	ResetRuneLog()
	DisplayDelete()
	DisplayCreate()
	DisplayItem()
	Return -1
EndFunc   ;==>LoadItem

;~ ################ Fonctions Annexes #################

Func UpdateLogRune($tmp)
	Local $QIndex = _ArraySearch($RuneLog, "Rune " & $Rune[$tmp][0], 0, 0, 1, 0, 1, 0)
	$RuneLog[$QIndex][1] = $RuneLog[$QIndex][1] + 1
EndFunc   ;==>UpdateLogRune

Func ResetRuneLog()
	For $x = 2 To UBound($Rune) - 1
		$RuneLog[$x - 2][0] = "Rune " & $Rune[$x][0]
		$RuneLog[$x - 2][1] = 0
	Next
EndFunc   ;==>ResetRuneLog

Func ExitScript()
	Exit
EndFunc   ;==>ExitScript

Func SetDataList($tmp)
	GUICtrlSetData($ListRune, "") ;Mise à 0 de la Liste Rune
	For $i = 1 To $NbRunes Step 1 ;Remplissage de la Liste
		If $Rune[$i][3] = $tmp Then
			If $Filtre = True And _ArraySearch($Item, $Rune[$i][5], 0, 0, 1, 0, 1, 6) = -1 Then ContinueLoop
			GUICtrlSetData($ListRune, $Rune[$i][0])
		EndIf
	Next
	Return -1
EndFunc   ;==>SetDataList

Func MY_WM_PAINT($hWnd, $msg, $wParam, $lParam)
	_WinAPI_RedrawWindow($GUIGlobal, 0, 0, $RDW_UPDATENOW)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage, 300, 190, 44, 44)
	_WinAPI_RedrawWindow($GUIGlobal, 0, 0, $RDW_VALIDATE)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_PAINT

Func Msg($Text)
	MsgBox(0, "MsgBox", $Text)
	Return -1
EndFunc   ;==>Msg

Func ShowArray()
;~ 	_ArrayDisplay($DisplayItem)
EndFunc   ;==>ShowArray

Func LoadPlatform($tmp)
	If $tmp = $Dofus Then
		$sFileMap = @ScriptDir & "\EasyFM\bin\Configuration.csv"
	ElseIf $tmp = $DofusTouch Then
		$sFileMap = @ScriptDir & "\EasyFM\bin\ConfigurationTouch.csv"
	Else
		Return
	EndIf
	ResetAll()
EndFunc   ;==>LoadPlatform

Func ResetAll()
	GUICtrlSetState($ButtonFusionner, $GUI_DISABLE)
	GUICtrlSetState($ButtonRAZ, $GUI_DISABLE)
	GUICtrlSetData($ListRune, "")
	GUICtrlSetData($LabelPuits, "")
	For $x = 0 To UBound($Annexe) - 1
		GUICtrlSetData($Annexe[$x], "")
	Next
	For $x = 0 To UBound($Resultat) - 1
		GUICtrlSetData($Resultat[$x], "")
	Next
	For $x = 0 To UBound($DisplayRune) - 1
		GUICtrlSetData($DisplayRune[$x], "")
	Next
	ReDim $Item[1][9]
	GUICtrlDelete($HomeBG)
	$HomeBG = GUICtrlCreatePic($sFileCore & "accueil.bmp", 6, 16, 264, 328)

	$NbRunes = _FileCountLines($sFileMap)
	ReDim $Rune[$NbRunes + 1][6]
	ReDim $RuneLog[$NbRunes - 1][2]
	_FileReadToArray2D($sFileMap, $Rune, ",")
	$Fusion = 0
	$Puits = 0
	ResetComparerObjet()
	ResetRuneLog()
	
	_GDIPlus_Startup()
	$hImage = _GDIPlus_ImageLoadFromFile("")
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($GUIGlobal)
	GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
	GUISetState(@SW_UNLOCK, $GUIGlobal)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()
EndFunc   ;==>ResetAll