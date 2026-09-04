-- Reload Config
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
	hs.reload()
end)

-- Mute built-in speakers when on office Wi-Fi.
-- Never unmutes; only the built-in speakers are affected, headphones/docks are left alone.
local officeSSIDs = {
	["Pareto"] = true,
}

local function muteBuiltInSpeakers()
	for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
		if dev:transportType() == "Built-in" and not dev:outputMuted() then
			dev:setOutputMuted(true)
			hs.alert.show("Office Wi-Fi: built-in speakers muted")
		end
	end
end

local function onNetworkChange()
	local ssid = hs.wifi.currentNetwork()
	if ssid and officeSSIDs[ssid] then
		muteBuiltInSpeakers()
	end
end

wifiWatcher = hs.wifi.watcher.new(onNetworkChange):start()
onNetworkChange()

hs.alert.show("config loaded")
