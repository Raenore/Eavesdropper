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
local indentSize = 14;
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
	"curseforge.com/wow/addons/",
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
	local versionComparePatter = "^%[[%w%d%.%-]+%]:"; -- Ignore line started with [version]:

	local function ColorizeText(text, color)
		return "|cn" .. color .. ":" .. text .. "|r";
	end

	for line in string.gmatch(Changelogs.currentMarkdown, "[^\r\n]*") do
		if line ~= "" and not string.find(line, versionComparePatter) then
			index = index + 1;

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
				text = string.gsub(text, gitRefRemovalPattern, ""); -- Remove [#1](url)

				local linkName, linkURL = string.match(text, urlMatchPattern); -- Match [text](url)
				while linkName do
					local isSupportedURL = false;
					for _, keyword in ipairs(supportedURL) do
						if string.find(linkURL, keyword) then
							isSupportedURL = true;
							break;
						end
					end

					if isSupportedURL then
						linkURL = string.gsub(linkURL, "https://", ""); -- Remove https:// due to the colon. We will add it back later
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
					text = string.gsub(text, "%[([^%]]+)%]", "%1"); -- Remove []
					local versionText, dateText = string.match(text, "(%d+%.%d+%.%d+%-?%a*)%s*%-%s*(%d+%-%d+%-%d+)"); -- Match 0.0.0[-alpha|-beta] - 2026-1-1
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
		if elementData.index == 1 then
			spacingBefore = paragraphSpacingBefore;
		else
			spacingBefore = spacingBefore + paragraphSpacingBefore; -- Extra
		end
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

function Eavesdropper_ChangelogTextContainerMixin:OnHyperlinkEnter(link, text, region, left, bottom, width, height) -- luacheck: no unused (link, height)
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("BOTTOMLEFT", region, "TOPLEFT", left + width, bottom);
	text = string.gsub(text, "%[", "");
	text = string.gsub(text, "%]", "");
	GameTooltip:SetText(text, 1, 1, 1);
	GameTooltip:AddLine(L.CLICK_TO_COPY, 1, 1, 1, false);
	GameTooltip:Show();
end

function Eavesdropper_ChangelogTextContainerMixin:OnHyperlinkLeave()
	GameTooltip:Hide();
end

function Eavesdropper_ChangelogTextContainerMixin:OnHyperlinkClick(link)
	local url = string.match(link, "url:([^:]+):0");
	if url then
		url = "https://" .. url;
		ED.LinkDialog.CreateExternalLinkDialog(url);
	end
end

-- ============================================================
-- Changelog Frame Mixin
-- ============================================================

Eavesdropper_ChangelogFrameMixin = {};

function Eavesdropper_ChangelogFrameMixin:OnLoad()
	Changelogs.frame = self;

	local contentWidth = self.ScrollBox:GetWidth() - (2 * scrollBoxPaddingH);
	self.PlaceholderText:SetWidth(contentWidth);
	self.PlaceholderText:SetSpacing(paragraphLineSpacing);

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(_dataIndex, elementData)
		SetupFont(self.PlaceholderText, elementData);
		local width = CalculateTextWidthAndIndent(contentWidth, elementData);
		self.PlaceholderText:SetWidth(width);
		self.PlaceholderText:SetText(elementData.text);
		local spacingBefore, spacingAfter = CalculateFramePadding(elementData);
		return self.PlaceholderText:GetHeight() + spacingBefore + spacingAfter;
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
			frame.Bullet:SetVertexColor(0.8, 0.8, 0.8);
		elseif tag == "li2" then
			frame.Bullet:Show();
			frame.Bullet:SetVertexColor(0.5, 0.5, 0.5);
		else
			frame.Bullet:Hide();
		end

		frame.Text:ClearAllPoints();
		frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", indent, -spacingBefore);
		frame.Text:SetWidth(width);
		frame.Text:SetText(elementData.text);

		frame.RightText:ClearAllPoints();
		frame.RightText:SetPoint("BOTTOMRIGHT", frame.Divider, "TOPRIGHT", 0, dividerOffsetV);
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

	ED.ElvUI.RegisterSkinnableElement(self.ScrollBar, "scrollbar", true);
end

function Eavesdropper_ChangelogFrameMixin:OnShow()
	self:SetScript("OnShow", nil);
	self:LoadChangelog();
end

function Eavesdropper_ChangelogFrameMixin:LoadChangelog()
	self.ScrollBox:GetWidth()
	if not self.dataProvider then
		self.dataProvider = ConvertMarkdownToDataProvider();
	end
	self.ScrollBox:SetDataProvider(self.dataProvider);
end

function Changelogs:SetMarkdown(markdown)
	self.currentMarkdown = markdown;
end

function Changelogs:CreateChangelogFrame(container)
	if Changelogs.frame then return; end

	local frame = CreateFrame("Frame", nil, container, "Eavesdropper_ChangelogFrameTemplate");
	local padding = 0;
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", container, "TOPLEFT", padding, -42);
	frame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -3 - padding, 3 + padding);
end

ED.Changelogs = Changelogs;
