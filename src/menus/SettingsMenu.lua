--[[
	The setting's Menu, where right now all you can do is change difficulty.

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

SettingsMenu = Class{__includes = BaseState}

function SettingsMenu:init(params)
	self.bigFont = love.graphics.newFont(64)
	self.difficultyString = gSaveData['difficulty']:gsub("^%l",string.upper)
	self.difficulty = gSaveData['difficulty']
	self.currentOption = 1
	self.highlightColor = {1,0,0,1}
	self.optionColors = {
		{1,1,1,1},
		{1,1,1,1},
	}
	self.currentColors = {
		{1,0,0,1},
		{1,1,1,1},
	}
end

function SettingsMenu:handleInput(key)
	self.currentColors[self.currentOption] = self.optionColors[self.currentOption]
	if key == 'down' then
		self.currentOption = self.currentOption == 2 and 1 or 2
	elseif key == 'up' then
		self.currentOption = self.currentOption == 1 and 2 or 1
	elseif self.currentOption == 1 and key == 'left' or key == 'right' then
			self.difficulty = self.difficulty == 'hard' and 'easy' or 'hard'
			self.difficultyString = self.difficulty:gsub("^%l",string.upper)
	elseif key == 'enter' or key == 'return' and self.currentOption == 2 then
		gStateMachine:change('main_menu',{})
	elseif key == 'escape' then
		gStateMachine:change('main_menu',{})
	end
	self.currentColors[self.currentOption] = self.highlightColor
end

function SettingsMenu:render()
	love.graphics.setFont(self.bigFont)
	love.graphics.printf("Settings Menu",0,20,780,"center")
	love.graphics.setFont(gFonts['md'])
	love.graphics.printf("Currently you can only select what difficulty you want.\nEasy or Hard.\nHard is the classic game rules whereas easy is for beginners.\n\n ",20,180,780,'left')
	love.graphics.setFont(gFonts['mono_xl'])
	love.graphics.printf("Current Difficulty",0,340,780,"center")

	love.graphics.printf({{1,1,1,1},'<- ',self.currentColors[1],self.difficultyString,{1,1,1,1},' ->'},0,400,780,'center')
	love.graphics.printf({self.currentColors[2],"Exit"},0,500,780,"center")
end

function SettingsMenu:exit()
	-- only change it/update the values if it's actually changed.
	print(gSaveData['difficulty'],self.difficulty)
	if gSaveData['difficulty'] ~= self.difficulty then
		gSaveData['difficulty'] = self.difficulty
		gSaveData:save()
	end
end