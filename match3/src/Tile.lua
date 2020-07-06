--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Authors: Colton Ogden, Macarthur Inbody
    cogden@cs50.harvard.edu, admin-contact@transcendental.us

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety,aborted,shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    self.shiny = shiny ~= nil and shiny or false
    self.color = color
    self.variety = variety
    self.psystem = love.graphics.newParticleSystem(gTextures['shine'], 64)
    self.psystem:setEmissionRate(10)
    self.psystem:setSizeVariation(1)
    self.psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
    self.psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency
end

function Tile:render(x, y)
    -- draw shadow
    love.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
    self.x + x, self.y + y)
    love.graphics.setColor(255,255,0,255)
    if self.shiny then
        -- the "shine" sprite denoting it as 'shiny' is drawn.
        love.graphics.draw(gTextures['shine'],self.x+x+2,self.y+y+2,0,0.2,0.2)
    end
    -- reset the colors.
    love.setColor(255,255,255,255)
end
