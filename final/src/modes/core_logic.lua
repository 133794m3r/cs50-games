--[[
	The base game class. This state is what all other game modes inherit
	from and implements all of the game features.

    Copyright (C) 2020  Macarthur David Inbody <admin-contact@transcendental.us>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

BaseGame = Class{ __includes=BaseState}

function BaseGame:init(params)
	BaseState.init(self,params or {})
	params = params or {}
	self.pieceStructures = {
		{
			--I block
			{
				{0, 0, 0, 0},
				{0, 0, 0, 0},
				{1, 1, 1, 1},
				{0, 0, 0, 0},
			},
			{
				{0, 1, 0, 0},
				{0, 1, 0, 0},
				{0, 1, 0, 0},
				{0, 1, 0, 0},
			},
		},
		{
			--O block
			{
				{2, 2},
				{2, 2},
			},
		},
		{
			--J block
			{
				{0, 0, 0},
				{3, 3, 3},
				{0, 0, 3},
			},
			{
				{0, 3, 0},
				{0, 3, 0},
				{3, 3, 0},
			},
			{
				{0, 0, 0},
				{3, 0, 0},
				{3, 3, 3},
			},
			{
				{0, 3, 3},
				{0, 3, 0},
				{0, 3, 0},
			},
		},
		{
			--L block
			{
				{0, 0, 0},
				{4, 4, 4},
				{4, 0, 0},
			},
			{
				{0, 4, 0},
				{0, 4, 0},
				{0, 4, 4},
			},
			{
				{0, 0, 0},
				{0, 0, 4},
				{4, 4, 4},
			},
			{
				{4, 4, 0},
				{0, 4, 0},
				{0, 4, 0},
			},
		},
		{
			--T Block
			{
				{0, 0, 0},
				{5, 5, 5},
				{0, 5, 0},
			},
			{
				{0, 5, 0},
				{0, 5, 5},
				{0, 5, 0},
			},
			{
				{0, 0, 0},
				{0, 5, 0},
				{5, 5, 5},
			},
			{
				{0, 5, 0},
				{5, 5, 0},
				{0, 5, 0},
			},
		},
		{
			--S block
			{
				{0, 0, 0},
				{0, 6, 6},
				{6, 6, 0},
			},
			{
				{6, 0, 0},
				{6, 6, 0},
				{0, 6, 0},
			},
		},
		{
			-- Z block
			{
				{0, 0, 0},
				{7, 7, 0},
				{0, 7, 7},
			},
			{
				{0, 7, 0},
				{7, 7, 0},
				{7, 0, 0},
			},
		},
	}
	--[[
	All of the variables we have to have set.
	]]

	-- variables for the game board/pieces.
	self.pieceRotation = 0
	self.pieceType = 0
	self.heldPiece = 0
	self.pieceY = 0
	self.pieceX = 0
	self.gridXCount = 10
	self.gridYCount = 22
	self.pieceRotations = 0
	self.pieceLength = 0
	self.heldPieceLength = 0
	-- the basic game variables.
	self.gravityTimer = 0
	self.fallTimer = 1.0
	self.lockTimer = 0
	self.gameTime = 0
	self.score = 0
	self.level = 1
	self.lines = 0
	self.currentLevelLines = 0
	self.shadowPiece = {
		x = 0,
		y = 0,
	}
	-- the amount of time we should wait until the item is locked.
	--[[
		for levels above 20 in endless what happens is that this is slowly
		decreased over time by 0.05s per level.
	]]


	self.maxMoveOption = {
		['hard'] = 15,
		['easy'] = 20,
	}
	self.lastChance = false
	-- seconds for how long it should take for the piece to fall 1 row.
	-- "Hard" mode uses the official timelines.
	self.dropTimeOptions = {
		['hard'] = {1.0, 0.793, 0.6178, 0.4727, 0.3552, 0.262, 0.1897, 0.1347, 0.0939, 0.0642, 0.043, 0.0282, 0.0182, 0.0114, 0.0071, 0.0043, 0.0025, 0.0015, 0.0008},
		['easy'] = {1.0, 0.803, 0.6336, 0.4912, 0.374, 0.2796, 0.2052, 0.1478, 0.1045, 0.0724, 0.0492, 0.0328, 0.0214, 0.0137, 0.0086, 0.0053, 0.0032, 0.0019, 0.0011, 1.0, 0.843, 0.6989, 0.5697, 0.4565, 0.3596, 0.2783, 0.2116, 0.158, 0.1158, 0.0834, 0.0589, 0.0408, 0.0277, 0.0185, 0.0121, 0.0077, 0.0049, 0.003}
	}
	self.lockTimes = {
		['hard'] = 0.5,
		['easy'] = 0.75,
	}

	if params.difficulty then
		self.dropTimes = self.dropTimeOptions[params.difficulty]
		self.maxMoves = self.maxMoveOption[params.difficulty]
		self.lockTime = self.lockTimes[params.difficulty]
	else
		self.maxMoves = self.maxMoveOption['hard']
		self.dropTimes = self.dropTimeOptions['hard']
		self.lockTime = self.lockTimes['hard']
	end

	self.remainingMoves = self.maxMoves

	self.inert = {}
	for y = 1, self.gridYCount do
		self.inert[y] = {}
		for x = 1, self.gridXCount do
			self.inert[y][x] = 0
		end
	end

	-- game state variables
	self.gameOver = false
	self.canInput = true

	-- the message
	self.msg =  ''
	self.endMsgY = -40
	self.gameMode = 1
	self.countDown = 0
	self:newBatch()
	self:newPiece()
end

function BaseGame:validMove(test_x,test_y,testRotation)
	local maxY = (self.gridYCount+1) - self.pieceLength
	for x=1,self.pieceLength do
		local testBlockX = test_x + x
		for y=0,self.pieceLength-1 do
			local testBlockY = test_y + y
			if self.pieceStructures[self.pieceType][testRotation][y+1][x] ~= 0 then
				--and (

				if
				testBlockX < 1
						or testBlockX > self.gridXCount
						or testBlockY > self.gridYCount
						or self.inert[testBlockY][testBlockX] ~= 0
				then
					return false
				end

			end
		end
	end
	return true
end

function BaseGame:handleInput(key)
	if not self.gameOver then
		if self.canInput then
			if key == 'x' or key == 'up' then
				if self.pieceType ~= 2 then
					local new_rotation = self.pieceRotation
					new_rotation = self.pieceRotation + 1
					if new_rotation > self.pieceRotations then
						new_rotation = 1
					end
					if self:canRotate(self.pieceRotation,new_rotation) then
						self.pieceRotation = new_rotation
						self.lockTimer = 0
						if self.lastChance then
							self.remainingMoves =  self.remainingMoves - 1
						end
						self:updateShadow()
						if gMusicMuted == false then
							gSFX['rotate']:play()
						end
					end
				else
					if self.lastChance then
						self.remainingMoves = self.remainingMoves - 1
					end
					self.lockTimer = 0
				end

			elseif key == 'z' or key == 'lctrl' or key == 'rctrl' then
				if pieceType ~= 2 then
					local new_rotation = self.pieceRotation
					new_rotation = self.pieceRotation -1
					if new_rotation == 0 then
						--new_rotation = #pieceStructures[self.pieceType]
						new_rotation = self.pieceRotations
					end

					if self:canRotate(self.pieceRotation,new_rotation) then
						self.pieceRotation = new_rotation
						self.lockTimer = 0
						if self.lastChance then
							self.remainingMoves =  self.remainingMoves - 1
						end
						if gMusicMuted == false then
							gSFX['rotate']:play()
						end

						self:updateShadow()
					end
				else
					if self.lastChance then
						self.remainingMoves =  self.remainingMoves - 1
					end
					self.lockTimer = 0
				end

			elseif key == 'left' then
				if self:validMove(self.pieceX-1,self.pieceY,self.pieceRotation) then
					self.pieceX = self.pieceX - 1
					self.lockTimer = 0
					if self.lastChance then
						self.remainingMoves =  self.remainingMoves - 1
					end
					self:updateShadow()
				end
			elseif key == 'right' then
				if self:validMove(self.pieceX+1,self.pieceY,self.pieceRotation) then
					self.pieceX = self.pieceX + 1
					self.lockTimer = 0
					if self.lastChance then
						self.remainingMoves =  self.remainingMoves - 1
					end
					self:updateShadow()
				end
			elseif key == 'down' then
				if self:validMove(self.pieceX,self.pieceY+1,self.pieceRotation) then
					self.pieceY = self.pieceY + 1
					self.lockTimer = 0
					self.lastChance = false
					self.remainingMoves = self.maxMoves
					self.score = self.score + 10
				end
			elseif key == 'c' then
				local tmp_extra = 0
				while self:validMove(self.pieceX, self.pieceY + 1, self.pieceRotation) do
					-- maximum of 280pts for the fall.
					if tmp_extra <= 14 then
						tmp_extra = tmp_extra + 1
					end
					self.pieceY = self.pieceY + 1
				end
				self.score = self.score + (tmp_extra * 20)
				-- make sure that the piece is then locked.
				self.gravityTimer = self.fallTimer
				self.lockTimer = self.lockTime
				if gMusicMuted == false then
					gSFX['drop']:play()
				end
			elseif key == 'lshift' or key == 'rshift' or key == 'shift' then
				if self.heldPiece ~= 0 then
					local tmpPiece = self.heldPiece
					self.heldPiece = self.pieceType
					self.pieceType = tmpPiece
					self.pieceRotations = #self.pieceStructures[self.pieceType]
					if self.pieceType == 1 then
						self.pieceX = 3
						self.pieceY = 1
						self.pieceRotation = 1
					else
						self.pieceX = 3
						self.pieceY = 1
						if self.pieceType == 3 or self.pieceType == 4 or self.pieceType == 5 then
							self.pieceRotation = 3
						else
							self.pieceRotation = 1
						end
					end
					self.pieceLength = #self.pieceStructures[self.pieceType][1]
				else
					self.heldPiece = self.pieceType
					self:newPiece()
				end
				self.heldPieceLength = #self.pieceStructures[self.heldPiece][1]
				self.lastChance = false
				self.remainingMoves = self.maxMoves
				self:updateShadow()
			elseif key == 'return' or key == 'enter' or key == 'space' then
				self.canInput = false
				self.paused = true
				self.msg = 'Game Paused'
				Timer.tween(0.5,{
					[self] = {endMsgY = 240}
				})
			end
		elseif self.canInput == false then
			if key == 'return' or key == 'enter' or key == 'space' then
				self.msg = '3'
				self.countDown = 3
				self.canInput = nil
				Timer.every(1,function()
					self.countDown = self.countDown - 1
					self.msg = tostring(self.countDown)
				end):finish(function()
					self.endMsgY = -40
					self.canInput = true
					self.paused = false
				end):limit(3)
			elseif key == 'escape' then
				gStateMachine:change('main_menu',{['mode'] = self.gameMode})
			end
		end
	elseif self.canInput then
		if key == 'return' or key == 'enter' then
			self:endGame()
		end
	end
end

function BaseGame:updatePiece(dt)
	self.gravityTimer = self.gravityTimer + dt
	self.lockTimer = self.lockTimer + dt
	if self.gravityTimer >= self.fallTimer then
		self.gravityTimer = self.gravityTimer - self.fallTimer
		local new_y = self.pieceY + 1
		if self:validMove(self.pieceX, new_y,self.pieceRotation) then
			self.pieceY = new_y
			self:updateShadow()
			self.lockTimer = 0
			self.lastChance = false
		else
			self.lastChance = true
			if self.lastChance then
				self.remainingMoves = self.remainingMoves - 1
			end
			if self.lockTimer > self.lockTime or (self.lastChance and self.remainingMoves <= 0) then
				if self:validMove(self.pieceX, new_y,self.pieceRotation) then
					self.piece_y = new_y
				end
				for y = 0, self.pieceLength-1 do
					for x = 1, self.pieceLength do
						local block = self.pieceStructures[self.pieceType][self.pieceRotation][y+1][x]
						if block ~= 0 then
							self.inert[self.pieceY + y][self.pieceX + x] = block
						end
					end
				end
				self.lockTimer = 0
				self:newPiece()
				if not self:validMove(self.pieceX, self.pieceY, self.pieceRotation) then
					self.gameOver = true
					self.pieceY = self.pieceY > 1 and self.pieceY - 1 or self.pieceY
					for y = 0, self.pieceLength-1 do
						for x = 1, self.pieceLength do
							local block = self.pieceStructures[self.pieceType][self.pieceRotation][y+1][x]
							if block ~= 0 then
								self.inert[self.pieceY + y][self.pieceX + x] = block
							end
						end
					end
					self:enterGameOver()
				end
				self.remainingMoves = self.maxMoves
			end

		end

	end
end

function BaseGame:enterGameOver()

	local current_y = self.gridYCount
	self.shadowPiece.x = 0
	self.shadowPiece.y = 0
	self.canInput = false
	gMusic[gCurrentSong]:stop()
	gCurrentSong = 'game_over'
	gMusic['game_over']:play()
	Timer.every(0.2, function()
		for x=1,self.gridXCount do
			if self.inert[current_y][x] ~= 0 then
				self.inert[current_y][x] = 9
			end
		end
		current_y = current_y - 1
		if current_y == 0 then
			self.msg =  'Game Over. Press enter.'
			Timer.tween(2,{
				[self] = {endMsgY = ((30*23)/2)-20}
			}):finish(function()
				self.canInput = true
			end)
		end
	end):limit(self.gridYCount)

end

function BaseGame:checkClears()
	local lines = 0
	for y =1, self.gridYCount do
		local line = true
		for x=1,self.gridXCount do
			if self.inert[y][x] == 0 then
				line = false
				break
			end
		end
		if line then
			lines = lines + 1
			for clear_y=y,2,-1 do
				for clear_x=1,self.gridXCount do
					self.inert[clear_y][clear_x] = self.inert[clear_y -1][clear_x]
				end
			end
			for clear_x = 1, self.gridXCount do
				self.inert[1][clear_x] = 0
			end
		end
	end

	if lines ~= 0 then
		local multiplier = {
			[1] = 100,
			[2] = 300,
			[3] = 500,
			[4] = 800,
		}
		self.score = self.score + (self.level * multiplier[lines])
		self.lines = lines + self.lines
		self.currentLevelLines = self.currentLevelLines + lines
		if self.currentLevelLines >= 10 then
			self.level = self.level + 1
			self.currentLevelLines = self.currentLevelLines % 10
			self.fallTimer = self.dropTimes[self.level > 20 and 20 or self.level ]
		end
	end
end

function BaseGame:updateShadow()
	self.shadowPiece.x = self.pieceX
	self.shadowPiece.y = self.pieceY
	while self:validMove(self.shadowPiece.x, self.shadowPiece.y + 1, self.pieceRotation) do
		self.shadowPiece.y =  self.shadowPiece.y + 1
	end
end

function BaseGame:drawShadow()
	local colors = {
		{{0.2895, 0.2913, 0.2932}, {0.6094, 0.6133, 0.6172}, {0.3827, 0.3852, 0.3876}}
	}

end

function BaseGame:canRotate(old_rotation,new_rotation)
	--z:7,s:6,t:5,l:4,j:3,o:2,i:1
	-- j,l,s,t,z all use the same rotation. o doesn't rotate.
	-- and i uses it's own special one.
	local kick_data_normal = {
		[0] = {
			[1] = { {-1,0},{-1,1},{0,-2},{-1,-2} },
			[3] = { {1,0},{1,1},{0,-2},{1,-2} }
		},
		[1] ={
			[0] ={ {1,0},{1,-1},{0,2},{1,2} },
			[2] = { {1,0},{1,-1},{0,2},{1,2} },

		},
		[2] = {
			[1]={ {-1,0},{-1,1},{0,-2},{-1,-2} },
			[3] ={ {1,0},{-1,1},{0,-2},{-1,-2} },
		},
		[3]={
			[0]={ {-1,0},{-1,-1},{0,2},{-1,2} },
			[2]={ {-1,0},{-1,-1},{0,2},{-1,2} },
		}
	}
	old_rotation = old_rotation -1
	new_rotation = new_rotation -1
	local kick_data_i = {
		[0] = {
			[1] = { {-2,0}, {1,0}, {-2,-1}, {1,2} },
			[3] = { {-1,0}, {2,0}, {-1,2}, {2,-1} }
		},
		[1] ={
			[0] ={ {2,0}, {-1,0}, {2,1}, {-1,-2} },
			[2] = { {-1,0}, {2,0}, {-1,2}, {2,-1} },
		},
		[2] = {
			[1]={ {1,0}, {-2,0}, {1,-2}, {-2,1} },
			[3] ={ {2,0}, {-1,0}, {2,1}, {-1,-2} }
		},
		[3]={
			[0]={ {1,0}, {-2,0}, {1,-2}, {-2,1} },
			[2]={ {-2,0}, {1,0}, {-2,-1}, {1,2} },
		}
	}
	local valid = false
	local old_x, old_y = self.pieceX, self.pieceY
	local new_x, new_y,mod_x, mod_y = 0,0,0,0

	if self.pieceType == 1 then
		if not self:validMove(old_x,old_y,new_rotation+1) then
			for i=1,4 do
				mod_x,mod_y = unpack(kick_data_i[old_rotation][new_rotation][i])
				new_x,new_y = old_x+mod_x, old_y+mod_y
				if self:validMove(new_x,new_y,new_rotation+1) then
					valid = true
					self.pieceX,self.pieceY = new_x, new_y
					break
				end
			end
		else
			valid = true
		end
	else
		if not self:validMove(old_x,old_y,new_rotation+1) then
			for i=1,4 do
				mod_x,mod_y = unpack(kick_data_normal[old_rotation][new_rotation][i])
				new_x,new_y = old_x+mod_x, old_y+mod_y
				if self:validMove(new_x,new_y,new_rotation+1) then
					valid = true
					self.pieceX,self.pieceY = new_x,new_y
					break
				end
			end
		else
			valid = true
		end
	end
	return valid
end

function BaseGame:newPiece()
	--z:7,s:6,t:5,l:4,j:3,o:2,i:1

	self.pieceType = table.remove(self.sequence)
	self.pieceLength = #self.pieceStructures[self.pieceType][1]
	self.pieceRotations = #self.pieceStructures[self.pieceType]
	if self.pieceType == 1 then
		self.pieceX = 3
		self.pieceY = 1
		self.pieceRotation = 1
	else
		self.pieceX = 3
		self.pieceY = 1
		if self.pieceType == 3 or self.pieceType == 4 or self.pieceType == 5 then
			self.pieceRotation = 3
		else
			self.pieceRotation = 1
		end
	end
	if #self.sequence == 0 then
		self:newBatch()
	end
	self.remainingMoves = self.maxMoves
	self.lastChance = false
	self:updateShadow()
end

function BaseGame:newBatch()
	self.sequence = {}
	for x=1, 7 do
		-- not using love.math.random() as it's too random this other one gives me the same inputs upon each startup which is good for
		-- testing.
		--local position = love.math.random(x+1)
		local position = math.random(x+1)
		table.insert(self.sequence,position,x)
	end
end

function BaseGame:drawField()
	local offsetX = 7
	local offsetY = 0
	for y = 2, self.gridYCount do
		for x = 1, self.gridXCount do
			if self.inert[y][x] ~= 0 then
				self:drawBlock(self.inert[y][x],x+offsetX,y)
			else
				love.graphics.setColor(0.0863,0.0863,0.0863)
				love.graphics.rectangle(
						'fill',
						((x - 1)+offsetX) * 30,
						(y - 1) * 30,
						26,
						26
				)
				love.graphics.setColor(1,1,1)
			end
		end
	end
	--[[ this check is here to see if we should even bother showing the ghost piece or not.
	 	No reason to render it if the piece is already at the bottom.
	]]
	if self.pieceY < self.gridYCount then
		-- ghost piece
		for y=1,self.pieceLength do
			for x=1,self.pieceLength do
				local block = self.pieceStructures[self.pieceType][self.pieceRotation][y][x]
				if block ~= 0 then
					self:drawBlock(10,x+self.shadowPiece.x +offsetX,y+self.shadowPiece.y-1 + offsetY)
				end
			end
		end
	end

	-- draw the actual piece
	for y=1,self.pieceLength do
		for x=1,self.pieceLength do
			local block = self.pieceStructures[self.pieceType][self.pieceRotation][y][x]
			if block ~= 0 then
				self:drawBlock(block,x+self.pieceX +offsetX,y+self.pieceY-1 + offsetY)
			end
		end
	end


end

function BaseGame:drawBlock(block,x,y)
	--z:7,s:6,t:5,l:4,j:3,o:2,i:1
	local colors = {
		{{0.2456, 0.3971, 0.4911}, {0.517, 0.836, 1.034}, {0.3247, 0.525, 0.6494}},
		{{0.4807, 0.3605, 0.2456}, {1.012, 0.759, 0.517}, {0.6355, 0.4767, 0.3247}},
		{{0.4859, 0.4755, 0.2195}, {1.023, 1.001, 0.462}, {0.6424, 0.6286, 0.2901}},
		{{0.256, 0.4441, 0.3971}, {0.539, 0.935, 0.836}, {0.3385, 0.5872, 0.525}},
		{{0.5068, 0.303, 0.4023}, {1.067, 0.638, 0.847}, {0.6701, 0.4007, 0.5319}},
		{{0.3448, 0.4337, 0.2403}, {0.726, 0.913, 0.506}, {0.4559, 0.5734, 0.3178}},
		{{0.4337, 0.2821, 0.4859}, {0.913, 0.594, 1.023}, {0.5734, 0.373, 0.6424}},
		-- The one when they're marked for clearning. Might use might not.
		{{0.74, 0.74, 0.74}, {1, 1 ,1}, {1, 1, 1}},
		-- The blocks that makeup the ghost piece show final drop position.
		{{0.5643, 0.5643, 0.5643}, {0.99, 0.99, 0.99}, {0.6633, 0.6633, 0.6633}},
		-- Dead blocks aka the ones that are added when selecting a level or something.
		{{0.2565, 0.2565, 0.2565}, {0.45, 0.45, 0.45}, {0.3015, 0.3015, 0.3015}}
	}

	local color = colors[block]
	local blockSize = 30
	local blockDrawSize = blockSize - 1
	x = x - 1
	y = y - 1
	local modifier = 1
	love.graphics.setColor(color[1])
	love.graphics.rectangle("fill", blockSize * x, blockSize * y, blockDrawSize, blockDrawSize)
	love.graphics.setColor(color[2])
	love.graphics.rectangle("fill", blockSize * x + 2, blockSize * y + 2, blockDrawSize - 4, blockDrawSize - 4)
	love.graphics.setColor(color[3])
	love.graphics.rectangle("fill", blockSize * x + 6, blockSize * y + 6, blockDrawSize - 12, blockDrawSize - 12)
end

function BaseGame:drawGUI()
	local offsetX = 7
	local offsetY = 0
	local sw = love.graphics.getWidth()
	local aw = 30 * 10
	local blockSize = 30
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf("HELD", blockSize-1,blockSize * (offsetY+1) , sw - aw, "left")
	love.graphics.printf("NEXT", aw-(blockSize+10),blockSize * (offsetY+1), sw - aw, "right")
	love.graphics.printf("SCORE", aw-(blockSize+10),blockSize * (offsetY+9), sw - aw, "right")
	love.graphics.printf(number_separator(self.score), gItemFont,aw-(blockSize),blockSize * (offsetY+11), sw - aw +15, "right")
	love.graphics.printf("LINES", aw-(blockSize+10),blockSize * (offsetY+14), sw - aw, "right")
	love.graphics.printf(number_separator(self.lines), gItemFont, aw-(blockSize+8),blockSize * (offsetY+16), sw - aw, "right")
	love.graphics.printf("LEVEL",  blockSize-1,blockSize * (offsetY+14), sw - aw, "left")
	love.graphics.print(string.format("%05s", number_separator(self.level)), gItemFont, blockSize*2,blockSize * (offsetY+16))
	local next_piece = self.pieceStructures[self.sequence[#self.sequence]][1]
	local next_piece_length = #next_piece --#pieceStructures[sequence[#sequence]][1]

	for y = 1, next_piece_length do
		for x = 1, next_piece_length do
			local block =next_piece[y][x] --pieceStructures[sequence[#sequence]][1][y][x]
			if block ~= 0 then
				self:drawBlock(block, x+21, y +offsetY+3)
			end
		end
	end

	if self.heldPiece ~= 0 then
		local block = 0
		for y=1, self.heldPieceLength do
			for x=1, self.heldPieceLength do
				block = self.pieceStructures[self.heldPiece][1][y][x]
				if block ~= 0 then
					self:drawBlock(block,x+1,y+offsetY+3)
				end
			end
		end
	end

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle(
			'fill',
			(offsetX)*30,
			offsetY,
			30*self.gridXCount,
			30*2
	)
	love.graphics.setColor(1,1,1,1)

end

function BaseGame:render()
	self:drawField()
	self:drawGUI()
	if self.gameOver or not self.canInput then
		self:drawMessage()
	end
end

function BaseGame:updateBoard(dt)
	-- check if the game is over or if we're paused. if paused no reason to update stuff.
		self:updatePiece(dt)
		self:checkClears()
		-- temporarily do this like this. Eventually it'll just exit the state.
		self:checkWin()
end

function BaseGame:drawMessage()
	love.graphics.setColor(0.5,0.5,0.5,0.75)
	love.graphics.rectangle('fill',0,self.endMsgY-8,30*26,48)
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(self.msg,0,self.endMsgY,30*26,'center')
end

function BaseGame:checkWin()
	-- don't know the equivalent of pass in lua.
	return false
end

function BaseGame:endGame()
	gStateMachine:change('check_scores',{
		['score'] = self.score,
		['lines'] = self.lines,
		['level'] = self.level,
		['mode'] = self.gameMode,
	})
end


function BaseGame:exit()
	if gMusicMuted == false then
		gMusic[gCurrentSong]:stop()
		gCurrentSong = 'title_music'
		gMusic['title_music']:play()
	end
	Timer.clear()
end