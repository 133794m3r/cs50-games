--[[
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

SaveData = Class{}
function SaveData:init(params)
	params = params or {}
	-- this is so that I can know if the save data needs to be updated for a future purpose mostly.
	self.version = params.version or 1
	self.difficulty = params.difficulty or 'hard'
	-- it holds the high score table as part of itself.
	self.highScores = params.highScores or HighScoreTable()
end

function SaveData:getRankInfo(mode,index)
	return self.highScores[mode][self.difficulty][index]
end

function SaveData:getRanks(mode)
	return self.highScores[mode][self.difficulty]
end

function SaveData:getScore(mode,index)
	return self.highScores[mode][self.difficulty][index].score
end

function SaveData:addScore(mode,index,params)
	table.insert(self.highScores[mode][self.difficulty],index,params)
	table.remove(self.highScores[mode][self.difficulty],#self.highScores[mode][self.difficulty])
end

function SaveData:save()
	-- this is just for testing to see how big the file will be.
	--local str = bitser.dumps(self)
	--print(#str)
	bitser.dumpLoveFile('savedata.dat',self)
end
