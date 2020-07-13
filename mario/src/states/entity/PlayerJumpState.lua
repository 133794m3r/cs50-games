--[[
	GD50
	Super Mario Bros. Remake

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com
]]

PlayerJumpState = Class{__includes = BaseState}

function PlayerJumpState:init(player, gravity)
	self.player = player
	self.gravity = gravity
	self.cur_time = 0
	self.frame = 1/60
	self.animation = Animation {
		frames = {3},
		interval = 1
	}
	self.player.currentAnimation = self.animation
end

function PlayerJumpState:enter(params)
	gSounds['jump']:play()
	self.player.dy = PLAYER_JUMP_VELOCITY
end

function PlayerJumpState:update(dt)
	self.player.currentAnimation:update(dt)
	self.cur_time = self.cur_time + dt
	--[[ Due to the fact that Colton never though to think about his gravity systems(again) outside of 60fps and tied
		it to frame rate. To make it play the same even at higher frame-rates we have to modify the code to either a)
		Limit the FPS to a maximum of 60. or b) make it so that the gravity system only gets triggered every 1/60th of
		a second. So that it plays as it did for him.
	]]
	if self.cur_time >= self.frame then
		self.player.dy = self.player.dy + self.gravity + 0.44
		self.cur_time = 0
		self.player.y = self.player.y + (self.player.dy * self.frame)
	end
	--self.player.y = self.player.y + (self.player.dy * dt)
	-- go into the falling state when y velocity is positive
	if self.player.dy >= 0 then
		self.player:changeState('falling')
	end

	self.player.y = self.player.y + (self.player.dy * dt)

	-- look at two tiles above our head and check for collisions; 3 pixels of leeway for getting through gaps
	local tileLeft = self.player.map:pointToTile(self.player.x + 3, self.player.y)
	local tileRight = self.player.map:pointToTile(self.player.x + self.player.width - 3, self.player.y)

	-- if we get a collision up top, go into the falling state immediately
	if (tileLeft and tileRight) and (tileLeft:collidable() or tileRight:collidable()) then
		self.player.dy = 0
		self.player:changeState('falling')

	-- else test our sides for blocks
	elseif love.keyboard.isDown('left') then
		self.player.direction = 'left'
		self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
		self.player:checkLeftCollisions(dt)
	elseif love.keyboard.isDown('right') then
		self.player.direction = 'right'
		self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
		self.player:checkRightCollisions(dt)
	end

	-- check if we've collided with any collidable game objects
	for k, object in pairs(self.player.level.objects) do
		if object:collides(self.player) then
			if object.solid then
				object.onCollide(object,self.player)
				self.player.y = object.y + object.height
				self.player.dy = 0
				self.player:changeState('falling')
			elseif object.consumable then
				object.onConsume(self.player,object)
				table.remove(self.player.level.objects, k)
			elseif object.collidable then
				object:onCollide(object,self.player)
			end
		end
	end

	-- check if we've collided with any entities and die if so
	for k, entity in pairs(self.player.level.entities) do
		if entity:collides(self.player) then
			self.player:lifeLost()
		end
	end
end