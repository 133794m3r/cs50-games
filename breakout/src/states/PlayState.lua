--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.powerUps = params.power_ups
    self.recoverPoints = 5000
    self.powerup_tick = 4
    self.powerup_timer = 0
    self.movement_timer = 0
    ---- give ball random starting velocity
    --self.ball[1].dx = math.random(-200, 200)
    --self.ball[1].dy = math.random(-50, -60)
    self.balls:spawn()
    for key,value in pairs(self.powerUps) do
        self.powerUps[key].paddle = self.paddle
    end

end

function PlayState:update(dt)
    local life_lost=false
    self.movement_timer = self.movement_timer + dt
    if self.powerUps['key'].state == 2 then
        paused=true
    end

    if not self.paused then
        --if self.movement_timer >= 1 then
            for i,_ in pairs(self.powerUps) do
                self.powerUps[i]:update(dt)
            end
        --    self.movement_timer = 0
        --end

    end
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    self.balls:update(dt)
    self.balls:paddle_collision(self.paddle)

    local locked=0
    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        self.score,self.recoverPoints,self.health=self.balls:bricks(self.powerUps,brick,self.score,self.recoverPoints,self.health)

        if self:checkVictory() then
            gSounds['victory']:play()

            gStateMachine:change('victory', {
                level = self.level,
                paddle = self.paddle,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                ball = self.balls,
                recoverPoints = self.recoverPoints
            })
        end
        --for i,_ in pairs(self.balls.balls) do
        --    -- only check collision if we're in play
        --    if brick.inPlay and self.balls.balls[i]:collides(brick) then
        --
        --        -- add to score
        --        if brick.locked == false then
        --            self.score = self.score + (brick.tier * 200 + brick.color * 25)
        --        end
        --
        --
        --        -- trigger the brick's hit function, which removes it from play
        --        locked = brick:hit(self.powerUps)
        --        if locked then
        --            self.powerUps['key'].state = 0
        --        end
        --        if brick.powerup_collected then
        --            print(tostring(self.powerUps['key'].state))
        --            self.paused = true
        --        end
        --        -- if we have enough points, recover a point of health
        --        if self.score > self.recoverPoints then
        --            -- can't go above 3 health
        --            self.health = math.min(3, self.health + 1)
        --
        --            -- multiply recover points by 2
        --            self.recoverPoints = math.min(100000, self.recoverPoints * 2)
        --
        --            -- play recover sound effect
        --            gSounds['recover']:play()
        --        end
        --
        --        -- go to our victory screen if there are no more bricks left
        --        if self:checkVictory() then
        --            gSounds['victory']:play()
        --
        --            gStateMachine:change('victory', {
        --                level = self.level,
        --                paddle = self.paddle,
        --                health = self.health,
        --                score = self.score,
        --                highScores = self.highScores,
        --                ball = self.ball[i],
        --                recoverPoints = self.recoverPoints
        --            })
        --        end
        --
        --        --
        --        -- collision code for bricks
        --        --
        --        -- we check to see if the opposite side of our velocity is outside of the brick;
        --        -- if it is, we trigger a collision on that side. else we're within the X + width of
        --        -- the brick and should check to see if the top or bottom edge is outside of the brick,
        --        -- colliding on the top or bottom accordingly
        --        --
        --
        --        -- left edge; only check if we're moving right, and offset the check by a couple of pixels
        --        -- so that flush corner hits register as Y flips, not X flips
        --        if self.balls.balls[i].x + 2 < brick.x and self.balls.balls[i].dx > 0 then
        --
        --            -- flip x velocity and reset position outside of brick
        --            self.balls.balls[i].dx = -self.balls.balls[i].dx
        --            self.balls.balls[i].x = brick.x - 8
        --
        --            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
        --            -- so that flush corner hits register as Y flips, not X flips
        --        elseif self.balls.balls[i].x + 6 > brick.x + brick.width and self.balls.balls[i].dx < 0 then
        --
        --            -- flip x velocity and reset position outside of brick
        --            self.balls.balls[i].dx = -self.balls.balls[i].dx
        --            self.balls.balls[i].x = brick.x + 32
        --
        --            -- top edge if no X collisions, always check
        --        elseif self.balls.balls[i].y < brick.y then
        --
        --            -- flip y velocity and reset position outside of brick
        --            self.balls.balls[i].dy = -self.balls.balls[i].dy
        --            self.balls.balls[i].y = brick.y - 8
        --
        --            -- bottom edge if no X collisions or top collision, last possibility
        --        else
        --
        --            -- flip y velocity and reset position outside of brick
        --            self.balls.balls[i].dy = -self.balls.balls[i].dy
        --            self.balls.balls[i].y = brick.y + 16
        --        end
        --
        --        -- slightly scale the y velocity to speed up the game, capping at +- 150
        --        if math.abs(self.balls.balls[i].dy) < 150 then
        --            self.balls.balls[i].dy = self.balls.balls[i].dy * 1.02
        --        end
        --
        --        -- only allow colliding with one brick, for corners
        --        break
        --    end
        --end

    end
    --for i,_ in pairs(self.balls.balls) do
    --    -- if ball goes below bounds, revert to serve state and decrease health
    --    if self.balls.balls[i].y >= VIRTUAL_HEIGHT then
    --        self.health = self.health - 1
    --        gSounds['hurt']:play()
    --
    --        if self.health == 0 then
    --            gStateMachine:change('game-over', {
    --                score = self.score,
    --                highScores = self.highScores
    --            })
    --        else
    --            gStateMachine:change('serve', {
    --                paddle = self.paddle,
    --                bricks = self.bricks,
    --                health = self.health,
    --                score = self.score,
    --                highScores = self.highScores,
    --                level = self.level,
    --                recoverPoints = self.recoverPoints,
    --                power_ups = self.powerUps
    --            })
    --        end
    --    end
    --
    --end
    self.health,life_lost=self.balls:lives(self.health)
    if self.health == 0 then
        gStateMachine:change('game-over', {
            score = self.score,
            highScores = self.highScores
        })
    elseif life_lost then
        gStateMachine:change('serve', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            level = self.level,
            recoverPoints = self.recoverPoints,
            power_ups = self.powerUps
        })
        life_lost = false
    end
    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end



    self.paddle:render()
    --for i,_ in pairs(self.balls) do
    --    self.balls[i]:render()
    --end
    self.balls:render()
    renderScore(self.score)
    renderHealth(self.health)
    for i,powerup in pairs(self.powerUps) do
        self.powerUps[i]:render()
    end
    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end