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

ED.ScreenshotHelper = ScreenshotHelper;
