--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class { __includes = BaseState }
function ScoreState:init()
    self.award_0 = love.graphics.newImage('imgs/award_0.png')
    self.award_1 = love.graphics.newImage('imgs/award_1.png')
    self.award_2 = love.graphics.newImage('imgs/award_2.png')
    self.tier_1 = 5
    self.tier_2 = 10
    self.tier_3 = 15
end
--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.was_pressed('enter') or love.keyboard.was_pressed('return') then
        gStateMachine:change('countdown')
    elseif love.keyboard.was_pressed("d") then
        gCurrentDifficulty = not gCurrentDifficulty
    end

end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappy_font)
    love.graphics.printf('Oof! You lost!', 0, 40, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(medium_font)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 80, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to Play Again!', 0, 205, VIRTUAL_WIDTH, 'center')
    local difficulty = (gCurrentDifficulty) and "hard" or "easy"
    love.graphics.printf("Difficulty: " .. difficulty, 0, 240, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(flappy_font)
    love.graphics.printf("Award ", 0, 110, VIRTUAL_WIDTH, 'center')
    local modifier = (gCurrentDifficulty) and 2 or 1

    love.graphics.setFont(medium_font)
    self.score = 10
    if self.score <= self.tier_1 * modifier then
        --show it as red text
        love.graphics.print({ { 1, 0, 0 }, "\"You Tried!\"" }, VIRTUAL_WIDTH / 2 - 80, 160)
        love.graphics.draw(self.award_0, VIRTUAL_WIDTH / 2 + 40, 150)

    elseif self.score <= self.tier_2 * modifier then
        --show it as yellow text
        love.graphics.print({ { 1, 1, 0 }, "\"Carry on my Flapping son!\"" }, VIRTUAL_WIDTH / 2 - 180, 160)
        love.graphics.draw(self.award_1, VIRTUAL_WIDTH / 2 + 40, 150)

    elseif self.score >= self.tier_2 * modifier then
        --show it as green text
        love.graphics.print({ { 0, 1, 0 }, "\"Flapmaster!\"" }, VIRTUAL_WIDTH / 2 - 90, 160)
        love.graphics.draw(self.award_2, VIRTUAL_WIDTH / 2 + 40, 150)
    end

end