--[[
	GD50
	Super Mario Bros. Remake

	-- LevelMaker Class --

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
	local tiles = {}
	local entities = {}
	local objects = {}

	local prev_column = false
	local column_skip = 1
	local cur_empty = 0
	local max_empty = 4
	local cur_skip = column_skip
	local tileID = TILE_ID_GROUND

	-- whether we should draw our tiles with toppers
	local topper = true
	local tileset = math.random(20)
	local topperset = math.random(20)
	local key_spawned = false
	local locked_block_spawned = false
	local prev_block_height = 1
	local prev_pillar = 1
	local max_coin_run = 4
	local prev_block = false
	local prev_empty = 0
	local lock_x = 0
	local ground_x = {}
	local coin_x = {}
	-- so that I can make sure that I'm not respawning something over something that already exists.
	local object_position = {}
	for x=0,width do
		object_position[x] = false
		ground_x[x] = true
		coin_x[x] = false
	end

	-- insert blank tables into tiles for later access
	for x = 1, height do
		table.insert(tiles, {})
	end

	-- column by column generation instead of row; sometimes better for platformers
	for x = 1, width do
		local tileID = TILE_ID_EMPTY

		-- lay out the empty space
		for y = 1, 6 do
			table.insert(tiles[y],
				Tile(x, y, tileID, nil, tileset, topperset))
		end

		-- chance to just be emptiness
		if math.random(7) == 1 and cur_empty ~= max_empty then
			for y = 7, height do
				table.insert(tiles[y],
					Tile(x, y, tileID, nil, tileset, topperset))
			end
			cur_empty = cur_empty + 1
			ground_x[x] = false
		else
			prev_empty = cur_empty
			cur_empty = 0
			tileID = TILE_ID_GROUND

			local blockHeight = 4

			for y = 7, height do
				table.insert(tiles[y],
					Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
			end
			if math.random(8) == 1 and not prev_block then

				blockHeight = 2
				prev_column = true
				prev_block = false
				-- chance to generate bush on pillar
				if math.random(8) == 1 then
					table.insert(objects,
						GameObject {
							texture = 'bushes',
							x = (x - 1) * TILE_SIZE,
							y = 3 * TILE_SIZE,
							width = 16,
							height = 16,

							-- select random frame from bush_ids whitelist, then random row for variance
							frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
						}
					)
				end

				-- pillar tiles
				tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
				tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
				tiles[7][x].topper = nil

			-- chance to generate bushes
			elseif math.random(8) == 1 then
				table.insert(objects,
					GameObject {
						texture = 'bushes',
						x = (x - 1) * TILE_SIZE,
						y = (6 - 1) * TILE_SIZE,
						width = 16,
						height = 16,
						frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
						collidable = false
					}
				)
			elseif math.random(6) == 1 then
				coin_x[x-1] = true
				local variety = math.random()
				local frame = 1
				local value = 1
				local coin_y = math.random(1,5)

					if variety <= 0.1 then
						frame = 3
						value = 5
					elseif variety <= 0.3 then
						frame = 2
						value = 5
					else
						frame = 1
						value = 1
					end
					-- maintain reference so we can set it to nil
					local coin = GameObject {
						texture = 'coins_and_bombs',
						x = (x - 1) * TILE_SIZE,
						y = coin_y * TILE_SIZE,
						width = 16,
						height = 16,
						frame = frame,
						collidable = false,
						consumable = true,
						solid = false,
						-- coins call the addCoins method of the player object.
						onConsume = function(player, object)
							gSounds['pickup']:play()
							player.score = player.score + 25
							player:addCoins(object.value)
						end

					}
					coin.value = value
					table.insert(objects,coin)
			end
			-- chance to spawn a block
			if math.random(10) == 1 then
				object_position[x-1] = true
				prev_block = true
				table.insert(objects,

					-- jump block
					GameObject {
						texture = 'jump-blocks',
						x = (x - 1) * TILE_SIZE,
						y = (blockHeight - 1) * TILE_SIZE,
						width = 16,
						height = 16,

						-- make it a random variant
						frame = math.random(#JUMP_BLOCKS),
						collidable = true,
						hit = false,
						solid = true,

						-- collision function takes itself
						onCollide = function(obj)

							-- spawn a gem if we haven't already hit the block
							if not obj.hit then

								-- chance to spawn gem, not guaranteed
								if math.random(5) == 1 then

									-- maintain reference so we can set it to nil
									local gem = GameObject {
										texture = 'gems',
										x = (x - 1) * TILE_SIZE,
										y = (blockHeight - 1) * TILE_SIZE - 4,
										width = 16,
										height = 16,
										frame = math.random(#GEMS),
										collidable = true,
										consumable = true,
										solid = false,

										-- gem has its own function to add to the player's score
										onConsume = function(player, object)
											gSounds['pickup']:play()
											player.score = player.score + 100
										end
									}

									-- make the gem move up from the block and play a sound
									Timer.tween(0.1, {
										[gem] = {y = (blockHeight - 2) * TILE_SIZE}
									})
									gSounds['powerup-reveal']:play()

									table.insert(objects, gem)
								elseif math.random(3) == 1 then
									local variety = math.random()
									local frame = 1
									local value = 1
									if variety <= 0.1 then
										frame = 3
										value = 5
									elseif variety <= 0.4 then
										frame = 2
										value = 5
									else
										frame = 1
										value = 1
									end
									-- maintain reference so we can set it to nil
									local coin = GameObject {
										texture = 'coins_and_bombs',
										x = (x - 1) * TILE_SIZE,
										y = (blockHeight - 1) * TILE_SIZE - 4,
										width = 16,
										height = 16,
										frame = frame,
										collidable = false,
										consumable = true,
										solid = false,
										-- coins call the addCoins method of the player object.
										onConsume = function(player, object)
											gSounds['pickup']:play()
											player.score = player.score + 25
											player:addCoins(object.value)
										end

									}
									coin.value = value
									-- make the gem move up from the block and play a sound
									Timer.tween(0.1, {
										[coin] = {y = (blockHeight - 2) * TILE_SIZE}
									})
									gSounds['powerup-reveal']:play()

									table.insert(objects, coin)
								end

								obj.hit = true
							end

							gSounds['empty-block']:play()
						end
					}
				)

			end
		end
		::continue::
	end
	local x = width
	x = width
		local lock
		local lock_x = 0
		while not locked_block_spawned do
			x = math.random(width) - 1
			if (not object_position[x]) and (not object_position[x-1]) and (not object_position[x+1])
					and (ground_x[x-1] and ground_x[x] and ground_x[x+1])  and not coin_x[x] then
				lock_x = x
				lock = GameObject{
					texture = 'locks',
					x = x * TILE_SIZE,
					y = 1 * TILE_SIZE,
					width = 16,
					height = 16,
					frame = LOCKS[math.random(4)],
					collidable = true,
					consumable = true,
					solid = true,
					hit = false,
					onCollide = function(obj,player)
						if not obj.hit and player.key == true then
							gSounds['pickup']:play()
							LevelMaker.addFlagGoal(player)
							--obj.hit = true
							local direction = false
							print('l',love.keyboard.isDown('left'))
							print('r',love.keyboard.isDown('right'))
							if love.keyboard.isDown('left') then
								direction = 'left'
							elseif love.keyboard.isDown('right') then
								direction = 'right'
							end
							player.x,player.y = player:findGround(player,direction)
							player.key = nil
							player.stateData.pole_spawned = true
							return true
						end
					end,
					onConsume = function(ob)

					end
				}
				locked_block_spawned = true
			end
		end
		table.insert(objects,lock)
		local key = {}
		if x <= width /2 then
			width = width - x
		else
			width = width - 1
		end
	local y = 0
		while not key_spawned do
			y = math.random(2)
			x = math.random(width)
			if not object_position[x] and not(x >= lock_x -15 and x <= lock_x + 15 ) and not coin_x[x] then
				key = GameObject{
					texture = 'locks',
					x = x * TILE_SIZE,
					y = y * TILE_SIZE,
					width = 16,
					height = 16,
					frame = KEYS[math.random(4)],
					collidable = false,
					consumable = true,
					solid = false,
					-- gem has its own function to add to the player's score
					onConsume = function(player, object)
						gSounds['pickup']:play()
						print('player_key',object.frame)
						player.stateData.key_color = object.frame
						player.key = true
					end
				}
				key_spawned = true
			end
		end
		table.insert(objects, key)
	local map = TileMap(width, height)
	map.tiles = tiles
	return GameLevel(entities, objects, map)
end

function LevelMaker.addFlagGoal(player)
	local level = player.level
	local height = level.tileMap.height
	local width = level.tileMap.width
	local tiles = level.tileMap.tiles
	local objects = level.objects
	local object_position = {}
	local player_x = player.x / TILE_SIZE
	local x = 0
	local y = 0
	local blockHeight = 4
	local pole
	local flag
	for y=1,height do
		object_position[y] = {}
		for x=1,width do
			object_position[y][x] = false
		end
	end

	for _, object in pairs(objects) do
		if object.collidable then
			y = math.floor(object.y / TILE_SIZE)+1
			x = math.floor(object.x / TILE_SIZE)+1
			object_position[y][x] = true
		end
	end
	local free = false
	x=1
	y=1
	local x2 = 1
	local y2 = 1
	local y3= 1
	local flag_grounds = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 30,
		[5] = 16,
		[6] = 40,
		[7] = 48
	}
	while free == false do
	x = math.random(width)
		if x <= player_x+5 and x>= player_x-5 then
			goto continue
		end
		free = false
		for y=2,10 do
			if tiles[y][x]:collidable() and free == false then
				y2 = flag_grounds[y]
				y3 = y
				free = true
			elseif object_position[y][x] then
				free = false
				break
			end
		end
		if free then
			x2 = x
			break
		end
		::continue::
	end
	local flag_chosen = 1+(math.random(0,2)*3)
	local pole = PoleObject{
		texture = 'poles',
		atlas = 'flags',
		x = (x2 - 1) * TILE_SIZE,
		y = y2,
		width = 16,
		height = 48,
		frame = POLES[math.random(6)],
		collidable = true,
		consumable = false,
		solid = false,
		hit = false,
		--when they hit it.
		onCollide = function(obj, player)
			gSounds['pickup']:play()
			if not obj.hit then
				print('collided')
			end
		end
	}

	local flag = FlagObject {
		texture = 'flags',
		atlas = 'flags',
		x = ((x2 - 1) * TILE_SIZE) + 10,
		y = y2 + 5,
		y2 = y2 + 34,
		width = 16,
		height = 14,
		frame = FLAGS[flag_chosen],
		collidable = false,
		consumable = false,
		solid = true,
		hit = false,
		--when they hit it.
		onCollide = function (obj,player)
			if not obj.hit then
				player.stateData.can_input = false
				local frame
				obj.hit = true
				frame = obj.animation.frames[2] + 1
				obj.animation = Animation{
				frames = {frame},
				interval = 300
				}
				Timer.tween(1,{
				[obj] = {y = obj.y2}
				}):finish(function()
						player.stateData.cur_level = player.stateData.cur_level + 1
						player.stateData.new_level = false
						gStateMachine:change('win',player.stateData)
					end)
				end
			end
		}

		local flagPole = FlagPoleObject{
			flag = flag,
			pole = pole,
			onCollide = function(obj,player)
				obj.hit = true
				obj.flag.onCollide(obj.flag,player)
			end
		}
	table.insert(level.objects,flagPole)
end