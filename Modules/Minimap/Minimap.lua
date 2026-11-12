-- Copyright The Eavesdropper Authors
-- Inspired by Sippy Cup
-- SPDX-License-Identifier: GPL-3.0-or-later

local Localization = ED.Localization;

---@class EavesdropperMinimap
local Minimap = {};

local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1");
local LibDBCompartment = LibStub:GetLibrary("LibDBCompartment-1.0");
local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0");

---Handles minimap/compartment button clicks.
---@param self table
---@param button string
function Minimap.OnClick(self, button) -- luacheck: no unused (self)
	if not IsShiftKeyDown() then
		if button == "LeftButton" then
			ED.Settings.ToggleSettings();
		elseif button == "RightButton" then
			ED.Settings.OpenSettings(Localization.PROFILES_TITLE);
		end
	elseif button == "LeftButton" then
		ED.Frame:SetShown(not ED.Frame:IsShown());
		ED.Database:SetCharSetting("WindowVisible", ED.Frame:IsShown());
	elseif button == "RightButton" then
		if ED.MentionsFrame:IsShown() then
			ED.MentionsFrame:Hide();
		else
			ED.MentionsFrame:Open();
		end
	end
end

---Populates the LDB tooltip with the addon title, version, and help text.
---@param tooltip table
local function OnTooltipShow(tooltip)
	tooltip:AddDoubleLine(ED.Globals.addon_title, ED.Globals.addon_version, nil, nil, nil, 1, 1, 1);
	tooltip:AddLine(Localization.ADDON_TOOLTIP_HELP);
end

---Initialises and registers the addon's minimap icon and addon compartment button.
function Minimap.SetupMinimapButtons()
	local ldb = LibDataBroker:NewDataObject(ED.Globals.addon_title, {
		type = "launcher",
		icon = ED.Globals.addon_icon_texture,
		tocname = ED.Globals.addon_title,
		OnClick = Minimap.OnClick,
		OnTooltipShow = OnTooltipShow,
	});

	---@type EavesdropperGlobalMinimapButton
	local minimapSettings = ED.Database:GetGlobalSetting("MinimapButton");

	LibDBIcon:Register(ED.Globals.addon_title, ldb, minimapSettings);
	LibDBCompartment:Register(ED.Globals.addon_title, ldb);

	Minimap.UpdateMinimapButtons();
end

---Refreshes the visibility of the minimap icon and compartment button from current settings.
function Minimap.UpdateMinimapButtons()
	---@type EavesdropperGlobalMinimapButton
	local minimapSettings = ED.Database:GetGlobalSetting("MinimapButton");

	if minimapSettings and not minimapSettings.Hide then
		LibDBCompartment:SetShown(ED.Globals.addon_title, minimapSettings.ShowAddonCompartmentButton);
		LibDBIcon:Refresh(ED.Globals.addon_title);
	else
		LibDBCompartment:Hide(ED.Globals.addon_title);
		LibDBIcon:Hide(ED.Globals.addon_title);
	end
end

ED.Minimap = Minimap;
