local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
awful.rules =  require("awful.rules")
local beautiful = require("beautiful")
-- local naughty = require("naughty")
local wibox = require("wibox")
local vicious = require("vicious")

local jbh = require("jbh")

beautiful.init("/home/snakebite/.config/awesome/theme.lua")

--[[naughty.config.screen = 1
naughty.config.margin = 4
naughty.config.height = 16
naughty.config.width = 300
naughty.config.presets.low.font = "DejaVu Sans ExtraLight 14"
naughty.config.presets.normal.font = "DejaVu Sans ExtraLight 14"
naughty.config.presets.critical.font = "DejaVu Sans ExtraLight 14"
naughty.config.default_preset.font = "DejaVu Sans ExtraLight 14"
naughty.config.icon_size = 48
naughty.config.fg = '#ffffff'
naughty.config.bg = beautiful.bg_focus
naughty.config.presets.normal.border_color = beautiful.border_focus
naughty.config.border_width = 1
]]--

for s = 1, screen.count() do
	gears.wallpaper.maximized("/home/snakebite/wallpaper." .. s .. ".png", s, true)
end

config = {}

--[[config.tags = {
	{name = "main", screen = 1, selected = true},
	{name = "web", screen = 1},
	--{name = "spotify", screen = 1},
	{name = "irssi", screen = 2, selected = true},
	{name = "foo"},
	{name = "bar"},
	{name = "dev", screen = 1}
}]]--

config.tags = {}

for i = 1, 9 do
	table.insert(config.tags, { name = i, selected = i == 1})
end

tags = {}

widgets = {}
config.layouts = {
	awful.layout.suit.tile.left,
	awful.layout.suit.tile,
	awful.layout.suit.tile.top,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	--awful.layout.suit.max,
	--awful.layout.suit.max.fullscreen,
	--awful.layout.suit.magnifier,
	--awful.layout.suit.floating
}
widgets.layoutbox = {}
widgets.taglist = {}
widgets.promptbox = {}
widgets.taglist.buttons = awful.util.table.join(
	awful.button({}, 1, awful.tag.viewonly),
	awful.button({"Mod4"}, 1, awful.client.movetotag),
	awful.button({}, 3, function(tag) tag.selected = not tag.selected end),
	awful.button({"Mod4"}, 3, awful.client.toggletag),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
)

widgets.tasklist = {}
widgets.tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, function(c) if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end client.focus = c; c:raise() end)
)

widgets.systray = wibox.widget.systray()

widgets.datewidget = wibox.widget.textbox()
vicious.register(widgets.datewidget, vicious.widgets.date, "<span color='" .. beautiful.fg_focus .. "'>%d.%m.%Y %T</span>", 1)

widgets.cpugraph = awful.widget.graph()
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

widgets.memgraph = awful.widget.graph()
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
vicious.register(widgets.net, vicious.widgets.net, "${eth0 down_kb} / ${eth0 up_kb}")

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

for s = 1, screen.count() do
	widgets.layoutbox[s] = awful.widget.layoutbox(s)
	widgets.layoutbox[s]:buttons(awful.util.table.join(
		awful.button({}, 1, function() awful.layout.inc(config.layouts, 1) end),
		awful.button({}, 3, function() awful.layout.inc(config.layouts, -1) end)
	))

	tags[s] = {} for _, t in ipairs(config.tags) do
		if not t.screen or t.screen == s then
			table.insert(tags[s], awful.tag({t.name}, s)[1])
			i = #tags[s]
			tags[s][i].screen = s
			tags[s][i].selected = t.selected or false
			awful.layout.set(config.layouts[5], tags[s][i])
		end
	end

	widgets.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, widgets.taglist.buttons)
	widgets.tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, widgets.tasklist.buttons)

	widgets.promptbox[s] = awful.widget.prompt()

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(widgets.taglist[s])
	left_layout:add(widgets.promptbox[s])

	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then
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
	right_layout:add(widgets.layoutbox[s])

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(widgets.tasklist[s])
	layout:set_right(right_layout)

	statusbar[s] = awful.wibox({position = "top", screen = s, height = 14})
	statusbar[s]:set_widget(layout)
end

globalkeys = awful.util.table.join(
	awful.key({"Mod4"}, "Left", awful.tag.viewprev),
	awful.key({"Mod4"}, "Right", awful.tag.viewnext),
	awful.key({"Mod4"}, "j", function() awful.client.focus.byidx(1) end),
	awful.key({"Mod4"}, "k", function() awful.client.focus.byidx(-1) end),
	awful.key({"Mod4", "Shift"}, "j", function() awful.client.swap.byidx(1) end),
	awful.key({"Mod4", "Shift"}, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({"Mod4", "Control"}, "j", function() awful.screen.focus_relative(1) end),
	awful.key({"Mod4", "Control"}, "k", function() awful.screen.focus_relative(-1) end),
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
	awful.key({"Mod4", "Shift"}, "h", function() awful.tag.incnmaster(1) end),
	awful.key({"Mod4", "Shift"}, "l", function() awful.tag.incnmaster(-1) end),
	awful.key({"Mod4", "Control"}, "h", function() awful.tag.incncol(1) end),
	awful.key({"Mod4", "Control"}, "l", function() awful.tag.incncol(-1) end),
	awful.key({"Mod4"}, "space", function() awful.layout.inc(config.layouts, 1) end),
	awful.key({"Mod4", "Shift"}, "space", function() awful.layout.inc(config.layouts, -1) end),
	awful.key({"Mod4"}, "r", function () widgets.promptbox[mouse.screen]:run() end),
	--awful.key({"Mod4"}, "r", function () awful.util.spawn(".bin/chakushu") end),
	awful.key({"Mod4", "Control"}, "r", awesome.restart),
	awful.key({"Mod4"}, "q", awesome.quit),

	-- Spawn stuff
	--awful.key({"Mod4"}, "Return", function() awful.util.spawn(".bin/urxvt-wrapper") end),
	awful.key({"Mod4"}, "Return", function() awful.util.spawn("urxvt") end),
	--awful.key({}, "XF86Tools", function() awful.util.spawn("mpdnotify") end),
	awful.key({}, "XF86Tools", function() awful.util.spawn("deadbeef") end),
	awful.key({}, "XF86HomePage", function() awful.util.spawn("google-chrome") end),
--[[	awful.key({}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc toggle") end),
	awful.key({"Shift"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc stop") end),
	awful.key({"Control"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc prev") end),
	awful.key({"Mod1"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc next") end),
	awful.key({"Mod4", "Control"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc seek -10") end),
	awful.key({"Mod4"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc seek +10") end),]]--
	awful.key({}, "XF86AudioPlay", function() awful.util.spawn("deadbeef --play-pause") end),
	awful.key({"Shift"}, "XF86AudioPlay", function() awful.util.spawn("deadbeef --stop") end),
	awful.key({"Control"}, "XF86AudioPlay", function() awful.util.spawn("deadbeef --prev") end),
	awful.key({"Mod1"}, "XF86AudioPlay", function() awful.util.spawn("deadbeef --next") end),
--[[	awful.key({"Mod4", "Control"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc seek -10") end),
	awful.key({"Mod4"}, "XF86AudioPlay", function() awful.util.spawn(".bin/mpcc seek +10") end),]]--
	awful.key({}, "Print", function() awful.util.spawn("scrot") end)
)

for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ "Mod4" }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				if tags[screen][i] then
					awful.tag.viewonly(tags[screen][i])
				end
			end),
		awful.key({ "Mod4", "Control" }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				if tags[screen][i] then
					awful.tag.viewtoggle(tags[screen][i])
				end
			end),
		awful.key({ "Mod4", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.movetotag(tags[client.focus.screen][i])
				end
			end),
		awful.key({ "Mod4", "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.toggletag(tags[client.focus.screen][i])
				end
			end))
end

root.keys(globalkeys)

clientkeys = awful.util.table.join(
	awful.key({"Mod4"}, "f", function(c) c.fullscreen = not c.fullscreen end),
	awful.key({"Mod4", "Control"}, "space", awful.client.floating.toggle),
	awful.key({"Mod4"}, "c", function(c) c:kill() end),
	awful.key({"Mod4"}, "b", function(c) if c.border_width == 0 then c.border_width = 1 else c.border_width = 0 end end),
	awful.key({"Mod4"}, "t", function(c) if c.titlebar then awful.titlebar.remove(c) else awful.titlebar.add(c, {modkey = "Mod4"}) end end)
)

awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons,
			floating = true,
			size_hints_honor = false
		}
	},
	{ rule = { class = "URxvt" }, properties = { floating = false } },
	{ rule = { name = "mplayer2" }, properties = { border_width = 0 } },
	{ rule = { class = "feh" }, properties = { border_width = 0} },
	{ rule = { class = "SDL_App" }, properties = { border_width = 0 } },
	{ rule = { class = "aquaria" }, properties = { border_width = 0 } },
	{ rule = { class = "net-minecraft-MinecraftLauncher" }, properties = { border_width = 0 } },
	{ rule = { class = "warzone2100" }, properties = { border_width = 0 } },
	{ rule = { class = "mupen64plus" }, properties = { border_width = 0 } },
	{ rule = { name = "Coertex Command" }, properties = { border_width = 0 } },
	{ rule = { class = "ioUrbanTerror" }, properties = { border_width = 0 } },
	{ rule = { class = "Google-chrome", role = "browser" }, properties = { floating = false } }
--[[	{ rule = { name = "MPlayer" }, properties = { floating = true, border_width = 0 } },
	{ rule = { class = "Gimp" }, properties = { floating = true } },
	{ rule = { name = "Mirage" }, properties = { floating = true } },
	{ rule = { class = "Walls" }, properties = { floating = true } },
	{ rule = { class = "feh" }, properties = { floating = true, border_width = 0} },
	{ rule = { class = "Dolphin" }, properties = { floating = true } },
	{ rule = { class = "Wine" }, properties = { floating = true } },
	{ rule = { class = "Comix" }, properties = { floating = true } },
	{ rule = { name = "GPU" }, properties = { floating = true } },
	{ rule = { class = "Epdfview" }, properties = { floating = true } },
	{ rule = { class = "Ufraw" }, properties = { floating = true } },
	{ rule = { class = "Rawstudio" }, properties = { floating = true } },
	{ rule = { class = "Easytag" }, properties = { floating = true } },
	{ rule = { class = "qemu" }, properties = { floating = true } },
	{ rule = { class = "Nvidia-settings" }, properties = { floating = true } },
	{ rule = { name = "NEStopia" }, properties = { floating = true } },
	{ rule = { name = "galculator" }, properties = { floating = true } },
	{ rule = { class = "Foo" }, properties = { floating = true } },
	{ rule = { class = "SDL_App" }, properties = { border_width = 0 } },
	{ rule = { class = "aquaria" }, properties = { border_width = 0 } },
	{ rule = { class = "net-minecraft-MinecraftLauncher" }, properties = { border_width = 0 } },
	{ rule = { class = "warzone2100" }, properties = { border_width = 0 } }]]--
}

clientbuttons = awful.util.table.join(
	awful.button({}, 1, function(c) client.focus = c; c:raise() end),
	awful.button({"Mod1"}, 1, awful.mouse.client.move),
	awful.button({"Mod1"}, 3, awful.mouse.client.resize)
)

client.connect_signal("manage", function(c, startup)
	c:connect_signal("mouse::enter", function(c)
		if awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup and awful.client.focus.filter(c) then
		awful.client.setslave(c)
		c.screen = mouse.screen
		c:raise()
	end
	c:buttons(clientbuttons)
	client.focus = c
	c:keys(clientkeys)
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
