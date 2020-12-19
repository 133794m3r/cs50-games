--[[
    Misc Functions

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

--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
--- Recursively prints a table.
--- @param t table The table we're going to print. Also does 'classes'.
function print_r (t)
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

---Sets the color used for drawing.
---@param red number @The amount of red.
---@param green number @The amount of green.
---@param blue number @The amount of blue.
---@param alpha number @The amount of alpha. The alpha value will be applied to all subsequent draw operations, even the drawing of an image.
---@overload fun(rgba:table):void
function love.setColor(red,green,blue,alpha)
    if alpha == nil then
        alpha = 255
    end
    if LOVE_VERSION_11 then
        if type(red) == 'table' then
            r=red[1]/255
            g=red[2]/255
            b=red[3]/255
            a=red[4]/255
            love.graphics.setColor(r,g,b,a)
        else
        --end
            love.graphics.setColor(red/255,green/255,blue/255,alpha/255)
        end
    else
        if type(red) == 'table' then
            print_r(red)
            love.graphics.setColor(red)
        else
            love.graphics.setColor(red,green,blue,alpha)

        end
    end
end

LOVE_VERSION_11 = love.getVersion()
--- Sprintf function. Takes input numbers and foramts into string.
--- @param s string the format string. Followed by the strings to pass to it.
--- @return string the formatted string.
function sprintf(s,...)
    return s:format(...)
end

--- Printf function.
--- @param s string the format string. Followed by the strings to pass to it.
function printf(s,...)
    return io.write(s:format(...))
end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
