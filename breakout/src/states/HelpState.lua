--[[
    GD50
    Breakout Remake

    -- HelpState Class --

    Author: Macarthur Inbody
    admin-contact.vss.edu

    This state is for when they're wanting to know what the various "powerups" do. It also will show them what their
    lives are worth along with some other basic information.
]]
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
-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
HelpState = Class{__includes = BaseState}

function HelpState:enter(params)
	self.highScores = params.highScores
end

function HelpState:update(dt)
	if love.keyboard.wasPressed('escape') or love.keyboard.wasPressed('enter') then
		gStateMachine:change('start',{
			highScores = self.highScores
		})
	end
end
-- Each character takes ~height*1.5(or there abouts) in width.
function HelpState:render()
	love.setColor(255,255,255,255)
	love.graphics.setFont(gFonts['help'])
	love.graphics.printf('Breakout Help Screen',0, 5,VIRTUAL_WIDTH,'center')
	love.graphics.setFont(gFonts['medium'])
	love.graphics.printf('Hit escape to go back to the main menu.',0,40,VIRTUAL_WIDTH,'center')
	-- PowerUps/Icons section
	love.graphics.print('Key',15,75)
	love.graphics.draw(gTextures['main'], gFrames['powerups'][10], 50, 75)
	love.graphics.print('MultiBall',150,75)
	love.graphics.draw(gTextures['main'],gFrames['powerups'][9],222,75)
	love.graphics.print('PaddleGrow',15,120)
	love.graphics.draw(gTextures['main'],gFrames['powerups'][5],115,120)
	love.graphics.print("ExtraLife",280,120)
	love.graphics.draw(gTextures['main'],gFrames['powerups'][3],356,120)
	-- details section
	love.graphics.setFont(gFonts['small'])
	love.graphics.print("Unlocks locked brick.",15,93)
	love.graphics.print("Adds 2 more balls (up to 5) to the field.",150,93)
	love.graphics.print("Increases the paddle size up to max size for 30s",15,138)
	love.graphics.print("Adds an extra life, If total < 5",280,138)
end
