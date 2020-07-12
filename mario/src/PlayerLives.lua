--[[
	GD50
	Super Mario Bros. Remake

	Authors: Macarthur Inbody
	133794m3r@gmail.com

	-- Player Lives --
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
	self.timer = 2
	self.cur_time = 0
	self.currentAnimation = self.animation
end

function PlayerLives:update(dt)
	self.animation:update(dt)
	self.cur_time = self.cur_time + dt
	if self.cur_time >= self.timer then
		self.direction = math.random(2)
		self.cur_time = 0
	end
end

function PlayerLives:render(x,y)
	x = x == nil and 85 or x
	y = y == nil and 5 or y
	--love.graphics.draw(gTextures['green-alien'],gFrames['green-alien-heads'][1],55,3,0,1,1)
	love.graphics.setFont(gFonts['small'])
	love.setColor(0, 0, 0, 255)
	love.graphics.print(tostring(self.player.lives), x, y-1)
	love.setColor(255, 255, 255, 255)
	love.graphics.print(tostring(self.player.lives), x, y)

	--love.graphics.setFont(gFonts['medium'])
	love.setColor(0,0,0,255)
	love.graphics.print('x',x-9,y-1)
	love.setColor(255,255,255,255)
	love.graphics.print('x',x-10,y)
	love.graphics.draw(gTextures[self.atlas],
			gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
			x - 20, y + 5, 0, self.direction == 1 and 1 or -1, 1, 8, 10)
end
