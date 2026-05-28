-- Copyright The Eavesdropper Authors
-- Inspired by Sippy Cup
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperElvUI
ED.ElvUI = {};

local skinnableElements = {};

local ElvUI_E = nil; -- ElvUI[1]
local SkinsModule = nil;
local TooltipModule = nil;

---Refreshes the cached ElvUI module references in case ElvUI loads or unloads dynamically.
local function UpdateElvUICaches()
	ElvUI_E = ElvUI and ElvUI[1] or nil;
	SkinsModule = ElvUI_E and ElvUI_E:GetModule("Skins") or nil;
	TooltipModule = ElvUI_E and ElvUI_E:GetModule("Tooltip") or nil;
end

UpdateElvUICaches();

---@alias ElvUISkinType
---| "button"
---| "checkbox"
---| "dropdown"
---| "editbox"
---| "frame"
---| "icon"
---| "inset"
---| "scrollbar"
---| "slider"
---| "toptabbutton"

---Adds a UI element to the skinning queue, optionally triggering immediate skinning.
---@param element table UI frame or widget to skin.
---@param skinType ElvUISkinType Type of UI element.
---@param applyImmediately boolean If true, skinning is triggered immediately.
function ED.ElvUI.RegisterSkinnableElement(element, skinType, applyImmediately)
	table.insert(skinnableElements, { element = element, type = skinType });
	if applyImmediately then
		ED.ElvUI.SkinRegisteredElements();
	end
end

---Applies ElvUI skins to all queued elements, then clears the queue.
---Safely checks for ElvUI presence and required modules before acting.
function ED.ElvUI.SkinRegisteredElements()
	UpdateElvUICaches();

	if not ElvUI_E or not SkinsModule or not ED.Database:GetGlobalSetting("ElvUITheme") then
		return;
	end

	for _, item in ipairs(skinnableElements) do
		local element, skinType = item.element, item.type;
		if element then
			if skinType == Enums.ELVUI_SKIN_TYPE.BUTTON and SkinsModule.HandleButton then
				SkinsModule:HandleButton(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.CHECKBOX and SkinsModule.HandleCheckBox then
				SkinsModule:HandleCheckBox(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.DROPDOWN and SkinsModule.HandleDropDownBox then
				SkinsModule:HandleDropDownBox(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.EDITBOX and SkinsModule.HandleEditBox then
				SkinsModule:HandleEditBox(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.FRAME and SkinsModule.HandleFrame then
				SkinsModule:HandleFrame(element);
				-- Skin any child buttons inside the frame.
				for _, child in ipairs({ element:GetChildren() }) do
					if child:IsObjectType("Button") then
						SkinsModule:HandleButton(child);
					end
				end
				if element.ItemIcon and SkinsModule.HandleIcon then
					SkinsModule:HandleIcon(element.ItemIcon);
				end
			elseif skinType == Enums.ELVUI_SKIN_TYPE.ICON and SkinsModule.HandleIcon then
				SkinsModule:HandleIcon(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.INSET and SkinsModule.HandleInsetFrame then
				if element.NineSlice and element.NineSlice.SetTemplate then
					element.NineSlice:SetTemplate("Transparent");
				else
					SkinsModule:HandleInsetFrame(element);
				end
			elseif skinType == Enums.ELVUI_SKIN_TYPE.SCROLLBAR and SkinsModule.HandleTrimScrollBar then
				SkinsModule:HandleTrimScrollBar(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.SLIDER and SkinsModule.HandleStepSlider then
				SkinsModule:HandleStepSlider(element);
			elseif skinType == Enums.ELVUI_SKIN_TYPE.TOPTABBUTTON and SkinsModule.HandleTab then
				SkinsModule:HandleTab(element);
			end
		end
	end

	table.wipe(skinnableElements); -- Clear the queue after skinning.
end

---Applies ElvUI tooltip styling to the given tooltip frame.
---@param tooltip table Tooltip frame to style.
function ED.ElvUI.SkinTooltip(tooltip)
	UpdateElvUICaches();
	if not ElvUI_E or not SkinsModule or not ED.Database:GetGlobalSetting("ElvUITheme") then
		return;
	end

	if TooltipModule and TooltipModule.SetStyle then
		TooltipModule:SetStyle(tooltip);
	end
end
