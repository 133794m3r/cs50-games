--[[
	GD50
	Super Mario Bros. Remake

	-- Snail Class --

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com
]]

Snail = Class{__includes = Entity}

function Snail:init(def)
	self.variety = def.variety
	Entity.init(self, def)
end

function Snail:render()
	love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
		math.floor(self.x) + 8, math.floor(self.y) + 8, 0, self.direction == 'left' and 1 or -1, 1, 8, 10)
end