--[[
	GD50
	Super Mario Bros. Remake

	-- Player Class --

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com
]]

Player = Class{__includes = Entity}

function Player:init(def)
	local x = 0
	local y = 0
	if def.map then
		x,y = self:findGround(def)
	end
	Entity.init(self, def)
	self.score = 0
	self.lives = def.lives == nil and 2 or def.lives
	self.coins = def.coins == nil and 1 or def.coins
	self.health = def.health == nil and 1 or def.health
	self.key = def.key == nil and false or def.key
end

function Player:findGround(def,direction)
	local x = def['x']
	local y = def['y']
	local tileBottomLeft = def.map:pointToTile(x + 1, y + def.height)
	local tileBottomRight = def.map:pointToTile(x + def.width - 1, y + def.height)
	local breakit = false
	local objects = def.level.objects
	local object_position = {}
	local true_position = {}
	local start_x=0
	local end_x = 1600
	local start_y=0
	local end_y=160
	local increment = TILE_SIZE
	printf('direction:%s\n',direction)
	if direction == nil then
		start_x = 0
		end_x = 1600
		increment = TILE_SIZE
	elseif direction == 'left' then
		start_x = x
		end_x = 0
		increment = -TILE_SIZE
	elseif direction == 'right' then
		start_x = x
		end_x = 1600
		increment = TILE_SIZE
	else
		start_x = x
		end_x = 1600
		increment = TILE_SIZE
	end

	for y=0,160,TILE_SIZE do
		object_position[y] = {}
		true_position[y] = {}
		for x=0,1600,TILE_SIZE do
			object_position[y][x] = false
			true_position[y][x] = {}
		end
	end
	for _, object in pairs(objects) do
		if object.solid then
			y = object.y
			x = object.x
			object_position[y][x] = true
			true_position[y][x] = {object.y,object.x}
		end
	end

	local y2 = 0

	-- if there is nothing below them, then we need to go across the map trying to find something. We need to iterate
	-- across the whole map to find a piece of solid ground. once we find it, we set the player's coordinates to be
	-- just above it.

	if (not (tileBottomLeft and tileBottomRight) ) or (not (tileBottomLeft:collidable() or tileBottomRight:collidable()) ) or (not object_position[0][0]) then
		-- We start with the y coordinate since it is more cache friendly to iterate over this table all the way through
		-- rather than going down the map.
		for x=start_x,end_x,increment do
			-- Then we iterate across the entire X axis.
			for y=start_y,end_y,increment do
				y2 = y
				tileBottomLeft = def.map:pointToTile(x + 1, y + def.height)
				tileBottomRight = def.map:pointToTile(x + def.width - 1, y + def.height)
				if( (tileBottomLeft or tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) ) or ( object_position[y][x]) then
					if tileBottomRight:collidable() and not tileBottomLeft:collidable() then
						def['x'] = x + TILE_SIZE /2
						print('l')
					elseif not tileBottomRight:collidable() and tileBottomLeft:collidable() then
						print('r')
						def['x'] = x - TILE_SIZE /2
					elseif object_position[y][x] then
						print('obj')
						def['x'] = true_position[y][x][2]
						y2 = true_position[y][x][1] - TILE_SIZE
					else
						def['x'] = x
						print('l&r')
						y2 = y
					end
					def['y'] = y2 - TILE_SIZE /4
					breakit = true
					break
				end
			end
			if breakit then
				break
			end
		end
	end
	print('x,y,y2',def['x'],def['y'],y)
	return def['x'],def['y']
end
function Player:update(dt)
	Entity.update(self, dt)
end

function Player:render()
	Entity.render(self)
end

function Player:checkLeftCollisions(dt)
	-- check for left two tiles collision
	local tileTopLeft = self.map:pointToTile(self.x + 1, self.y + 1)
	local tileBottomLeft = self.map:pointToTile(self.x + 1, self.y + self.height - 1)

	-- place player outside the X bounds on one of the tiles to reset any overlap
	if (tileTopLeft and tileBottomLeft) and (tileTopLeft:collidable() or tileBottomLeft:collidable()) then
		self.x = (tileTopLeft.x - 1) * TILE_SIZE + tileTopLeft.width - 1
	else

		self.y = self.y - 1
		local collidedObjects = self:checkObjectCollisions()
		self.y = self.y + 1

		-- reset X if new collided object
		if #collidedObjects > 0 then
			self.x = self.x + PLAYER_WALK_SPEED * dt
		end
	end
end

function Player:checkRightCollisions(dt)
	-- check for right two tiles collision
	local tileTopRight = self.map:pointToTile(self.x + self.width - 1, self.y + 1)
	local tileBottomRight = self.map:pointToTile(self.x + self.width - 1, self.y + self.height - 1)

	-- place player outside the X bounds on one of the tiles to reset any overlap
	if (tileTopRight and tileBottomRight) and (tileTopRight:collidable() or tileBottomRight:collidable()) then
		self.x = (tileTopRight.x - 1) * TILE_SIZE - self.width
	else

		self.y = self.y - 1
		local collidedObjects = self:checkObjectCollisions()
		self.y = self.y + 1

		-- reset X if new collided object
		if #collidedObjects > 0 then
			self.x = self.x - PLAYER_WALK_SPEED * dt
		end
	end
end

function Player:checkObjectCollisions()
	local collidedObjects = {}

	for k, object in pairs(self.level.objects) do
		if object:collides(self) then
			if object.solid then
				table.insert(collidedObjects, object)
			elseif object.consumable then
				object.onConsume(self,object)
				table.remove(self.level.objects, k)
			elseif object.side_collide then
				object.onCollide(object,self)
			end
		end
	end

	return collidedObjects
end

function Player:addCoins(coins)
	self.coins = self.coins + coins
	if self.coins >= 100 then
		self.lives = self.lives + 1
		self.coins = self.coins - 100
	end
end

function Player:lifeLost()
	self.lives = self.lives - 1
	gSounds['death']:play()
	if self.lives <= 0 then
		gStateMachine:change('start')
	else
		gStateMachine:change('death',self.stateData)
	end
end
function Player:die()
	self:lifeLost()

end