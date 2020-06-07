--[[
    TitleScreenState Class
    
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The TitleScreenState is the starting screen of the game, shown on startup. It should
    display "Press Enter" and also our highest score.
]]

TitleScreenState = Class { __includes = BaseState }

function TitleScreenState:init()
    -- nothing
end

function TitleScreenState:update(dt)
    if love.keyboard.was_pressed('enter') or love.keyboard.was_pressed('return') then
        -- reseed the PRNG again.
        math.randomseed(os.time() + love.timer.getAverageDelta())
        gStateMachine:change('countdown')
    elseif love.keyboard.was_pressed("d") then
        gCurrentDifficulty = not gCurrentDifficulty
    end
end

function TitleScreenState:render()
    love.graphics.setFont(flappy_font)
    love.graphics.printf('Fifty Bird', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(medium_font)
    love.graphics.printf('Press Enter', 0, 100, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("To Limit FPS to 60. Hit the letter \"t\"", 0, 150, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("To toggle difficulty, press the letter \"d\".", 0, 190, VIRTUAL_WIDTH, "center");
    local current_difficulty = (gCurrentDifficulty) and "hard" or "easy";
    love.graphics.print("Current Difficulty: " .. current_difficulty, VIRTUAL_WIDTH - 200, 5)
end