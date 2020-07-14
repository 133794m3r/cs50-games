--[[
	GD50
	Super Mario Bros. Remake

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com

	A classic platformer in the style of Super Mario Bros., using a free
	art pack. Super Mario Bros. was instrumental in the resurgence of video
	games in the mid-80s, following the infamous crash shortly after the
	Atari age of the late 70s. The goal is to navigate various levels from
	a side perspective, where jumping onto enemies inflicts damage and
	jumping up into blocks typically breaks them or reveals a powerup.

	Art pack:
	https://opengameart.org/content/kenney-16x16

	Music:
	https://freesound.org/people/Sirkoto51/sounds/393818/
]]

require 'src/Dependencies'

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setFont(gFonts['medium'])
	love.window.setTitle('Super 50 Bros.')

	math.randomseed(os.time())

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		vsync = true,
		resizable = true
	})

	gStateMachine = StateMachine {
		['start'] = function() return StartState() end,
		['play'] = function() return PlayState() end,
		['death'] = function() return DeathState() end,
		['win'] = function() return WinState() end
	}
	gStateMachine:change('start')

	gSounds['music']:setLooping(true)
	gSounds['music']:setVolume(0.5)
	gSounds['music']:play()

	love.keyboard.keysPressed = {}
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end

	love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end
MIN_FRAME = 1/60
CUR_TIME = 0
NEXT_TIME = love.timer.getTime()
function love.update(dt)
	NEXT_TIME = NEXT_TIME + MIN_FRAME
	gStateMachine:update(dt)

	love.keyboard.keysPressed = {}
end

function love.draw()
	-- uncomment to set FPS to 60.
	--local cur_time = love.timer.getTime()
	--if NEXT_TIME <= cur_time then
	--	NEXT_TIME = cur_time
	--	return
	--end
	--love.timer.sleep(NEXT_TIME - cur_time)
	push:start()
	gStateMachine:render()
	--fps_counter()
	push:finish()
end
function fps_counter()
	love.graphics.setFont(gFonts['small'])
	love.graphics.setColor(0,255,0,255)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),10,10)
end