require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")
--require("naughty")
require("vicious")

require("jbh")

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

widgets.systray = widget({ type = "systray" })

widgets.datewidget = widget({ type = "textbox" })
vicious.register(widgets.datewidget, vicious.widgets.date, "<span color='" .. beautiful.fg_focus .. "'>%d.%m.%Y %T</span>", 1)

widgets.cpugraph = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
widgets.cpugraph:set_width(50)
widgets.cpugraph:set_height(14)
widgets.cpugraph:set_background_color(beautiful.bg_normal)
widgets.cpugraph:set_color("#AECF96")
--widgets.cpugraph:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(widgets.cpugraph, vicious.widgets.cpu, "$1")

widgets.memgraph = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
widgets.memgraph:set_width(50)
widgets.memgraph:set_height(14)
widgets.memgraph:set_background_color(beautiful.bg_normal)
widgets.memgraph:set_border_color(nil)
widgets.memgraph:set_color("#FF5656")
--widgets.memgraph:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(widgets.memgraph, vicious.widgets.mem, "$1")

--[[memgraph_t = awful.tooltip({
	timer_function = function()
		local f = io.popen("cat /proc/meminfo | awk '{print $2}'")
		local s = f:read()
		local s2 = f:read()
		return s .. "\n" .. s2
	end,
})]]--
--memgraph_t:add_to_object(widgets.memgraph.widget)
--widgets.memgraph.widget:add_signal("mouse:enter", function()
--end)

widgets.hddtemp = widget({ type = "textbox" })
vicious.register(widgets.hddtemp, vicious.widgets.hddtemp, "${/dev/sda} °C", 19)

widgets.hddtemp = jbh.widgets.sensors(5)

widgets.net = widget({ type = "textbox" })
vicious.register(widgets.net, vicious.widgets.net, "${eth0 down_kb} / ${eth0 up_kb}")

--widgets.mpd = widget({ type = "textbox" })
--[[vicious.register(widgets.mpd, vicious.widgets.mpd, function(w, t)
	if t["{state}"] == "Stop" then
		return ""
	else
		return t["{Artist}"] .. " - " .. t["{Album}"] .. " - ".. t["{Title}"]
	end
end)]]--

--widgets.mail = widget({ type = "textbox" })
--vicious.register(widgets.mail, vicious.widgets.gmail, " ${count}")

icons = {}

icons.separator = widget({ type = "imagebox" })
icons.separator.image = image(beautiful.widget_separator)

icons.cpu = widget({ type = "imagebox" })
icons.cpu.image = image(beautiful.widget_cpu)

icons.mem = widget({ type = "imagebox" })
icons.mem.image = image(beautiful.widget_mem)

icons.down = widget({ type = "imagebox" })
icons.down.image = image(beautiful.widget_down)

icons.up = widget({ type = "imagebox" })
icons.up.image = image(beautiful.widget_up)

icons.temp = widget({ type = "imagebox" })
icons.temp.image = image(beautiful.widget_temp)

--icons.mail = widget({ type = "imagebox" })
--icons.mail.image = image(beautiful.widget_mail)

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
			awful.layout.set(config.layouts[1], tags[s][i])
		end
	end

	widgets.taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, widgets.taglist.buttons)
	widgets.tasklist[s] = awful.widget.tasklist(function(c) return awful.widget.tasklist.label.currenttags(c, s) end, widgets.tasklist.buttons)

	widgets.promptbox[s] = awful.widget.prompt({layout = awful.widget.layout.horizontal.leftright})

	statusbar[s] = awful.wibox({position = "top", screen = s, height = 14})
	statusbar[s].widgets = {
		{
			widgets.taglist[s],
			widgets.promptbox[s],
			layout = awful.widget.layout.horizontal.leftright
		},
		widgets.layoutbox[s],
		s == 1 and {
			widgets.datewidget,
			icons.separator,
			widgets.systray,
			icons.separator,
			widgets.cpugraph,
			icons.cpu,
			icons.separator,
			widgets.memgraph,
			icons.mem,
			icons.separator,
			--widgets.mail,
			--icons.mail,
			--icons.separator,
			widgets.hddtemp,
			icons.temp,
			icons.separator,
			icons.up,
			widgets.net,
			icons.down,
			layout = awful.widget.layout.horizontal.rightleft
		} or nil,
		--s == 2 and widgets.mpd or nil,
		widgets.tasklist[s],
		layout = awful.widget.layout.horizontal.rightleft
	}
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
			floating = true
		}
	},
	{ rule = { class = "URxvt" }, properties = { floating = false } },
	{ rule = { name = "mplayer2" }, properties = { border_width = 0 } },
	{ rule = { class = "feh" }, properties = { border_width = 0} },
	{ rule = { class = "SDL_App" }, properties = { border_width = 0 } },
	{ rule = { class = "aquaria" }, properties = { border_width = 0 } },
	{ rule = { class = "net-minecraft-MinecraftLauncher" }, properties = { border_width = 0 } },
	{ rule = { class = "warzone2100" }, properties = { border_width = 0 } },
	{ rule = { class = "ioUrbanTerror" }, properties = { border_width = 0 } }
	--{ rule = { class = "Google-chrome" }, properties = { floating = false } }
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

client.add_signal("manage", function(c, startup)
	c:add_signal("mouse::enter", function(c)
		client.focus = c
	end)

	if not startup and awful.client.focus.filter(c) then
		c.screen = mouse.screen
		c:raise()
	end
	c:buttons(clientbuttons)
	client.focus = c
	c:keys(clientkeys)
	c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
