local wezterm = require("wezterm")
local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

M.theme_switcher = function(window, pane)
	local schemes = wezterm.get_builtin_color_schemes()
	local choices = {}
	local config_path = "~/.config/wezterm/wezterm.lua"

	-- Populate theme names in choices list
	for key, _ in pairs(schemes) do
		table.insert(choices, { label = tostring(key) })
	end

	-- Sort choices list
	table.sort(choices, function(c1, c2)
		return c1.label < c2.label
	end)

	window:perform_action(
		act.InputSelector({
			title = "🎨 Pick a Theme!",
			choices = choices,
			fuzzy = true,
			action = act.callback(function(inner_window, inner_pane, _, label)
				inner_window:perform_action(
					act.SpawnCommandInNewTab({
						args = {
							"sed",
							"-i",
							'/^Colorscheme/c\\Colorscheme = "' .. label .. '"',
							config_path,
						},
					}),
					inner_pane
				)
			end),
		}),
		pane
	)
end

-- Define keybinds
local keybinds = {
	{
		key = "k",
		mods = "CMD|ALT",
		action = wezterm.action_callback(function(window, pane)
			M.theme_switcher(window, pane)
		end),
	},
}

return {
	keys = keybinds,
	theme_switcher = M.theme_switcher, -- Expose the theme switcher if needed elsewhere
}
