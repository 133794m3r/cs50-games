--[[
	GD50
	Super Mario Bros. Remake

	-- SnailIdleState Class --

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com
]]

SnailIdleState = Class{__includes = BaseState}

function SnailIdleState:init(tilemap, player, snail)
	self.tilemap = tilemap
	self.player = player
	self.snail = snail
	self.waitTimer = 0
	local frame = snail.variety == 1 and 51 or 55
	self.animation = Animation {
		frames = {51},
		interval = 1
	}
	self.snail.currentAnimation = self.animation
end

function SnailIdleState:enter(params)
	self.waitPeriod = params.wait
end

function SnailIdleState:update(dt)
	if self.waitTimer < self.waitPeriod then
		self.waitTimer = self.waitTimer + dt
	else
		self.snail:changeState('moving')
	end

	-- calculate difference between snail and player on X axis
	-- and only chase if <= 5 tiles
	local diffX = math.abs(self.player.x - self.snail.x)

	if diffX < 5 * TILE_SIZE then
		self.snail:changeState('chasing')
	end
end