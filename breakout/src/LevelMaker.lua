--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local bricks = {}
    local PowerUps = {}
    local PowerUpLUT = {
        [1] = MultiBallPowerUp,
        [2] = LifePowerUp,
        [3] = GrowPowerUp
    }

    -- randomly choose the number of rows
    local numRows = math.random(1, 3)

    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 9)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick color in this level; ensure we
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of the highest tier, no higher than 5
    --local highestColor = math.min(5, level % 5 + 3)
    local highestColor = 3
    local locked = false
    -- Basically we make a number between 1 and this number and if it is that number then we make the brick contain
    -- a powerup. Except level 1. Level 1 _always_ has a locked brick and a key powerup.PowerUp
    -- All levels always have a "key" powerup that's indexed by that value _always_ to make sure it's spawned.

    local powerup_min = 10

    local total_powerups = 1
    local locked_chance = level ~= 1 and 1000 or 30
    local check = 0
    local num_locked = 0
    local num_bricks = 0
    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)
        
        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want to alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not skipping or alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)
        for x = 1, numCols do
            -- if skipping is turned on and we're on a skip iteration...
            if skipPattern and skipFlag then
                -- turn skipping off for the next iteration
                skipFlag = not skipFlag

                -- Lua doesn't have a continue statement, so this is the workaround
                goto continue
            else
                -- flip the flag to true on an iteration we don't use it
                skipFlag = not skipFlag
            end
            num_bricks = num_bricks + 1
            b = Brick(
                -- x-coordinate
                (x-1)                   -- decrement x by 1 because tables are 1-indexed, coords are 0
                * 32                    -- multiply by 32, the brick width
                + 8                     -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixels total
                + (13 - numCols) * 16,  -- left-side padding for when there are fewer than 13 columns
                
                -- y-coordinate
                y * 16                  -- just use y * 16, since we need top padding anyway
            )

            if math.random(6) == 6 then
                check = math.random(100)
                if check <= 30 then
                    PowerUps[total_powerups] = PowerUpLUT[1](b)
                elseif check <= 50 then
                    PowerUps[total_powerups] = PowerUpLUT[2](b)
                else
                    PowerUps[total_powerups] = PowerUpLUT[3](b)
                end
                b.powerup = total_powerups
                total_powerups = total_powerups + 1
            end
            -- if we're alternating, figure out which color/tier we're on
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not alternating and we made it here, use the solid color/tier
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end
            if math.random(locked_chance) == locked_chance then
                b.locked = true
                PowerUps[total_powerups] = KeyPowerUp(b)
                total_powerups = total_powerups + 1
                num_locked = num_locked + 1
            end
            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end
    --bricks[#bricks].locked=true
    --bricks[#bricks].color = 1
    --bricks[#bricks].tier = 0
    --bricks[#bricks].powerup = nil
   --if level > 1 then
   --     local brick_number = math.random(1,#bricks*2)
   --     if brick_number <= #bricks then
   --         bricks[brick_number].locked=true
   --     end
   -- end
    PowerUps['key']={}
    --PowerUps['multi']=PowerUp(9,0,nil,nil,50)
    --PowerUps['glue']=PowerUp(8,255,nil,nil,50)


    --local pu = PowerUp(10,0,bricks[#bricks-1],nil,50)
    local pu = KeyPowerUp(bricks[1],nil)

    PowerUps['key'] = pu
    --PowerUps['multi'] = MultiBallPowerUp(bricks[1],nil)

    if level == 1 then
        num_locked = num_locked + 1
        PowerUps[total_powerups] = KeyPowerUp(bricks[num_bricks],50)
        bricks[num_bricks].locked = true
        bricks[num_bricks-1].powerup = total_powerups
        PowerUps[total_powerups + 1] = PowerUpLUT[1](bricks[num_bricks - 1],50)
        bricks[num_bricks - 2].powerup = total_powerups + 1
        PowerUps[total_powerups+2] = PowerUpLUT[2](bricks[num_bricks -1 ],50)
        PowerUps[total_powerups+3] = PowerUpLUT[3](bricks[num_bricks -2],50)
        bricks[num_bricks - 3].powerup = total_powerups+2
        bricks[num_bricks - 4].powerup = total_powerups+3
    end

    -- in the event we didn't generate any bricks, try again
    if num_bricks == 0 then
        return self.createMap(level)
    else
        return bricks,PowerUps,num_locked
    end
end