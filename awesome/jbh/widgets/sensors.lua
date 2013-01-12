local setmetatable = setmetatable
local widget = widget
local timer = timer
local io = { popen = io.popen }
local string = { match = string.match }
local print = print
local table = { insert = table.insert, concat = table.concat }
local tonumber = tonumber
local math = { floor = math.floor }
local wibox = require("wibox")

module("jbh.widgets.sensors")

local function new(timeout)
	local w = wibox.widget.textbox()
	t = timer { timeout = timeout or 10 }
	t:connect_signal("timeout", function()
		local f = io.popen("sensors k10temp-pci-*")
		local temp = {}
		for line in f:lines() do
			local v = string.match(line, "[%w%s]+:[%s%+-]*([%d]+%.[%d]+)")
			if v then
				table.insert(temp, tonumber(v))
			end
		end
		w:set_text(table.concat(temp, "/") .. "°C")
	end)
	t:start()
	t:emit_signal("timeout")
	return w
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
