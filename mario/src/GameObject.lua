--[[
	GD50
	-- Super Mario Bros. Remake --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def)
	self.x = def.x
	self.y = def.y
	self.texture = def.texture
	self.width = def.width
	self.height = def.height
	self.frame = def.frame
	self.solid = def.solid
	self.collidable = def.collidable
	self.consumable = def.consumable
	self.onCollide = def.onCollide
	self.onConsume = def.onConsume
	self.hit = def.hit
end

function GameObject:collides(target)
	return not (target.x > self.x + self.width or self.x > target.x + target.width or
			target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)

end

function GameObject:render()
	--print_r(self)
	love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
end

FlagPoleObject = Class{__includes=GameObject}
function FlagPoleObject:init(params)
	self.collidable = true
	self.side_collide = true
	self.consumable = false
	self.onCollide = params.onCollide
	self.onConsume = params.onConsume
	self.hit = params.hit
	self.pole = params.pole
	self.solid = false
	self.height = self.pole.height
	self.flag = params.flag
	self.x = params.pole.x
	self.y = params.pole.y
end

function FlagPoleObject:update(dt)
	self.flag:update(dt)
end

function FlagPoleObject:collides(target)
	return not (target.x > self.pole.x + self.pole.width or self.pole.x > target.x + target.width or
			target.y > self.pole.y + self.pole.height or self.pole.y > target.y + target.height)
end

function FlagPoleObject:render()
	self.pole:render()
	self.flag:render()
end

PoleObject = Class{__includes=GameObject}
function PoleObject:init(def)
	self.x = def.x
	self.y = def.y
	self.atlas = def.atlas
	self.texture = def.texture
	self.width = def.width
	self.height = def.height
	self.frame = def.frame
	self.solid = def.solid
	self.collidable = def.collidable
	self.consumable = def.consumable
	self.onCollide = def.onCollide
	self.onConsume = def.onConsume
	self.hit = def.hit
end

function PoleObject:render()
	love.graphics.draw(gTextures[self.atlas], gFrames[self.texture][self.frame],self.x,self.y)
end

FlagObject = Class{__includes = PoleObject}

function FlagObject:init(def)
	self.x = def.x
	self.y = def.y
	self.y2 = def.y2
	self.atlas = def.atlas
	self.texture = def.texture
	self.width = def.width
	self.height = def.height
	self.frame = def.frame
	self.solid = def.solid
	self.collidable = def.collidable
	self.consumable = def.consumable
	self.onCollide = def.onCollide
	self.onConsume = def.onConsume
	self.hit = def.hit
	self.animation = Animation{
		frames = {def.frame,def.frame + 1},
		interval = 0.6
	}
	self.flag_animation = self.animation
end
function FlagObject:update(dt)
	self.flag_animation:update(dt)
end
function FlagObject:render()
	love.graphics.draw(gTextures[self.atlas], gFrames[self.texture][self.animation:getCurrentFrame()],self.x,self.y)
end