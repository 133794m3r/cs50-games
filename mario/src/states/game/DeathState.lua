--[[
	GD50
	Super Mario Bros. Remake

	-- DeathState Class --
]]

DeathState = Class{__includes = BaseState}

function DeathState:enter(params)
	self.player = params.player
	self.cur_level = params.cur_level
	self.coins = params.coins
	self.lives = params.lives
	self.level = params.level
	self.tileMap = params.level.tileMap
	self.has_lock = params.has_lock
	self.pole_spawned = params.pole_spawned
	self.key_color = params.key_color
	self.player.key = params.player.key
	local x = 0
	local y = 0
	x,y = self.player:findGround(self.player)
	self.player.x = x
	self.player.y = y
	self.background = params.background
end
function DeathState:update(dt)
	Timer.update(dt)
	self.lives:update(dt)
	self.coins:update(dt)
	if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('t') then
		gStateMachine:change('play',{
			player = self.player,
			cur_level = self.cur_level,
			coins = self.coins,
			lives = self.lives,
			level = self.level,
			tileMap = self.level.tileMap,
			has_lock = self.has_lock,
			pole_spawned = self.pole_spawned,
			player = self.player,
			lives = self.lives,
			background = self.background,
			key_color = self.key_color
		})
	end
end
function DeathState:render()
	love.graphics.setFont(gFonts['medium'])
	love.setColor(0, 0, 0, 255)
	love.graphics.print("Level: ", 35, 25)
	love.setColor(255, 255, 255, 255)
	love.graphics.print("Level: ", 34, 24)

	love.setColor(0,0,0,255)
	love.graphics.print(tostring(self.level),85,25)
	love.setColor(255, 255, 255, 255)
	love.graphics.print(tostring(self.cur_level),84,24)
	self.lives:render(VIRTUAL_WIDTH / 2 + 2,VIRTUAL_HEIGHT / 2 + 2)
end
