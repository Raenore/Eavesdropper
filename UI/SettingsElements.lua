-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperSettingsElements
local SettingsElements = {};

-- ============================================================
-- Header elements
-- ============================================================

---Creates a medium subtitle with an optional dynamic subtitle line
function SettingsElements.CreateSubTitle(parent, titleText, subTitleText, data)
	local container = CreateFrame("Frame", nil, parent);
	container:SetPoint("LEFT", parent, "LEFT");
	container:SetPoint("RIGHT", parent, "RIGHT");

	container.settingKey = data and data.settingKey or nil;

	-- Title
	local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1");
	local padding = Constants.SETTINGS.TITLE_OFFSET;

	if type(data) == "table" and data.icon then
		local iconSize = Constants.SETTINGS.TITLE_ICON_SIZE;
		local icon = CreateTextureMarkup(data.icon, 1, 1, iconSize, iconSize, 0, 1, 0, 1);
		titleText = icon .. " " .. (titleText or "");
	end

	title:SetText(titleText or "");
	title:SetJustifyH(Constants.SETTINGS.TITLE_JUSTIFY_H);
	title:SetPoint("TOPLEFT", container, "TOPLEFT", padding, 0);

	-- Subtitle (optional)
	local subTitle = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	local descTextColor = Constants.SETTINGS.DESC_TEXT_COLOR;
	subTitle:SetSpacing(4);
	subTitle:SetJustifyH(Constants.SETTINGS.TITLE_JUSTIFY_H);
	subTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8); -- spacing under title
	subTitle:SetTextColor(descTextColor, descTextColor, descTextColor);

	local function UpdateTextWidth()
		local containerWidth = parent:GetWidth() - (2 * padding);
		title:SetWidth(containerWidth);
		subTitle:SetWidth(containerWidth);
	end

	UpdateTextWidth();

	local function GetSubtitleText()
		if type(data) == "table" and type(data.get) == "function" then
			return data.get() or "";
		end
		return subTitleText or "";
	end

	container.Refresh = function(self)
		local text = GetSubtitleText();

		UpdateTextWidth();

		if text ~= "" then
			subTitle:SetText(text);
			subTitle:Show();
		else
			subTitle:SetText("");
			subTitle:Hide();
		end

		local titleHeight = title:GetStringHeight();
		local subHeight = subTitle:IsShown() and subTitle:GetStringHeight() or 0;

		-- Adjust container height to fit both title and subtitle
		local totalHeight = titleHeight + (subHeight > 0 and (subHeight + 8) or 0) + 5;

		container:SetHeight(totalHeight);
	end

	container:Refresh();

	return container;
end

-- ============================================================
-- Tooltip helpers
-- ============================================================

---Attaches a standard settings tooltip to a widget
function SettingsElements.AttachTooltip(frame, title, description, anchorFrame, anchor, isFocused)
	if not title or not description then return; end
	anchor = anchor or "ANCHOR_TOP";
	local target = anchorFrame or frame;

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(target, anchor);
		GameTooltip:SetText(title, WHITE_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end);

	frame:SetScript("OnLeave", function()
		if isFocused and isFocused() then return; end
		GameTooltip:Hide();
	end);
end

local AttachTooltip = SettingsElements.AttachTooltip;

local function AttachSliderTooltip(sliderWidget, title, description)
	if not sliderWidget or not title or not description then return; end

	local frames = { sliderWidget:GetParent(), sliderWidget, sliderWidget.Slider, sliderWidget.Back, sliderWidget.Forward, sliderWidget.RightText };
	for _, f in ipairs(frames) do
		if f then
			AttachTooltip(f, title, description, sliderWidget);
		end
	end
end

local function AttachMultiLineEditBoxTooltip(backdrop, scrollFrame, editBox, title, description, anchor)
	if not backdrop or not title or not description then return; end

	anchor = anchor or "ANCHOR_TOP";

	local function IsFocused()
		return editBox:HasFocus();
	end

	local frames = {
		backdrop,
		scrollFrame,
		editBox,
	};

	for _, f in ipairs(frames) do
		if f then
			AttachTooltip(f, title, description, backdrop, anchor, IsFocused);
		end
	end

	-- Keep tooltip visible while the edit box is focused
	editBox:HookScript("OnEditFocusGained", function()
		GameTooltip:SetOwner(backdrop, "ANCHOR_TOP");
		GameTooltip:SetText(title, WHITE_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end);

	editBox:HookScript("OnEditFocusLost", function()
		GameTooltip:Hide();
	end);
end

-- ============================================================
-- Shared layout helpers
-- ============================================================

---Creates a left-label / right-control pair anchored inside parent
---data.hideLabel leaves the label column empty (but is still used for tooltip title / header in dropdowns, etc.)
function SettingsElements.CreateLabeledFrame(parent, data)
	local labelText = not data.hideLabel and data.label or "";

	local left = CreateFrame("Frame", nil, parent);
	left:SetWidth(Constants.SETTINGS.LABEL_WIDTH);
	left:SetPoint("LEFT", parent, "LEFT", Constants.SETTINGS.OPTION_OFFSET_LEFT, 0);
	left:SetPoint("TOP", parent, "TOP");
	left:SetPoint("BOTTOM", parent, "BOTTOM");

	local right = CreateFrame("Frame", nil, parent);
	right:SetPoint("LEFT", left, "RIGHT", 0, 0);
	right:SetPoint("RIGHT", parent, "RIGHT", -Constants.SETTINGS.OPTION_OFFSET_RIGHT, 0);
	right:SetPoint("TOP", parent, "TOP");
	right:SetPoint("BOTTOM", parent, "BOTTOM");

	local label;
	if labelText ~= "" then
		label = left:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		label:SetPoint("LEFT", left, "LEFT", 0, 0);
		label:SetPoint("RIGHT", left, "RIGHT", -8, 0);
		label:SetJustifyH("LEFT");
		label:SetText(labelText);
	end

	return left, right, label;
end

local CreateLabeledFrame = SettingsElements.CreateLabeledFrame;

-- ============================================================
-- Widget constructors
-- ============================================================

---Creates a plain description font string anchored to the left of parent
function SettingsElements.CreateDescription(parent, descriptionText)
	local description = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	description:SetText(descriptionText or "");
	description:SetPoint("LEFT", parent, "LEFT", Constants.SETTINGS.OPTION_OFFSET_LEFT, 0);
	description:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);

	return description;
end

---Make the widget's label grey when disabled
local function SetupDisabledVisual(widget, label)
	widget:HookScript("OnEnable", function(self)
		if label then
			label:SetTextColor(1, 1, 1);
			if widget:IsObjectType("EditBox") then
				widget:SetTextColor(1, 1, 1);
			end
		end
	end);

	widget:HookScript("OnDisable", function(self)
		if label then
			local descTextColor = Constants.SETTINGS.DESC_TEXT_COLOR;
			label:SetTextColor(descTextColor, descTextColor, descTextColor);
			if widget:IsObjectType("EditBox") then
				widget:SetTextColor(descTextColor, descTextColor, descTextColor);
			end
		end
	end);
end

local function CreateCheckbox(parent, data)
	local _, right, label = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("CheckButton", nil, right, "SettingsCheckBoxTemplate");
	widget:SetPoint("LEFT", right);
	widget:SetSize(Constants.SETTINGS.WIDGET_HEIGHT, Constants.SETTINGS.WIDGET_HEIGHT);
	widget:SetMotionScriptsWhileDisabled(true);
	widget:EnableMouse(true);
	SetupDisabledVisual(widget, label);

	widget.settingKey = data.settingKey;

	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	widget.Refresh = function(self)
		if type(data.get) == "function" then
			self:SetChecked(data.get());
		end
		self:SetEnabled(not IsDisabled());
	end

	widget:SetScript("OnClick", function(self)
		if not self:IsEnabled() then return; end

		local checked = self:GetChecked();
		if type(data.get) == "function" and checked ~= data.get() then
			data.set(checked, self);
		end
	end);

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(widget, "checkbox");

	return widget;
end

local function CreateColorSwatch(parent, data)
	local _, right, label = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("Button", nil, right, "ColorSwatchTemplate");
	widget:SetPoint("LEFT", right);
	widget:SetSize(Constants.SETTINGS.WIDGET_HEIGHT, Constants.SETTINGS.WIDGET_HEIGHT);
	widget:SetMotionScriptsWhileDisabled(true);
	widget:EnableMouse(true);
	SetupDisabledVisual(widget, label);

	---@type { r:number, g:number, b:number, a:number }
	widget.currentColor = { r = 0, g = 1, b = 0, a = 1 };

	---@param color table
	local function ApplyColor(color)
		widget.currentColor = color;
		if widget.Color then
			widget.Color:SetColorTexture(
				color.r,
				color.g,
				color.b,
				color.a or 1
			);
		end
	end

	widget:SetScript("OnClick", function(_, button)
		if button ~= "LeftButton" then
			local resetColor = { r = 0, g = 1, b = 0, a = 1 };
			ApplyColor(resetColor);
			if type(data.set) == "function" then
				data.set(resetColor);
			end
			return;
		end

		local original = {
			r = widget.currentColor.r,
			g = widget.currentColor.g,
			b = widget.currentColor.b,
			a = widget.currentColor.a,
		};

		local function OnColorChanged()
			local r, g, b = ColorPickerFrame:GetColorRGB();
			local a = data.opacity and ColorPickerFrame:GetColorAlpha() or original.a;
			local newColor = { r = r, g = g, b = b, a = a };

			ApplyColor(newColor);

			if type(data.set) == "function" then
				data.set(newColor);
			end
		end

		ColorPickerFrame:SetupColorPickerAndShow({
			r = original.r,
			g = original.g,
			b = original.b,
			opacity = data.opacity and original.a or 1,
			hasOpacity = data.opacity and true or false,
			swatchFunc = OnColorChanged,
			opacityFunc = OnColorChanged,
			cancelFunc = function()
				ApplyColor(original);
				if type(data.set) == "function" then
					data.set(original);
				end
			end,
		});
	end);

	widget.Refresh = function(self)
		local color = type(data.get) == "function" and data.get() or nil;
		if type(color) ~= "table" then
			color = { r = 0, g = 1, b = 0, a = 1 };
		end
		ApplyColor(color);
	end

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	return widget;
end

local function CreateSlider(parent, data)
	local _, right, label = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("Slider", nil, right, "MinimalSliderWithSteppersTemplate");
	widget:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);
	widget:SetPoint("LEFT", right, "LEFT", 0, 0);
	widget:SetPoint("RIGHT", right, "RIGHT", -25, 0); -- leave space for RightText
	widget:SetPoint("CENTER", right, "CENTER");
	SetupDisabledVisual(widget.Slider, label);

	local minVal = data.min or 1;
	local maxVal = data.max or 10;
	local stepVal = data.step or 1;

	widget.Slider:SetMinMaxValues(minVal, maxVal);
	widget.Slider:SetValueStep(stepVal);
	widget:SetObeyStepOnDrag(true);
	widget.RightText:Show();

	widget.Back:SetMotionScriptsWhileDisabled(true);
	widget.Forward:SetMotionScriptsWhileDisabled(true);

	widget.settingKey = data.settingKey;

	---@return boolean
	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	---@param val number
	local function RoundToStep(val)
		return Round(val / stepVal) * stepVal;
	end

	---@param val number
	local function UpdateText(val)
		if widget.RightText then
			widget.RightText:SetText(string.format("%d", val));
		end
	end

	local lastValue;

	widget.Slider:SetScript("OnValueChanged", function(_, val)
		if IsDisabled() then return; end

		local rounded = RoundToStep(val);
		if rounded ~= lastValue then
			lastValue = rounded;
			UpdateText(rounded);

			if type(data.set) == "function" then
				data.set(lastValue);
			end
		end
	end);

	widget.Refresh = function(self)
		self:SetEnabled(not IsDisabled());
		widget.Slider:SetEnabled(not IsDisabled());
		widget.Back:SetEnabled(not IsDisabled());
		widget.Forward:SetEnabled(not IsDisabled());

		if type(data.get) == "function" then
			local val = RoundToStep(data.get());
			lastValue = val;
			widget.Slider:SetValue(val);
			UpdateText(val);
		end
	end

	widget:Refresh();

	if data.tooltip then
		AttachSliderTooltip(widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(widget, "slider");

	return widget;
end

local function CreateDropDown(parent, data)
	local _, right, label = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("DropdownButton", nil, right, "WowStyle1DropdownTemplate");
	widget:SetPoint("LEFT", right, "LEFT", 0, 0);
	widget:SetPoint("RIGHT", right, "RIGHT", 0, 0);
	widget:SetPoint("CENTER", right, "CENTER");
	widget:SetMotionScriptsWhileDisabled(true);
	SetupDisabledVisual(widget, label);

	widget.settingKey = data.settingKey;

	---@return boolean
	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	widget.Refresh = function(self)
		local disabled = IsDisabled();
		self:SetEnabled(not disabled);

		self:SetupMenu(function(_, root)
			local values = type(data.values) == "function" and data.values() or data.values or {};
			local sorting = data.sorting or {};

			root:CreateTitle(data.label);
			root:CreateDivider();

			if root.SetScrollMode then
				local optionHeight = 20; -- 20 is the default height.
				local maxLines = 20;
				local maxScrollExtent = optionHeight * maxLines;
				root:SetScrollMode(maxScrollExtent);
			end

			local entries = {};
			local defaultEntry = data.defaultEntry;

			if #sorting > 0 then
				for _, key in ipairs(sorting) do
					if values[key] then
						entries[#entries + 1] = { values[key], key };
					end
				end
			else
				local temp = {};
				for key, text in pairs(values) do
					temp[#temp + 1] = { key = key, label = text };
				end
				table.sort(temp, function(a, b)
					-- Pin the default entry above the alphabetical run.
					local aIsDefault = a.label == defaultEntry;
					local bIsDefault = b.label == defaultEntry;
					if aIsDefault ~= bIsDefault then
						return aIsDefault;
					end

					return a.label:lower() < b.label:lower();
				end);
				for _, item in ipairs(temp) do
					entries[#entries + 1] = { item.label, item.key };
				end
			end

			local function IsSelected(index)
				return type(data.get) == "function" and index == data.get();
			end

			local function SetSelected(index)
				if disabled then return; end
				if type(data.set) == "function" then
					data.set(index);
				end
			end

			-- Leading action rows, drawn with an inline icon like Blizzard's new layout entry:
			-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EditMode/Shared/EditModeLayoutManagerUtil.lua
			if data.actionEntries then
				for _, action in ipairs(data.actionEntries) do
					local iconSize = action.iconSize;
					local icon;

					if action.texture then
						icon = CreateTextureMarkup(action.texture, 1, 1, iconSize or 0, iconSize or 0, 0, 1, 0, 1);
					else
						icon = CreateAtlasMarkup(disabled and action.disabledAtlas or action.atlas, iconSize, iconSize);
					end

					local actionEntry = root:CreateButton(action.label:format(icon), action.func);
					actionEntry:SetEnabled(not disabled);

					if action.tooltip then
						-- Strip the icon and colour so the title reads like every other settings tooltip.
						local title = string.trim(ED.Utils.StripColorCodes(action.label:format("")));
						ED.Utils.SetMenuTooltip(actionEntry, action.tooltip, title);
					end
				end

				root:CreateDivider();
			end

			local disabledValues = type(data.disabledValues) == "function" and data.disabledValues() or data.disabledValues or {};
			for _, entry in ipairs(entries) do
				local text, value = entry[1], entry[2];
				local dropdownOption;

				-- Only the label is blue (Blizzard uses this to denote 'default' / 'base'/ 'starter')
				local isDefaultEntry = text == defaultEntry;
				local displayText = isDefaultEntry and BLUE_FONT_COLOR:WrapTextInColorCode(text) or text;

				local isEntryDisabled = disabled or (disabledValues[value] == true);
				if data.style == "button" then
					dropdownOption = root:CreateButton(displayText, SetSelected, value);
					dropdownOption:SetEnabled(not isEntryDisabled);
				else
					dropdownOption = root:CreateRadio(displayText, IsSelected, SetSelected, value);
					dropdownOption:SetEnabled(not isEntryDisabled);
				end

				-- Row gear/delete buttons follow Blizzard's Cooldown Manager layout rows:
				-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_CooldownViewer/CooldownViewerSettings.lua#L1092
				-- The default entry is permanently named and undeletable, so it only gets the gear.
				local showDelete = data.deleteButton and not isDefaultEntry;
				if data.gearButton or showDelete then
					if data.gearButton then
						-- Submenu entries are children of this row; DeactivateSubmenu stops hover from
						-- opening them so only the gear button does, through ForceOpenSubmenu below.
						local copyEntry = dropdownOption:CreateButton(L.PROFILES_COPYPROFILE, function()
							ED.CopyDialog.Show(text);
						end);
						ED.Utils.SetMenuTooltip(copyEntry, L.PROFILES_COPYPROFILE_HELP);

						if not isDefaultEntry then
							local renameEntry = dropdownOption:CreateButton(L.PROFILES_RENAMEPROFILE, function()
								ED.RenameDialog.Show(text);
							end);
							ED.Utils.SetMenuTooltip(renameEntry, L.PROFILES_RENAMEPROFILE_HELP);
						end

						dropdownOption:DeactivateSubmenu();
					end

					dropdownOption:AddInitializer(function(button, description, menu)
						local gearButton;

						if data.gearButton then
							gearButton = MenuTemplates.AttachAutoHideGearButton(button);
							MenuTemplates.SetUtilityButtonLockedEnabledState(gearButton, true);
							MenuTemplates.SetUtilityButtonAnchor(gearButton, MenuVariants.GearButtonAnchor, button);
							MenuTemplates.SetUtilityButtonClickHandler(gearButton, function()
								description:ForceOpenSubmenu();
							end);

							MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
								GameTooltip_SetTitle(tooltip, L.PROFILES_OPTIONS);
								GameTooltip_AddNormalLine(tooltip, L.PROFILES_OPTIONS_HELP);
							end);
						end

						if showDelete then
							local cancelButton = MenuTemplates.AttachAutoHideCancelButton(button);

							cancelButton.Texture:SetTexture(Constants.ICONS.STOP);

							MenuTemplates.SetUtilityButtonLockedEnabledState(cancelButton, true);
							MenuTemplates.SetUtilityButtonAnchor(cancelButton, MenuVariants.CancelButtonAnchor, gearButton or button);
							MenuTemplates.SetUtilityButtonClickHandler(cancelButton, function()
								-- Deleting the active profile also switches characters, so warn separately.
								local isCurrent = text == ED.Database:GetProfileName();
								local prompt = isCurrent and L.PROFILES_CONFIRM_DELETE_CURRENT or L.PROFILES_CONFIRM_DELETE;
								ED.ConfirmDialog.Show(prompt:format(text), function()
									ED.Database:DeleteProfile(text);
								end);
								menu:Close();
							end);

							MenuUtil.HookTooltipScripts(cancelButton, function(tooltip)
								GameTooltip_SetTitle(tooltip, L.PROFILES_DELETEPROFILE);
								GameTooltip_AddNormalLine(tooltip, L.PROFILES_DELETEPROFILE_HELP);
							end);
						end
					end);
				end
			end

			if data.style == "button" then
				self:OverrideText(data.defaultText and data.label or "");
			end
		end);
	end

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(widget, "dropdown");

	return widget;
end

local function CreateMultiLineEditBox(parent, data)
	local height = data.height or (Constants.SETTINGS.WIDGET_HEIGHT * 4);
	local labelScrollFrameDistance = 4;
	local extraBottomPadding = 10;

	local container = CreateFrame("Frame", nil, parent);
	container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
	container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0);

	local label;
	if data.label then
		label = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		label:SetPoint("TOPLEFT", container, "TOPLEFT", Constants.SETTINGS.OPTION_OFFSET_LEFT, 0);
		label:SetSize(container:GetWidth(), 20);
		label:SetJustifyH("LEFT");
		label:SetText(data.label);
	end

	local backdrop = CreateFrame("Frame", nil, container, "BackdropTemplate");
	if label then
		backdrop:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -labelScrollFrameDistance);
	else
		backdrop:SetPoint("TOPLEFT", container, "TOPLEFT", Constants.SETTINGS.OPTION_OFFSET_LEFT, 0);
	end
	backdrop:SetPoint("TOPRIGHT", container, "TOPRIGHT", -Constants.SETTINGS.OPTION_OFFSET_RIGHT, 0);
	backdrop:SetHeight(height);

	backdrop:SetBackdrop({
		bgFile = "Interface/ChatFrame/ChatFrameBackground",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	});
	backdrop:SetBackdropColor(0, 0, 0, 0.35);
	backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);


	local paddingLeft, paddingRight, paddingTop, paddingBottom = 5, 5, 5, 5;

	local scrollFrame = CreateFrame("ScrollFrame", nil, container, "ScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", backdrop, "TOPLEFT", paddingLeft, -paddingTop);
	scrollFrame:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -paddingRight, paddingBottom);
	scrollFrame:EnableMouseWheel(false);

	scrollFrame.ScrollBar:Hide();
	scrollFrame.ScrollBar:ClearAllPoints();
	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -6, -3);
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -6, 2);

	local editBox = CreateFrame("EditBox", nil, scrollFrame);
	editBox:SetMultiLine(true);
	editBox:SetAutoFocus(false);
	editBox:SetFontObject("ChatFontNormal");
	editBox:SetWidth(scrollFrame:GetWidth());
	editBox:SetHeight(height);
	local surroundingInset = 4; -- Text inset for left/top/bottom of the EditBox
	local rightInset = 24; -- Leave room for the ScrollBar on the right
	editBox:SetTextInsets(surroundingInset, rightInset, surroundingInset, surroundingInset);
	SetupDisabledVisual(editBox, label);

	scrollFrame:SetScrollChild(editBox);

	editBox:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0);

	editBox.settingKey = data.settingKey;
	editBox.savedThisEdit = false;

	---@return boolean
	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	editBox.Refresh = function(self)
		local disabled = IsDisabled();
		self:SetEnabled(not disabled);

		if disabled then
			self:ClearFocus();
		end

		if type(data.get) == "function" then
			self:SetText(data.get() or "");
			self:HighlightText(0, 0);
		end
	end

	if type(data.set) == "function" then
		local function SaveValue(self)
			if self.savedThisEdit then return; end
			self.savedThisEdit = true;

			local cleaned = ED.Utils.SanitizeKeywordInput(self:GetText());
			data.set(cleaned);
			self:SetText(cleaned);
		end

		editBox:SetScript("OnTextChanged", function(self)
			self.savedThisEdit = false;
			local max = scrollFrame:GetVerticalScrollRange();
			if max > 0 then
				scrollFrame.ScrollBar:Show();
			else
				scrollFrame.ScrollBar:Hide();
			end
			scrollFrame:SetVerticalScroll(max);
		end);

		editBox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus();
		end);

		editBox:SetScript("OnEnterPressed", function(self)
			self:ClearFocus();
		end);

		editBox:SetScript("OnEditFocusGained", function(self)
			scrollFrame:EnableMouseWheel(true);
		end);

		editBox:SetScript("OnEditFocusLost", function(self)
			scrollFrame:EnableMouseWheel(false);
			SaveValue(self);
		end);
	end

	backdrop:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			editBox:SetFocus();
		end
	end);

	scrollFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			editBox:SetFocus();
		end
	end);

	scrollFrame:SetScript("OnSizeChanged", function(self)
		editBox:SetWidth(self:GetWidth());
	end);

	if data.tooltip then
		AttachMultiLineEditBoxTooltip(backdrop, scrollFrame, editBox, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(scrollFrame.ScrollBar, "scrollbar");

	container.Refresh = function()
		editBox:Refresh();
	end

	local labelHeight = (label and label:GetStringHeight() + labelScrollFrameDistance) or 0;
	local widgetHeight = labelHeight + labelScrollFrameDistance + height + extraBottomPadding;
	container:SetHeight(widgetHeight);

	container:Refresh();

	return container, scrollFrame, widgetHeight;
end

local function CreateEditBox(parent, data)
	local _, right, label = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("EditBox", nil, right, "InputBoxTemplate");
	widget:SetAutoFocus(false);
	SetupDisabledVisual(widget, label);

	local visualOffsetLeft = 4; -- Workaround for border textures not aligned to frame. It will still be problematic when ElvUI skin is enabled.
	local visualOffsetRight = -1;
	widget:SetPoint("LEFT", right, "LEFT", visualOffsetLeft, 0);
	widget:SetPoint("RIGHT", right, "RIGHT", visualOffsetRight, 0);
	widget:SetPoint("CENTER", right, "CENTER");
	widget:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);
	widget:SetFontObject("ChatFontNormal");

	widget.settingKey = data.settingKey;

	---@return boolean
	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	widget.Refresh = function(self)
		local disabled = IsDisabled();
		self:SetEnabled(not disabled);

		if disabled then
			self:ClearFocus();
		end

		if type(data.get) == "function" then
			self:SetText(data.get() or "");
		end
	end

	if type(data.set) == "function" then
		if data.trigger == "focus" then
			widget:SetScript("OnEditFocusLost", function(self)
				if IsDisabled() then
					self:ClearFocus();
					return;
				end
				data.set(self:GetText());
			end);
		else
			widget:SetScript("OnEnterPressed", function(self)
				if IsDisabled() then
					self:ClearFocus();
					return;
				end
				data.set(self:GetText());
				self:SetText("");
				self:ClearFocus();
			end);
		end
	end

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(widget, "editbox");

	return widget;
end

local function CreateButton(parent, data)
	local _, right, label = CreateLabeledFrame(parent, { label = "" });

	local widget = CreateFrame("Button", nil, right, "UIPanelButtonTemplate");
	widget:SetAllPoints(right);
	widget:SetText(data.label or "Button");
	SetupDisabledVisual(widget, label);

	widget.settingKey = data.settingKey;

	---@return boolean
	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	widget.Refresh = function(self)
		self:SetEnabled(not IsDisabled());
	end

	if type(data.func) == "function" then
		widget:SetScript("OnClick", function(self, ...)
			if IsDisabled() then return; end
			data.func(self, ...);
		end);
	end

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(widget, "button");

	return widget;
end

-- ============================================================
-- Developer Info Frame
-- ============================================================

---@param parent table The parent frame to attach the frame to.
---@return Frame infoFrame The created infoFrame.
function SettingsElements.CreateDeveloperInfoFrame(parent)
	local infoFrame = CreateFrame("Frame", nil, parent);
	infoFrame:SetSize(240, 24);

	local text = ED.Globals.author;
	local characterName, server = string.match(text, "(%w+)%s*(%([%s%-%w%d)]+%))");
	if not characterName then
		characterName = text;
		server = "";
	end

	local authorNameFontString = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	authorNameFontString:SetText(string.format("%s |cffff17a9%s|r", L.AUTHOR_COLON, characterName));
	authorNameFontString:SetTextColor(0.8, 0.8, 0.8);
	authorNameFontString:SetPoint("LEFT", infoFrame, "LEFT", 0, 0);

	local authorServerFontString = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
	authorServerFontString:SetText(string.format("|cff808080%s|r", server));
	authorServerFontString:SetTextColor(0.8, 0.8, 0.8);
	authorServerFontString:SetPoint("LEFT", authorNameFontString, "RIGHT", 4, 0);

	local websites = {
		{name = "Bluesky", link = "https://bsky.app/profile/dawnsong.me", icon = "Bluesky.png", tooltip = L.ADDONINFO_BLUESKY_SHILL_HELP},
		{name = "CurseForge", link = "https://www.curseforge.com/wow/addons/eavesdropper", icon = "CurseForge.png"},
		{name = "Wago Addons", link = "https://addons.wago.io/addons/eavesdropper", icon = "Wago.png"},
	};

	local buttonSize = 24;
	local buttonGap = 6;

	for i, info in ipairs(websites) do
		local logoButton = ED.Utils.CreateLogoButton(infoFrame, info, buttonSize);
		logoButton:SetPoint("RIGHT", infoFrame, "RIGHT", (-#websites + i) * (buttonSize + buttonGap), 0);
	end

	return infoFrame;
end

-- ============================================================
-- Element factory
-- ============================================================

---Dispatches to the appropriate widget constructor based on data.type
function SettingsElements.CreateElement(parent, data)
	local frame = CreateFrame("Frame", nil, parent);
	frame:SetPoint("LEFT", 0, 0);
	frame:SetPoint("RIGHT", 0, 0);

	local widget;
	local height = Constants.SETTINGS.WIDGET_HEIGHT;

	if data.global then
		data.label = data.label .. "*";
		data.tooltip = data.tooltip .. L.GLOBAL_SETTING_TOOLTIP;
	end

	if data.type == "dropdown" then
		widget = CreateDropDown(frame, data);
	elseif data.type == "slider" then
		widget = CreateSlider(frame, data);
	elseif data.type == "editbox_multiline" then
		widget, _, height = CreateMultiLineEditBox(frame, data);
	elseif data.type == "checkbox" then
		widget = CreateCheckbox(frame, data);
	elseif data.type == "editbox" then
		widget = CreateEditBox(frame, data);
	elseif data.type == "button" then
		widget = CreateButton(frame, data);
	elseif data.type == "colorswatch" then
		widget = CreateColorSwatch(frame, data);
	end

	if data.buildAdded and ED.Utils.CheckNewlyAdded(data.buildAdded) then
		local newPip = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		widget.newPip = newPip;
		newPip:SetPoint("CENTER", widget, "TOPLEFT");
		newPip:SetText("|A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a");
	end

	frame:SetHeight(height);

	return frame, widget;
end

ED.SettingsElements = SettingsElements;
