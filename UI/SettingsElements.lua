-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperConstants
local Constants = ED.Constants;

---@class EavesdropperSettingsElements
local SettingsElements = {};

function SettingsElements.CreateTitleWithDescription(parent, titleText, descriptionText)
	local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOPLEFT", 20, -8);
	title:SetText(titleText or "");

	local description = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8);
	description:SetWidth(parent:GetWidth() - 32);
	description:SetJustifyH("LEFT");
	description:SetText(descriptionText or "");

	return description;
end

function SettingsElements.CreateTitle(parent, titleText)
	local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOPLEFT", 20, -8);
	title:SetText(titleText or "");

	return title;
end

function SettingsElements.CreateSubTitle(parent, titleText, subTitleText)
	local container = CreateFrame("Frame", nil, parent);
	container:SetWidth(parent:GetWidth());

	-- Title
	local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1");
	title:SetText(titleText or "");
	title:SetJustifyH("CENTER");
	title:SetPoint("TOP", container, "TOP", 0, 0);
	title:SetWidth(container:GetWidth());
	title:SetHeight(title:GetStringHeight());

	-- Subtitle (optional)
	local subTitle;
	if subTitleText and subTitleText ~= "" then
		subTitle = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		subTitle:SetSpacing(4);
		subTitle:SetText(subTitleText);
		subTitle:SetJustifyH("CENTER"); -- center horizontally
		subTitle:SetPoint("TOP", title, "BOTTOM", 0, -8); -- spacing under title
		subTitle:SetWidth(container:GetWidth() - 8);
		subTitle:SetHeight(subTitle:GetStringHeight());
	end

	-- Adjust container height to fit both title and subtitle
	local totalHeight = title:GetStringHeight() + (subTitle and (subTitle:GetStringHeight() + 8) or 0) + 5;
	container:SetHeight(totalHeight);

	return container;
end

local function AttachTooltip(frame, title, description, anchorFrame, anchor, isFocused)
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

	-- Keep tooltip visible while focused
	editBox:SetScript("OnEditFocusGained", function()
		GameTooltip:SetOwner(backdrop, "ANCHOR_TOP");
		GameTooltip:SetText(title, WHITE_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end);

	editBox:SetScript("OnEditFocusLost", function()
		GameTooltip:Hide();
	end);
end

local OUTER_PADDING = 10;
local LABEL_WIDTH = 145;

function SettingsElements.CreateDescription(parent, descriptionText)
	local description = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	description:SetText(descriptionText or "");
	description:SetPoint("LEFT", parent, "LEFT", OUTER_PADDING + 8, 0);
	description:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);

	return description;
end

local function CreateLabeledFrame(parent, data)
	local labelText = data.label or "";
	local left = CreateFrame("Frame", nil, parent);
	left:SetWidth(LABEL_WIDTH);
	left:SetPoint("LEFT", parent, "LEFT", OUTER_PADDING, 0);
	left:SetPoint("TOP", parent, "TOP");
	left:SetPoint("BOTTOM", parent, "BOTTOM");

	local right = CreateFrame("Frame", nil, parent);
	right:SetPoint("LEFT", left, "RIGHT", 0, 0);
	right:SetPoint("RIGHT", parent, "RIGHT", -OUTER_PADDING, 0);
	right:SetPoint("TOP", parent, "TOP");
	right:SetPoint("BOTTOM", parent, "BOTTOM");

	local label;
	if labelText ~= "" then
		label = left:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		label:SetPoint("LEFT", left, "LEFT", 8, 0);
		label:SetPoint("RIGHT", left, "RIGHT", -8, 0);
		label:SetJustifyH("LEFT");
		label:SetText(labelText);
	end

	return left, right, label;
end

local function CreateCheckbox(parent, data)
	local _, right = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("CheckButton", nil, right, "SettingsCheckBoxTemplate");
	widget:SetPoint("LEFT", right);
	widget:SetSize(Constants.SETTINGS.WIDGET_HEIGHT, Constants.SETTINGS.WIDGET_HEIGHT);

	widget:SetMotionScriptsWhileDisabled(true);
	widget:EnableMouse(true);

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
		if not self:IsEnabled() then
			return;
		end

		local checked = self:GetChecked();
		if type(data.get) == "function" and checked ~= data.get() then
			data.set(checked);
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
	local _, right = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("Button", nil, right, "ColorSwatchTemplate");
	widget:SetPoint("LEFT", right);
	widget:SetSize(Constants.SETTINGS.WIDGET_HEIGHT, Constants.SETTINGS.WIDGET_HEIGHT);
	widget:SetMotionScriptsWhileDisabled(true);
	widget:EnableMouse(true);

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
	end;

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	return widget;
end

local function CreateSlider(parent, data)
	local _, right = CreateLabeledFrame(parent, data)

	local widget = CreateFrame("Slider", nil, right, "MinimalSliderWithSteppersTemplate")
	widget:SetPoint("LEFT", right, "LEFT", 0, 0);
	widget:SetPoint("RIGHT", right, "RIGHT", -25, 0); -- leave space for RightText
	widget:SetPoint("CENTER", right, "CENTER");

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
		return math.floor(val / stepVal + 0.5) * stepVal;
	end

	---@param val number
	local function UpdateText(val)
		if widget.RightText then
			widget.RightText:SetText(string.format("%d", val));
		end
	end

	local lastValue;

	widget.Slider:SetScript("OnValueChanged", function(_, val)
		if IsDisabled() then
			return;
		end

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
	local _, right = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("DropdownButton", nil, right, "WowStyle1DropdownTemplate");
	widget:SetPoint("LEFT", right, "LEFT", 0, 0);
	widget:SetPoint("RIGHT", right, "RIGHT", 0, 0);
	widget:SetPoint("CENTER", right, "CENTER");

	widget:SetMotionScriptsWhileDisabled(true);

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

			if #sorting > 0 then
				for _, key in ipairs(sorting) do
					if values[key] then
						table.insert(entries, { values[key], key });
					end
				end
			else
				local temp = {};
				for key, text in pairs(values) do
					table.insert(temp, { key = key, label = text });
				end
				table.sort(temp, function(a, b)
					return a.label:lower() < b.label:lower();
				end);
				for _, item in ipairs(temp) do
					table.insert(entries, { item.label, item.key });
				end
			end

			local function IsSelected(index)
				return type(data.get) == "function" and index == data.get();
			end

			local function SetSelected(index)
				if disabled then
					return;
				end
				if type(data.set) == "function" then
					data.set(index);
				end
			end

			for _, entry in ipairs(entries) do
				local text, value = entry[1], entry[2];

				if data.style == "button" then
					root:CreateButton(text, SetSelected, value)
						:SetEnabled(not disabled);
				else
					root:CreateRadio(text, IsSelected, SetSelected, value)
						:SetEnabled(not disabled);
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

-- Rudimentary means to update if an editBox should have a scrollbar.
local function UpdateScrollBarVisibility(scrollFrame, editBox)
	local scrollBar = scrollFrame.ScrollBar;
	if not scrollBar then return; end

	-- Number of lines in the edit box
	local numLines = editBox:GetNumLines() or 1;

	-- Height per line from font
	local fontObject = editBox:GetFontObject();
	local _, lineHeight = fontObject:GetFont();

	-- Calculate content height
	local contentHeight = numLines * lineHeight;
	local visibleHeight = scrollFrame:GetHeight() or 0;

	-- Show scrollbar only if content exceeds visible height
	scrollBar:SetShown(contentHeight > visibleHeight + 1);
end

local function CreateMultiLineEditBox(parent, data)
	local height = data.height or (Constants.SETTINGS.WIDGET_HEIGHT * 4);

	local backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate");
	backdrop:SetPoint("LEFT", parent, "LEFT", 20, 0);
	backdrop:SetPoint("RIGHT", parent, "RIGHT", -8, 0);
	backdrop:SetHeight(height);

	backdrop:SetBackdrop({
		bgFile = "Interface/ChatFrame/ChatFrameBackground",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	});
	backdrop:SetBackdropColor(0, 0, 0, 0.35);
	backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

	local paddingLeft, paddingRight, paddingTop, paddingBottom = 10, 25, 5, 0;

	local scrollFrame = CreateFrame("ScrollFrame", nil, backdrop, "ScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", backdrop, "TOPLEFT", paddingLeft, -paddingTop);
	scrollFrame:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -paddingRight, paddingBottom);
	scrollFrame:SetHeight(height);

	local widget = CreateFrame("EditBox", nil, scrollFrame);
	widget:SetMultiLine(true);
	widget:SetMaxLetters(0);
	widget:SetAutoFocus(false);
	widget:SetFontObject("ChatFontNormal");
	widget:EnableMouse(true);
	widget:EnableKeyboard(true);

	scrollFrame:SetScrollChild(widget);

	widget:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -5);

	widget.settingKey = data.settingKey;
	widget.savedThisEdit = false;

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
			self:HighlightText(0, 0);
		end

		UpdateScrollBarVisibility(scrollFrame, self);
	end;

	if type(data.set) == "function" then
		local function SaveValue(self)
			if self.savedThisEdit then return; end
			self.savedThisEdit = true;

			local cleaned = ED.Utils.SanitizeKeywordInput(self:GetText());
			data.set(cleaned);
			self:SetText(cleaned);
		end

		widget:SetScript("OnEditFocusLost", function(self)
			SaveValue(self);
		end);

		widget:SetScript("OnEnterPressed", function(self)
			SaveValue(self);
			self:ClearFocus();
		end);

		widget:SetScript("OnTextChanged", function(self)
			self.savedThisEdit = false;
			UpdateScrollBarVisibility(scrollFrame, self);
		end);
	end

	scrollFrame:EnableMouse(true);
	scrollFrame:SetScript("OnMouseDown", function(self)
		if not widget:IsEnabled() then return; end
		widget:SetFocus();
	end);

	scrollFrame:SetScript("OnSizeChanged", function(self)
		UpdateScrollBarVisibility(scrollFrame, widget);
		widget:SetWidth(self:GetWidth());
	end);

	widget:SetScript("OnEscapePressed", function(self)
		self:ClearFocus();
	end);

	widget:Refresh();

	if data.tooltip then
		AttachMultiLineEditBoxTooltip(backdrop, scrollFrame, widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(scrollFrame.ScrollBar, "scrollbar");

	local extraBottomPadding = 20;
	return widget, scrollFrame, height + extraBottomPadding;
end

local function CreateEditBox(parent, data)
	local _, right = CreateLabeledFrame(parent, data);

	local widget = CreateFrame("EditBox", nil, right, "InputBoxTemplate");
	widget:SetAutoFocus(false);
	widget:SetPoint("LEFT", right, "LEFT", 4, 0);
	widget:SetPoint("RIGHT", right, "RIGHT", 0, 0);
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

local function WrapButtonClick(original)
	return function(self, ...)
		original(self, ...);
	end
end

local function CreateButton(parent, data)
	local _, right = CreateLabeledFrame(parent, { label = "" });

	local widget = CreateFrame("Button", nil, right, "UIPanelButtonTemplate");
	widget:SetAllPoints(right);
	widget:SetText(data.label or "Button");

	widget.settingKey = data.settingKey;

	---@return boolean
	local function IsDisabled()
		return type(data.disabled) == "function" and data.disabled() or false;
	end

	widget.Refresh = function(self)
		self:SetEnabled(not IsDisabled());
	end

	if type(data.func) == "function" then
		widget:SetScript("OnClick", WrapButtonClick(function(self, ...)
			if IsDisabled() then
				return;
			end
			data.func(self, ...);
		end));
	end

	widget:Refresh();

	if data.tooltip then
		AttachTooltip(widget, data.label, data.tooltip);
	end

	ED.ElvUI.RegisterSkinnableElement(widget, "button");

	return widget;
end

---CreateInset creates a skinnable inset frame inside the parent with provided widget data.
---Positions the inset relative to a previous element, parent's top, or parent's bottom.
---@param parent table The parent frame to attach the inset frame to.
---@param insetData table List of widget data entries describing the inset contents.
---@param bottomOfParent boolean? If true, anchors the bottom of the inset to the bottom of the parent.
---@param relativeTo Frame? Optional frame to anchor the inset below.
---@param topOffset number? Optional vertical offset (default -5 if relativeTo, -20 otherwise).
---@return Frame infoInset The created inset frame containing the widgets.
function SettingsElements.CreateInset(parent, insetData, bottomOfParent, relativeTo, topOffset)
	local infoInset = CreateFrame("Frame", nil, parent, "InsetFrameTemplate");

	if bottomOfParent then
		infoInset:SetPoint("BOTTOM", parent, "BOTTOM", 0, 10);
	else
		if relativeTo then
			topOffset = topOffset or -5;
			infoInset:SetPoint("TOP", relativeTo, "BOTTOM", 0, topOffset);
		else
			topOffset = topOffset or -20;
			infoInset:SetPoint("TOP", parent, "TOP", 0, topOffset);
		end
	end

	infoInset:SetPoint("LEFT", parent, "LEFT", 10, 0);
	infoInset:SetPoint("RIGHT", parent, "RIGHT", -10, 0);
	infoInset:SetHeight(75);


	local logo, title, author, version, build, bsky;
	for _, data in ipairs(insetData) do
		local entryType = data.type or "logo";

		if entryType == "logo" then
			logo = infoInset:CreateTexture(nil, "ARTWORK");
			logo:SetTexture("Interface\\AddOns\\Eavesdropper\\Resources\\SmallLogo64");
			logo:SetSize(52, 52);
			logo:SetPoint("LEFT", 8, 0);
			ED.ElvUI.RegisterSkinnableElement(logo, "icon");
		elseif entryType == "title" then
			title = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			title:SetText(data.text or "");
			title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 0);
		elseif entryType == "version" then
			version = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			version:SetText(data.text or "");
			version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -2)
		elseif entryType == "build" then
			build = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate");
			build:SetText(data.text or "");
			DynamicResizeButton_Resize(build);
			build:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 8, 0);
			ED.ElvUI.RegisterSkinnableElement(build, "button");

			local tooltipText = type(data.tooltip) == "function" and data.tooltip() or (data.tooltip or "");
			AttachTooltip(build, data.text or "", tooltipText);
		elseif entryType == "author" then
			author = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			author:SetText(data.text or "");
			author:SetPoint("TOPRIGHT", infoInset, "TOPRIGHT", -8, 0);
			author:SetPoint("TOP", logo, "TOP", 0, 0);
		elseif entryType == "bsky" then
			bsky = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate");
			bsky:SetText(data.text or "");
			DynamicResizeButton_Resize(bsky);
			bsky:SetPoint("BOTTOMRIGHT", infoInset, "BOTTOMRIGHT", -8, 0);
			bsky:SetPoint("BOTTOM", logo, "BOTTOM", 0, 0);
			ED.ElvUI.RegisterSkinnableElement(bsky, "button");

			AttachTooltip(bsky, data.text or "", data.tooltip or "");

			bsky:SetScript("OnClick", function()
				ED.LinkDialog.CreateExternalLinkDialog("https://bsky.app/profile/dawnsong.me");
			end);
		end
	end

	ED.ElvUI.RegisterSkinnableElement(infoInset, "inset");

	return infoInset;
end

function SettingsElements.CreateElement(parent, data)
	local frame = CreateFrame("Frame", nil, parent);
	frame:SetPoint("LEFT", 0, 0);
	frame:SetPoint("RIGHT", 0, 0);

	local widget;
	local height = Constants.SETTINGS.WIDGET_HEIGHT;

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

	frame:SetHeight(height);

	return frame, widget;
end

ED.SettingsElements = SettingsElements;
