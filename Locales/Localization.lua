-- Copyright The Eavesdropper Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: GPL-3.0-or-later

local DEFAULT_LOCALE_CODE = "enUS";

---@class ED.LocalizationClass
---@field New fun(defaultLocaleContent:table<string,string>):ED.Localization
---@field RegisterNewLocale fun(self:ED.LocalizationClass, code:string, name:string, content:table<string,string>)
---@field SetCurrentLocale fun(self:ED.LocalizationClass, code:string, fallback:boolean?)
---@field GetText fun(self:ED.LocalizationClass, key:string, ...:any):string
---@field GetDefaultLocale fun(self:ED.LocalizationClass):string
---@field GetPreferredLocale fun(self:ED.LocalizationClass):string
local Localization = {};

---Create a new localization instance
---@param defaultLocaleContent table<string,string>
---@return ED.Localization
function Localization:New(defaultLocaleContent)
	local localeInstance = {};

	local mt = {
		__index = function(t, k)
			if Localization[k] then
				return Localization[k];  -- class method
			else
				return t:GetText(k);     -- instance key lookup
			end
		end,
		__call = function(t, k, ...)
			return t:GetText(k, ...);
		end
	};
	setmetatable(localeInstance, mt);

	localeInstance.locales = {};
	localeInstance.currentLocaleCode = DEFAULT_LOCALE_CODE;

	if defaultLocaleContent then
		localeInstance:RegisterNewLocale(DEFAULT_LOCALE_CODE, "Default", defaultLocaleContent);
	end

	return localeInstance;
end

---Register a new locale table
---@param code string
---@param name string
---@param content table<string,string>
function Localization:RegisterNewLocale(code, name, content) -- luacheck: no unused (name)
	if type(code) ~= "string" then return; end
	if type(content) ~= "table" then content = {}; end

	self.locales[code] = content;

	-- Selected here too so file-scope lookups see the final locale
	self:SetCurrentLocale(self:GetPreferredLocale(), true);
end

---Set the active locale
---@param code string
---@param fallback boolean?
function Localization:SetCurrentLocale(code, fallback)
	if self.locales[code] then
		self.currentLocaleCode = code;
	elseif fallback then
		self.currentLocaleCode = self:GetDefaultLocale();
	end
end

---Get the default locale
---@return string
function Localization:GetDefaultLocale()
	return DEFAULT_LOCALE_CODE;
end

---Get the preferred locale: GAME_LOCALE override, else the client locale, else enUS
---@return string
function Localization:GetPreferredLocale()
	-- GAME_LOCALE is an opt-in override (e.g. AddonLocale), nil on a normal client
	local clientLocale = GAME_LOCALE or GetLocale();
	if self.locales[clientLocale] then
		return clientLocale;
	end
	return DEFAULT_LOCALE_CODE;
end

---Get a localized string by key
---@param key string
---@param ... any
---@return string
function Localization:GetText(key, ...)
	local text;
	local active = self.locales[self.currentLocaleCode];

	if active then
		text = active[key];
	end

	if text == nil then
		text = self.locales[DEFAULT_LOCALE_CODE] and self.locales[DEFAULT_LOCALE_CODE][key];
	end

	if text == nil then
		text = key;
	end

	if select("#", ...) > 0 then
		return text:format(...);
	end

	return text;
end

---Initialize localization and set the Global keybindings.
function Localization:Initialize()
	self:SetCurrentLocale(self:GetPreferredLocale(), true);

	BINDING_NAME_ED_TOGGLE = ED.Localization.BINDING_NAME_ED_TOGGLE;
	BINDING_NAME_ED_SETTINGS = ED.Localization.BINDING_NAME_ED_SETTINGS;
	BINDING_NAME_ED_MENTIONS = ED.Localization.BINDING_NAME_ED_MENTIONS;
	BINDING_NAME_ED_EAVESDROP_ON = ED.Localization.BINDING_NAME_ED_EAVESDROP_ON;
end

ED.LocalizationClass = Localization;
