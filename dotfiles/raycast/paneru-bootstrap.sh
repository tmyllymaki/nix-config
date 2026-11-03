#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Bootstrap Workspaces
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟
# @raycast.packageName Paneru
# @raycast.description Start my apps and move them to their Paneru workspaces.

# Starts every app below that is not running, waits for its first window, then
# presses cmd-ctrl-shift-b, the bootstrap chord in dotfiles/paneru/init.lua.
# The workspace for each app is set there, in `app_workspaces`. Pressing the
# chord needs Raycast to have Accessibility access.

paneru=/opt/homebrew/bin/paneru

apps=(
	"com.mitchellh.ghostty"
	"com.vivaldi.Vivaldi"
	"com.tinyspeck.slackmacgap"
	"com.microsoft.teams2"
	"org.whispersystems.signal-desktop"
	"net.whatsapp.WhatsApp"
	"com.spotify.client"
	"com.1password.1password"
)

has_window() {
	"$paneru" query state --json |
		jq -e --arg bundle "$1" '[.virtual_workspaces[].windows[] | select(.bundle_id == $bundle)] | length > 0' >/dev/null
}

for bundle in "${apps[@]}"; do
	open -g -b "$bundle"
done

# Give slow starters (Teams, Slack) up to 30 seconds to open a window.
for _ in $(seq 30); do
	missing=0
	for bundle in "${apps[@]}"; do
		has_window "$bundle" || missing=1
	done
	[ "$missing" = 0 ] && break
	sleep 1
done

# key code 11 is "b"
osascript -e 'tell application "System Events" to key code 11 using {command down, control down, shift down}'

echo "Workspaces bootstrapped"
