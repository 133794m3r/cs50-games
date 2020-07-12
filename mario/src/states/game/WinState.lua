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
	self.level = LevelMaker.generate(100, 10)
	self.tileMap = params.level.tileMap
	local x = 0
	local y = 0
	x,y = self.player:findGround(self.player)
	self.player.x = x
	self.player.y = y
	self.player.StateDate = nil

end

function WinState:update(dt)
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