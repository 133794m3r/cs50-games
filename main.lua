--[[
	Falling Blocks game. The final project main code file

    Copyright (C) 2020  Macarthur David Inbody <admin-contact@transcendental.us>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

--[[
	Version 1.0.0
]]

require 'src/init'

function love.load()
	-- I can't let the keyboard repeat due to not being able to modify the delays.
	-- The only way I could maybe do this is to manually ignore delay if some timer isn't filled yet.
	-- SFX are broken because how fast the keys can repeat.
	love.keyboard.setKeyRepeat(true)
	-- should be done some other way but I don't know of a good way to do it other than this to make sure it'll work.
	gTextString = '_________'
	gTextStringLength = 0
	love.window.setTitle('Falling Blocks')
	love.graphics.setBackgroundColor(0, 0, 0)
	--setting up my fonts.
	gUIFont = love.graphics.newFont(36)
	gItemFont = love.graphics.newFont(37)
	gMenuFont = love.graphics.newFont(48)
	love.graphics.setFont(gUIFont)
	love.window.setMode(30 * (20 + 6), 30 * (23))
	love.graphics.setDefaultFilter( 'nearest', 'nearest', 1 )
	--[[
	-- Title is the title screen that has the logo
	-- HighScores is the high scores menu that lets you see the best scores/initials for the different modes
	-- Add Score is when they have achieved one, we'll check their current mode and final score/items at the end of the game
	-- Help tells them the current controls for the game
	-- Menu is the main menu where they'll select between the modes, help screen, to see the high score table etc
	-- The three game modes all just go into the "GamePlay" state, but initialize the class based upon what they need.
	-- Plus they set their respective music tracks to play
	-- Start Marathon is the start of the Marathon game mode. Goal is to get max score within 15 levels.
	-- Start Endless is just that it's the endless mode get as high of a score as possible.
	-- Time Attack is trying to get to 50 lines as fast as possible
	]]

	gStateMachine = StateMachine {
		['title'] = function() return TitleState() end,
		['high_scores'] = function() return HighScoreMenu() end,
		['check_scores'] = function() return CheckScores()  end,
		['add_score'] = function() return AddHighScore() end,
		['help'] = function() return HelpMenu() end,
		['main_menu'] = function() return MainMenu() end,
		['start_marathon'] = function() return MarathonMode() end,
		['start_endless'] = function() return EndlessMode() end,
		['time_attack'] = function() return TimeAttack() end,
		['settings'] = function() return SettingsMenu()  end
	}
	gCurrentSong = ''

	if love.filesystem.getInfo('savedata.dat') then
		--gSaveData = SaveData()
		gSaveData = SaveData(bitser.loadLoveFile('savedata.dat'))
	else
		gSaveData = SaveData()
	end
	love.keyboard.setTextInput(false)
	gStateMachine:change('title',{})
	gMusicMuted = false
end

function love.keypressed(key)
	-- too avoid having it trigger when we're doing textual inputs.
	-- If we're inputting text no reason to render the inputs.
	if not love.keyboard.hasTextInput() then
		-- m key is only ever used for muting across all game modes.
		if key == 'm' then
			gMusicMuted = not gMusicMuted
			if gMusic[gCurrentSong]:isPlaying() then
				gMusic[gCurrentSong]:pause()
			else
				gMusic[gCurrentSong]:play()
			end
		else
			gStateMachine:handleInput(key)
		end
	elseif key == 'enter' or key == 'return' then
		gStateMachine:handleInput(key)
	end

end

function love.textinput(t)
	local str_len = #gTextString
	if gTextStringLength <= 9 then
		--[[
		 replace the "_" with the actual character we get. This has to be done in main due to the way that love2d works.
		]]
		if gTextStringLength == 0 then
			gTextString = t  .. string.sub('_______',1,9-(gTextStringLength+1))
		elseif gTextStringLength <=8 then
			gTextString = string.sub(gTextString,1,gTextStringLength) .. t .. string.sub('_______',1,10-(gTextStringLength+1))
			--elseif gTextStringLength == 8 then
			--gTextString = string.sub(gTextString,1,8) .. t .. '_'
		elseif gTextStringLength == 9 then
			gTextString = string.sub(gTextString,1,9) .. t
		end
		gTextStringLength = gTextStringLength + 1
	end

end

function love.update(dt)
	gStateMachine:update(dt)
	Timer.update(dt)
end

function love.draw()
	gStateMachine:render()
end