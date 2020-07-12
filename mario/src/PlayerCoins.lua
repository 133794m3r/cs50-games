--[[
	GD50
	Super Mario Bros. Remake

	Authors: Macarthur Inbody
	133794m3r@gmail.com

	-- Dependencies --

	A file to organize all of the global dependencies for our project, as
	well as the assets for our game, rather than pollute our main.lua file.
]]
PlayerCoins = Class{}

function PlayerCoins:init(player,atlas,texture)
	self.atlas = atlas
	self.texture = texture
	self.player = player
	self.animation = Animation {
		frames = {1,2,1,2,3},
		interval = 3
	}
	self.timer = 0
	self.max_timer = 1
	self.currentAnimation = self.animation
end

function PlayerCoins:update(dt)
	self.animation:update(dt)
end

function PlayerCoins:render()
	--love.graphics.draw(gTextures['green-alien'],gFrames['green-alien-heads'][1],55,3,0,1,1)
	love.graphics.setFont(gFonts['small'])
	love.setColor(0, 0, 0, 255)
	love.graphics.print(tostring(self.player.coins), 115, 5)
	love.setColor(255, 255, 255, 255)
	love.graphics.print(tostring(self.player.coins), 114, 4)

	--love.graphics.setFont(gFonts['medium'])
	love.setColor(0,0,0,255)
	love.graphics.print('x',110,5)
	love.setColor(255,255,255,255)
	love.graphics.print('x',109,4)
	love.graphics.draw(gTextures[self.atlas],
			gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
			100, 10, 0, self.direction == 1 and 1 or -1, 1, 8, 10)
end