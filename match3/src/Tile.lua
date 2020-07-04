--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

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
end

function Tile:render(x, y)
    
    -- draw shadow
    love.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end

function Tile:renderShiny(x,y)
    love.setColor(255, 0, 0, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
                self.x + x, self.y + y)
    love.setColor(255,255,255,255)
end