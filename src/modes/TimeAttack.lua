--[[
	Time Attack/Sprint Game Mode

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

TimeAttack = Class{__includes=BaseGame}

function TimeAttack:enter(params)
	gMusic['sprint_theme']:play()
	gCurrentSong = 'sprint_theme'
	self.paused = false
	BaseGame.init(self,params or {})
	love.graphics.setFont(gUIFont)
	self.endLines = params.endLines or 50
	self.gameMode = 2
end

function TimeAttack:update(dt)
	if not self.gameOver and not self.paused then
		self:updateBoard(dt)
	end
end

function TimeAttack:checkWin()
	if self.lines >= self.endLines then
		self:endGame()
	end
end