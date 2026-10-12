-- Copyright The Eavesdropper Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: GPL-3.0-or-later

---@class EavesdropperGlobals
---@field DEBUG_MODE boolean
---@field addon_title string
---@field addon_version string
---@field addon_icon_texture string
---@field addon_wow_icon_texture number
---@field addon_settings_icon string
---@field addon_build string
---@field author string
---@field initialized boolean
---@field magnifier_nil_throttle number
---@field player_character_name string?
---@field player_sender_name string?
---@field player_guid string?
---@field empty table
---@field addon table?
ED.Globals = {
	--@debug@
	DEBUG_MODE = true,
	--@end-debug@

	--[===[@non-debug@
	DEBUG_MODE = false,
	--@end-non-debug@]===]

	initialized = false,

	addon_title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title"),
	addon_version = C_AddOns.GetAddOnMetadata("Eavesdropper", "Version"),
	addon_icon_texture = C_AddOns.GetAddOnMetadata("Eavesdropper", "IconTexture"),
	addon_wow_icon_texture = 4419345,
	addon_settings_icon = "|TInterface\\AddOns\\Eavesdropper\\Resources\\SmallLogo32:14:14|t",
	addon_build = C_AddOns.GetAddOnMetadata("Eavesdropper", "X-Build"),
	author = C_AddOns.GetAddOnMetadata("Eavesdropper", "Author"),

	magnifier_nil_throttle = 0.5,

	empty = {},
};

local emptyMeta = {
	__newindex = function(_, _, _) end,
};
setmetatable(ED.Globals.empty, emptyMeta);

ED.Globals.addon = ED_Addon;
