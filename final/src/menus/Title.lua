--[[
	Title State, which is what's shown upon startup

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
TitleState = Class{__includes = BaseState}
function TitleState:enter(params)
	self.titleFont = love.graphics.newFont(52)
	self.title1 = {
		{1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{1,0,0,0,0,0,0,0,2,0,0,0,3,0,0,0,0,4,0,0,0,0,5,0,6,0,0,0,6,0,0,7,7,7,7,0,},
		{1,0,0,0,0,0,0,2,0,2,0,0,3,0,0,0,0,4,0,0,0,0,5,0,6,6,0,0,6,0,7,0,0,0,0,7,},
		{1,1,1,0,0,0,2,0,0,0,2,0,3,0,0,0,0,4,0,0,0,0,5,0,6,0,6,0,6,0,7,0,0,0,0,0,},
		{1,0,0,0,0,0,2,2,2,2,2,0,3,0,0,0,0,4,0,0,0,0,5,0,6,0,0,6,6,0,7,0,0,7,7,7,},
		{1,0,0,0,0,0,2,0,0,0,2,0,3,0,0,0,0,4,0,0,0,0,5,0,6,0,0,0,6,0,7,0,0,0,0,7,},
		{1,0,0,0,0,0,2,0,0,0,2,0,3,3,3,3,0,4,4,4,4,0,5,0,6,0,0,0,6,0,0,7,7,7,7,0,},
	}
	self.title2 = {
		{0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
		{0,1,0,0,0,1,0,2,0,0,0,0,0,3,3,3,0,0,0,4,4,4,0,0,5,0,0,0,5,0,0,6,6,6,0,0,},
		{0,1,0,0,0,1,0,2,0,0,0,0,3,0,0,0,3,0,4,0,0,0,4,0,5,0,0,5,0,0,6,0,0,0,0,0,},
		{0,1,1,1,1,0,0,2,0,0,0,0,3,0,0,0,3,0,4,0,0,0,0,0,5,5,5,0,0,0,0,6,6,6,0,0,},
		{0,1,0,0,0,1,0,2,0,0,0,0,3,0,0,0,3,0,4,0,0,0,0,0,5,0,5,0,0,0,0,0,0,0,6,0,},
		{0,1,0,0,0,1,0,2,0,0,0,0,3,0,0,0,3,0,4,0,0,0,0,0,5,0,0,5,0,0,0,0,0,0,6,0,},
		{0,1,1,1,1,0,0,2,2,2,2,0,0,3,3,3,0,0,0,4,4,4,0,0,5,0,0,0,5,0,0,6,6,6,0,0,},
	}
	gCurrentSong = 'title_music'
	gMusic['title_music']:play()
end

function TitleState:update(dt)

end
function TitleState:handleInput(key)
	if key == 'enter' or key == 'return' then
		gStateMachine:change('main_menu',{})
	end
end
function TitleState:drawBlock(block,x,y)
	--z:7,s:6,t:5,l:4,j:3,o:2,i:1
	local colors = {
		{{0.2456, 0.3971, 0.4911}, {0.517, 0.836, 1.034}, {0.3247, 0.525, 0.6494}},
		{{0.4807, 0.3605, 0.2456}, {1.012, 0.759, 0.517}, {0.6355, 0.4767, 0.3247}},
		{{0.4859, 0.4755, 0.2195}, {1.023, 1.001, 0.462}, {0.6424, 0.6286, 0.2901}},
		{{0.256, 0.4441, 0.3971}, {0.539, 0.935, 0.836}, {0.3385, 0.5872, 0.525}},
		{{0.5068, 0.303, 0.4023}, {1.067, 0.638, 0.847}, {0.6701, 0.4007, 0.5319}},
		{{0.3448, 0.4337, 0.2403}, {0.726, 0.913, 0.506}, {0.4559, 0.5734, 0.3178}},
		{{0.4337, 0.2821, 0.4859}, {0.913, 0.594, 1.023}, {0.5734, 0.373, 0.6424}},
		-- The one when they're marked for clearning. Might use might not.
		{{0.74, 0.74, 0.74}, {1, 1 ,1}, {1, 1, 1}},
		-- The blocks that makeup the ghost piece show final drop position.
		{{0.5643, 0.5643, 0.5643}, {0.99, 0.99, 0.99}, {0.6633, 0.6633, 0.6633}},
		-- Dead blocks aka the ones that are added when selecting a level or something.
		{{0.2565, 0.2565, 0.2565}, {0.45, 0.45, 0.45}, {0.3015, 0.3015, 0.3015}}
	}
	local color = colors[block]
	local blockSize =18
	local blockDrawSize = 17
	x = x - 1
	y = y - 1
	local modifier = 1
	love.graphics.setColor(color[1])
	love.graphics.rectangle("fill", blockSize * x, blockSize * y, blockDrawSize, blockDrawSize)
	love.graphics.setColor(color[2])
	love.graphics.rectangle("fill", blockSize * x + 2, blockSize * y + 2, blockDrawSize -2, blockDrawSize -2)
	love.graphics.setColor(color[3])
	love.graphics.rectangle("fill", blockSize * x + 4, blockSize * y + 4, blockDrawSize - 6, blockDrawSize - 6)
end

function TitleState:render()
	local max_x = #self.title1[1]
	local x2 = 0
	local blockSize = 18
	local blockDrawSize = blockSize - 2

	for y=1, 7 do
		for x = 1, max_x do
			x2 = x+4
			if self.title1[y][x] ~= 0 then
				self:drawBlock(self.title1[y][x],x2,y)
			else
				love.graphics.setColor(0.0863,0.0863,0.0863)
				love.graphics.rectangle(
						'fill',
						(x2-1) * blockSize,
						(y-1) * blockSize,
						blockDrawSize,
						blockDrawSize
				)
			end
		end
	end
	max_x = #self.title2[1]
	for y=1, 7 do
		for x = 1, max_x do
			x2 = x+4
			if self.title2[y][x] ~= 0 then
				self:drawBlock(self.title2[y][x],x2,y+8)
			else
				love.graphics.setColor(0.0863,0.0863,0.0863)
				love.graphics.rectangle(
						'fill',
						(x2-1) * blockSize,
						(y+7) * blockSize,
						blockDrawSize,
						blockDrawSize
				)
			end
		end
	end
	for y=1,15 do
		if y == 8 then
			for x=1, 44 do
				love.graphics.setColor(0.0863,0.0863,0.0863)
				love.graphics.rectangle(
						'fill',
						(x-1) * blockSize,
						(y-1) * blockSize,
						blockDrawSize,
						blockDrawSize
				)
			end
		else
			for x=1, 4 do
				love.graphics.setColor(0.0863,0.0863,0.0863)
				love.graphics.rectangle(
						'fill',
						(x-1) * blockSize,
						(y-1) * blockSize,
						blockDrawSize,
						blockDrawSize
				)
				love.graphics.rectangle(
						'fill',
						(x+39) * blockSize,
						(y-1) * blockSize,
						blockDrawSize,
						blockDrawSize
				)
			end
		end



	end
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(self.titleFont)
	local enter_font = love.graphics.newFont(64)
	local width, height, flags = love.window.getMode()
	love.graphics.printf("By Macarthur Inbody",0, height/3+70,width,'center')
	love.graphics.setFont(enter_font)
	love.graphics.printf('PRESS ENTER',0, height/3+180,width,'center')
end

function TitleState:exit()

end