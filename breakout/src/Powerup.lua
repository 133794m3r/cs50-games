---@param type number the type/skin of the object.
---@param duration number how long it'll last.
---@param brick object the brick this powerup is tied to.
---@param paddle object the paddle of the playfield.
---@param dy number the default acceleration sped.
PowerUp = Class{}

---init
---@param type number the type/skin of the object.
---@param duration number how long it'll last.
---@param brick object the brick this powerup is tied to.
---@param paddle object the paddle of the playfield.
---@param dy number the default acceleration sped.
function PowerUp:init(type,duration,brick,paddle,dy)
    -- the type is the "skin" we'll use and also attach information to later on.
    self.type = type
    -- how long the item should be active once the collected state is set to true.
    self.duration = duration
    -- spawn it in the middle of the brick.
    self.x = brick.x + 16
    self.y = brick.y + 8


    -- set the velocity in the y direction.
    self.dy = dy == nil and dy or 50
    self.time_left = duration
    --[[
        0 = not in play
        1 = moving down the screen
        2 = collected / active, if the item becomes inactive then it is no longer shown in the GUI and it is also of course not in play.
    ]]
    self.state = 0
    --[[ so that when we're doing updates we can see if the paddle has hit it, since the parameter is passed by reference
        So this means that we automatically have the item itself.
    ]]
    self.paddle = paddle
end

function PowerUp:update(dt)
    local collides = false
    if self.state == 1 then
        self.y = self.y  + (dt * self.dy)
        collides = self:collides(self.paddle)
        if collides == true then
            if self.type == 5 then
                self.paddle:resize(1)
            end
            self.state = 2
        elseif self.y >= self.paddle.y then
            self.state = 0
        end
    elseif self.state == 2 then
        if self.duration ~= 0 then
            self.time_left = self.time_left - dt
        end
        if self.time_left <= 0  and self.duration >= 1 then
            if self.type == 5 then
                self.paddle:resize(-1)
            end
            self.state = 0
        end
    end
end

function PowerUp:collides(target)

    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other

    if self.x > target.x + target.width+1  or target.x > self.x + 15 then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other

    if self.y > target.y + target.height+1 or target.y > self.y + 15 then
        --printf("sy:%f ty:%f\n",math.floor(self.y),target.y+target.height + 2)
        return false
    end

    -- if the above aren't true, they're overlapping with something else.
    return true
end

function PowerUp:reset()
    self.x = VIRTUAL_WIDTH / 2
    self.y = 16
end

function PowerUp:render()
    if self.state == 1 then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
    end
end
--[[ This lists the sprites for the various powerups so that I can easily reference them later in the code.
The type is also their index in the graphics table to keep things simple.
1 = not used
2 = not used
3 = extra life
4 = ai control
5 = grow paddle one stage.
6 = shrink paddle one stage.
7 = unused
8 = glue
9 = multi-ball
10 = key
]]
function KeyPowerUp(brick,dy,paddle)
    return PowerUp(10,0,brick,paddle,dy)
end

function MultiBallPowerUp(brick,dy,paddle)
    return PowerUp(9,0,brick,paddle,dy)
end

function GluePowerUp(brick,dy,paddle)
    return PowerUp(8,0,brick,paddle,dy)
end
function GrowPowerUp(brick,dy,paddle)
    return PowerUp(5,30,brick,paddle,dy)
end
function LifePowerUp(brick,dy,paddle)
    return PowerUp(3,0,brick,paddle,dy)
end

function addLives(health)
    print(health)
    return health <= 4 and health +1 or health
end