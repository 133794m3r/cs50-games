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

CheckScores = Class{__includes=BaseState}
function CheckScores:enter(params)
	self.score = params.score or 0
	self.lines = params.lines or 0
	self.level = params.level or 0
	self.mode = params.mode or 1
	self.rank = 0
	self.name = ''
	self.print_string = ''
	-- basic enum
	local modes = {'marathon','sprint','endless'}
	self.currentMode = modes[self.mode]
	for x=1,15 do
		if gSaveData:getScore(self.currentMode,x) < self.score then
			self.rank = x
			break
		end
	end
	if self.rank == 0 then
		gStateMachine:change('high_scores',{['mode'] = self.mode})
	else
		love.keyboard.setTextInput(true)
		self.print_string = sprintf("You got Rank '%s' with a Score of %s",self.rank,number_separator(self.score))
	end

end

function CheckScores:update(dt)

end

function CheckScores:enterName(pos)
	local name = ''
end

function CheckScores:handleInput(key)
	-- if they press backspace or delete delete a character.
	self.print_string = sprintf("Rank: %s Score: %s",self.rank,self.score)
	if key == 'backspace' or key == 'delete' then
		if gTextStringLength >= 1 then
			gTextString = string.sub(gTextString,1,gTextStringLength-1)
			gTextString = gTextString .. string.sub('__________',1,10-(gTextStringLength-1))
			gTextStringLength = gTextStringLength - 1
		end
	elseif key == 'enter'  or key == 'return' then
		self.name = string.sub(gTextString,1,gTextStringLength)
		gSaveData:addScore(self.currentMode,self.rank,{
			['name'] = self.name,
			['score'] = self.score,
			['level'] = self.level,
			['lines'] = self.lines,
		})
		gSaveData:save()
		love.keyboard.setTextInput(false)
		gStateMachine:change('high_scores',{['mode'] = self.mode})
	end
end

function CheckScores:render()
	if self.name == '' then
		love.graphics.printf('Enter name then press enter when done.',0,140,780,'center')
	end
	love.graphics.printf(self.print_string,0,0,780,'center')
	love.graphics.printf('Name:' .. gTextString,0,90,780,'center')
	end
function CheckScores:exit()
	gTextString = '_________'
	gTextStringLength = 0
	-- failsafe disabler here.
	love.keyboard.setTextInput(false)
end