--[[
	Marathon Game Mode file
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

-- MarathonMode inhertis from the BaseGame class and handles it's game over bits
MarathonMode = Class{__includes={BaseGame} }

function MarathonMode:enter(params)
	gCurrentSong = 'normal_theme'

	self.paused = false
	BaseGame.init(self,params or {})
	love.graphics.setFont(gUIFont)
	self.endLevel = params.level or 15
	self.gameMode = 1
	if gMusicMuted == false then
		gMusic['normal_theme']:play()
	end
end

function MarathonMode:update(dt)
	if not self.gameOver and not self.paused then
		self:updateBoard(dt)
	end
end

function MarathonMode:checkWin()
	if self.level >= self.endLevel then
		self:endGame()
	elseif self.level == 14 then
		gMusic['normal_theme']:stop()
		gMusic['final_countdown']:play()
		gCurrentSong = 'final_countdown'
	end
end