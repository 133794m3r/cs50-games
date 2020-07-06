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
    self.shiny_toggle = 0
end

function Tile:render(x, y)
    local toggle = math.floor(144 * 2)
    -- draw shadow
    love.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)
    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
    self.x + x, self.y + y)
    love.graphics.setColor(255,255,0,255)
    if self.shiny then
        love.graphics.setLineWidth(2)
        love.graphics.line(self.x+x+2,self.y+y+16,self.x+x+28,self.y+y+16)
    end
    love.setColor(255,255,255,255)
end

