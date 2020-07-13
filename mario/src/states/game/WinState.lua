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
	print('background',self.background)
	for i=1,9 do
		print(i)
		print_r(gFrames['backgrounds2'][i])
	end
end

function WinState:update(dt)
	self.lives:update(dt)
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
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX), 0)
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX),
			gTextures['backgrounds2']:getHeight() / 9 * 2, 0, 1, -1)
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX + 256), 0)
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX + 256),
			gTextures['backgrounds2']:getHeight() / 9 * 2, 0, 1, -1)

	love.graphics.setFont(gFonts['medium'])
	love.setColor(0, 0, 0, 255)
	love.graphics.print("Level "..tostring(self.cur_level)..' Start', 35, 25)
	love.setColor(255, 255, 255, 255)
	love.graphics.print("Level "..tostring(self.cur_level)..' Start', 34, 24)

end