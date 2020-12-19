--[[
	The Base State Machine Class
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

StateMachine = Class{}

function StateMachine:init(states)
	self.empty = {
		render = function()  end,
		handleInput = function()  end,
		update = function() end,
		enter = function()  end,
		exit = function()  end
	}
	self.states = states or {}
	self.current = self.empty
end

function StateMachine:change(newState, params)
	assert(self.states[newState])
	self.current:exit()
	self.current = self.states[newState]()
	self.current:enter(params)
end

function StateMachine:update(dt)
	self.current:update(dt)
end

function StateMachine:handleInput(key)
	self.current:handleInput(key)
end

function StateMachine:render()
	self.current:render()
end