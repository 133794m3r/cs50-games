--[[
	Assets file

    Copyright (C) 2020  Macarthur David Inbody <admin-contact@transcendental.us>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

-- fonts
gFonts = {
	['title'] = love.graphics.newFont(64),
	['menu'] = love.graphics.newFont(48),
	['sm'] = love.graphics.newFont(20),
	['md'] = love.graphics.newFont(26),
	['lg'] = love.graphics.newFont(36),
	['mono_sm'] = love.graphics.newFont('res/source_code_pro.otf',16),
	['mono_md'] = love.graphics.newFont('res/source_code_pro.otf',24),
	['mono_lg'] = love.graphics.newFont('res/source_code_pro.otf',36),
	['mono_xl'] = love.graphics.newFont('res/source_code_pro.otf',52)
}


-- music
--[[
Music is what it's used for, then next line is link to OGA page, and the submitter's name

Chip Bit Danger will be used for level 14+ on Endless mode/final level of marathon aka level 14.
https://opengameart.org/content/chip-bit-danger Sudocolon

for game over music.
https://opengameart.org/content/this-game-is-over mccartneytm

Oribital Colossus will be Time Attack
https://opengameart.org/content/space-boss-battle-theme Matthew Pablo

Title screen/menu music/high score screen music.
https://opengameart.org/content/twister-tetris poinl

Marathon Mode maybe
https://opengameart.org/content/chiptune-techno Nicole Marie T

Endless Mode
https://opengameart.org/content/let-the-games-begin-0 section31
]]

gMusic ={
	['title_music'] = love.audio.newSource('res/music/Twister Tetris.mp3','stream'),
	['sprint_theme'] = love.audio.newSource('res/music/Orbital Colossus.mp3','stream'),
	['normal_theme'] = love.audio.newSource('res/music/S31-Let the Games Begin.ogg','stream'),
	['final_countdown'] = love.audio.newSource('res/music/Chip Bit Danger.mp3','stream'),
	['game_over'] = love.audio.newSource('res/music/ThisGameIsOver.ogg','stream'),
}
for k,v in pairs(gMusic) do
	-- the default volume for some of them is a bit too much. The db range needs to be normalized.
	gMusic[k]:setVolume(0.75)
	-- make sure they all are set to loop.
	gMusic[k]:setLooping(true)
end

--[[
Sound effects came from this pack but renamed

https://opengameart.org/content/rpg-sound-pack artisticdude
rotate and the block drop sounds.
]]
gSFX = {
	['rotate'] = love.audio.newSource('res/sfx/rotate.wav','static'),
	['drop'] = love.audio.newSource('res/sfx/drop.wav','static'),
}