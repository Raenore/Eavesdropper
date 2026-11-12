-- Copyright The Eavesdropper Authors
-- Inspired by Sippy Cup
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

if not C_AddOns.IsAddOnLoaded("totalRP3") then
	return;
end

-- Flags TRP3 as safe to call for the rest of the addon.
-- Not in onStart, so that disabling the Eavesdropper module inside TRP3 does not disable it.
TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
	ED.MSP.SetTRPReady();
end);

-- Drops cached MSP data when TRP3's register changes. Not in onStart, for the same reason.
TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.REGISTER_DATA_UPDATED, function(_, unitID)
	-- A nil unitID means some profile changed without telling us which character, so the only
	-- safe answer is to drop everything. This is probably very rare, but let's still handle it.
	if not unitID then
		ED.MSP.InvalidateCache();
		return;
	end

	ED.MSP.InvalidatePlayer(unitID);
end);

---Registers the Eavesdropper toolbar button once TRP3's workflow is fully loaded.
local function OnStart()
	TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
		if not TRP3_API.toolbar then return; end

		TRP3_API.toolbar.toolbarAddButton{
			id = "trp3_eavesdropper",
			icon = ED.Globals.addon_wow_icon_texture,
			configText = ED.Globals.addon_title,
			tooltip = ED.Globals.addon_title,
			tooltipSub = L.ADDON_TOOLTIP_HELP,
			onClick = function(_, _, button)
				ED.Minimap.OnClick(nil, button);
			end,
		};
	end);
end

-- Module Registration
TRP3_API.module.registerModule({
	["name"] = "Eavesdropper",
	["description"] = "Adds a toolbar button to open Eavesdropper easily.",
	["version"] = ED.Globals.addon_version,
	["id"] = "trp_eavesdropper",
	["onStart"] = OnStart,
	["minVersion"] = 3,
});
