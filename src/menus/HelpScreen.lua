--[[
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
HelpMenu = Class{__includes = BaseState}

function HelpMenu:init(params)
	self.currentTextScreen = 1
	self.helpScreenTitles = {
		'Controls',
		'Gameplay 1',
		'Gameplay 2',
		'Game Difficulties',
		'Marathon Mode',
		'Sprint Mode',
		'Endless Mode',
		'Scoring',
	}
	self.helpScreenTexts= {
		"This game uses keyboard controls. Gamepads aren't currently supported.\n\nThe left/right arrow keys move the piece in their respective directions. Down moves the piece down by one cell.\n\nUp arrow and 'x' rotate the piece clockwise. 'z' left/right ctrl rotate it counter clockwise. 'c' is the 'hard drop' key causing the piece to drop to the bottom as fast as possible and lock in place.\n\nYour 'shift' keys allow you to hold a piece if no piece is already held or it will swap the currently held piece with the piece on the game board.\n\n'return'/'enter' 'space bar' will cause the game to become paused. Pressing it again will unpause the game.\n\n'm' will mute/unmute the audio.",
		"Gameplay involves placing the pieces onto the gameboard such that you can create a line of them from one side to the other.\n\nDoing so will clear that line, award points, and if enough lines have been cleared moving to the next level.\n\nAfter a piece touches the ground/frozen piece you have 0.5s to move it/15 moves before it is locked in place and a new piece will be spawned.\n\nYou can store a piece in your held slot, doing so will help you to create larger number of lines to rack up even more points as there are bonuses for additional lines.\n\nEvery 10 lines you complete advances you by 1 level.\n\nThere are 3 gameplay modes in the game.\nMarathon, Sprint and Endless and are explained on their respective screens.",
	"As you move your piece you have a 'ghost' piece that is shown below it. This piece shows where your piece would land if you 'hard dropped' it or where it will end up after letting gravity pull it to the ground.\n\nThen after getting a game over or completing the game mode you will be given the option to enter your name for the high score table. There is one for each difficulty and game mode. Your name must be no more than 10 characters in length.\n\nThere is an Easy Mode and a Hard/Classic Mode.\n\nYou get a game over by having a piece be locked in place above the top of the visible game window. The other way is to complete the specific conditions laid out in the game mode.",
		"There are two different difficulty options. The first is the 'easy' mode and in that mode you have the following changes to make the game easier. Whereas the default mode 'hard' is actually the classic mode.\n\n1) The curve of the drop times is adjusted. As in the amount of time it takes before a piece moves down by 1 cell.\n2) The amount of moves/time you have before a piece locks into place is increased.\n\nThe easy mode gives you more time to think/move before a piece is auto-advanced. This is achieved by making the fall speed increase ~30% more slowly.\nSecondly you are given 3 additional moves before a piece is locked in place.",
		'This game mode has you attempting to get as high of a score as possible by the start of level 15.\n\nThis means you have 14 levels to rack up your score. Then upon achieving your 150th line you will have the game be ended.\n\nThe levels past 15 are considered to increase in difficulty rapidly.',
		'Sprint Mode tasks you with getting the maximum score within the first 50 lines of the game.\n\nThis is a mode to quickly get into a game and practice your abilities to buildup combos.',
		'Endless mode is all about playing until game over.\n\nThe game will no end until you have no more valid moves in the game or a piece is locked above the game board thus making the spawning of the next piece impossible.\n\nNote that all levels beyond 15 rapidly increase in difficulty due to the pieces moving more and more rapidly.',
		"The scoring system is explained below.\nFor each cell you move a piece down(by pressing the down arrow) you get 10 points. When you 'hard drop' the piece you'll get 20 points per cell up to a maximum of 280 points.\n\nThe points for each line cleared is based upon how much the clear is worth multiplied by the level.\nGetting a single line clear is worth 100 points.\nTwo lines is worth 300 points.\nThree lines are worth 500 points.\nFinally a Quad is worth 800 points.\n\nThe basic formula for point awarding for line clears is as follows.\npointsAwarded = currentLevel*linePoints\nSo if you got a double on level 5 then you'd be awarded 5*300 = 1,500 points.",
		'',
	}
	self.highlightColor = {1,0,0,1}
	self.currentColors = {
		{1,0,0,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
	}
	self.optionColors = {
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
	}
	self.positions = {
		157,
		200,
		245,
		288,
		332,
		376,
		420,
		465,
	}
end

function HelpMenu:handleInput(key)
	if key == 'escape' or key == 'esc' then
		gStateMachine:change('main_menu',{})
	else
		self.currentColors[self.currentTextScreen] = self.optionColors[self.currentTextScreen]
		if key == 'left' then
			self.currentTextScreen = self.currentTextScreen == 1 and #self.helpScreenTitles or self.currentTextScreen -1
		elseif key == 'right' then
			self.currentTextScreen = self.currentTextScreen == #self.helpScreenTitles and 1 or self.currentTextScreen + 1
		else
			local num = tonumber(key)
			if num ~= nil and num >= 1 and num <= #self.helpScreenTitles then
				self.currentTextScreen = num
			end
		end
		self.currentColors[self.currentTextScreen] = self.highlightColor
	end
end

function HelpMenu:render()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(gFonts['title'])
	love.graphics.printf(self.helpScreenTitles[self.currentTextScreen],0,0,780,'center')
	love.graphics.setFont(gFonts['sm'])
	love.graphics.printf(self.helpScreenTexts[self.currentTextScreen],20,90,740,'left')
	love.graphics.setFont(gFonts['md'])
	love.graphics.printf('Press Escape to return to main menu.',0,550,780,'center')
	love.graphics.setFont(gFonts['mono_lg'])
	love.graphics.printf({
		{1,1,1,1},'     <- ',
		self.currentColors[1],'1',
		self.currentColors[2],' 2',
		self.currentColors[3],' 3',
		self.currentColors[4],' 4',
		self.currentColors[5],' 5',
		self.currentColors[6], ' 6',
		self.currentColors[7],' 7',
		self.currentColors[8],' 8',
		{1,1,1,1},' ->     '
	},0,600,780)

	love.graphics.setColor(1,0,0)
	love.graphics.print('[',self.positions[self.currentTextScreen],600)
	love.graphics.print(']',self.positions[self.currentTextScreen]+39,600)


end