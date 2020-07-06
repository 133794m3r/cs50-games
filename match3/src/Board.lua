--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y,level,no_moves)
    self.x = x
    self.y = y
    self.matches = {}
    self.totalMatches = 0
    self.level = level
    --self.max_color = math.min(12,math.round((self.level / 5)* 12 ))
    if no_moves then
        self.max_color = 12
    else
        self.max_color = math.min(12,math.floor(self.level+1/2)+4)

    end
    --self.max_color  = 11
    self.max_pattern = math.min(6,math.floor(self.level / 2))
    --self.max_pattern = 6
    self:initializeTiles()
    self.shinies = 0
end

function Board:initializeTiles()
    self.tiles = {}
    local shinies = 0
    local continuing=false
    local shiny = false
    local shiny_chance = level == 1 and 10 or 25

    local shiny_roll = 0
    for tileY = 1, 8 do

        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            shiny = shiny_chance == math.random(shiny_chance) and true or false

            if shiny then
                shinies = shinies + 1
            end
            -- create a new tile at X,Y with a random color and variety
            --table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(6)))m
            table.insert(self.tiles[tileY],Tile(tileX,tileY, math.random(self.max_color),math.random(self.max_pattern),shiny))
            end
        end

    --while self:calculateMatches() do
    while self:validMove() do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        shinies = 0
        self:initializeTiles()

    end

    if self.level <= 4  and shinies == 0 then
        self.tiles[math.random(2,3)][math.random(1,2)].shiny = true
    end
end
--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1
    local totalMatchNum = 1
    local shinies = 0
    local shiny_col = false
    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1
        shiny_col = self.tiles[y][1].shiny
        -- every horizontal tile
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                if shiny_col then
                    matchNum = 8
                    break
                elseif self.tiles[y][x].shiny then
                    matchNum = 8
                    break
                else
                    matchNum = matchNum + 1
                end
            else

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                shiny_col = self.tiles[y][x].shiny
                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then

                    totalMatchNum = totalMatchNum + 1
                    local match = {}
                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            totalMatchNum = totalMatchNum + 1
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        matchNum = 1
        shiny_col = self.tiles[1][x].shiny
        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                if shiny_col then
                    matchNum = matchNum + 8
                elseif self.tiles[y][x].shiny then
                    matchNum = matchNum + 8
                else
                    matchNum = matchNum + 1
                end
            else

                colorToMatch = self.tiles[y][x].color
                shiny_col = self.tiles[y][x].shiny

                if matchNum >= 3 then

                    totalMatchNum = totalMatchNum + 1
                    local match = {}
                    if matchNum  >= 8 then
                        totalMatchNum = totalMatchNum + matchNum
                        for x2 = 1,8 do
                            if x ~= x2 then
                                table.insert(match,self.tiles[y][x2])
                            end
                        end
                        matchNum = matchNum - 8
                    end
                    if matchNum >= 1 then

                        if matchNum >= 9 then
                            matchNum = matchNum - 8
                        end

                        for y2 = y - 1, y - matchNum, -1 do
                            if y2 <= 0 then
                                break;
                            end
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            if matchNum  >= 8 then
                totalMatchNum = totalMatchNum + 1
                for x2 = 1,8 do
                    if x ~= x2 then
                        table.insert(match,self.tiles[y][x2])
                    end
                end
                matchNum = matchNum - 8
            end
            if matchNum >= 1 then

                if matchNum >= 9 then
                    matchNum = matchNum - 8
                end

                for y2 =8, 8 - matchNum + 1, -1 do
                    if y2 <= 0 then
                        break;
                    end
                    table.insert(match, self.tiles[y2][x])
                end
            end
            -- go backwards from end of last row by matchNum
            --for y = 8, 8 - matchNum + 1, -1 do
            --    table.insert(match, self.tiles[y][x])
            --end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches
    self.totalMatches = totalMatchNum
    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}
    local shiny = false
    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do

            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then

                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then

                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end
    local shiny_chance = level == 1 and 10 or 25
    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                shiny = shiny_chance == math.random(shiny_chance) and true or false
                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(self.max_color), math.random(self.max_pattern),shiny)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end

function Board:renderShinies()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:renderShine(self.x, self.y)
        end
    end
end
function Board:addTime(time)
    local bonus
    for _,match in pairs(self.matches) do

        bonus = 1.02+((4.0/ self.level) * 0.075)
        time =time + bonus
    end
end
function Board:scoreMatches(score,time)
    -- also adds the time to the timer since we're already iterating over them. Shinies and higher variety add more time.
    -- add score for each match
    local bonus = 0
    local time_bonus = 1
    local time_add = 1.02+((4.0/ self.level) * 0.075)
    local chain_bonus =
    (self.level / 4 * ((self.totalMatches - 1) * 0.0125))+1

    for _, match in pairs(self.matches) do
        for __,tile in pairs(match) do
            if tile.variety > 1 then
                bonus = 1 +tile.variety / 3
            else
                bonus = 1
            end
            if tile.shiny then
                time_bonus = time_add + 0.125

                bonus = bonus + 0.125
            end
            score = score + (bonus + (chain_bonus/2)) * 50
            time = time + (time_bonus * ((bonus + chain_bonus)/4))
        end
        --self.score = self.score + #match * 50
    end
    return math.floor(score),math.floor(time)
end

function Board:checkBoard()
    local x2 = 1
    local y2 = 1
    local tmp_tiles = deepcopy(self.tiles)
    local prev_tile = tmp_tiles[y2][x2]
    local swaps =1
    for y=1,8 do
        x2=1
        y2=y
        for x=2,8 do
            prev_tile = tmp_tiles[y2][x2]
            -- swap grid positions of tiles
            local tempX = prev_tile.gridX
            local tempY = prev_tile.gridY

            local newTile = tmp_tiles[y][x]

            prev_tile.gridX = newTile.gridX
            prev_tile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY

            -- swap tiles in the tiles table
            tmp_tiles[prev_tile.gridY][prev_tile.gridX] =
            prev_tile

            tmp_tiles[newTile.gridY][newTile.gridX] = newTile
            if self:validMove2(tmp_tiles) then
                return true
            end
            x2=x
            swaps = swaps + 1
        end
        y2=y
    end
    for x=1,8 do
        y2=1
        x2=x
        for y=1,8 do
            prev_tile = tmp_tiles[y2][x2]
            -- swap grid positions of tiles
            local tempX = prev_tile.gridX
            local tempY = prev_tile.gridY

            local newTile = tmp_tiles[y][x]

            prev_tile.gridX = newTile.gridX
            prev_tile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY

            -- swap tiles in the tiles table
            tmp_tiles[prev_tile.gridY][prev_tile.gridX] =
            prev_tile

            tmp_tiles[newTile.gridY][newTile.gridX] = newTile
            if self:validMove2(tmp_tiles) then
                return true
            end
            x2=x
            swaps = swaps + 1
        end
    end
    return false
end

function Board:validMove2(tiles)
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1
    local moves = 0
    local shiny_col = false
    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = tiles[y][1].color
        matchNum = 1
        shiny_col = tiles[y][1].shiny
        -- every horizontal tile
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if tiles[y][x].color == colorToMatch then
                if shiny_col then
                    matchNum = 8
                    break
                elseif tiles[y][x].shiny then
                    matchNum = 8
                    break
                else
                    matchNum = matchNum + 1
                end
            else

                -- set this as the new color we want to watch for
                colorToMatch = tiles[y][x].color
                shiny_col = tiles[y][x].shiny
                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    return true
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            return true
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = tiles[1][x].color
        matchNum = 1
        shiny_col = tiles[1][x].shiny
        -- every vertical tile
        for y = 2, 8 do
            if tiles[y][x].color == colorToMatch then
                if shiny_col then
                    matchNum = matchNum + 8
                else
                    matchNum = matchNum + 1
                end
            else

                colorToMatch = tiles[y][x].color
                shiny_col = tiles[y][x].shiny

                if matchNum >= 3 then
                    return true
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            return true
        end
    end
    return false
end

function Board:validMove()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1
    local moves = 0
    local shiny_col = false
    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1
        shiny_col = self.tiles[y][1].shiny
        -- every horizontal tile
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                if shiny_col then
                    matchNum = 8
                    break
                elseif self.tiles[y][x].shiny then
                    matchNum = 8
                    break
                else
                    matchNum = matchNum + 1
                end
            else

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                shiny_col = self.tiles[y][x].shiny
                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    return true
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            return true
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        matchNum = 1
        shiny_col = self.tiles[1][x].shiny
        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                if shiny_col then
                    matchNum = matchNum + 8
                else
                    matchNum = matchNum + 1
                end
            else

                colorToMatch = self.tiles[y][x].color
                shiny_col = self.tiles[y][x].shiny

                if matchNum >= 3 then
                    return true
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            return true
        end
    end
    return false
end