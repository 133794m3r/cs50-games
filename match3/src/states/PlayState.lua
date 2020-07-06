--[[
    GD50
    Match-3 Remake

    -- PlayState Class --

    Authors: Colton Ogden, Macarthur Inbody
    cogden@cs50.harvard.edu, 133794m3r@gmail.com

    State in which we can actually play, moving around a grid cursor that
    can swap two tiles; when two tiles make a legal swap (a swap that results
    in a valid match), perform the swap and destroy all matched tiles, adding
    their values to the player's point score. The player can continue playing
    until they exceed the number of points needed to get to the next level
    or until the time runs out, at which point they are brought back to the
    main menu or the score entry menu if they made the top 10.
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
	self.moves = 0
	-- start our transition alpha at full, so we fade in
	self.transitionAlpha = 255

	-- position in the grid which we're highlighting
	self.boardHighlightX = 0
	self.boardHighlightY = 0

	-- timer used to switch the highlight rect's color
	self.rectHighlighted = false

	-- flag to show whether we're able to process input (not swapping or clearing)
	self.canInput = true

	-- tile we're currently highlighting (preparing to swap)
	self.highlightedTile = nil

	self.score = 0
	self.timer = 60
	self.paused = false
	-- For when there's no moves we'll render that text. Later I'll make it an actual state.
	--self.no_moves = true
	-- set our Timer class to turn cursor highlight on and off
	Timer.every(0.5, function()
		self.rectHighlighted = not self.rectHighlighted
	end)

	-- subtract 1 from timer every second
	Timer.every(1, function()
		if self.paused == false then
			self.timer = self.timer - 1
		end

		-- play warning sound on timer if we get low
		if self.timer <= 5 then
			gSounds['clock']:play()
		end
	end)
	--Timer.every(1,function()
	--	self.board:renderShinies()
	--end)
	self.no_moves_y = -64

end

function PlayState:enter(params,timer)

	-- grab level # from the params we're passed
	self.level = params.level

	-- spawn a board and place it toward the right
	self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16,self.level)

	-- grab score from params if it was passed
	self.score = params.score or 0

	-- score we have to reach to get to the next level
	self.scoreGoal = self.level * 1.25 * 1000

	-- so that when I re-enter this state I can make sure that it works.
	self.timer = timer ~= nil and timer or self.timer
end

function PlayState:update(dt)
	if love.keyboard.wasPressed('escape') then
		love.event.quit()
	end

	-- go back to start if time runs out
	if self.timer <= 0 then

		-- clear timers from prior PlayStates
		Timer.clear()

		gSounds['game-over']:play()

		gStateMachine:change('game-over', {
			score = self.score
		})
	end

	-- go to next level if we surpass score goal
	if self.score >= self.scoreGoal then

		-- clear timers from prior PlayStates
		-- always clear before you change state, else next state's timers
		-- will also clear!
		Timer.clear()

		gSounds['next-level']:play()

		-- change to begin game state with new level (incremented)
		gStateMachine:change('begin-game', {
			level = self.level + 1,
			score = self.score
		})
	end

	if self.canInput then
		-- move cursor around based on bounds of grid, playing sounds
		if love.keyboard.wasPressed('up') then
			self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
			gSounds['select']:play()
		elseif love.keyboard.wasPressed('down') then
			self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
			gSounds['select']:play()
		elseif love.keyboard.wasPressed('left') then
			self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
			gSounds['select']:play()
		elseif love.keyboard.wasPressed('right') then
			self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
			gSounds['select']:play()
		end
		-- if we've pressed space pause/unpause the game.
		if love.keyboard.wasPressed('space') then
			self.paused = not self.paused
		end
		-- if we've pressed enter, to select or deselect a tile...
		if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
			self.moves = self.moves + 1
			-- if same tile as currently highlighted, deselect
			local x = self.boardHighlightX + 1
			local y = self.boardHighlightY + 1

			-- if nothing is highlighted, highlight current tile
			if not self.highlightedTile then
				self.highlightedTile = self.board.tiles[y][x]

				-- if we select the position already highlighted, remove highlight
			elseif self.highlightedTile == self.board.tiles[y][x] then
				self.highlightedTile = nil
				-- if the difference between X and Y combined of this highlighted tile
				-- vs the previous is not equal to 1, also remove highlight
			elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
				gSounds['error']:play()
				self.highlightedTile = nil
			else
				-- swap grid positions of tiles
				local tempX = self.highlightedTile.gridX
				local tempY = self.highlightedTile.gridY

				local newTile = self.board.tiles[y][x]
				self.highlightedTile.gridX = newTile.gridX
				self.highlightedTile.gridY = newTile.gridY
				newTile.gridX = tempX
				newTile.gridY = tempY
				-- swap tiles in the tiles table
				self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
				self.highlightedTile

				self.board.tiles[newTile.gridY][newTile.gridX] = newTile
				--if self.board:validMove() then
				if self.board:fastValid(newTile.gridX,newTile.gridY,self.highlightedTile.gridX,self.highlightedTile.gridY) then

					-- tween coordinates between the two so they swap
					Timer.tween(0.25, {
						[self.highlightedTile] = {x = newTile.x, y = newTile.y},
						[newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
					})

					-- once the swap is finished, we can tween falling blocks as needed
						 :finish(function()
						self:calculateMatches()
					end)

				else
					gSounds['error']:play()
					-- swap grid positions of tiles

					tempX = self.highlightedTile.gridX
					tempY = self.highlightedTile.gridY
					self.highlightedTile.gridX = newTile.gridX
					self.highlightedTile.gridY = newTile.gridY
					newTile.gridX = tempX
					newTile.gridY = tempY
					self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile

					self.board.tiles[newTile.gridY][newTile.gridX] = newTile
					self.highlightedTile = nil
					self.canInput = true
				end
				if not self.board:checkBoard() then
					self.canInput = false
					self.no_moves = true
					Timer.tween(0.5, {
						[self] = {no_moves_y = VIRTUAL_HEIGHT / 2 - 8}
					})
						 :finish(function()
						Timer.after(1,function()
							Timer.tween(0.5,{
								[self] = {no_moves_y = VIRTUAL_HEIGHT + 30}
							})
								:finish(function()
									self.board:initializeTiles()
									self.no_moves = false
									self.canInput = true
									self.timer = self.timer + 5
							end)

						end)
					end)

				end
			end
		end
	end

	Timer.update(dt)
end

--[[
    Calculates whether any matches were found on the board and tweens the needed
    tiles to their new destinations if so. Also removes tiles from the board that
    have matched and replaces them with new randomized tiles, deferring most of this
    to the Board class.
]]
function PlayState:calculateMatches()
	self.highlightedTile = nil

	-- if we have any matches, remove them and tween the falling blocks that result
	local matches = self.board:calculateMatches()
	local bonus = 0
	if matches then
		gSounds['match']:stop()
		gSounds['match']:play()

		self.score,self.timer = self.board:scoreMatches(self.score,self.timer)
		-- add to the timer the number of matched tiles.
		--self.timer = self.board:addTime(self.timer)

		-- remove any tiles that matched from the board, making empty spaces
		self.board:removeMatches()

		-- gets a table with tween values for tiles that should now fall
		local tilesToFall = self.board:getFallingTiles()

		-- tween new tiles that spawn from the ceiling over 0.25s to fill in
		-- the new upper gaps that exist
		Timer.tween(0.25, tilesToFall):finish(function()

			-- recursively call function in case new matches have been created
			-- as a result of falling blocks once new blocks have finished falling
			self:calculateMatches()
		end)
		love.graphics.clear()
		-- if no matches, we can continue playing
	else
		self.canInput = true

	end
end

function PlayState:render()
	-- render board of tiles
	self.board:render()

	-- render highlighted tile if it exists
	if self.highlightedTile then

		-- multiply so drawing white rect makes it brighter
		love.graphics.setBlendMode('add')

		love.setColor(255, 255, 255, 96)
		love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
				(self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

		-- back to alpha
		love.graphics.setBlendMode('alpha')
	end

	-- render highlight rect color based on timer
	if self.rectHighlighted then
		love.setColor(217, 87, 99, 255)
	else
		love.setColor(172, 50, 50, 255)
	end

	-- draw actual cursor rect
	love.graphics.setLineWidth(4)
	love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
			self.boardHighlightY * 32 + 16, 32, 32, 4)

	-- GUI text
	love.setColor(56, 56, 56, 234)
	love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

	love.setColor(99, 155, 255, 255)
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
	love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
	love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
	love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')

	-- the no moves rectangle.
	love.setColor(95, 205, 228, 200)
	love.graphics.rectangle('fill', 0, self.no_moves_y - 8, VIRTUAL_WIDTH, 48)
	love.setColor(255, 255, 255, 255)
	love.graphics.setFont(gFonts['large'])
	love.graphics.printf('No valid moves.',
			0, self.no_moves_y, VIRTUAL_WIDTH, 'center')

	-- the paused text screen.
	if self.paused then
		love.setColor(95, 205, 228, 200)
		love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 48)
		love.setColor(255, 255, 255, 255)
		love.graphics.setFont(gFonts['large'])
		love.graphics.printf('Game Paused',
				0, VIRTUAL_HEIGHT / 2 + 8
		, VIRTUAL_WIDTH, 'center')

	end
end