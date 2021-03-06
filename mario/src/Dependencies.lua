--[[
	GD50
	Super Mario Bros. Remake

	Authors: Colton Ogden, Macarthur Inbody
	cogden@cs50.harvard.edu, 133794m3r@gmail.com

	-- Dependencies --

	A file to organize all of the global dependencies for our project, as
	well as the assets for our game, rather than pollute our main.lua file.
]]

--
-- libraries
--
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

--
-- our own code
--

-- utility
require 'src/constants'
require 'src/StateMachine'
require 'src/Util'

-- game states
require 'src/states/BaseState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'
require 'src/states/game/DeathState'
require 'src/states/game/WinState'

-- entity states
require 'src/states/entity/PlayerFallingState'
require 'src/states/entity/PlayerIdleState'
require 'src/states/entity/PlayerJumpState'
require 'src/states/entity/PlayerWalkingState'

require 'src/states/entity/snail/SnailChasingState'
require 'src/states/entity/snail/SnailIdleState'
require 'src/states/entity/snail/SnailMovingState'

-- general
require 'src/Animation'
require 'src/Entity'
require 'src/GameObject'
require 'src/GameLevel'
require 'src/LevelMaker'
require 'src/Player'
require 'src/Snail'
require 'src/Tile'
require 'src/TileMap'

-- The player objects that are rendered.
require 'src/PlayerLives'
require 'src/PlayerCoins'

gSounds = {
	['jump'] = love.audio.newSource('sounds/jump.wav','static'),
	['death'] = love.audio.newSource('sounds/death.wav','static'),
	['music'] = love.audio.newSource('sounds/music.wav','static'),
	['powerup-reveal'] = love.audio.newSource('sounds/powerup-reveal.wav','static'),
	['pickup'] = love.audio.newSource('sounds/pickup.wav','static'),
	['empty-block'] = love.audio.newSource('sounds/empty-block.wav','static'),
	['kill'] = love.audio.newSource('sounds/kill.wav','static'),
	['kill2'] = love.audio.newSource('sounds/kill2.wav','static')
}

gTextures = {
	['tiles'] = love.graphics.newImage('graphics/tiles.png'),
	['toppers'] = love.graphics.newImage('graphics/tile_tops.png'),
	['bushes'] = love.graphics.newImage('graphics/bushes_and_cacti.png'),
	['jump-blocks'] = love.graphics.newImage('graphics/jump_blocks.png'),
	['backgrounds'] = love.graphics.newImage('graphics/backgrounds.png'),
	['green-alien'] = love.graphics.newImage('graphics/green_alien.png'),
	['blue-alien'] = love.graphics.newImage('graphics/blue_alien.png'),
	['creatures'] = love.graphics.newImage('graphics/creatures.png'),
	['flags'] = love.graphics.newImage('graphics/flags.png'),
	['gems'] = love.graphics.newImage('graphics/gems.png'),
	['locks'] = love.graphics.newImage('graphics/keys_and_locks.png'),
	['coins_and_bombs'] = love.graphics.newImage('graphics/coins_and_bombs.png'),
	['backgrounds2'] = love.graphics.newImage('graphics/backgrounds2.png')
}

gFrames = {
	['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),
	['toppers'] = GenerateQuads(gTextures['toppers'], TILE_SIZE, TILE_SIZE),
	['bushes'] = GenerateQuads(gTextures['bushes'], 16, 16),
	['jump-blocks'] = GenerateQuads(gTextures['jump-blocks'], 16, 16),
	['backgrounds'] = GenerateQuads(gTextures['backgrounds'], 256, 128),
	['backgrounds2'] = GenerateQuads(gTextures['backgrounds2'], 256,128),
	['green-alien'] = GenerateQuads(gTextures['green-alien'], 16, 20),
	['green-alien-heads'] = GenerateQuads(gTextures['green-alien'],16,14),
	['blue-alien'] = GenerateQuads(gTextures['blue-alien'],16,20),
	['creatures'] = GenerateQuads(gTextures['creatures'], 16, 16),
	['gems'] = GenerateQuads(gTextures['gems'], 16, 16),
	['locks'] = GenerateQuads(gTextures['locks'],16,16),
	['poles'] = GeneratePoleTiles(gTextures['flags'],16,48),
	['flags'] = GenerateFlagTiles(gTextures['flags'],16,16),
	['coins_and_bombs'] = GenerateQuads(gTextures['coins_and_bombs'],16,16)
}
-- these need to be added after gFrames is initialized because they refer to gFrames from within
gFrames['tilesets'] = GenerateTileSets(gFrames['tiles'], 
	TILE_SETS_WIDE, TILE_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFrames['toppersets'] = GenerateTileSets(gFrames['toppers'], 
	TOPPER_SETS_WIDE, TOPPER_SETS_TALL, TILE_SET_WIDTH, TILE_SET_HEIGHT)

gFonts = {
	['small'] = love.graphics.newFont('fonts/font.ttf', 8),
	['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
	['large'] = love.graphics.newFont('fonts/font.ttf', 32),
	['title'] = love.graphics.newFont('fonts/ArcadeAlternate.ttf', 32)
}