-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperPlayerName
local PlayerName = {};

PlayerName.preferredName = ED.Globals.player_character_name;

---@param defaultName string
function PlayerName:RefreshPlayerPreferredName()
	PlayerName.preferredName = ED.Globals.player_character_name;
	-- Request MSP data with a cache bust to make sure we get latest.
	local fullName, firstName = ED.MSP.TryGetMSPData(ED.Utils.GetUnitName(), ED.Globals.player_guid);
	local questTextNameDisplayMode = ED.Database:GetSetting("QuestTextNameDisplayMode");
	local useRPName = questTextNameDisplayMode ~= 3;

	if useRPName then
		if questTextNameDisplayMode == 2 and firstName then
			PlayerName.preferredName = firstName;
		elseif fullName then
			PlayerName.preferredName = fullName;
		end
	end
end

---@param sourceText string
function PlayerName:SubstitutePlayerPreferredName(sourceText)
	if not PlayerName.preferredName then
		self:RefreshPlayerPreferredName();
	end

	if not PlayerName.preferredName or not ED.Globals.player_character_name or ED.Globals.player_character_name == "" then
		return sourceText;
	end

	-- Escape certain characters that could be in names like - and . (Mary-Sue, J.W.).
	local escapedName = ED.Globals.player_character_name:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1");
	local result = sourceText:gsub(escapedName, PlayerName.preferredName);
	return result;
end

ED.PlayerName = PlayerName;
