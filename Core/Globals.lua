-- Copyright The Eavesdropper Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

ED.Globals = {
	--@debug@
	DEBUG_MODE = true,
	--@end-debug@

	--[===[@non-debug@
	DEBUG_MODE = false,
	--@end-non-debug@]===]

	addon_title = C_AddOns.GetAddOnMetadata("Eavesdropper", "Title"),
	addon_version = C_AddOns.GetAddOnMetadata("Eavesdropper", "Version"),
	addon_icon_texture = C_AddOns.GetAddOnMetadata("Eavesdropper", "IconTexture"),
	addon_wow_icon_texture = 7549113;
	addon_settings_icon = "|TInterface\\AddOns\\Eavesdropper\\Resources\\SmallLogo32:14:14|t";
	addon_build = C_AddOns.GetAddOnMetadata("Eavesdropper", "X-Build"),
	author = C_AddOns.GetAddOnMetadata("Eavesdropper", "Author"),

	magnifier_nil_throttle = 0.5,

	empty = {},
};

local emptyMeta = {
	__newindex = function(_, _, _) end
};
setmetatable(ED.Globals.empty, emptyMeta);

ED.Globals.addon = ED_Addon;
