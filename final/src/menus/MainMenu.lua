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
MainMenu = Class{__includes = BaseState}

function MainMenu:enter(params)
	self.bigFont = love.graphics.newFont(64)
	-- once they finish a game I want them to be back on this screen with their previous mode already being selected.
	self.currentGameMode = params.mode or 1
	self.currentOption = 1
	self.currentModeString = ''
	self.gameModeStrings = {'Marathon Mode','Sprint Mode','Endless Mode'}
	self.gameModeDesc = {'Complete the 15 levels and attempt get the highest possible score.',
						 'Race against the clock till you get 50 lines completed.',
						 'Attempt to achieve the highest score possible with no limit except your skill.'}
	self.descFont = love.graphics.newFont(26)
	self.highlightColor = {1,0,0,1}
	self.optionColors = {
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
	}
	self.currentColors = {
		{1,0,0,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
		{1,1,1,1},
	}
	love.graphics.setColor(1,1,1,1)
	self.gameModes = {'start_marathon','time_attack','start_endless'}
	gCurrentSong = 'title_music'
end

function MainMenu:update(dt)

end

function MainMenu:handleInput(key)
	if key == 'down' then
		self.currentColors[self.currentOption] = self.optionColors[self.currentOption]
		self.currentOption = (self.currentOption + 1)
		if self.currentOption == 6 then
			self.currentOption = 1
		end
		self.currentColors[self.currentOption] = self.highlightColor
	elseif key == 'up' then
		self.currentColors[self.currentOption] = self.optionColors[self.currentOption]
		self.currentOption = self.currentOption -1
		if self.currentOption == 0 then
			self.currentOption = 1
		end
		self.currentColors[self.currentOption] = self.highlightColor
	elseif key == 'right' and self.currentOption == 1 then
		self.currentGameMode = self.currentGameMode + 1
		if self.currentGameMode == 4 then
			self.currentGameMode = 1
		end
	elseif key == 'left' and self.currentOption == 1 then
		self.currentGameMode = self.currentGameMode - 1
		if self.currentGameMode == 0 then
			self.currentGameMode = 3
		end
	elseif key == 'enter' or key == 'return' then
		if self.currentOption == 1 then
			gStateMachine:change(self.gameModes[self.currentGameMode],gSaveData['difficulty'])
		elseif self.currentOption == 2 then
			gStateMachine:change('high_scores',{
				['mode'] =  self.currentGameMode
			})
		elseif self.currentOption == 3 then
			gStateMachine:change('settings',{})
		elseif self.currentOption == 4 then
			gStateMachine:change('help')
		elseif self.currentOption == 5 then
			love.event.quit(0)
		end
	end
end

function MainMenu:render()
	love.graphics.setFont(self.bigFont)
	love.graphics.printf("MAIN MENU",0,20,780,"center")
	love.graphics.setFont(gMenuFont)
	love.graphics.printf({self.currentColors[1],
						  "<- " .. self.gameModeStrings[self.currentGameMode]  .. " ->"},
			0,120,780,"center")
	love.graphics.printf({self.currentColors[2],"View High Scores"},0,300,780,"center")
	love.graphics.printf({self.currentColors[4],"Help"},0,450,780,"center")
	love.graphics.printf({self.currentColors[3],"Settings"},0,380,780,"center")
	love.graphics.setFont(self.descFont)
	love.graphics.printf(self.gameModeDesc[self.currentGameMode],0,190,720,"center")
	love.graphics.setFont(self.bigFont)
	love.graphics.printf({self.currentColors[5],"EXIT"},0,580,780,"center")


end

function MainMenu:exit()
	if self.currentOption == 1 then
		gMusic['title_music']:pause()
	end
end