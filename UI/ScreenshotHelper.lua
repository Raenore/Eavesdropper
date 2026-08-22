-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@class EavesdropperScreenshotHelper
local ScreenshotHelper = {};

---Frames rendering above the fullscreen backdrop, which have to be hidden manually
local externalFrames = {
	"PTR_IssueReporter",
};

---Frames hidden on entering a mode, restored when it is exited
local hiddenFrames = {};

---Store FontStyle/FontObject original color
local FontStyles = {
	"UserScaledFontGameNormal",
	"UserScaledFontGameDisable",
	"UserScaledFontGameHighlight",
	"GameFontNormal",
	"GameFontDisable",
	"GameFontHighlight",
};

local FontStyleColorBackup = {};

for _, fontStyleName in ipairs(FontStyles) do
	local object = _G[fontStyleName];
	if object then
		FontStyleColorBackup[object] = {object:GetTextColor()};
	end
end

---Colorize an object and all their children
---@param object any
---@param colorize boolean
---@param colorValue number
function ScreenshotHelper.SetupObjectColor(object, colorize, colorValue)
	if object:IsObjectType("FontString") then
		local text = object:GetText();
		if text then
			-- Change the vertex color for Texture/Atlas escape sequences
			local textureFound;

			local sequence = string.match(text, "|A:([^|]+)|a");
			while sequence do
				local atlas, height, width, offsetX, offsetY = string.split(":", sequence);
				local r, g, b;
				if colorize then
					local vertexColor = math.floor(colorValue * 255);
					r, g, b = vertexColor, vertexColor, vertexColor;
				else
					r, g, b = 255, 255, 255;
				end
				sequence = string.gsub(sequence, "%-", "%%-");
				text = string.gsub(text, "|A:"..sequence.."|a", string.format("|AA:%s:%s:%s:%s:%s:%s:%s:%s|a", atlas, height or 0, width or 0, offsetX or 0, offsetY or 0, r or 255, g or 255, b or 255), 1);
				sequence = string.match(text, "|A:([^|]+)|a");
				textureFound = true;
			end

			sequence = string.match(text, "|T([^|]+)|t");
			while sequence do
				local path, height, width, offsetX, offsetY, textureWidth, textureHeight, leftTexel, rightTexel, topTexel, bottomTexel = string.split(":", sequence);
				local r, g, b;
				if colorize then
					local vertexColor = math.floor(colorValue * 255);
					r, g, b = vertexColor, vertexColor, vertexColor;
				else
					r, g, b = 255, 255, 255;
				end
				sequence = string.gsub(sequence, "%-", "%%-");
				text = string.gsub(text, "|T"..sequence.."|t", string.format("|Z%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s|z", path, height or 0, width or 0, offsetX or 0, offsetY or 0, textureWidth or 16, textureHeight or 16, leftTexel or 0, rightTexel or 16, topTexel or 0, bottomTexel or 16, r or 255, g or 255, b or 255), 1);
				sequence = string.match(text, "|T([^|]+)|t");
				textureFound = true;
			end

			if textureFound then
				text = string.gsub(text, "|AA", "|A");
				text = string.gsub(text, "|Z", "|T");
				text = string.gsub(text, "|z", "|t");
				object:SetText(text);
			end
		end

		if colorize then
			if not object.originalColor then
				local r, g, b = object:GetTextColor();
				object.originalColor = {r = r, g = g, b = b};
			end
			object:SetTextColor(colorValue, colorValue, colorValue);
			object:SetFixedColor(true);
		else
			if object.originalColor then
				local color = object.originalColor;
				object:SetTextColor(color.r, color.g, color.b);
				object.originalColor = nil;
			end
			object:SetFixedColor(false);

			-- Restore fontObject color. Fix things like StaticPopupButton.
			-- Only button labels take their color from the font object; any other
			-- FontString keeps the color it was given, so it must not be overwritten.
			local parent = object:GetParent();
			if parent and parent.GetFontString and parent:GetFontString() == object then
				local fontObject = object:GetFontObject();
				if FontStyleColorBackup[fontObject] then
					object:SetTextColor(unpack(FontStyleColorBackup[fontObject]));
				end
			end
		end
	elseif object:IsObjectType("Texture") then
		if colorize then
			if not object.originalColor then
				local r, g, b = object:GetVertexColor();
				object.originalColor = {r = r, g = g, b = b};
			end
			object:SetVertexColor(colorValue, colorValue, colorValue);
		else
			if object.originalColor then
				local color = object.originalColor;
				object:SetVertexColor(color.r, color.g, color.b);
				object.originalColor = nil;
			end
		end
	end

	if object.GetRegions then
		for _, region in ipairs({object:GetRegions()}) do
			ScreenshotHelper.SetupObjectColor(region, colorize, colorValue);
		end
	end

	if object.GetChildren then
		for _, child in ipairs({object:GetChildren()}) do
			ScreenshotHelper.SetupObjectColor(child, colorize, colorValue);
		end
	end

	if object:IsObjectType("EditBox") then
		if colorize then
			object:SetHighlightColor(0, 0, 0, 1);
		else
			object:SetHighlightColor(0.3764, 0.3764, 0.3764, 1);
		end
	end
end

---Colorize an object by alphaChannelMode
---@param object any
---@param alphaChannelMode number|nil
function ScreenshotHelper.SetupObjectColorByMode(object, alphaChannelMode)
	-- mode 1: All Widgets turn black + white fullscreen backdrop
	-- mode 2: Widgets use original colors + black fullscreen backdrop
	-- other : Disable

	local colorize = alphaChannelMode == 1;
	local colorValue = alphaChannelMode == 1 and 0 or 1;
	ScreenshotHelper.SetupObjectColor(object, colorize, colorValue);
end

---Hide frames the fullscreen backdrop cannot cover, or restore the ones we hid
---@param hide boolean
function ScreenshotHelper.SetExternalFramesHidden(hide)
	if hide then
		for _, frameName in ipairs(externalFrames) do
			local frame = _G[frameName];
			if frame and frame.IsShown and frame:IsShown() then
				hiddenFrames[#hiddenFrames + 1] = frame;
				frame:Hide();
			end
		end
	else
		for _, frame in ipairs(hiddenFrames) do
			frame:Show();
		end
		wipe(hiddenFrames);
	end
end

function ScreenshotHelper.SetAlphaChannelMode(alphaChannelMode)
	ScreenshotHelper.SetExternalFramesHidden(alphaChannelMode == 1 or alphaChannelMode == 2);

	if not ED.SettingsFrame then
		ED.Settings:Init();
	end

	if ED.SettingsFrame then
		if alphaChannelMode then
			ED.SettingsFrame:Show();
		end
		ED.SettingsFrame:SetAlphaChannelMode(alphaChannelMode);
	end

	if ED.Frame:IsVisible() then
		ED.Frame:SetAlphaChannelMode(alphaChannelMode);
	else
		ED.Frame:SetAlphaChannelMode(nil);
	end

	ED.DedicatedFrame:ForEachFrame(function(frame)
		if frame:IsVisible() then
			frame:SetAlphaChannelMode(alphaChannelMode);
		else
			frame:SetAlphaChannelMode(nil);
		end
	end);

	ED.GroupFrame:ForEachFrame(function(frame)
		if frame:IsVisible() then
			frame:SetAlphaChannelMode(alphaChannelMode);
		else
			frame:SetAlphaChannelMode(nil);
		end
	end);

	local importExportDialog = ED.ImportExportDialog and ED.ImportExportDialog.frame;
	if importExportDialog then
		if importExportDialog:IsVisible() then
			importExportDialog:SetAlphaChannelMode(alphaChannelMode);
		else
			importExportDialog:SetAlphaChannelMode(nil);
		end
	end

	if GameTooltip:IsVisible() then
		ED.ScreenshotHelper.SetupObjectColorByMode(GameTooltip, alphaChannelMode);
	end

	-- StaticPopup frames are shared with Blizzard and other addons, so only the ones
	-- currently showing one of our own dialogs are touched
	local index = 1;
	local dialog = _G["StaticPopup" .. index];
	while dialog do
		if dialog:IsVisible() and dialog.which and string.find(dialog.which, "EAVESDROPPER", 1, true) == 1 then
			ED.ScreenshotHelper.SetupObjectColorByMode(dialog, alphaChannelMode);
		end

		index = index + 1;
		dialog = _G["StaticPopup" .. index];
	end

	if Menu.GetManager():IsAnyMenuOpen() then
		local openMenu = Menu.GetManager():GetOpenMenu();
		if openMenu then
			ED.ScreenshotHelper.SetupObjectColorByMode(openMenu, alphaChannelMode);

			-- To modify submenu, hover the cursor over a button on the submenu then call this function again
			local foci = GetMouseFoci();
			if foci and foci[1] then
				local objectParent = foci[1]:GetParent();
				if objectParent and objectParent.GetPoint then
					local _, relativeTo = objectParent:GetPoint(1);
					if relativeTo and relativeTo.GetParent and relativeTo:GetParent() == openMenu then
						ED.ScreenshotHelper.SetupObjectColorByMode(objectParent, alphaChannelMode);
					end
				end
			end
		end
	end
end

---Hide various of UI element
---@param bitmask number? Select extra UI element to hide. `ActionBar, Minimap`
function ScreenshotHelper.HideDistractions(bitmask)
	local optionalBlockedRolesets = {
		"actionBars",
		"minimap",
	};

	local objects = {
		TargetFrame.TargetFrameContent.TargetFrameContentContextual,  --Target's Auras
		PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual,  --Animated Zzz, Leader Crown
		PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture,  --Portrait Flash
		WarlockPowerFrame,
		RogueComboPointBarFrame,
		PTR_IssueReporter,
		HousingControlsFrame,
	};

	for _, obj in ipairs(objects) do
		if obj then
			obj:Hide();
		end
	end

	local blockedRolesets = {
		"arenaFrames",
		"bags",
		"buffs",
		"cooldownViewers",
		"encounterUI",
		"extraAbilities",
		"microMenu",
		"objectives",
		"pvp",
		"statusBars",
		"widgets",
	};

	bitmask = bitmask or 0;

	for index, tag in ipairs(optionalBlockedRolesets) do
		if bit.band(1, bit.arshift(bitmask, index - 1)) == 1 then
			table.insert(blockedRolesets, tag);
		end
	end

	local allowedRolesets = {};

	C_Roleset.ApplyRolesetFilters(blockedRolesets, allowedRolesets);
end

---Toggle a full-screen background ON/OFF
---
---Save the file as png under `Interface/AddOns/Eavesdropper/Assets/Base`, the file name must start with `EDBG`
---@param fileIndex number|string? Example: `1` for `EDBG1.png`
function ScreenshotHelper.ToggleFullScreenBackground(fileIndex)
	local frame = ScreenshotHelper.FullScreenBackground;
	if not frame then
		frame = CreateFrame("Frame", nil, UIParent);
		frame:Hide();
		frame:SetAllPoints(true);
		frame:SetFrameStrata("BACKGROUND");
		frame.Texture = frame:CreateTexture();
		frame.Texture:SetAllPoints(true);
		ScreenshotHelper.FullScreenBackground = frame;
	end

	local filePath = "Interface/AddOns/Eavesdropper/Assets/Base/EDBG%s.png";
	frame.Texture:SetTexture(string.format(filePath, fileIndex or ""));
	frame:SetShown(not frame:IsShown());
end

ED.ScreenshotHelper = ScreenshotHelper;
