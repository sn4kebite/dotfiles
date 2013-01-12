---------------------------
-- Default awesome theme --
---------------------------

theme = {}

--theme.confdir = awful.util.getdir("config")
theme.confdir = "/home/snakebite/.config/awesome"

theme.widget_separator = theme.confdir .. "/icons/separator.png"
theme.widget_cpu = theme.confdir .. "/icons/cpu.png"
theme.widget_mem = theme.confdir .. "/icons/mem.png"
theme.widget_down = theme.confdir .. "/icons/down.png"
theme.widget_up = theme.confdir .. "/icons/up.png"
theme.widget_temp = theme.confdir .. "/icons/temp.png"
theme.widget_mail = theme.confdir .. "/icons/mail.png"

--theme.font           = "silkscreen 6"
--theme.font           = "terminus 9"
theme.font           = "ProFont 8"

theme.bg_normal     = "#101010"
theme.bg_focus      = "#404040"
theme.bg_urgent     = "#bf4646"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#404040"
theme.fg_focus      = "#aaaaaa"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 1
theme.border_normal = "#111111"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

theme.taglist_fg_focus  = "#dddddd"
theme.taglist_bg_focus  = "#404040"

theme.tasklist_fg_focus = "#dddddd"
theme.tasklist_bg_focus = "#404040"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = theme.confdir .. "/icons-awesome-anrxc/taglist/squaref_a.png"
theme.taglist_squares_unsel = theme.confdir .. "/icons-awesome-anrxc/taglist/square_a.png"

theme.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper_cmd = { "awsetbg -t wallpaper.png" }
theme.wallpaper = "/home/snakebite/wallpaper.png"

-- You can use your own layout icons like this:
theme.layout_fairh = theme.confdir .. "/icons-awesome-anrxc/layouts-small/fairh.png"
theme.layout_fairv = theme.confdir .. "/icons-awesome-anrxc/layouts-small/fairv.png"
theme.layout_floating  = theme.confdir .. "/icons-awesome-anrxc/layouts-small/floating.png"
theme.layout_magnifier = theme.confdir .. "/icons-awesome-anrxc/layouts-small/magnifier.png"
theme.layout_max = theme.confdir .. "/icons-awesome-anrxc/layouts-small/max.png"
theme.layout_fullscreen = theme.confdir .. "/icons-awesome-anrxc/layouts-small/fullscreen.png"
theme.layout_tilebottom = theme.confdir .. "/icons-awesome-anrxc/layouts-small/tilebottom.png"
theme.layout_tileleft   = theme.confdir .. "/icons-awesome-anrxc/layouts-small/tileleft.png"
theme.layout_tile = theme.confdir .. "/icons-awesome-anrxc/layouts-small/tile.png"
theme.layout_tiletop = theme.confdir .. "/icons-awesome-anrxc/layouts-small/tiletop.png"
theme.layout_spiral  = theme.confdir .. "/icons-awesome-anrxc/layouts-small/spiral.png"
theme.layout_dwindle = theme.confdir .. "/icons-awesome-anrxc/layouts-small/dwindle.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

theme.icon_theme = nil

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80
