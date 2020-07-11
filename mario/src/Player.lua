--[[
	GD50
	Super Mario Bros. Remake

	-- Player Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
	local x = 0
	local y = 0

	x,y = self:findGround(def)
	Entity.init(self, def)
	self.score = 0
	self.lives = def.lives == nil and 3 or def.lives
	self.coins = def.coins == nil and 1 or def.coins
	self.health = def.health == nil and 1 or def.health
	self.key = def.key == nil and false or def.key
end

function Player:findGround(def)
	local x = 0
	local y = 0
	local tileBottomLeft = def.map:pointToTile(x + 1, y + def.height)
	local tileBottomRight = def.map:pointToTile(x + def.width - 1, y + def.height)
	local breakit = false
	local objects = def.level.objects
	local object_position = {}
	for y=1,100 do
		object_position[y] = {}
		for x=1,100 do
			object_position[y][x] = false
		end
	end

	for _, object in pairs(objects) do
		if object.collidable then
			--					x = (x - 1) * TILE_SIZE,
			--					y = (blockHeight - 1) * TILE_SIZE,
			y = (object.y / TILE_SIZE) + 1
			x = (object.x / TILE_SIZE) + 1
			object_position[y][x] = true
		end
	end

	-- if we get a collision beneath us, go into either walking or idle
	if (not (tileBottomLeft and tileBottomRight) ) or (not (tileBottomLeft:collidable() or tileBottomRight:collidable()) ) or object_position[x][y] then
		--for y=1,100,TILE_SIZE do
		--for x=1,100,TILE_SIZE do
		for y=1,100,TILE_SIZE do
			for x=1,100,TILE_SIZE do
				tileBottomLeft = def.map:pointToTile(x + 1, y + def.height)
				tileBottomRight = def.map:pointToTile(x + def.width - 1, y + def.height)
				--tileBottomLeft = def.map.tiles[y][x]
				--tileBottomRight = def.map.tiles[y][x+1]
				if( (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) ) or ( object_position[x][y]) then
					if tileBottomRight:collidable() and not tileBottomLeft:collidable() then
						def['x'] = x + def.width
					elseif not tileBottomRight:collidable() and tileBottomLeft:collidable() then
						def['x'] = x + 1
					else
						def['x'] = x - 1
					end
					def['y'] = y
					breakit = true
					break
				end
			end
			if breakit then
				break
			end
		end

	end
	print('def',def['x'],def['y'])
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
				object.onCollide(object)
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