--[[
	GD50
	Super Mario Bros. Remake

	-- StartState Class --

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

StartState = Class{__includes = BaseState}

function StartState:init()
	self.map = LevelMaker.generate(100, 10)
	local flag_chosen = 1+(math.random(0,2)*3)
	self.pole = PoleObject{
		texture = 'poles',
		atlas = 'flags',
		x = (2 - 1) * TILE_SIZE,
		y = 24,
		width = 16,
		height = 48,
		frame = POLES[math.random(6)],
		collidable = false,
		consumable = false,
		solid = false,
		hit = false,
		--when they hit it.
		onCollide = function(obj,player)
			gSounds['pickup']:play()
			if not obj.hit then
				print('collided')
			end
		end
	}
	self.flag = FlagObject{
		texture = 'flags',
		atlas = 'flags',
		x = ((2 -1 ) * TILE_SIZE) + 10,
		y = 21,
		width = 16,
		height = 14,
		frame = FLAGS[flag_chosen],
		collidable = false,
		consumable = false,
		solid = false,
		hit = false,

	}
	self.background = math.random(3)
end

function StartState:update(dt)
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		gStateMachine:change('play')
	end
	self.flag:update(dt)
end

function StartState:render()
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
	love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
		gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
	self.map:render()

	love.graphics.setFont(gFonts['title'])
	love.setColor(0, 0, 0, 255)
	love.graphics.printf('Super 50 Bros.', 1, VIRTUAL_HEIGHT / 2 - 40 + 1, VIRTUAL_WIDTH, 'center')
	love.setColor(255, 255, 255, 255)
	love.graphics.printf('Super 50 Bros.', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

	love.graphics.setFont(gFonts['medium'])
	love.setColor(0, 0, 0, 255)
	love.graphics.printf('Press Enter', 1, VIRTUAL_HEIGHT / 2 + 17, VIRTUAL_WIDTH, 'center')
	love.setColor(255, 255, 255, 255)
	love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
	self.flag:render()
	self.pole:render()
end