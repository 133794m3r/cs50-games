--[[
	GD50
	Super Mario Bros. Remake

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(player)
	self.player = player

	self.animation = Animation {
		frames = {1},
		interval = 1
	}

	self.player.currentAnimation = self.animation
end

function PlayerIdleState:update(dt)
	if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
		self.player:changeState('walking')
	end

	if love.keyboard.wasPressed('space') then
		self.player:changeState('jump')
	end

	-- check if we've collided with any entities and die if so
	for k, entity in pairs(self.player.level.entities) do
		if entity:collides(self.player) then
			self.player:lifeLost()
		end
	end
end