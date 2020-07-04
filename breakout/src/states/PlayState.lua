--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden, Macarthur Inbody
    cogden@cs50.harvard.edu, mdi2455@email.vccs.edu

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
    self.num_bricks = #self.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.num_locked = params.num_locked
    self.power_ups = params.power_ups
    self.recoverPoints = 5000
    self.powerup_tick = 20
    self.powerup_timer = 0
    self.movement_timer = 0
    self.render_timer = 0
    self.balls:spawn()
    for key,value in pairs(self.power_ups) do
        self.power_ups[key].paddle = self.paddle
    end
    self.min_dt = 1/60
    self.render_timer = love.timer.getTime()
end

function PlayState:update(dt)
    --printf("key_state:%d\n",self.power_ups['key'].state)
    self.render_timer = self.render_timer + self.min_dt
    local life_lost=false
    self.powerup_timer = self.powerup_timer + dt

    if not self.paused then
        for i,_ in pairs(self.power_ups) do
            self.power_ups[i]:update(dt)
            --if self.power_ups[i].state ~= 0 then
            --    print('i',tostring(i),'state',tostring(self.power_ups[i].state),'type',tostring(self.power_ups[i].type))
            --end
            if self.power_ups[i].state == 2 then
                if self.power_ups[i].type == 9 then
                    self.balls:add(3)
                    self.power_ups[i].state = 0
                elseif self.power_ups[i].type == 3 then
                    self.health = addLives(self.health)
                    self.power_ups[i].state = 0
                end
            end

        end

    end

    if self.powerup_tick <= self.powerup_timer and self.num_locked >= 1 and self.power_ups['key'].state == 0 then
        self.power_ups['key'].state = 1
        self.power_ups['key']:reset()
        self.powerup_timer = 0
        self.powerup_tick = 90
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
        self.score,self.recoverPoints,self.health,self.num_locked=self.balls:bricks(self.power_ups,brick,self.score,self.recoverPoints,self.health,self.num_locked)

        if self:checkVictory() then
            gSounds['victory']:play()
            self.paddle:reset()
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

    end
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
            num_locked = self.num_locked,
            power_ups = self.power_ups
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
    self.balls:render()
    renderScore(self.score)
    renderHealth(self.health)
    displayPowerUPs(self.power_ups)
    for i,powerup in pairs(self.power_ups) do
        self.power_ups[i]:render()
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