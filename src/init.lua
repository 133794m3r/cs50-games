--[[
	The dependency file
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

-- importing module
Class = require 'lib/class'
bitser = require 'lib/bitser'
Timer = require 'lib/timer'


-- misc utilities and such
require 'src/util'
require 'src/misc'
require 'src/state_machine'


-- asset file loader
require 'src/assets'


-- the base state
require 'src/base_state'


-- menus
require 'src/menus/Title'
require 'src/menus/MainMenu'
require 'src/menus/CheckScores'
require 'src/menus/HighScoreMenu'
require 'src/menus/SettingsMenu'
require "src/menus/HelpScreen"


-- base game mode
require 'src/modes/core_logic'

-- derived game modes
require 'src/modes/Marathon'
require 'src/modes/Endless'
require 'src/modes/TimeAttack'


-- classes
require 'src/classes/HighScore'
require 'src/classes/SaveData'

-- registering classes that need to be serialized.
HighScoreTable = bitser.registerClass('HighScoreTable',HighScoreTable)
SaveData = bitser.registerClass('SaveData',SaveData)