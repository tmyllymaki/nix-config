-- vim: tabstop=2 shiftwidth=2 expandtab

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Find a binary across multiple possible paths (portable across homebrew/nix-darwin)
local function find_bin(name, extra_paths)
	local paths = { "/run/current-system/sw/bin", "/opt/homebrew/bin", "/opt/local/bin", "/usr/local/bin" }
	if extra_paths then
		for _, p in ipairs(extra_paths) do
			table.insert(paths, p)
		end
	end
	for _, dir in ipairs(paths) do
		local full = dir .. "/" .. name
		local f = io.open(full)
		if f then
			f:close()
			return full
		end
	end
	return paths[1] .. "/" .. name -- fallback
end

-- Check if a binary actually exists on this machine
local has_zmx = io.open(find_bin("zmx")) ~= nil

config.set_environment_variables = {
	PATH = "/run/wrappers/bin:/run/current-system/sw/bin:/opt/homebrew/bin:" .. os.getenv("PATH"),
}

config.term = "wezterm"

local appearance = require("appearance")

config.color_schemes = {
	["dayfox"] = {
		foreground = "#3d2b5a",
		background = "#f6f2ee",
		cursor_bg = "#3d2b5a",
		cursor_border = "#3d2b5a",
		cursor_fg = "#f6f2ee",
		compose_cursor = "#955f61",
		selection_bg = "#e7d2be",
		selection_fg = "#3d2b5a",
		scrollbar_thumb = "#824d5b",
		split = "#e4dcd4",
		visual_bell = "#3d2b5a",
		ansi = { "#352c24", "#a5222f", "#396847", "#ac5402", "#2848a9", "#6e33ce", "#287980", "#f2e9e1" },
		brights = { "#534c45", "#b3434e", "#577f63", "#b86e28", "#4863b6", "#8452d5", "#488d93", "#f4ece6" },
		indexed = { [16] = "#a440b5", [17] = "#955f61" },
		tab_bar = {
			background = "#e4dcd4",
			inactive_tab_edge = "#e4dcd4",
			active_tab = { bg_color = "#824d5b", fg_color = "#f6f2ee" },
			inactive_tab = { bg_color = "#dbd1dd", fg_color = "#643f61" },
			inactive_tab_hover = { bg_color = "#d3c7bb", fg_color = "#3d2b5a" },
			new_tab = { bg_color = "#f6f2ee", fg_color = "#643f61" },
			new_tab_hover = { bg_color = "#d3c7bb", fg_color = "#3d2b5a" },
		},
	},
	["carbonfox"] = {
		foreground = "#f2f4f8",
		background = "#161616",
		cursor_bg = "#f2f4f8",
		cursor_border = "#f2f4f8",
		cursor_fg = "#161616",
		compose_cursor = "#3ddbd9",
		selection_bg = "#2a2a2a",
		selection_fg = "#f2f4f8",
		scrollbar_thumb = "#7b7c7e",
		split = "#0c0c0c",
		visual_bell = "#f2f4f8",
		ansi = { "#282828", "#ee5396", "#25be6a", "#08bdba", "#78a9ff", "#be95ff", "#33b1ff", "#dfdfe0" },
		brights = { "#484848", "#f16da6", "#46c880", "#2dc7c4", "#8cb6ff", "#c8a5ff", "#52bdff", "#e4e4e5" },
		indexed = { [16] = "#ff7eb6", [17] = "#3ddbd9" },
		tab_bar = {
			background = "#0c0c0c",
			inactive_tab_edge = "#0c0c0c",
			active_tab = { bg_color = "#7b7c7e", fg_color = "#161616" },
			inactive_tab = { bg_color = "#252525", fg_color = "#b6b8bb" },
			inactive_tab_hover = { bg_color = "#353535", fg_color = "#f2f4f8" },
			new_tab = { bg_color = "#161616", fg_color = "#b6b8bb" },
			new_tab_hover = { bg_color = "#353535", fg_color = "#f2f4f8" },
		},
	},
}

config.color_scheme = appearance.is_dark() and "carbonfox" or "dayfox"
local colors = config.color_schemes[config.color_scheme]
config.colors = colors

config.font =
	wezterm.font("IoskeleyMonoTerm Nerd Font", { weight = "Medium", stretch = "SemiCondensed", style = "Normal" })
-- config.font = wezterm.font("Iosevka Term SS03", { weight = "Medium" })
config.font_size = 16
config.line_height = 1.0

config.window_background_opacity = 1
config.macos_window_background_blur = 30
config.window_decorations = "RESIZE"

local function move_pane(key, direction)
	return {
		key = key,
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.key_tables = {
	resize_panes = {
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("h", "Left"),
		resize_pane("l", "Right"),
	},
}

config.default_prog = { find_bin("fish") }
config.send_composed_key_when_left_alt_is_pressed = true

config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.animation_fps = 120

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
	regex = [[\b(TEL-\d+)\b]],
	format = "https://example-a.atlassian.net/browse/$1",
})

table.insert(config.hyperlink_rules, {
	regex = [[\b(BFT-\d+)\b]],
	format = "https://example-b.atlassian.net/browse/$1",
})

table.insert(config.hyperlink_rules, {
	regex = [[\b([a-zA-Z]{3}-\d+)\b]],
	format = "https://example-c.atlassian.net/browse/$1",
})

table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})

config.mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
}

-- Per-project tab layouts (optional)
-- Each tab gets its own zmx session named "<project>-<session>"
-- Projects without a layout get a single tab with "zmx attach <project>"
local project_layouts = {
	["example-project"] = {
		{ session = "nvim", cmd = "nvim" },
		{ session = "backend" },
		{ session = "frontend" },
	},
}

-- The workspace wezterm starts in doubles as a global scratch session: it has
-- no project dir, it keeps running while hidden, and it is reachable from any
-- project workspace with a single toggle.
local SCRATCH_WORKSPACE = "default"

local function workspace_exists(name)
	for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
		if ws == name then
			return true
		end
	end
	return false
end

-- Where to go when leaving the scratch workspace.
local function scratch_return_workspace()
	local previous = wezterm.GLOBAL.scratch_return_workspace
	if previous and previous ~= SCRATCH_WORKSPACE and workspace_exists(previous) then
		return previous
	end

	-- The stored workspace is gone (wezterm restart, or its window was closed).
	-- Fall back to any other open workspace.
	for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
		if ws ~= SCRATCH_WORKSPACE then
			return ws
		end
	end

	return nil
end

-- Show the scratch workspace, or go back to the workspace it was invoked from.
local function toggle_scratch_workspace(window, pane)
	if window:active_workspace() == SCRATCH_WORKSPACE then
		local back = scratch_return_workspace()
		if back then
			window:perform_action(wezterm.action.SwitchToWorkspace({ name = back }), pane)
		end
		return
	end

	wezterm.GLOBAL.scratch_return_workspace = window:active_workspace()
	window:perform_action(wezterm.action.SwitchToWorkspace({ name = SCRATCH_WORKSPACE }), pane)
end

local function zmx_session_picker(window, pane)
	-- Check which workspaces are already open
	local open_workspaces = {}
	for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
		open_workspaces[ws] = true
	end

	-- Fetch zoxide dirs (and zmx session names when available)
	local zmx_list_cmd = has_zmx
			and ("echo '===SEP==='; ls -1 \"$TMPDIR/zmx-$(id -u)/\" 2>/dev/null | grep -v '^\\.\\|^logs$'")
			or "echo '===SEP==='"
	local _, combined_stdout = wezterm.run_child_process({
		"/bin/sh",
		"-c",
		find_bin("zoxide") .. " query -l;" .. zmx_list_cmd,
	})

	local zoxide_stdout, zmx_stdout = "", ""
	if combined_stdout then
		zoxide_stdout, zmx_stdout = combined_stdout:match("^(.-)===SEP===\n?(.*)$")
		zoxide_stdout = zoxide_stdout or ""
		zmx_stdout = zmx_stdout or ""
	end

	local choices = {}
	local seen = {}

	-- Collect zmx session names and map zoxide dirs by basename
	local zmx_sessions = {}
	if zmx_stdout ~= "" then
		for line in zmx_stdout:gmatch("[^\r\n]+") do
			local s = line:match("^%s*(.-)%s*$")
			if s and s ~= "" then
				table.insert(zmx_sessions, s)
			end
		end
	end

	local zoxide_by_name = {}
	if zoxide_stdout ~= "" then
		for line in zoxide_stdout:gmatch("[^\r\n]+") do
			local dir = line:match("^%s*(.-)%s*$")
			if dir and dir ~= "" then
				local name = dir:match("([^/]+)$")
				if name and not zoxide_by_name[name] then
					zoxide_by_name[name] = dir
				end
			end
		end
	end

	-- Determine the root directory of each open workspace so we can hide its
	-- subdirectories below. zoxide indexes deep dirs, and when a project is
	-- already open those child dirs (e.g. .../fresh-purchasing/src/Web/...)
	-- otherwise drown the open workspace itself in the fuzzy results.
	local open_roots = {}
	for ws, _ in pairs(open_workspaces) do
		if ws ~= "default" and zoxide_by_name[ws] then
			open_roots[zoxide_by_name[ws]] = true
		end
	end
	-- Fallback for workspaces zoxide doesn't know about: read the live cwd,
	-- but only trust it when it points at the project root (basename matches
	-- the workspace name, mirroring how workspaces are created). Otherwise a
	-- pane parked at e.g. $HOME would become a "root" and hide every project
	-- beneath it.
	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		local ws = mux_win:get_workspace()
		if open_workspaces[ws] and ws ~= "default" then
			local p = mux_win:active_pane()
			local cwd = p and p:get_current_working_dir()
			if cwd and cwd.file_path then
				local fp = cwd.file_path:gsub("/+$", "")
				if fp:match("([^/]+)$") == ws then
					open_roots[fp] = true
				end
			end
		end
	end

	local function under_open_root(dir)
		for root, _ in pairs(open_roots) do
			if dir ~= root and dir:sub(1, #root + 1) == root .. "/" then
				return true
			end
		end
		return false
	end

	-- 1) Open workspaces (instant switch)
	for ws, _ in pairs(open_workspaces) do
		table.insert(choices, {
			id = "ws:" .. ws,
			label = "● " .. ws .. (ws == SCRATCH_WORKSPACE and "  (scratch)" or "  (open)"),
		})
		seen[ws] = true
	end

	-- 2) Zmx sessions that have a matching zoxide dir (use dir: so multi-tab restore works)
	--    plus standalone zmx sessions (no zoxide dir)
	for _, s in ipairs(zmx_sessions) do
		if not seen[s] then
			local dir = zoxide_by_name[s]
			if dir then
				table.insert(choices, {
					id = "dir:" .. dir,
					label = "◆ " .. s .. "  (zmx session)",
				})
			else
				table.insert(choices, {
					id = "zmx:" .. s,
					label = "◆ " .. s .. "  (zmx session)",
				})
			end
			seen[s] = true
		end
	end

	-- 3) Remaining zoxide directories (no active zmx session),
	--    skipping anything that lives inside an already-open workspace.
	for name, dir in pairs(zoxide_by_name) do
		if not seen[name] and not under_open_root(dir) then
			table.insert(choices, {
				id = "dir:" .. dir,
				label = "○ " .. name .. "  (" .. dir .. ")",
			})
			seen[name] = true
		end
	end

	if #choices == 0 then
		window:toast_notification("zmx", "No projects found", nil, 3000)
		return
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Projects",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
				if not id then
					return
				end

				local kind, value = id:match("^(%w+):(.+)$")

				-- Already open workspace: just switch
				if kind == "ws" then
					-- Keep the scratch toggle in sync: whatever we leave here is
					-- where the toggle should bring us back to.
					wezterm.GLOBAL.scratch_return_workspace = inner_window:active_workspace()
					inner_window:perform_action(wezterm.action.SwitchToWorkspace({ name = value }), inner_pane)
					return
				end

				-- Standalone zmx session: open workspace and attach
				if kind == "zmx" then
					local _, first_pane, _ = wezterm.mux.spawn_window({
						workspace = value,
					})
					first_pane:send_text("zmx attach " .. value .. "\n")
					inner_window:perform_action(wezterm.action.SwitchToWorkspace({ name = value }), inner_pane)
					return
				end

				-- New workspace from directory
				local dir = value
				local name = dir:match("([^/]+)$")

				-- Check if workspace already exists (opened by another selection)
				for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
					if ws == name then
						inner_window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), inner_pane)
						return
					end
				end

				if has_zmx then
					-- Find existing zmx sessions for this workspace (fast socket dir listing)
					local _, zmx_ls = wezterm.run_child_process({
						"/bin/sh",
						"-c",
						"ls -1 \"$TMPDIR/zmx-$(id -u)/\" 2>/dev/null | grep -v '^\\.\\|^logs$'",
					})
					local sessions = {}
					if zmx_ls and zmx_ls ~= "" then
						local prefix = name .. "-"
						for line in zmx_ls:gmatch("[^\r\n]+") do
							local s = line:match("^%s*(.-)%s*$")
							if s and (s == name or s:sub(1, #prefix) == prefix) then
								table.insert(sessions, s)
							end
						end
					end

					if #sessions > 0 then
						-- Restore tabs from existing zmx sessions
						table.sort(sessions, function(a, b)
							if a == name then
								return true
							end
							if b == name then
								return false
							end
							return a < b
						end)
						local _, first_pane, mux_win = wezterm.mux.spawn_window({
							workspace = name,
							cwd = dir,
						})
						first_pane:send_text("zmx attach " .. sessions[1] .. "\n")
						for i = 2, #sessions do
							local _, new_pane = mux_win:spawn_tab({ cwd = dir })
							new_pane:send_text("zmx attach " .. sessions[i] .. "\n")
						end
					elseif project_layouts[name] then
						-- First time: use project layout
						local layout = project_layouts[name]
						local _, first_pane, mux_win = wezterm.mux.spawn_window({
							workspace = name,
							cwd = dir,
						})
						local cmd = "zmx attach " .. name .. "-" .. layout[1].session
						if layout[1].cmd then
							cmd = cmd .. " " .. layout[1].cmd
						end
						first_pane:send_text(cmd .. "\n")
						for i = 2, #layout do
							local _, new_pane = mux_win:spawn_tab({ cwd = dir })
							local tab_cmd = "zmx attach " .. name .. "-" .. layout[i].session
							if layout[i].cmd then
								tab_cmd = tab_cmd .. " " .. layout[i].cmd
							end
							new_pane:send_text(tab_cmd .. "\n")
						end
					else
						-- Single tab with zmx
						local _, first_pane, _ = wezterm.mux.spawn_window({
							workspace = name,
							cwd = dir,
						})
						first_pane:send_text("zmx attach " .. name .. "\n")
					end
				else
					-- No zmx: just open workspace at the directory
					wezterm.mux.spawn_window({
						workspace = name,
						cwd = dir,
					})
				end

				inner_window:perform_action(wezterm.action.SwitchToWorkspace({ name = name }), inner_pane)
			end),
		}),
		pane
	)
end

config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bb"),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bf"),
	},

	{
		key = ",",
		mods = "SUPER",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = { "nvim", wezterm.config_file },
		}),
	},

	-- New tab (with zmx child session when available)
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			if has_zmx then
				local workspace = window:active_workspace()
				local mux_win = window:mux_window()
				local tab, new_pane = mux_win:spawn_tab({})
				local session_name = workspace .. "-" .. #mux_win:tabs()
				new_pane:send_text("zmx attach " .. session_name .. "\n")
			else
				window:perform_action(wezterm.action.SpawnTab("CurrentPaneDomain"), pane)
			end
		end),
	},
	{
		key = "t",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			if has_zmx then
				local workspace = window:active_workspace()
				local mux_win = window:mux_window()
				local tab, new_pane = mux_win:spawn_tab({})
				local session_name = workspace .. "-" .. #mux_win:tabs()
				new_pane:send_text("zmx attach " .. session_name .. "\n")
			else
				window:perform_action(wezterm.action.SpawnTab("CurrentPaneDomain"), pane)
			end
		end),
	},

	{
		key = '"',
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "%",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
	{ key = "1", mods = "CTRL", action = wezterm.action.ActivateTab(0) },
	{ key = "2", mods = "CTRL", action = wezterm.action.ActivateTab(1) },
	{ key = "3", mods = "CTRL", action = wezterm.action.ActivateTab(2) },
	{ key = "4", mods = "CTRL", action = wezterm.action.ActivateTab(3) },
	{ key = "5", mods = "CTRL", action = wezterm.action.ActivateTab(4) },
	{ key = "6", mods = "CTRL", action = wezterm.action.ActivateTab(5) },
	{ key = "7", mods = "CTRL", action = wezterm.action.ActivateTab(6) },

	move_pane("j", "Down"),
	move_pane("k", "Up"),
	move_pane("h", "Left"),
	move_pane("l", "Right"),

	{
		key = "r",
		mods = "LEADER|CTRL",
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			one_shot = false,
			timeout_milliseconds = 1000,
		}),
	},

	-- zmx session picker
	{
		key = "p",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(zmx_session_picker),
	},

	-- Scratch workspace: show it, or go back to where the toggle was pressed
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action_callback(toggle_scratch_workspace),
	},

	-- Kill a zmx session
	{
		key = "k",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(function(window, pane)
			if not has_zmx then
				window:toast_notification("zmx", "zmx not available on this machine", nil, 3000)
				return
			end
			local success, stdout = wezterm.run_child_process({
				find_bin("zmx"),
				"list",
				"--short",
			})
			if not success or stdout == "" then
				return
			end

			local choices = {}
			for line in stdout:gmatch("[^\r\n]+") do
				local name = line:match("^%s*(.-)%s*$")
				if name and name ~= "" then
					table.insert(choices, { id = name, label = name })
				end
			end

			window:perform_action(
				wezterm.action.InputSelector({
					title = "Kill zmx Session",
					choices = choices,
					fuzzy = true,
					action = wezterm.action_callback(function(_, _, id, _)
						if not id then
							return
						end
						wezterm.run_child_process({
							find_bin("zmx"),
							"kill",
							id,
						})
					end),
				}),
				pane
			)
		end),
	},

	-- Open a new independent WezTerm instance (for side-by-side workflow)
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action_callback(function()
			wezterm.run_child_process({
				find_bin("wezterm"),
				"start",
				"--always-new-process",
			})
		end),
	},

	-- Search for C# stack traces
	{
		key = "H",
		mods = "LEADER|CTRL",
		action = wezterm.action.Search({
			Regex = [[(?: *)at (?:(?<namespace>[\w\d_.]*)\.)?(?<class>[\w\d_.]*(\.[\w\d_.<>]+)?)\.(?<method>[\w\d_\[\]<>]*)\((?:(?<parameter>[\w\d_]+(?:\[\]|&|\*)? [\w\d_]+)(?:, )?)*\)(?: *in *(?<file>[^:]+(?::[^:]+)?))?(?::line *(?<line>\d+))?]],
		}),
	},
	{
		key = "E",
		mods = "LEADER|CTRL",
		action = wezterm.action.Search({
			Regex = [[error [A-Z][A-Z][0-9]+:]],
		}),
	},

	-- Claude Code
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}

local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)
modal.set_default_keys(config)

wezterm.on("modal.enter", function(name, window, pane)
	modal.set_right_status(window, name)
	modal.set_window_title(pane, name)
end)

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function get_zmx_session(pane)
	local ok, vars = pcall(function()
		return pane:get_user_vars()
	end)
	if ok and vars and vars.zmx_session and vars.zmx_session ~= "" then
		return vars.zmx_session
	end
	return "local"
end

wezterm.on("modal.exit", function(name, window, pane)
	window:set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = colors.ansi[5] } },
		{ Text = get_zmx_session(pane) .. "  " },
	}))
	modal.reset_window_title(pane)
end)

wezterm.on("update-status", function(window, pane)
	local mode = window:active_key_table()
	if mode then
		window:set_right_status(wezterm.format({
			{ Background = { Color = "#101010" } },
			{ Foreground = { Color = "#faf9f5" } },
			{ Text = "  " .. mode:upper() .. "  " },
		}))
	else
		window:set_right_status(wezterm.format({
			{ Attribute = { Intensity = "Bold" } },
			{ Foreground = { Color = colors.ansi[5] } },
			{ Text = get_zmx_session(pane) .. "  " },
		}))
	end
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.active_pane.title
	local clean_title = basename(title)
	if clean_title == "" then
		clean_title = tab.tab_index + 1
	end
	return {
		{ Text = "  " .. clean_title .. "  " },
	}
end)

wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
