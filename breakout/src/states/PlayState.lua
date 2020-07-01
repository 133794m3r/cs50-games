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
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.powerUps = params.powerups
    self.recoverPoints = 5000
    self.powerup_tick = 4
    self.powerup_timer = 0
    self.movement_timer = 0
    self.render_timer = 0
    self.balls:spawn()
    for key,value in pairs(self.powerUps) do
        self.powerUps[key].paddle = self.paddle
    end
    self.min_dt = 1/60
    self.render_timer = love.timer.getTime()
end

function PlayState:update(dt)
    self.render_timer = self.render_timer + self.min_dt
    local life_lost=false
    --self.movement_timer = self.movement_timer + dt
    if self.powerUps['key'].state == 2 then
        paused=true
    end

    if not self.paused then
        for i,_ in pairs(self.powerUps) do
            self.powerUps[i]:update(dt)
            --if self.powerUps[i].state ~= 0 then
            --    print('i',tostring(i),'state',tostring(self.powerUps[i].state),'type',tostring(self.powerUps[i].type))
            --end
            if self.powerUps[i].state == 2 and self.powerUps[i].type == 9 then
                print('collected multiball')
                self.balls:add(3)
                self.powerUps[i].state = 0
            end
        end


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
            powerups = self.powerUps
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
    --local cur_time = love.timer.getTime()
    --if self.render_timer <= cur_time then
    --    self.render_timer = cur_time
    --else
    --    love.timer.sleep(self.render_timer - cur_time)
    --end


    self.paddle:render()
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
    --displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    -- Check if they're running >=love11. If so we use the other colors.
    love.graphics.setColor(1,1,1,1)

    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end