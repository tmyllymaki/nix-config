-- dotfiles/paneru/init.lua -- installed by modules/darwin/paneru.nix as paneru's
-- $PANERU_LUA, so paneru reads *only* this file: a paneru.toml beside it (or a
-- ~/.config/paneru/init.lua) is ignored entirely.
--
-- Paneru config, ported from ~/.config/aerospace/aerospace.toml.
--
-- The two bindings that used to live in
-- paneru.toml (`alt - r` resize, `alt - c` center) are folded in below.
--
-- Editing this file needs a rebuild (`nh darwin switch . -H laptop`); errors
-- show up in /tmp/paneru.err.log

paneru.setup {
	default_workspaces = 7, -- aerospace uses workspaces 1-7

	options = {
		focus_follows_mouse = true,
		mouse_follows_focus = true, -- closest thing to `move-mouse monitor-lazy-center`

		-- Exponential ease-out decay rate for the strip/window movement and
		-- resizes: t = 1 - e^(-rate*dt). UNSET means 1_000_000, i.e. an instant
		-- snap with no animation -- that's the jarring jump. Suggested 8-20 for a
		-- fluid feel; higher = snappier.
		animation_speed = 16.0,

		-- Virtual workspace (row) switches stay instant, matching the upstream
		-- default -- no slow vertical slide on top of the horizontal strip
		-- animation above. `animation_speed` still drives that horizontal slide.
		virtual_workspace_animations = false,
	},

	decorations = {
		-- the 1-second workspace-number toast shown on every switch
		workspace_popup_status = false,
	},

	swipe = {
		-- travel per unit of finger movement; lower = slower, calmer strip
		-- (0.1-2.0, clamped). Also scales alt+scroll sliding.
		sensitivity = 0.15,

		-- how fast inertia dies out; higher = stops sooner (1.0-10.0, clamped).
		-- This is the knob to turn if the *glide after finger-lift* is too fast.
		deceleration = 4.0,
		continuous = true,

		-- Three fingers slide the window strip; vertical three-finger swipes
		-- switch virtual workspace rows. NOTE: this takes three-finger swipes
		-- away from macOS, so 3-finger "Swipe between Spaces" stops working.
		-- The `direction` value must stay capitalised: "Natural" or "Reversed".
		gesture = { fingers_count = 3, direction = "Natural", vertical = true },

		-- mouse/trackpad fallback: alt+scroll slides, alt+shift+scroll changes row
		scroll = { modifier = "alt", vertical_modifier = "shift" },
	},
}

-- Binds one command to several chords (aerospace had the same action on both
-- the letter keys and the arrow keys).
local function bind(command, ...)
	for _, chord in ipairs({ ... }) do
		paneru.bind(chord, command)
	end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Navigation / focus
-- alt-hjkl is aerospace's own focus scheme; h/l walk the strip, j/k move
-- between windows in a stack and fall through to the virtual workspace below
-- or above when there is nothing left to focus that way.
-- ─────────────────────────────────────────────────────────────────────────────

bind("window focus west", "alt - h")
bind("window focus east", "alt - l")
bind("window virtualfocus north", "alt - k")
bind("window virtualfocus south", "alt - j")

-- aerospace also had these on a four-modifier chord
bind("window focus west", "alt + shift + cmd + ctrl - h", "alt + shift + cmd + ctrl - leftarrow")
bind("window focus east", "alt + shift + cmd + ctrl - l", "alt + shift + cmd + ctrl - rightarrow")
bind(
	"window virtualfocus north",
	"alt + shift + cmd + ctrl - k",
	"alt + shift + cmd + ctrl - uparrow"
)
bind(
	"window virtualfocus south",
	"alt + shift + cmd + ctrl - j",
	"alt + shift + cmd + ctrl - downarrow"
)

-- Deliberately *not* bound: paneru's README example uses cmd-h/cmd-l for focus,
-- which shadows Hide and "focus address bar" in every app.
--   bind("window focus west", "cmd - h")
--   bind("window focus east", "cmd - l")

-- ─────────────────────────────────────────────────────────────────────────────
-- Moving windows
-- Horizontal moves swap along the strip; vertical moves send the window to the
-- virtual workspace below/above and follow it. (aerospace `move left/right`
-- and `move up/down`.)
-- ─────────────────────────────────────────────────────────────────────────────

bind("window swap west", "alt + shift - h", "cmd + shift - h", "cmd + shift - leftarrow")
bind("window swap east", "alt + shift - l", "cmd + shift - l", "cmd + shift - rightarrow")
bind(
	"window virtualmove north",
	"alt + shift - k",
	"cmd + shift - k",
	"cmd + shift - uparrow"
)
bind(
	"window virtualmove south",
	"alt + shift - j",
	"cmd + shift - j",
	"cmd + shift - downarrow"
)

-- ─────────────────────────────────────────────────────────────────────────────
-- Workspaces (paneru virtual workspaces = rows, 1-7)
--
-- aerospace's `cmd-shift-N` moved the window to workspace N *and followed it*;
-- paneru needs the follow spelled out, hence `virtualmovenum`.
-- ─────────────────────────────────────────────────────────────────────────────

-- Switch workspace, remembering the one we came from so cmd-alt-tab can toggle
-- back. Only switches made with these keys (and the toggle itself) are tracked.
local function goto_workspace(number)
	return function(ws)
		local current = ws:current()
		if current ~= nil and current ~= number then
			paneru.state.set("previous_workspace", current)
		end
		return ws:view(number)
	end
end

for number = 1, 7 do
	paneru.bind("cmd - " .. number, goto_workspace(number))

	-- move window to workspace N, and follow it (aerospace cmd-shift-N)
	paneru.bind("cmd + shift - " .. number, "window virtualmovenum " .. number)

	-- move window to workspace N, but stay here
	paneru.bind("cmd + alt + shift - " .. number, "window virtualsendnum " .. number)
end

-- aerospace's `workspace-back-and-forth`
paneru.bind("cmd + alt - tab", function(ws)
	local previous = paneru.state.get("previous_workspace")
	local current = ws:current()
	if previous == nil or previous == current then
		return
	end
	paneru.state.set("previous_workspace", current)
	return ws:view(previous)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Size and layout
-- ─────────────────────────────────────────────────────────────────────────────

bind("window resize", "cmd - 9", "alt - r") -- aerospace cmd-9, plus the old paneru.toml key
bind("window shrink", "cmd - 0") -- aerospace cmd-0
bind("window fullwidth", "cmd - m") -- aerospace cmd-m fullscreen
bind("window manage", "cmd + shift - f") -- aerospace cmd-shift-f floating/tiling
bind("window center", "alt - i", "alt - c") -- aerospace alt-i, plus the old paneru.toml key

-- 50/50: focused column and whichever side has a neighbour, both to exactly
-- half the viewport. Niri has no balance action -- its SetColumnWidth only ever
-- touches the focused column -- so this is the one-key stand-in. `ws:west()` and
-- `ws:east()` do not wrap, hence the `or`.
paneru.bind("cmd + alt - 5", function(ws)
	local focused = ws:focused()
	if focused == nil then
		return
	end
	local result = ws:width(focused, 0.5)
	local neighbour = ws:west(focused) or ws:east(focused)
	if neighbour ~= nil then
		result = result:width(neighbour, 0.5)
	end
	return result
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Displays
-- aerospace moved a whole workspace to the next monitor (cmd-alt-n); paneru has
-- no workspace-to-display assignment, so this moves the focused window instead.
-- ─────────────────────────────────────────────────────────────────────────────

bind("window nextdisplay", "cmd + alt - n")
bind("mouse nextdisplay", "cmd + alt + shift - n")

-- ─────────────────────────────────────────────────────────────────────────────
-- Suppress macOS shortcuts, as aerospace did with `cmd-alt-h = []` / `cmd-tab = []`.
-- Returning nothing from a Lua handler commits nothing, so these are no-ops.
-- Delete this block if you want Hide-others and the app switcher back.
-- ─────────────────────────────────────────────────────────────────────────────

paneru.bind("cmd + alt - h", function() end)
paneru.bind("cmd - tab", function() end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Paneru extras -- nothing in aerospace maps to these, delete freely.
-- ─────────────────────────────────────────────────────────────────────────────

bind("window swap north", "ctrl + alt - k") -- reorder inside a stack
bind("window swap south", "ctrl + alt - j")
bind("window swap first", "ctrl + alt - h")
bind("window swap last", "ctrl + alt - l")
bind("window stack", "ctrl + alt - s") -- stack onto the column on the left
bind("window unstack", "ctrl + alt + shift - s")
bind("window equalize", "ctrl + alt - e") -- equal heights within a stack
bind("window balance", "ctrl + alt - b") -- equal widths across the strip
bind("window snap", "ctrl + alt - n") -- pull an overflowing window into view

-- ─────────────────────────────────────────────────────────────────────────────
-- App -> workspace rules, ported from aerospace's [[on-window-detected]].
-- paneru has no `[windows]` rule for this, so they run on window_spawned.
-- Like `move-node-to-workspace`, these do not follow the window.
-- ─────────────────────────────────────────────────────────────────────────────

local app_workspaces = {
	["com.jetbrains.rider"] = 1,
	["com.github.wez.wezterm"] = 1,
	["com.mitchellh.ghostty"] = 1,
	["app.zen-browser.zen"] = 2,
	["com.tinysleak.slackmacgap"] = 3,
	["com.microsoft.teams2"] = 3,
	["org.whispersystems.signal-desktop"] = 3,
	["com.spotify.client"] = 4,
}

for bundle, workspace in pairs(app_workspaces) do
	paneru.on("window_spawned", { bundle = bundle }, function(event, ws)
		if ws:workspace_of(event.window_id) == workspace then
			return
		end
		return ws:shift(event.window_id, workspace)
	end)
end

-- aerospace had a second ghostty rule that also ran `layout floating`, which
-- makes *every* window on workspace 1 float. Left out on purpose; uncomment if
-- you really want floating ghostty terminals:
--
-- paneru.on("window_spawned", { bundle = "com.mitchellh.ghostty" }, function(event, ws)
-- 	return ws:float(event.window_id)
-- end)

-- ─────────────────────────────────────────────────────────────────────────────
-- quit (kept from the previous paneru config)
-- ─────────────────────────────────────────────────────────────────────────────

bind("quit", "ctrl + alt - q")
