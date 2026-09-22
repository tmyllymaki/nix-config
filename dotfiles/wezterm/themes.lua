-- Official palettes exported by each theme project (extras/wezterm in the
-- kanso.nvim and kanagawa-paper.nvim repos; github-nvim-theme has none, so
-- those follow the GitHub Primer terminal colors).
--
-- Family names are duplicated in three places and must stay in sync:
--   modules/home/wezterm.nix          (enum for custom.home.wezterm.theme)
--   ~/.config/nvim/init.lua           (theme_pairs in the Colorscheme section)
--   dotfiles/.config/fish/config.fish (theme file names)
local schemes = {
	["kanso-ink"] = {
		foreground = "#C5C9C7",
		background = "#14171d",
		cursor_bg = "#C5C9C7",
		cursor_fg = "#14171d",
		cursor_border = "#C5C9C7",
		selection_fg = "#C5C9C7",
		selection_bg = "#393B44",
		scrollbar_thumb = "#393B44",
		split = "#393B44",
		ansi = { "#14171d", "#C4746E", "#8A9A7B", "#C4B28A", "#8BA4B0", "#A292A3", "#8EA4A2", "#A4A7A4" },
		brights = { "#A4A7A4", "#E46876", "#87A987", "#E6C384", "#7FB4CA", "#938AA9", "#7AA89F", "#C5C9C7" },
	},
	["kanso-pearl"] = {
		foreground = "#22262D",
		background = "#F2F1EF",
		cursor_bg = "#22262D",
		cursor_fg = "#F2F1EF",
		cursor_border = "#C5C9C7",
		selection_fg = "#22262D",
		selection_bg = "#E2E1DF",
		scrollbar_thumb = "#43464E",
		split = "#43464E",
		ansi = { "#22262D", "#c84053", "#6f894e", "#77713f", "#4d699b", "#b35b79", "#597b75", "#545464" },
		brights = { "#6d6f6e", "#d7474b", "#6e915f", "#836f4a", "#6693bf", "#624c83", "#5e857a", "#43436c" },
	},
	["kanagawa-paper-ink"] = {
		foreground = "#DCD7BA",
		background = "#1F1F28",
		cursor_bg = "#c4b28a",
		cursor_border = "#c4b28a",
		cursor_fg = "#1F1F28",
		selection_bg = "#363646",
		selection_fg = "#DCD7BA",
		split = "#8992a7",
		compose_cursor = "#8ea49e",
		scrollbar_thumb = "#363646",
		ansi = { "#393836", "#c4746e", "#699469", "#c4b28a", "#435965", "#a292a3", "#8ea49e", "#C8C093" },
		brights = { "#aca9a4", "#cc928e", "#72a072", "#d4c196", "#698a9b", "#b4a7b5", "#96ada7", "#d5cd9d" },
		indexed = { [16] = "#b6927b", [17] = "#c4746e" },
		tab_bar = {
			background = "#2A2A37",
			inactive_tab_edge = "#658594",
			active_tab = { fg_color = "#c4b28a", bg_color = "#1F1F28", intensity = "Bold" },
			inactive_tab = { fg_color = "#9e9b93", bg_color = "#2A2A37" },
			inactive_tab_hover = { fg_color = "#a292a3", bg_color = "#1F1F28" },
			new_tab = { fg_color = "#9e9b93", bg_color = "#2A2A37" },
			new_tab_hover = { fg_color = "#a292a3", bg_color = "#1F1F28", intensity = "Bold" },
		},
	},
	["kanagawa-paper-canvas"] = {
		foreground = "#73787d",
		background = "#e1e1de",
		cursor_bg = "#7e8faf",
		cursor_border = "#7e8faf",
		cursor_fg = "#e1e1de",
		selection_bg = "#d4cdd4",
		selection_fg = "#73787d",
		split = "#9ba1bf",
		compose_cursor = "#7e8faf",
		scrollbar_thumb = "#cbc8bc",
		ansi = { "#8e8a80", "#c27672", "#7b958e", "#a7956a", "#809ba7", "#9e7e98", "#7e8faf", "#aeaea6" },
		brights = { "#99958a", "#c68582", "#84a098", "#b29f71", "#91b0bd", "#a989a3", "#8a9ab8", "#b6b6ae" },
		indexed = { [16] = "#b28d77", [17] = "#c27672" },
		tab_bar = {
			background = "#d1cfc5",
			inactive_tab_edge = "#7e8faf",
			active_tab = { fg_color = "#7e8faf", bg_color = "#e1e1de", intensity = "Bold" },
			inactive_tab = { fg_color = "#8e8a80", bg_color = "#d1cfc5" },
			inactive_tab_hover = { fg_color = "#9e7e98", bg_color = "#e1e1de" },
			new_tab = { fg_color = "#8e8a80", bg_color = "#d1cfc5" },
			new_tab_hover = { fg_color = "#9e7e98", bg_color = "#e1e1de", intensity = "Bold" },
		},
	},
	["github-dark"] = {
		background = "#30363d",
		foreground = "#e6edf3",
		cursor_bg = "#e6edf3",
		cursor_border = "#e6edf3",
		cursor_fg = "#30363d",
		selection_bg = "#33588a",
		selection_fg = "#e6edf3",
		ansi = { "#484f58", "#ff7b72", "#3fb950", "#d29922", "#58a6ff", "#bc8cff", "#39c5cf", "#b1bac4" },
		brights = { "#6e7681", "#ffa198", "#56d364", "#e3b341", "#79c0ff", "#d2a8ff", "#56d4dd", "#ffffff" },
	},
	["github-light"] = {
		background = "#ffffff",
		foreground = "#1F2328",
		cursor_bg = "#1F2328",
		cursor_border = "#1F2328",
		cursor_fg = "#ffffff",
		selection_bg = "#bbdfff",
		selection_fg = "#1F2328",
		ansi = { "#24292f", "#cf222e", "#116329", "#4d2d00", "#0969da", "#8250df", "#1b7c83", "#6e7781" },
		brights = { "#57606a", "#a40e26", "#1a7f37", "#633c01", "#218bff", "#a475f9", "#3192aa", "#8c959f" },
	},
}

local families = {
	kanso = { dark = "kanso-ink", light = "kanso-pearl" },
	["kanagawa-paper"] = { dark = "kanagawa-paper-ink", light = "kanagawa-paper-canvas" },
	github = { dark = "github-dark", light = "github-light" },
}

local default_family = "kanso"

-- Pick the theme family from an explicit value, then a one-line file, then
-- the default. Unknown names fall back to the default.
local function resolve_family(explicit, file_path)
	local candidate = explicit
	if not candidate or candidate == "" then
		local f = io.open(file_path)
		if f then
			candidate = f:read("*l")
			f:close()
		end
	end
	if candidate and families[candidate] then
		return candidate
	end
	return default_family
end

-- Schemes without upstream tab bar colors get a flat bar in the scheme's own
-- colors, so the retro tab bar never falls back to WezTerm's grey defaults.
local function with_tab_bar(scheme)
	if scheme.tab_bar then
		return scheme
	end
	local inactive = { fg_color = scheme.brights[1], bg_color = scheme.background }
	local hover = { fg_color = scheme.foreground, bg_color = scheme.selection_bg }
	scheme.tab_bar = {
		background = scheme.background,
		active_tab = { fg_color = scheme.foreground, bg_color = scheme.background, intensity = "Bold" },
		inactive_tab = inactive,
		inactive_tab_hover = hover,
		new_tab = inactive,
		new_tab_hover = hover,
	}
	return scheme
end

return {
	schemes = schemes,
	families = families,
	default_family = default_family,
	resolve_family = resolve_family,
	with_tab_bar = with_tab_bar,
}
