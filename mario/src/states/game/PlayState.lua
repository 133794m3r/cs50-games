--[[
	GD50
	Super Mario Bros. Remake

	-- PlayState Class --
	Author: Macarthur Inbody
	133794m3r@gmail.com
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
	self.camX = 0
	self.camY = 0
	self.cur_level = 1
	self.level = LevelMaker.generate(70 + (self.cur_level * 5), 10)
	self.tileMap = self.level.tileMap
	self.background = math.random(6)
	self.backgroundX = 0
	self.has_lock = true
	self.gravityOn = true
	self.gravityAmount = 6
	self.text_y = -100
	self.pole_spawned = false
	self.can_input = true
	self.new_level = false
	self.player= Player({
		x = 0, y = 0,
		width = 16, height = 20,
		texture = 'green-alien',
		stateMachine = StateMachine {
			['idle'] = function() return PlayerIdleState(self.player) end,
			['walking'] = function() return PlayerWalkingState(self.player) end,
			['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
			['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
		},
		map = self.tileMap,
		level = self.level,
		key = true
	})
	self.lives = PlayerLives(self.player,'green-alien','green-alien-heads')
	self.coins = PlayerCoins(self.player,'coins_and_bombs','coins_and_bombs')
	self.key_color = 1
	self.player.stateData = self
	self.player:changeState('falling')
end

function PlayState:enter(params)
	if params ~= nil then
		if params.new_level then
			self.player = params.player
			self.coins = params.coins
			self.lives = params.lives
			self.level = params.level
			self.tileMap = self.level.tileMap
			self:spawnEnemies()
			self.player.map = self.tileMap
			self.player.level = self.level
			local x,y = self.player:findGround(self.player)
			self.player.x = x
			self.player.y = y
			self.player.stateData = self
			self.cur_level = params.cur_level

		else
			self.player = params.player
			self.cur_level = params.cur_level
			self.coins = params.coins
			self.lives = params.lives
			self.level = params.level
			self.tileMap = params.level.tileMap
			self.has_lock = params.has_lock
			self.pole_spawned = params.pole_spawned
			self.player = params.player
			self.lives = params.lives
			self.coins = params.coins
			self.background = params.background
		end
		self.key_color = params.key_color
		self.player.stateData = self
	else
		self:spawnEnemies()
	end
end
function PlayState:update(dt)
	if self.player.key == nil then
		self.player.key = false
		self.can_input = false
		Timer.tween(1.5,{
				[self] = {text_y = VIRTUAL_HEIGHT / 2 - 8}
		}):finish(function()
			Timer.after(2,function()
				Timer.tween(1.5,{
					[self] = {text_y = VIRTUAL_HEIGHT + 30}
				})
					:finish(function()
						self.can_input = true
					end)
				end)
		end)
	end
	Timer.update(dt)

	-- remove any nils from pickups, etc.
	self.level:clear()
	if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
		printf("Player x:%d y:%d\n",self.player.x,self.player.y)
		if self.can_input or self.paused then
			self.paused = not self.paused
			self.can_input = not self.can_input
		end
	end

	-- update player and level
	if self.can_input == true then
		self.player:update(dt)
		self.level:update(dt)
	end

	-- constrain player X no matter which state
	if self.player.x <= 0 then
		self.player.x = 0
	elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
		self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
	end
	self.lives:update(dt)
	self:updateCamera()
	self.coins:update(dt)
end

function PlayState:render()
	love.graphics.push()
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX), 0)
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX),
		gTextures['backgrounds2']:getHeight() / 9 * 2, 0, 1, -1)
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX + 256), 0)
	love.graphics.draw(gTextures['backgrounds2'], gFrames['backgrounds2'][self.background], math.floor(-self.backgroundX + 256),
		gTextures['backgrounds2']:getHeight() / 9 * 2, 0, 1, -1)

	-- translate the entire view of the scene to emulate a camera
	love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))

	self.level:render()

	self.player:render()
	love.graphics.pop()

	-- render score
	love.graphics.setFont(gFonts['medium'])
	love.setColor(0, 0, 0, 255)
	love.graphics.print(tostring(self.player.score), 5, 5)
	love.setColor(255, 255, 255, 255)
	love.graphics.print(tostring(self.player.score), 4, 4)

	-- render lives
	self.lives:render()

	-- render their coins
	self.coins:render()
	-- the "a flag pole has spawned message"
	love.setColor(95, 205, 228, 200)
	love.graphics.rectangle('fill', 0, self.text_y - 8, VIRTUAL_WIDTH, 36)
	love.setColor(255, 255, 255, 255)
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf('GET TO THE FLAG POLE!', 0, self.text_y, VIRTUAL_WIDTH, 'center')

	-- the paused text screen.
	if self.paused then
		love.setColor(95, 205, 228, 200)
		love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT / 2-20, VIRTUAL_WIDTH, 48)
		love.setColor(255, 255, 255, 255)
		love.graphics.setFont(gFonts['large'])
		love.graphics.printf('Game Paused', 0, VIRTUAL_HEIGHT / 2 -12 , VIRTUAL_WIDTH, 'center')

	end
	if self.player.key then
		love.graphics.draw(gTextures['locks'],gFrames['locks'][self.key_color],150,0)
	end
end

function PlayState:updateCamera()
	-- clamp movement of the camera's X between 0 and the map bounds - virtual width,
	-- setting it half the screen to the left of the player so they are in the center
	self.camX = math.max(0,
		math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
		self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

	-- adjust background X to move a third the rate of the camera for parallax
	self.backgroundX = (self.camX / 3) % 256
end

--[[
	Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
	local enemyChance = math.ceil( 20 - self.cur_level/2)
	local player_x = self.player.x / 16
	local player_x2 = player_x + 2
	player_x = player_x - 2
	-- spawn snails in the level
	for x = 1, self.tileMap.width do
		if (x <= player_x2 and x >= player_x) then
			goto next
		end
		groundFound = true
		-- flag for whether there's ground on this column of the level
		local groundFound = false
		for y = 1, self.tileMap.height do
			if not groundFound then
				if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
					-- If we are near the player we won't let this continue on anymore.
					-- random chance, 1 in ceil(20 - cur_level /2). So basically every 2 levels the range goes down by 1.
					groundFound = true
					if math.random(enemyChance ) == 1 then
						-- instantiate snail, declaring in advance so we can pass it into state machine
						local snail
						snail = Snail {
							texture = 'creatures',
							x = (x - 1) * TILE_SIZE,
							y = (y - 2) * TILE_SIZE + 2,
							width = 16,
							height = 16,
							stateMachine = StateMachine {
								['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
								['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
								['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
							},
							variety = math.random(2)
						}
						snail:changeState('idle', {
							wait = math.random(5)
						})

						table.insert(self.level.entities, snail)
					end
				end
			end
		end
		::next::
	end
end