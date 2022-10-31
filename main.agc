
// Project: NoughtsAndCrosses 
// Created: 22-10-29

// show all errors
#include "MainMenu.scene"
#include "Game.scene"
#include "EndGame.scene"

type Block
	id as integer
	state as integer // 0 - empty | 1 - O | 2 - X
endtype

SetErrorMode(1) // only report errors

// set window properties
SetWindowTitle( "Noughts and Crosses" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 1024, 768 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 )

global current_scene = 1
global blocks as integer[9]
global x as integer
x = LoadImage("x.png")
global o as integer
o = LoadImage("o.png")
global turn = 1
global game_result = 0
global clicksound as integer
clicksound = LoadSound("ClickLight.wav")
global winsound as integer
winsound = LoadSound("YayWobble.wav")
global music as integer
music = LoadMusicOGG("music.ogg")
global fadespeed = 2

function SelectSlot(spriteid as integer)
	SetSpriteVisible(spriteid, 1)
	if turn = 1
		SetSpriteImage(spriteid, o, 1)
	else 
		SetSpriteImage(spriteid, x, 1)
	endif
endfunction

function PlayClick()
	PlaySound(clicksound, 50)
endfunction

function TestVictory()
	for i=1 to 2
		for j=1 to 3 //Rows
			prog = 0
			for k=1 to 3
				if blocks[k * j] = i
					prog = prog + 1
				endif
			next k
			if prog = 3
				current_scene=3
				game_result = i
			endif
		next j
		for j=1 to 3 //Columns
			prog = 0
			for k=j to 6+j step 3
				if blocks[k] = i
					prog = prog + 1
				endif
			next k
			if prog = 3
				current_scene = 3
				game_result = i
			endif
		next j
		if blocks[1] = i and blocks[5] = i and blocks[9] = i // diagonal 1
			current_scene=3
			game_result = i
		endif
		if blocks[3]=i and blocks[5]=i and blocks[7]=i // diagonal 2
			current_scene=3
			game_result = i
		endif
	next i
endfunction

function EvalClick(id as integer, hit as integer)
if blocks[id] = 0
    SelectSlot(hit)
   	blocks[id] = turn
    TestVictory()
    if turn = 1
    	turn = 2
   	else
   		turn = 1
  	endif
    PlayClick()
endif
endfunction

PlayMusicOGG(music, 1)

do
    Print( ScreenFPS() )
    if current_scene = 1
    	MainMenu_Setup()
    	while current_scene = 1
    		print(ScreenFPS())
    		if GetVirtualButtonReleased(MainMenu_PlayButton)
    			current_scene = 2
    			PlayClick()
    		endif
    		MainMenu_Sync()
    		Sync()
    	endwhile
    	for fade=100 to 0 step fadespeed * -1
    		MainMenu_fade(fade)
    		sync()
    	next fade
    	MainMenu_cleanup()
    endif
    if current_scene = 2 // Game
    	Game_Setup()
    	game_result = 0
    	for i=0 to blocks.length
    		blocks[i] = 0
    	next i
    	turn = 1
    	for fade=0 to 100 step fadespeed
    		Game_fade(fade)
    		sync()
    	next fade
    	while current_scene = 2
    		print(ScreenFPS())
    		if GetPointerReleased() = 1
    			pointerx = GetPointerX()
    			pointery = GetPointerY()
    			
    			hit = GetSpriteHit(pointerx, pointery)
    			select hit
    				case Game_slot1
    					EvalClick(1, hit)
    				endcase
    				case Game_slot2
    					EvalClick(2, hit)
    				endcase
    				case Game_slot3
    					EvalClick(3, hit)
    				endcase
    				case Game_slot4
    					EvalClick(4, hit)
    				endcase
    				case Game_slot5
    					EvalClick(5, hit)
    				endcase
    				case Game_slot6
    					EvalClick(6, hit)
    				endcase
    				case Game_slot7
    					EvalClick(7, hit)
    				endcase
    				case Game_slot8
    					EvalClick(8, hit)
    				endcase
    				case Game_slot9
    					EvalClick(9, hit)
    				endcase
    				case default
    				endcase
    			endselect
    		endif
    		Game_Sync()
    		Sync()
    	endwhile
    	PlaySound(winsound, 60)
    	Game_cleanup()
    endif
    if current_scene = 3
    	EndGame_Setup()
    	for fade=0 to 100 step fadespeed
    		EndGame_fade(fade)
    		sync()
    	next fade
    	select game_result
    		case 1
    			SetTextString(EndGame_ResultText, "Player 1 Won!")
    		endcase
    		case 2
    			SetTextString(Endgame_resulttext, "Player 2 Won!")
    		endcase 
    		case 3
    			SetTextString(Endgame_resulttext, "Draw!")
    		endcase
 
    		case default
    			SetTextString(Endgame_resulttext, "Undefined")
    		endcase 
    	endselect
    	while current_scene = 3
    		if GetVirtualButtonReleased(EndGame_ReplayButton)
    			current_scene = 2
    		endif
    		if GetVirtualButtonPressed(EndGame_MainMenuButton)
    			current_scene = 1
    		endif 
    		sync()
    	endwhile
    	for fade=100 to 0 step fadespeed * -1
    		EndGame_fade(fade)
    		sync()
    	next fade
    	EndGame_cleanup()
    endif
    Sync()
loop
