-- Copyright The Eavesdropper Authors
-- Pipe-escaping adapted from Total RP 3
-- SPDX-License-Identifier: GPL-3.0-or-later

local L = ED.Localization;

---@type EavesdropperConstants
local Constants = ED.Constants;

---@type EavesdropperEnums
local Enums = ED.Enums;

---@class EavesdropperImportExportDialog
local ImportExportDialog = {};

local FRAME_NAME = "Eavesdropper_ImportExportDialog";

-- Layout. Offsets and widths come from Constants.SETTINGS so the rows line up with the
-- settings window.
local BODY_INSET_TOP = 34;
local BODY_INSET_BOTTOM = 14;
local ROW_SPACING = 8;
local ACTION_BUTTON_WIDTH = 120;
local ACTION_BUTTON_HEIGHT = 22;
local STATUS_TEXT_MIN_HEIGHT = 28; -- Two lines; the warning grows past this as needed
local INSTRUCTIONS_HEIGHT = 34;

---Escapes "|" to prevent interpretation as color/hyperlink codes.
---@param editBox table
local function InstallPipeEscaping(editBox)
	local baseGetText = editBox.GetText;
	local baseSetText = editBox.SetText;

	editBox.GetText = function(self)
		return (string.gsub(baseGetText(self), "||", "|"));
	end;

	editBox.SetText = function(self, text)
		return baseSetText(self, (string.gsub(text or "", "|", "||")));
	end;
end

---Substitutes readable wording for the unpackaged dev build.
---@param version string?
---@return string
local function FormatVersion(version)
	if type(version) ~= "string" or version == "" then return UNKNOWN; end
	if version:find("project-version", 1, true) then return L.IMPORTEXPORT_VERSION_DEV; end
	return version;
end

---Creates a settings-style row, laid out bottom-up from whatever sits below it.
---@param parent table
---@param relativeTo table Frame this row sits directly above.
---@param spacing number Gap between the two.
---@return table row
local function CreateRow(parent, relativeTo, spacing)
	local row = CreateFrame("Frame", nil, parent);
	row:SetPoint("LEFT", parent, "LEFT");
	row:SetPoint("RIGHT", parent, "RIGHT");
	row:SetPoint("BOTTOM", relativeTo, "TOP", 0, spacing);
	row:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);

	return row;
end

-- ============================================================
-- Frame mixin
-- ============================================================

Eavesdropper_ImportExportDialogMixin = {};

function Eavesdropper_ImportExportDialogMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName());

	-- Matching the settings list width keeps the rows here identical to settings rows.
	self:SetSize(Constants.SETTINGS.SETTINGS_LIST_WIDTH, Constants.SETTINGS.FRAME_HEIGHT);

	NineSliceUtil.DisableSharpening(self.NineSlice);
	self.Background.BackgroundColor:SetColorTexture(0.12, 0.12, 0.12, 0.95);
	self.Background.InnerShadow:SetTexture("Interface/AddOns/Eavesdropper/Resources/SettingsPanelInnerShadow.png");

	self.CloseButton:SetScript("OnClick", function()
		self:Hide();
	end);

	self:BuildBody();

	ED.ElvUI.RegisterSkinnableElement(self, Enums.ELVUI_SKIN_TYPE.FRAME);
	ED.ElvUI.RegisterSkinnableElement(self.NameEditBox, Enums.ELVUI_SKIN_TYPE.EDITBOX);
	ED.ElvUI.RegisterSkinnableElement(self.OverwriteCheckbox, Enums.ELVUI_SKIN_TYPE.CHECKBOX);
	ED.ElvUI.RegisterSkinnableElement(self.ScrollFrame.ScrollBar, Enums.ELVUI_SKIN_TYPE.SCROLLBAR);
	ED.ElvUI.RegisterSkinnableElement(self.ActionButton, Enums.ELVUI_SKIN_TYPE.BUTTON, true);
end

function Eavesdropper_ImportExportDialogMixin:OnDragStart()
	self:StartMoving();
end

function Eavesdropper_ImportExportDialogMixin:OnDragStop()
	self:StopMovingOrSizing();
end

function Eavesdropper_ImportExportDialogMixin:OnHide()
	-- Never leave a payload sitting in the box between openings.
	self.TextBox:SetReadOnlyText(nil);
	self.TextBox:SetText("");
	self.NameEditBox:SetText("");
	self.decodedPayload = nil;
	self.decodeError = nil;
	self.payloadType = nil;
	self:SetStatus(nil);
	self:SetDetected(nil);

	if self.alphaChannelMode and self.SetAlphaChannelMode then
		self:SetAlphaChannelMode(nil);
	end
end

-- ============================================================
-- Screenshot Helper
-- ============================================================

---@param mode number?
function Eavesdropper_ImportExportDialogMixin:SetAlphaChannelMode(mode)
	-- mode 1: All Widgets turn black + white fullscreen backdrop
	-- mode 2: Widgets use original colors + black fullscreen backdrop
	-- other : Disable

	-- Nothing to restore if this dialog was never colorized
	if not mode and not self.alphaChannelMode then return; end

	self.alphaChannelMode = mode;

	local colorize = mode == 1;

	-- Captured before the colorize pass rewrites the icon escape sequence in the title
	if colorize and not self.alphaChannelTitle then
		self.alphaChannelTitle = self.NineSlice.Text:GetText();
	end

	ED.ScreenshotHelper.SetupObjectColorByMode(self, mode);

	self.Background.BackgroundColor:SetVertexColor(1, 1, 1);

	if colorize then
		self.NineSlice.Text:SetText(nil);
	elseif self.alphaChannelTitle then
		self.NineSlice.Text:SetText(self.alphaChannelTitle);
		self.alphaChannelTitle = nil;
	end

	self.Background.BackgroundColor:SetColorTexture(ED.ScreenshotHelper.GetBackgroundColorByMode(mode));
end

---Builds the instructions, paste box, name row, status line and action button
function Eavesdropper_ImportExportDialogMixin:BuildBody()
	---@type EavesdropperSettingsElements
	local SettingsElements = ED.SettingsElements;
	local descTextColor = Constants.SETTINGS.DESC_TEXT_COLOR;

	local instructions = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	instructions:SetPoint("TOPLEFT", self, "TOPLEFT", Constants.SETTINGS.TITLE_OFFSET, -BODY_INSET_TOP);
	instructions:SetPoint("TOPRIGHT", self, "TOPRIGHT", -Constants.SETTINGS.TITLE_OFFSET, -BODY_INSET_TOP);
	instructions:SetHeight(INSTRUCTIONS_HEIGHT);
	instructions:SetJustifyH(Constants.SETTINGS.TITLE_JUSTIFY_H);
	instructions:SetJustifyV("TOP");
	instructions:SetSpacing(4);
	instructions:SetTextColor(descTextColor, descTextColor, descTextColor);
	self.Instructions = instructions;

	local actionButton = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
	actionButton:SetSize(ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT);
	actionButton:SetPoint("BOTTOM", self, "BOTTOM", 0, BODY_INSET_BOTTOM);
	actionButton:SetText(L.IMPORTEXPORT_BUTTON_IMPORT);
	actionButton:SetScript("OnClick", function() self:OnActionClicked(); end);
	self.ActionButton = actionButton;

	local status = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	status:SetPoint("BOTTOM", actionButton, "TOP", 0, ROW_SPACING);
	status:SetPoint("LEFT", self, "LEFT", Constants.SETTINGS.TITLE_OFFSET, 0);
	status:SetPoint("RIGHT", self, "RIGHT", -Constants.SETTINGS.TITLE_OFFSET, 0);
	status:SetHeight(STATUS_TEXT_MIN_HEIGHT);
	status:SetJustifyH("CENTER"); -- Can also be "LEFT", decide on this for the Warning msg
	status:SetJustifyV("BOTTOM");
	status:SetWordWrap(true);
	self.StatusText = status;

	local overwriteRow = CreateRow(self, status, ROW_SPACING);
	local _, overwriteRight, overwriteLabel = SettingsElements.CreateLabeledFrame(overwriteRow, {
		label = L.IMPORTEXPORT_OVERWRITE,
	});
	self.OverwriteRow = overwriteRow;

	local overwrite = CreateFrame("CheckButton", nil, overwriteRight, "SettingsCheckBoxTemplate");
	overwrite:SetPoint("LEFT", overwriteRight);
	overwrite:SetSize(Constants.SETTINGS.WIDGET_HEIGHT, Constants.SETTINGS.WIDGET_HEIGHT);
	overwrite:SetMotionScriptsWhileDisabled(true);
	overwrite:EnableMouse(true);
	-- HookedScript as the template owns its own OnClick for the checked visual.
	overwrite:HookScript("OnClick", function() self:UpdateActionButton(); end);
	SettingsElements.AttachTooltip(overwrite, L.IMPORTEXPORT_OVERWRITE, L.IMPORTEXPORT_OVERWRITE_HELP);
	self.OverwriteCheckbox = overwrite;
	self.OverwriteLabel = overwriteLabel;

	-- Name row.
	local nameRow = CreateRow(self, overwriteRow, 0);
	local _, nameRight, nameLabel = SettingsElements.CreateLabeledFrame(nameRow, {
		label = L.IMPORTEXPORT_NAME_LABEL,
	});
	self.NameRow = nameRow;
	self.NameLabel = nameLabel;

	local nameEditBox = CreateFrame("EditBox", nil, nameRight, "InputBoxTemplate");
	local visualOffsetLeft = 4; -- Workaround for border textures not aligned to frame. It will still be problematic when ElvUI skin is enabled.
	local visualOffsetRight = -1;
	nameEditBox:SetPoint("LEFT", nameRight, "LEFT", visualOffsetLeft, 0);
	nameEditBox:SetPoint("RIGHT", nameRight, "RIGHT", visualOffsetRight, 0);
	nameEditBox:SetPoint("CENTER", nameRight, "CENTER");
	nameEditBox:SetHeight(Constants.SETTINGS.WIDGET_HEIGHT);
	nameEditBox:SetFontObject("ChatFontNormal");
	nameEditBox:SetAutoFocus(false);
	nameEditBox:SetMaxLetters(Constants.MAX_PROFILE_NAME_LENGTH);
	nameEditBox:SetScript("OnTextChanged", function(box, userInput)
		-- The flag means "the user has a name of their own", not "the user touched this",
		if userInput then
			self.nameEdited = string.trim(box:GetText()) ~= "";
		end
		self:UpdateActionButton();
	end);
	nameEditBox:SetScript("OnEscapePressed", function() self:Hide(); end);
	nameEditBox:SetScript("OnEnterPressed", function() self:OnActionClicked(); end);
	SettingsElements.AttachTooltip(nameEditBox, L.IMPORTEXPORT_NAME_LABEL, L.IMPORTEXPORT_NAME_LABEL_HELP);
	self.NameEditBox = nameEditBox;

	self:BuildTextBox();
end

---Builds the multi-line paste box and wires up paste detection.
function Eavesdropper_ImportExportDialogMixin:BuildTextBox()
	local backdrop, scrollFrame, editBox = ED.DialogWidgets.CreateReadOnlyTextBox(self, self.Instructions);
	self.TextBoxBackdrop = backdrop;
	self.ScrollFrame = scrollFrame;

	InstallPipeEscaping(editBox);

	-- A payload is only ever valid whole, so always select all of it. On import that also
	-- makes a paste a replacement rather than landing beside the previous string.
	editBox:SetScript("OnEditFocusGained", function(box)
		box:HighlightText();
	end);

	-- Clicking an already-focused box clears the selection without re-firing the above.
	editBox:SetScript("OnMouseUp", function(box)
		box:HighlightText();
	end);

	-- The payload is only ever copied whole, so close right after Ctrl-C.
	editBox:HookScript("OnKeyDown", function(box, key)
		if box.readOnlyText ~= nil and key == "C" and IsControlKeyDown() then
			box:HighlightText();
			RunNextFrame(function()
				self:Hide();
			end);
		end
	end);

	-- Chains after DialogWidgets' read-only backstop hook.
	editBox:HookScript("OnTextChanged", function(box)
		if box.readOnlyText ~= nil then return; end
		self:OnPastedTextChanged();
	end);

	self.TextBox = editBox;
end

-- ============================================================
-- Mode
-- ============================================================

---Switches the dialog between export and import layouts.
---@param mode string "export" or "import"
---@param payloadType string? "profile" or "global"; nil in import mode.
function Eavesdropper_ImportExportDialogMixin:SetMode(mode, payloadType)
	self.mode = mode;
	self.payloadType = payloadType;
	self.nameEdited = false;

	local isImport = mode == "import";

	self.ActionButton:SetShown(isImport);

	local title;
	if isImport then
		-- SetDetected owns the import instructions and restates them after a paste.
		title = L.IMPORTEXPORT_TITLE_IMPORT;
		self:SetDetected(nil);
	else
		title = (payloadType == "global") and L.IMPORTEXPORT_TITLE_EXPORT_GLOBAL or L.IMPORTEXPORT_TITLE_EXPORT_PROFILE;
		self.Instructions:SetText(L.IMPORTEXPORT_INSTRUCTIONS_EXPORT);
	end

	self.NineSlice.Text:SetText(ED.Globals.addon_settings_icon .. " " .. ED.Globals.addon_title .. " " .. title);

	self:SetStatus(nil);
	self:RefreshLayout();
end

---Updates the instructions to say what kind of string was pasted
---@param payload table? Decoded payload, or nil to ask for one.
function Eavesdropper_ImportExportDialogMixin:SetDetected(payload)
	if self.mode ~= "import" then return; end

	if not payload then
		self.Instructions:SetText(L.IMPORTEXPORT_INSTRUCTIONS_IMPORT);
		return;
	end

	if payload.payloadType == "profile" then
		self.Instructions:SetText(L.IMPORTEXPORT_DETECTED_PROFILE);
	else
		self.Instructions:SetText(L.IMPORTEXPORT_DETECTED_GLOBAL);
	end
end

---Re-anchors the paste box and shows the rows the current state calls for
function Eavesdropper_ImportExportDialogMixin:RefreshLayout()
	local isImport = self.mode == "import";
	local showNameRow = isImport and self.payloadType == "profile";

	self.NameRow:SetShown(showNameRow);
	self.OverwriteRow:SetShown(showNameRow);

	-- The name and overwrite rows keep their place while hidden, so anchoring to them
	-- would leave a gap. Anchor to the lowest row that is actually shown, and inset it to
	-- match Instructions above; StatusText already sits at that inset itself.
	local titleOffset = Constants.SETTINGS.TITLE_OFFSET;
	local anchorTo, anchorPoint, offset, insetLeft, insetRight;
	if showNameRow then
		anchorTo, anchorPoint, offset, insetLeft, insetRight = self.NameRow, "TOP", ROW_SPACING, titleOffset, -titleOffset;
	elseif isImport then
		anchorTo, anchorPoint, offset, insetLeft, insetRight = self.StatusText, "TOP", ROW_SPACING, 0, 0;
	else
		anchorTo, anchorPoint, offset, insetLeft, insetRight = self, "BOTTOM", BODY_INSET_BOTTOM, titleOffset, -titleOffset;
	end

	self.TextBoxBackdrop:ClearAllPoints();
	self.TextBoxBackdrop:SetPoint("TOPLEFT", self.Instructions, "BOTTOMLEFT", 0, -ROW_SPACING);
	self.TextBoxBackdrop:SetPoint("TOPRIGHT", self.Instructions, "BOTTOMRIGHT", 0, -ROW_SPACING);
	self.TextBoxBackdrop:SetPoint("BOTTOMLEFT", anchorTo, anchorPoint .. "LEFT", insetLeft, offset);
	self.TextBoxBackdrop:SetPoint("BOTTOMRIGHT", anchorTo, anchorPoint .. "RIGHT", insetRight, offset);
end

---Sets the warning line, or clears it when message is nil.
---Grows to fit a long message, but never below two lines so the layout does not jump.
---@param message string?
function Eavesdropper_ImportExportDialogMixin:SetStatus(message)
	self.StatusText:SetText(message and WARNING_FONT_COLOR:WrapTextInColorCode(message) or "");
	self.StatusText:SetHeight(math.max(STATUS_TEXT_MIN_HEIGHT, math.ceil(self.StatusText:GetStringHeight())));
end

---Decodes the pasted string, keeping the payload or the reason it could not be read.
---Nothing is decoded until the closing line arrives, so a half-finished paste is not an error.
function Eavesdropper_ImportExportDialogMixin:RefreshDecodedPayload()
	local previousType = self.payloadType;

	self.decodedPayload = nil;
	self.decodeError = nil;
	self.payloadType = nil;

	local text = string.trim(self.TextBox:GetText());

	if text ~= "" and text:find("-----END", 1, true) then
		self.decodedPayload, self.decodeError = ED.ProfileTransfer.DecodeString(text);
	end

	if self.decodedPayload then
		self.payloadType = self.decodedPayload.payloadType;

		-- Prefill from the string itself. SetText does not set nameEdited, so a name the
		-- user typed is never overwritten.
		if self.decodedPayload.name and not self.nameEdited then
			self.NameEditBox:SetText(self.decodedPayload.name);
		end
	end

	self:SetDetected(self.decodedPayload);

	if self.payloadType ~= previousType then
		self:RefreshLayout();
	end
end

---Reports whether the dialog currently holds something importable.
---@return boolean ok
---@return string? reason Shown to the user when ok is false.
function Eavesdropper_ImportExportDialogMixin:Validate()
	if self.decodeError then return false, self.decodeError; end
	if not self.decodedPayload then return false, nil; end
	if self.payloadType ~= "profile" then return true, nil; end

	local profileName = string.trim(self.NameEditBox:GetText());
	if profileName == "" then return false, L.IMPORTEXPORT_ERROR_NAME_EMPTY; end

	if ED.Database:ProfileExists(profileName) and not self.OverwriteCheckbox:GetChecked() then
		return false, L.IMPORTEXPORT_ERROR_NAME_TAKEN:format(profileName);
	end

	return true, nil;
end

---Re-runs validation and syncs the warning line and the action button to the result
function Eavesdropper_ImportExportDialogMixin:UpdateActionButton()
	if self.mode ~= "import" then return; end

	local ok, reason = self:Validate();

	self.ActionButton:SetEnabled(ok);
	self:SetStatus(reason);
end

---Re-decodes and re-validates after the pasted text changes
function Eavesdropper_ImportExportDialogMixin:OnPastedTextChanged()
	self:RefreshDecodedPayload();
	self:UpdateActionButton();
end

-- ============================================================
-- Import
-- ============================================================

---Applies a decoded profile payload under the chosen name.
---@param payload table
---@param profileName string
---@param overwrite boolean
function Eavesdropper_ImportExportDialogMixin:ApplyProfile(payload, profileName, overwrite)
	local clean, dropped = ED.ProfileTransfer.SanitizeProfile(payload.data);

	if not ED.Database:ImportProfile(profileName, clean, overwrite) then
		self:SetStatus(L.IMPORTEXPORT_ERROR_WRITE_FAILED);
		return;
	end

	ED.Utils.Write(dropped > 0
		and L.IMPORTEXPORT_SUCCESS_PROFILE_SKIPPED:format(profileName, dropped)
		or L.IMPORTEXPORT_SUCCESS_PROFILE:format(profileName));

	self:Hide();
end

---Applies a decoded global payload, then offers a reload.
---@param payload table
function Eavesdropper_ImportExportDialogMixin:ApplyGlobals(payload)
	local clean, dropped = ED.ProfileTransfer.SanitizeGlobals(payload.data);

	if not ED.Database:ImportGlobals(clean) then
		self:SetStatus(L.IMPORTEXPORT_ERROR_WRITE_FAILED);
		return;
	end

	ED.Utils.Write(dropped > 0
		and L.IMPORTEXPORT_SUCCESS_GLOBAL_SKIPPED:format(dropped)
		or L.IMPORTEXPORT_SUCCESS_GLOBAL);

	self:Hide();

	-- While not strictly necessary, we still offer an UI refresh just in case.
	RunNextFrame(function()
		ED.ConfirmDialog.Show(L.IMPORTEXPORT_CONFIRM_RELOAD, function()
			ReloadUI();
		end);
	end);
end

---Confirms the import before anything is written.
---Validated again here because Enter bypasses the action button's enabled state.
function Eavesdropper_ImportExportDialogMixin:OnActionClicked()
	self:UpdateActionButton();

	local ok = self:Validate();
	if not ok then return; end

	local payload = self.decodedPayload;
	local version = FormatVersion(payload.addonVersion);

	-- This prompt covers the paste box, so the header's date is restated here.
	local exported = payload.exported or UNKNOWN;

	if self.payloadType ~= "profile" then
		ED.ConfirmDialog.Show(L.IMPORTEXPORT_CONFIRM_GLOBAL:format(exported, version), function()
			self:ApplyGlobals(payload);
		end);
		return;
	end

	local profileName = string.trim(self.NameEditBox:GetText());
	local overwrite = self.OverwriteCheckbox:GetChecked() and true or false;

	local prompt = ED.Database:ProfileExists(profileName)
		and L.IMPORTEXPORT_CONFIRM_OVERWRITE:format(profileName, exported, version)
		or L.IMPORTEXPORT_CONFIRM_PROFILE:format(profileName, exported, version);

	ED.ConfirmDialog.Show(prompt, function()
		self:ApplyProfile(payload, profileName, overwrite);
	end);
end

-- ============================================================
-- Module
-- ============================================================

---Creates the dialog on first use and returns it
---@return table frame
function ImportExportDialog:GetFrame()
	if not self.frame then
		self.frame = CreateFrame("Frame", FRAME_NAME, UIParent, "Eavesdropper_ImportExportDialogTemplate");
	end

	return self.frame;
end

---Shows the dialog pre-filled with a freshly generated export string.
---@param payloadType string "profile" or "global"
function ImportExportDialog:ShowExport(payloadType)
	local text = (payloadType == "global")
		and ED.ProfileTransfer.ExportGlobals()
		or ED.ProfileTransfer.ExportProfile();

	if not text then
		ED.Utils.Write(L.IMPORTEXPORT_ERROR_EXPORT_FAILED);
		return;
	end

	local frame = self:GetFrame();
	frame:SetMode("export", payloadType);
	frame:Show();

	frame.TextBox:SetReadOnlyText(text);
	frame.TextBox:SetFocus();
	frame.TextBox:HighlightText();
end

---Shows the dialog with an empty, editable box ready for a pasted string.
---The payload type is detected from whatever is pasted, so it is not asked for here.
function ImportExportDialog:ShowImport()
	local frame = self:GetFrame();
	frame:SetMode("import", nil);
	frame:Show();

	frame.TextBox:SetReadOnlyText(nil);
	frame.TextBox:SetText("");
	frame.NameEditBox:SetText("");
	frame.OverwriteCheckbox:SetChecked(false);
	frame.decodedPayload = nil;
	frame.decodeError = nil;
	frame:UpdateActionButton();
	frame.TextBox:SetFocus();
end

ED.ImportExportDialog = ImportExportDialog;
