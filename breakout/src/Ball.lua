--[[
    GD50
    Breakout Remake

    -- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a ball which will bounce back and forth between the sides
    of the world space, the player's paddle, and the bricks laid out above
    the paddle. The ball can have a skin, which is chosen at random, just
    for visual variety.
]]

Ball = Class{}

function Ball:init(skin,dy,dx,x,y)
    -- simple positional and dimensional variables
    self.width = 8
    self.height = 8

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = dy
    self.dx = dx
    self.x = x == nil and  VIRTUAL_WIDTH / 2 - 2 or x
    self.y = y == nil and VIRTUAL_HEIGHT / 2 - 2 or y
    -- this will effectively be the color of our ball, and we will index
    -- our table of Quads relating to the global block texture using this
    self.skin = skin
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Ball:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- allow ball to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end
end

function Ball:render()
    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin],
        self.x, self.y)
end

MultiBall = Class{}

function MultiBall:init(num_balls,dy,dx,skin)
    self.num_balls = num_balls == nil and 1 or num_balls
    self.balls = {}

    for i=1,self.num_balls do
        self.balls[i] = Ball(skin,dy,dx)
    end

end
function MultiBall:add(number)

    if self.num_balls < 5 then
        local additional = math.min(number,(5 - self.num_balls))
        additional = self.num_balls + additional
        local x = self.balls[1].x
        local y = self.balls[1].y
        for i=self.num_balls,additional do
            local dx = math.random(5, 100) * (math.random(2) == 1 and 1 or -1 )
            local dy = math.random(3,30) * (math.random(2) == 1 and 1 or -1 )
            self.balls[i]=Ball(math.random(7),dx,dy,x,y)
        end

        self.num_balls = additional
    end
end

function MultiBall:track(paddle)
    for _,ball in pairs(self.balls) do
        ball.x = paddle.x + (paddle.width / 2) - 4
        ball.y = paddle.y - 8
    end
end
function MultiBall:reset()
    for _,ball in pairs(self.balls) do
        ball.reset()
    end
end


function MultiBall:spawn()
    -- give ball random starting velocity
    for _,ball in pairs(self.balls) do
        ball.dx = math.random(30,200) * (math.random(2) == 1 and -1 or 1)
        ball.dy = math.random(10,60) * (math.random(2) == 1 and -1 or 1)
    end
end
function MultiBall:paddle_collision(paddle)
    for i,ball in pairs(self.balls) do
        if self.balls[i]:collides(paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.balls[i].y = paddle.y - 8
            self.balls[i].dy = -self.balls[i].dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.balls[i].x < paddle.x + (paddle.width / 2) and paddle.dx < 0 then
                self.balls[i].dx = -50 + -(8 * (paddle.x + paddle.width / 2 - self.balls[i].x))

                -- else if we hit the paddle on its right side while moving right...
            elseif self.balls[i].x > paddle.x + (paddle.width / 2) and paddle.dx > 0 then
                self.balls[i].dx = 50 + (8 * math.abs(paddle.x + paddle.width / 2 - self.balls[i].x))
            end

            gSounds['paddle-hit']:play()
        end

    end
end

function MultiBall:update(dt)
    for _,ball in pairs(self.balls) do
        ball:update(dt)
    end
end

function MultiBall:render()
    for _,ball in pairs(self.balls) do
        love.graphics.draw(gTextures['main'], gFrames['balls'][ball.skin],
                ball.x, ball.y)
    end
end

function MultiBall:lives(health)
    local life_lost = false

    for i,ball in pairs(self.balls) do

        -- if ball goes below bounds, revert to serve state and decrease health
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.balls,i)
            self.num_balls = self.num_balls - 1
            if self.num_balls <= 0 then
                health = health - 1
                gSounds['hurt']:play()
                return health,true
            end

            end


    end
    return health,life_lost

end

function MultiBall:bricks(power_ups,brick,score,recoverPoints,health,num_locked,level)
    local locked = false
    local num_unlocked = 0
    --for i=1,self.num_balls do
    for _,ball in pairs(self.balls) do
        -- only check collision if we're in play
        --printf('i:%d balls[i].skin:%d\n',i,self.balls[i].skin)
        if brick.inPlay and ball:collides(brick) then

            -- add to score
            if brick.locked == nil then
                score = score + math.floor((brick.tier+level/15) * 200 + (brick.color+level/15) * 25)
            elseif brick.locked == false then
                score = score + math.floor(100 + ((brick.tier+level/15) * 200 + (brick.color+level/15) * 25) + math.floor(score * 0.05))
            end

            -- trigger the brick's hit function, which removes it from play
            locked = brick:hit(power_ups,num_locked)
            if locked then
                for _,power_up in pairs(power_ups) do
                    if power_up.type == 5 then
                        power_up.state = 0
                        num_locked = num_locked > 0 and num_locked - 1 or num_locked
                        break
                    end
                end
                --power_ups['key'].state = 0
                --num_locked = num_locked  > 0 and num_locked -1 or num_locked
            end

            -- if we have enough points, recover a point of health
            if score > recoverPoints then
                -- can't go above 3 health
                health = math.min(3, health + 1)

                -- multiply recover points by 2
                recoverPoints = math.min(100000, recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left


            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if ball.x + 2 < brick.x and ball.dx > 0 then

                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x - 8

                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
            elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x + 32

                -- top edge if no X collisions, always check
            elseif ball.y < brick.y then

                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y - 8

                -- bottom edge if no X collisions or top collision, last possibility
            else

                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(ball.dy) < 150 then
                ball.dy = ball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
    end
    --printf("score:%d rp:%d health:%d\n",score,recoverPoints,health)
    return score,recoverPoints,health,num_locked
end