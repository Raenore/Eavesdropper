-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperScreenshotHelper
local ScreenshotHelper = {};

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

function ScreenshotHelper.SetAlphaChannelMode(alphaChannelMode)
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

	if GameTooltip:IsVisible() then
		ED.ScreenshotHelper.SetupObjectColorByMode(GameTooltip, alphaChannelMode);
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

ED.ScreenshotHelper = ScreenshotHelper;
