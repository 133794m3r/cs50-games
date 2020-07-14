--[[
	GD50
	Super Mario Bros. Remake

	-- WinState Class --
]]

WinState = Class{__includes = BaseState}

function WinState:enter(params)
	self.player = params.player
	self.cur_level = params.cur_level
	self.coins = params.coins
	self.lives = params.lives
	self.background = params.background
	self.level = LevelMaker.generate(100, 10)
	self.tileMap = params.level.tileMap
	local x = 0
	local y = 0
	x,y = self.player:findGround(self.player)
	self.player.x = x
	self.player.y = y
	self.player.StateDate = nil
	self.backgroundX = 0
end

function WinState:update(dt)
	--self.lives:update(dt)
	Timer.update(dt)
	if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('t') then
		print('cl',self.cur_level)
		gStateMachine:change('play',{
			player = self.player,
			cur_level = self.cur_level,
			coins = self.coins,
			lives = self.lives,
			level = self.level,
			tileMap = self.level.tileMap,
			player = self.player,
			lives = self.lives,
			new_level = true
		})
	end
end
function WinState:render()

	love.graphics.setFont(gFonts['large'])
	love.setColor(255, 255, 255, 255)
	-- render the current level they're on message text.
	love.graphics.printf("Level "..tostring(self.cur_level)..' Start', 0, 12,VIRTUAL_WIDTH,'center')
	--reset font size to medium.
	love.graphics.setFont(gFonts['medium'])
	-- render score
	love.graphics.printf('Score: '..tostring(self.player.score), 0, (VIRTUAL_HEIGHT/2)-15,VIRTUAL_WIDTH,'center')
	self.lives:render((VIRTUAL_WIDTH / 2) + 2,(VIRTUAL_HEIGHT / 2) + 10  )
	self.coins:render((VIRTUAL_WIDTH/2) - 1, (VIRTUAL_HEIGHT / 2) + 25 )
end