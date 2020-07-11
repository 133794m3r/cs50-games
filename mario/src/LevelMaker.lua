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
	local prev_block = 0
	-- so that I can make sure that I'm not respawning something over something that already exists.
	local object_position = {}
	for y=1,10 do
		object_position[y] = {}
		for x=1,100 do
			object_position[y][x] = false
		end
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
		else
			cur_empty = 0
			tileID = TILE_ID_GROUND

			local blockHeight = 4

			for y = 7, height do
				table.insert(tiles[y],
					Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
			end
			--if prev_column and cur_skip ~= 0 then
			--	cur_skip = cur_skip - 1
			--	prev_column = false
			--	goto continue
			--elseif prev_column then
			--	cur_skip = column_skip
			--	prev_column = false
			--	goto continue
			--else
			--	prev_column = false
			--end
			-- chance to generate a pillar
			if math.random(8) == 1 and not prev_block  then
				blockHeight = 2
				prev_column = true
				prev_pillar = x
				-- chance to generate bush on pillar
				if math.random(8) == 1 then
					table.insert(objects,
						GameObject {
							texture = 'bushes',
							x = (x - 1) * TILE_SIZE,
							y = (4 - 1) * TILE_SIZE,
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
				local num_coins = math.random(3)
				local variety = math.random()
				local frame = 1
				local value = 1
				local coin_y = math.random(1,5)

				for i=1,num_coins do
					if variety <= 0.1 then
						value = 10
						frame = 3
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
						collidable = true,
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
			end

			-- chance to spawn a block
			if math.random(10) == 1 then
				prev_block = prev_block + 1
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
										value = 10
										frame = 3
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
										collidable = true,
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

			elseif math.random(30) == 1 and key_spawned == false then
				-- the key.
				key_spawned = true
				local key =	GameObject{
					texture = 'locks',
					x = (x - 1) * TILE_SIZE,
					y = (blockHeight - 1) * TILE_SIZE,
					width = 16,
					height = 16,
					frame = KEYS[math.random(4)],
					collidable = true,
					consumable = true,
					solid = false,
					-- gem has its own function to add to the player's score
					onConsume = function(player, object)
						gSounds['pickup']:play()
						player.key = true
					end
				}
				table.insert(objects,
						key
				)
			elseif math.random(30) == 1 and locked_block_spawned == false then
				locked_block_spawned = true

			-- make it a random variant
				local lock = GameObject{
					texture = 'locks',
					x = (x - 1) * TILE_SIZE,
					y = (2 - 1) * TILE_SIZE,
					width = 16,
					height = 16,
					frame = LOCKS[math.random(4)],
					collidable = true,
					consumable = false,
					solid = true,
					hit = false,
					onCollide = function(obj,player)
						if not obj.hit and player.key == true then
							gSounds['pickup']:play()
							LevelMaker.addFlagGoal(player.level)
							obj.hit = true
							obj.solid = false
							obj.consumable = true
							obj.collidable = false
							player.key = nil
						end
					end,
					onConsume = function(ob)

					end
				}
				print('lock x,y',x,y)
				-- the locked block object has to have special properties.
				table.insert(objects,
				lock
				)
				prev_column = true
			end
		end
		::continue::
	end

	local map = TileMap(width, height)
	map.tiles = tiles
	--local lock = GameObject{
	--	texture = 'locks',
	--	x = (1 - 1) * TILE_SIZE,
	--	y = (2 - 1) * TILE_SIZE,
	--	width = 16,
	--	height = 16,
	--	frame = LOCKS[math.random(4)],
	--	collidable = true,
	--	consumable = true,
	--	solid = true,
	--	hit = false,
	--	-- gem has its own function to add to the player's score
	--	onCollide = function(obj,player)
	--		gSounds['pickup']:play()
	--		if not obj.hit then
	--			LevelMaker.addFlagGoal(player.level)
	--		end
	--	end
	--}
	--table.insert(objects,lock)
	return GameLevel(entities, objects, map)
end

function LevelMaker.addFlagGoal(level)
	local height = level.tileMap.height
	local width = level.tileMap.width
	local tiles = level.tileMap.tiles
	local objects = level.objects
	local object_position = {}
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
	flag_grounds = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
		[4] = 30,
		[5] = 16,
		[6] = 40,
		[7] = 48
	}
	while free == false do
	x = math.random(100)
	---for x=1,100 do
		free = false
		for y=2,10 do
			if tiles[y][x]:collidable() and free == false then
				--y2 = (y - 1) * 8
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
	end
	local flag_chosen = 1+(math.random(0,2)*3)
	local pole = PoleObject{
	--table.insert(level.objects,PoleObject {
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
	--})

	local flag = FlagObject {
		--table.insert(level.objects,FlagObject{
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
		onCollide = function (obj)
			Timer.tween(1,{
			[obj] = {y = obj.y2}
			})

			end
		}
		--})

		local flagPole = FlagPoleObject{
			flag = flag,
			pole = pole,
			onCollide = function(obj)
				obj.hit = true
				obj.flag.onCollide(obj.flag)
			end
		}

	table.insert(level.objects,flagPole)
end