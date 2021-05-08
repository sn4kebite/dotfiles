local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
awful.rules =  require("awful.rules")
awful.remote =  require("awful.remote")
local beautiful = require("beautiful")
local wibox = require("wibox")
local vicious = require("vicious")

local jbh = require("jbh")

beautiful.init("/home/snakebite/.config/awesome/theme.lua")

local function set_wallpaper(s)
	gears.wallpaper.maximized("/home/snakebite/wallpaper." .. s.index .. ".png", s, true)
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(set_wallpaper)

config = {}

widgets = {}
config.layouts = {
	--awful.layout.suit.tile.left,
	--awful.layout.suit.tile,
	--awful.layout.suit.tile.top,
	--awful.layout.suit.tile.bottom,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	--awful.layout.suit.magnifier,
	--awful.layout.suit.floating
}
widgets.taglist = {}
--widgets.promptbox = {}
widgets.taglist.buttons = awful.util.table.join(
	awful.button({}, 1, function(t) t:view_only() end),
	awful.button({"Mod4"}, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({"Mod4"}, 3, awful.client.toggletag),
	awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
	awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
)

widgets.tasklist = {}
widgets.tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, function(c) if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end client.focus = c; c:raise() end),
	awful.button({}, 4, function() awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),
	awful.button({}, 5, function() awful.client.focus.byidx(1) if client.focus then client.focus:raise() end end)
)

widgets.systray = wibox.widget.systray()

widgets.datewidget = wibox.widget.textbox()
vicious.register(widgets.datewidget, vicious.widgets.date, "<span color='" .. beautiful.fg_focus .. "'>%d.%m.%Y %T</span>", 1)

--widgets.cpugraph = awful.widget.graph()
widgets.cpugraph = wibox.widget.graph()
widgets.cpugraph:set_width(50)
widgets.cpugraph:set_height(14)
widgets.cpugraph:set_background_color(beautiful.bg_normal)
widgets.cpugraph:set_color("#AECF96")
vicious.register(widgets.cpugraph, vicious.widgets.cpu, "$1")

local cpu_total = {}
local cpu_active = {}
cpugraph_t = awful.tooltip({
	timer_function = function()
		-- The following lines are mostly copy-paste from vicious' cpu-widget.

		local cpu_lines = {}

		-- Get CPU stats
		local f = io.open("/proc/stat")
		for line in f:lines() do
			if string.sub(line, 1, 3) ~= "cpu" then break end

			cpu_lines[#cpu_lines+1] = {}

			for i in string.gmatch(line, "[%s]+([^%s]+)") do
				table.insert(cpu_lines[#cpu_lines], i)
			end
		end
		f:close()

		-- Ensure tables are initialized correctly
		for i = #cpu_total + 1, #cpu_lines do
			cpu_total[i]  = 0
			cpu_active[i] = 0
		end

		local s = {}
		for i, v in ipairs(cpu_lines) do
			-- Calculate totals
			local total_new = 0
			for j = 1, #v do
				total_new = total_new + v[j]
			end
			local active_new = total_new - (v[4] + v[5])

			-- Calculate percentage
			local diff_total  = total_new - cpu_total[i]
			local diff_active = active_new - cpu_active[i]

			if diff_total == 0 then diff_total = 1E-6 end
			table.insert(s, string.format("%.2f %%", (diff_active / diff_total) * 100))

			-- Store totals
			cpu_total[i]   = total_new
			cpu_active[i]  = active_new
		end
		return table.concat(s, "\n")
	end,
})
cpugraph_t:add_to_object(widgets.cpugraph)

widgets.memgraph = wibox.widget.graph()
widgets.memgraph:set_width(50)
widgets.memgraph:set_height(14)
widgets.memgraph:set_background_color(beautiful.bg_normal)
widgets.memgraph:set_border_color(nil)
widgets.memgraph:set_color("#FF5656")
vicious.register(widgets.memgraph, vicious.widgets.mem, "$1")

memgraph_t = awful.tooltip({
	timer_function = function()
		local f = io.popen("awk '{print $2}' < /proc/meminfo")
		local total = f:read()
		local free = f:read()
		local used = total - free
		total = total / 2^10
		free = free / 2^10
		used = used / 2^10
		return string.format("Used: %.2f MB (%.f %%)\nFree: %.2f MB (%.f %%)\nTotal: %.2f MB",
			used, used / total * 100, free, free / total * 100, total)
	end,
})
memgraph_t:add_to_object(widgets.memgraph)

widgets.temp = jbh.widgets.sensors("k10temp-pci-*", 5)

widgets.net = wibox.widget.textbox()
vicious.register(widgets.net, vicious.widgets.net, '<span color="#408040">${enp2s0 down_kb}</span> / <span color="#804040">${enp2s0 up_kb}</span>')

icons = {}

icons.separator = wibox.widget.imagebox()
icons.separator:set_image(beautiful.widget_separator)

icons.cpu = wibox.widget.imagebox()
icons.cpu:set_image(beautiful.widget_cpu)

icons.mem = wibox.widget.imagebox()
icons.mem:set_image(beautiful.widget_mem)

icons.down = wibox.widget.imagebox()
icons.down:set_image(beautiful.widget_down)

icons.up = wibox.widget.imagebox()
icons.up:set_image(beautiful.widget_up)

icons.temp = wibox.widget.imagebox()
icons.temp:set_image(beautiful.widget_temp)

statusbar = {}

awful.screen.connect_for_each_screen(function(s)
	s.widgets = {}
	s.widgets.layoutbox = awful.widget.layoutbox(s.index)
	s.widgets.layoutbox:buttons(awful.util.table.join(
		awful.button({}, 1, function() awful.layout.inc(config.layouts, 1) end),
		awful.button({}, 3, function() awful.layout.inc(config.layouts, -1) end)
	))

	awful.tag({'1', '2', '3', '4', '5', '6', '7', '8', '9'}, s, config.layouts[s.index == 3 and 2 or 1])

	s.widgets.taglist = awful.widget.taglist(s.index, awful.widget.taglist.filter.all, widgets.taglist.buttons)
	s.widgets.tasklist = awful.widget.tasklist(s.index, awful.widget.tasklist.filter.currenttags, widgets.tasklist.buttons)

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(s.widgets.taglist)

	local right_layout = wibox.layout.fixed.horizontal()
	if s.index == 1 then
		right_layout:add(icons.down)
		right_layout:add(widgets.net)
		right_layout:add(icons.up)
		right_layout:add(icons.separator)
		right_layout:add(icons.temp)
		right_layout:add(widgets.temp)
		right_layout:add(icons.separator)
		right_layout:add(icons.mem)
		right_layout:add(widgets.memgraph)
		right_layout:add(icons.separator)
		right_layout:add(icons.cpu)
		right_layout:add(widgets.cpugraph)
		right_layout:add(icons.separator)
		right_layout:add(widgets.systray)
		right_layout:add(icons.separator)
		right_layout:add(widgets.datewidget)
	end
	right_layout:add(s.widgets.layoutbox)

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(s.widgets.tasklist)
	layout:set_right(right_layout)

	statusbar[s.index] = awful.wibar({position = "top", screen = s.index, height = 14})
	statusbar[s.index]:set_widget(layout)
end)

globalkeys = awful.util.table.join(
	awful.key({"Mod4"}, "Left", awful.tag.viewprev),
	awful.key({"Mod4"}, "Right", awful.tag.viewnext),
	awful.key({"Mod4"}, "k", function() awful.client.focus.byidx(1) if client.focus then client.focus:raise() end end),
	awful.key({"Mod4"}, "j", function() awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),
	awful.key({"Mod4", "Shift"}, "k", function() awful.client.swap.byidx(1) end),
	awful.key({"Mod4", "Shift"}, "j", function() awful.client.swap.byidx(-1) end),
	awful.key({"Mod4", "Control"}, "k", function() awful.screen.focus_relative(1) end),
	awful.key({"Mod4", "Control"}, "j", function() awful.screen.focus_relative(-1) end),
	awful.key({"Mod4"}, "u", awful.client.urgent.jumpto),
	awful.key({"Mod4"}, "Tab",
		function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),
	awful.key({"Mod4"}, "l", function() awful.tag.incmwfact(0.05) end),
	awful.key({"Mod4"}, "h", function() awful.tag.incmwfact(-0.05) end),
	awful.key({"Mod4", "Shift"}, "h", function() awful.tag.incnmaster(1, nil, true) end),
	awful.key({"Mod4", "Shift"}, "l", function() awful.tag.incnmaster(-1, nil, true) end),
	awful.key({"Mod4", "Control"}, "h", function() awful.tag.incncol(1, nil, true) end),
	awful.key({"Mod4", "Control"}, "l", function() awful.tag.incncol(-1, nil, true) end),
	awful.key({"Mod4"}, "space", function() awful.layout.inc(config.layouts, 1) end),
	awful.key({"Mod4", "Shift"}, "space", function() awful.layout.inc(config.layouts, -1) end),
	awful.key({"Mod4"}, "r", function () awful.spawn("rofi -show drun") end),
	awful.key({"Mod4"}, "F12", function () awful.spawn("rofi -show window") end),
	awful.key({"Mod4", "Control"}, "r", awesome.restart),
	awful.key({"Mod4", "Control"}, "q", awesome.quit),

	-- Spawn stuff
	--awful.key({"Mod4"}, "Return", function() awful.spawn("urxvt") end),
	awful.key({"Mod4"}, "Return", function() awful.spawn("alacritty") end),
	--awful.key({}, "XF86Tools", function() awful.spawn("deadbeef") end),
	awful.key({}, "XF86Tools", function() awful.spawn("/home/snakebite/.bin/playerctl-osd") end),
	--awful.key({}, "XF86AudioPlay", function() awful.spawn("deadbeef --play-pause") end),
	awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end),
	--awful.key({"Shift"}, "XF86AudioPlay", function() awful.spawn("deadbeef --stop") end),
	--awful.key({"Control"}, "XF86AudioPlay", function() awful.spawn("deadbeef --prev") end),
	--awful.key({"Mod1"}, "XF86AudioPlay", function() awful.spawn("deadbeef --next") end),
	awful.key({}, "Print", function() awful.spawn("/home/snakebite/.bin/maim-clipboard -s") end),
	awful.key({}, "XF86HomePage", function() awful.spawn("google-chrome-stable") end)
)

for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ "Mod4" }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end),
		awful.key({ "Mod4", "Control" }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end),
		awful.key({ "Mod4", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end),
		awful.key({ "Mod4", "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end))
end

root.keys(globalkeys)

clientkeys = awful.util.table.join(
	awful.key({"Mod4", "Mod1"}, "k", function(c) c:move_to_screen(c, c.screen+1) end),
	awful.key({"Mod4", "Mod1"}, "j", function(c) c:move_to_screen(c, c.screen-1) end),
	awful.key({"Mod4"}, "f", function(c) c.fullscreen = not c.fullscreen end),
	awful.key({"Mod4", "Control"}, "space", awful.client.floating.toggle),
	awful.key({"Mod4"}, "c", function(c) c:kill() end),
	awful.key({"Mod4"}, "b", function(c) if c.border_width == 0 then c.border_width = 1 else c.border_width = 0 end end),
	awful.key({"Mod4"}, "m", function(c) c.maximized = not c.maximized end),
	awful.key({"Mod4"}, "t", function(c) c.ontop = not c.ontop end),
	awful.key({"Mod4", "Control"}, "m", function(c) c.maximized_vertical = not c.maximized_vertical end),
	awful.key({"Mod4", "Shift"}, "m", function(c) c.maximized_horizontal = not c.maximized_horizontal end)
)

clientbuttons = awful.util.table.join(
	awful.button({}, 1, function(c) client.focus = c; c:raise() end),
	awful.button({"Mod1"}, 1, awful.mouse.client.move),
	awful.button({"Mod1"}, 3, awful.mouse.client.resize)
)

awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			floating = true,
			size_hints_honor = false
		}
	},
	{ rule = { class = "URxvt" }, properties = { floating = false } },
	{ rule = { class = "kitty" }, properties = { floating = false } },
	{ rule = { class = "Alacritty" }, properties = { floating = false } },
	{ rule = { class = "Termite" }, properties = { floating = false } },
	{ rule = { name = "mplayer2" }, properties = { border_width = 0 } },
	{ rule = { name = "MPlayer" }, properties = { border_width = 0 } },
	{ rule = { class = "mpv" }, properties = { border_width = 0 } },
	{ rule = { class = "vdpau" }, properties = { border_width = 0 } },
	{ rule = { class = "feh" }, properties = { border_width = 0} },
	{ rule = { class = "SDL_App" }, properties = { border_width = 0 } },
	{ rule = { class = "Google-chrome", role = "browser" }, properties = { floating = false, border_width = 0 } }
}

client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
	if not awesome.startup and awful.client.focus.filter(c) then
		awful.client.setslave(c)
		c.screen = mouse.screen
		c:raise()
	end
end)

client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.mangifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
