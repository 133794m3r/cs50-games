--[[
	GD50
	Super Mario Bros. Remake

	Authors: Macarthur Inbody
	133794m3r@gmail.com

	-- PlayerLives Class --
	This class shows the current lives that the player has. It also has a simple animation that is shown.
	This animation is similar to that of Wolf3d or DOOM in that it shows the character's head and some random  movements
	so that it looks to be "alive".
]]
PlayerLives = Class{}

function PlayerLives:init(player,atlas,texture)
	self.atlas = atlas
	self.texture = texture
	self.player = player
	self.direction = math.random(2)
	self.animation = Animation {
		frames = {1,2,3},
		interval = 1
	}
	self.timer = 3
	self.cur_time = 0
	self.currentAnimation = self.animation
end

function PlayerLives:update(dt)
	self.animation:update(dt)
	self.cur_time = self.cur_time + dt
	if self.cur_time >= self.timer then
		if math.random(2) == 1 then
			self.direction = self.direction == 1 and 2 or 1
		end
		self.cur_time = 0
	end
end

function PlayerLives:render(x,y)
	x = x == nil and 80 or x
	y = y == nil and 6 or y
	love.graphics.setFont(gFonts['small'])
	love.setColor(0, 0, 0, 255)
	love.graphics.print(tostring(self.player.lives), x-2, y)
	love.setColor(255, 255, 255, 255)
	love.graphics.print(tostring(self.player.lives), x-3, y-1)

	love.setColor(0,0,0,255)
	love.graphics.print('x',x-7,y)
	love.setColor(255,255,255,255)
	love.graphics.print('x',x-8,y-1)
	love.setColor(0,0,0,255)
	love.graphics.draw(gTextures[self.atlas],
			gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
			x - 19, y + 5, 0, self.direction == 1 and 1 or -1, 1, 8, 10)
	love.setColor(255,255,255,255)
	love.graphics.draw(gTextures[self.atlas],
			gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
			x - 20, y + 4, 0, self.direction == 1 and 1 or -1, 1, 8, 10)
end
