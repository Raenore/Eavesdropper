-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

local L = ED.Localization;

---@class EavesdropperChangelogs
local Changelogs = {};

local scrollBoxPaddingH = 12;
local scrollBoxPaddingV = 4;
local paragraphLineSpacing = 2;
local paragraphSpacingBefore = 8;
local paragraphSpacingAfter = 8;
local indentSize = 24;
local dividerOffsetV = 6;

local styleList = {
	{pattern = "^#%s+(.+)", tag = "h1"}, -- # TEXT
	{pattern = "^##%s+(.+)", tag = "h2"}, -- ## TEXT
	{pattern = "^###%s+(.+)", tag = "h3"}, -- ### TEXT
	{pattern = "^%-%s+(.+)", tag = "li"}, -- - Bullet
	{pattern = "^[%s%c]+%-%s+(.+)", tag = "li2"}, --   - Bullet with extra indent
	{pattern = "^%s*(.+)", tag = "p"}, -- Body
};

local supportedURL = {
	"Eavesdropper/wiki",
	"dialogueui",
};

local textColors = {
	Emphasis = "NORMAL_FONT_COLOR", -- #, ##, ###, **
	Date = "HIGHLIGHT_FONT_COLOR",
	ClickableLink = "LINK_FONT_COLOR",
	UnclickableLink = "LIGHTYELLOW_FONT_COLOR",
};

local function ConvertMarkdownToDataProvider()
	local dataProvider = CreateDataProvider();
	local index = 0;

	local urlMatchPattern = "%[([^]]+)%]%(([^%)]+)%)"; -- [text](url) Preserve text only
	local urlRemovalPattern = "%[[^]]+%]%([^%)]+%)";
	local gitRefRemovalPattern = "%s*%(%[#.-%([^%)]+%)%s*%)"; -- ([#1](url)) or ([#1](url) and [#2](url)) Remove entirely

	local function ColorizeText(text, color)
		return "|cn" .. color .. ":" .. text .. "|r";
	end

	for line in string.gmatch(Changelogs.currentMarkdown, "[^\r\n]*") do
		index = index + 1;
		if line ~= "" then
			-- Process the start of the line
			local tag;
			local text;
			local rightText;

			for _, style in ipairs(styleList) do
				text = string.match(line, style.pattern);
				if text then
					tag = style.tag;
					break;
				end
			end

			if text then
				-- Convert url [text](url)
				text = string.gsub(text, gitRefRemovalPattern, "");

				local linkName, linkURL = string.match(text, urlMatchPattern); -- luacheck: no unused (linkURL)
				while linkName do
					local isSupportedURL = false;
					for _, keyword in ipairs(supportedURL) do
						if string.find(linkURL, keyword) then
							isSupportedURL = true;
							break;
						end
					end

					if isSupportedURL then
						linkURL = string.gsub(linkURL, "https://", "");
						local linkHyperlink = string.format("|cn%s:|Haddon:Eavesdropper:url:%s:0|h[%s]|h|r", textColors.ClickableLink, linkURL, linkName);
						text = string.gsub(text, urlRemovalPattern, linkHyperlink, 1);
					else
						text = string.gsub(text, urlRemovalPattern, ColorizeText(linkName, textColors.UnclickableLink), 1); -- for credits
					end

					linkName, linkURL = string.match(text, urlMatchPattern);
				end

				if tag == "h1" then
					text = string.gsub(text, "%[([^]]+)%]", ColorizeText("%1", textColors.Emphasis)); -- Make version [0.0.0] yellow
				elseif tag == "h2" then
					text = string.gsub(text, "%[([^%]]+)%]", "%1");
					local versionText, dateText = string.match(text, "(%d+%.%d+%.%d+)%s*%-%s*(%d+%-%d+%-%d+)");
					if versionText then
						text = ColorizeText(versionText, textColors.Emphasis);
						rightText = ColorizeText(dateText, textColors.Date);
					end
				elseif tag == "h3" then
					text = ColorizeText(text, textColors.Emphasis); -- Make ### yellow
				end

				text = string.gsub(text, "%*%*([^%*]+)%*%*", ColorizeText("%1", textColors.Emphasis)); -- Colorize **bold** yellow

				dataProvider:Insert({index = index, tag = tag, text = text, rightText = rightText});
			end
		end
	end

	dataProvider:Insert({index = index + 1, tag = "p", text = " "}); -- Extra padding at the bottom

	return dataProvider;
end

local function CalculateTextWidthAndIndent(contentWidth, elementData)
	local indent = 0;
	if elementData.tag == "li" then
		indent = 1;
	elseif elementData.tag == "li2" then
		indent = 2;
	end
	return contentWidth - indent * indentSize, indent * indentSize;
end

local function CalculateFramePadding(elementData)
	local spacingBefore = paragraphSpacingBefore;
	local spacingAfter = paragraphSpacingAfter;
	if elementData.tag == "h1" or elementData.tag == "h2" then
		spacingBefore = spacingBefore + paragraphSpacingBefore; -- Extra
		spacingAfter = dividerOffsetV;
	end
	return spacingBefore, spacingAfter;
end

local function SetupFont(fontString, elementData)
	if elementData.tag == "h1" then
		fontString:SetFontObject("GameFontNormalLarge");
		fontString:SetTextColor(1, 0.82, 0);
	elseif elementData.tag == "h2" then
		fontString:SetFontObject("GameFontNormalLarge");
		fontString:SetTextColor(1, 0.82, 0);
	elseif elementData.tag == "h3" then
		fontString:SetFontObject("GameFontNormalMed1");
		fontString:SetTextColor(1, 1, 1);
	else
		fontString:SetFontObject("GameFontNormal");
		fontString:SetTextColor(1, 1, 1);
	end
end

-- ============================================================
-- Text Container
-- ============================================================

Eavesdropper_ChangelogTextContainerMixin = {};

function Eavesdropper_ChangelogTextContainerMixin:OnHyperlinkEnter(link, text, region, left, bottom, width, height)
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("BOTTOMLEFT", region, "TOPLEFT", left + width, bottom);
	GameTooltip:SetText(text, 1, 1, 1);
	GameTooltip:AddLine(L.CLICK_TO_COPY, 1, 1, 1, false);
	GameTooltip:Show();
end

function Eavesdropper_ChangelogTextContainerMixin:OnHyperlinkLeave()
	GameTooltip:Hide();
end

function Eavesdropper_ChangelogTextContainerMixin:OnHyperlinkClick(link, text, button, region, left, bottom, width, height)
	if button == "LeftButton" then
		local url = string.match(link, "url:([^:]+):0");
		if url then
			url = "https://"..url;
			ED.LinkDialog.CreateExternalLinkDialog(url);
		end
	end
end

-- ============================================================
-- Changelog Frame Mixin
-- ============================================================

Eavesdropper_ChangelogFrameMixin = {};

function Eavesdropper_ChangelogFrameMixin:OnLoad()
	local contentWidth = self.ScrollBox:GetWidth() - (2 * scrollBoxPaddingH);
	self.PlaceholderParagraph:SetWidth(contentWidth);
	self.PlaceholderParagraph:SetSpacing(paragraphLineSpacing);

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(_dataIndex, elementData)
		SetupFont(self.PlaceholderParagraph, elementData);
		self.PlaceholderParagraph:SetWidth(CalculateTextWidthAndIndent(contentWidth, elementData));
		self.PlaceholderParagraph:SetText(elementData.text);
		local spacingBefore, spacingAfter = CalculateFramePadding(elementData);
		return self.PlaceholderParagraph:GetHeight() + spacingBefore + spacingAfter;
	end);

	local function TextContainerInitializer(frame, elementData)
		SetupFont(frame.Text, elementData);

		local width, indent = CalculateTextWidthAndIndent(contentWidth, elementData);

		local tag = elementData.tag;
		local spacingBefore, spacingAfter = CalculateFramePadding(elementData);

		if tag == "h1" or tag == "h2" then
			frame.Divider:SetWidth(contentWidth);
			frame.Divider:SetHeight(PixelUtil.ConvertPixelsToUIForRegion(1, self));
			frame.Divider:Show();
		else
			frame.Divider:Hide();
		end

		if tag == "li" then
			frame.Bullet:Show();
			frame.Bullet:SetColorTexture(0.8, 0.8, 0.8);
		elseif tag == "li2" then
			frame.Bullet:Show();
			frame.Bullet:SetColorTexture(0.4, 0.4, 0.4);
		else
			frame.Bullet:Hide();
		end

		frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", indent, -spacingBefore);
		frame.Text:SetWidth(width);
		frame.Text:SetText(elementData.text);

		frame.RightText:ClearAllPoints();
		frame.RightText:SetPoint("BOTTOMRIGHT", frame.Divider, "BOTTOMRIGHT", 0, dividerOffsetV + 1);
		frame.RightText:SetText(elementData.rightText);
		frame.RightText:SetShown(elementData.rightText ~= nil);


		frame:SetSize(contentWidth, frame.Text:GetHeight() + spacingBefore + spacingAfter);
	end

	view:SetElementInitializer("Eavesdropper_ChangelogTextContainerTemplate", TextContainerInitializer);
	--view:SetElementResetter(TextContainerResetter); -- Unused for now

	local top, bottom, left, right, spacing = scrollBoxPaddingV, scrollBoxPaddingV, scrollBoxPaddingH, scrollBoxPaddingH, 0;
	view:SetPadding(top, bottom, left, right, spacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end

function Eavesdropper_ChangelogFrameMixin:OnShow()
	self:SetScript("OnShow", nil);
	self:LoadChangelog();
end

function Eavesdropper_ChangelogFrameMixin:LoadChangelog()
	if not self.dataProvider then
		self.dataProvider = ConvertMarkdownToDataProvider();
	end
	self.ScrollBox:SetDataProvider(self.dataProvider);
end

function Changelogs:SetMarkdown(markdown)
	self.currentMarkdown = markdown;
end

function Changelogs:CreateChangelogFrame(container)
	local frame = CreateFrame("Frame", nil, container, "Eavesdropper_ChangelogFrameTemplate");
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", container, "TOPLEFT", 4, 0);
	frame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -4, 4);
end

ED.Changelogs = Changelogs;
