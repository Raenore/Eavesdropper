-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperPlayerName
local PlayerName = {};

---Default to the OOC character name until MSP data is available.
PlayerName.preferredName = ED.Globals.player_character_name;

---Refreshes the cached preferred name from MSP data, falling back to the OOC name.
function PlayerName.RefreshPlayerPreferredName()
	PlayerName.preferredName = ED.Globals.player_character_name;

	-- Request MSP data with a cache bust to make sure we get latest.
	local fullName, firstName = ED.MSP.TryGetMSPData(ED.Utils.GetUnitName(), ED.Globals.player_guid);
	local nameDisplayMode = ED.Database:GetSetting("NPCAndQuestNameDisplayMode");
	local useRPName = nameDisplayMode ~= 3;

	if useRPName then
		if nameDisplayMode == 2 and firstName then
			PlayerName.preferredName = firstName;
		elseif fullName then
			PlayerName.preferredName = fullName;
		end
	end
end

---Replaces the OOC player name in sourceText with the preferred (RP) name.
---@param sourceText string
---@return string
function PlayerName:SubstitutePlayerPreferredName(sourceText)
	if not PlayerName.preferredName then
		PlayerName.RefreshPlayerPreferredName();
	end

	if not PlayerName.preferredName
	or not ED.Globals.player_character_name
	or ED.Globals.player_character_name == "" then
		return sourceText;
	end

	-- Escape certain characters that could be in names like - and . (Mary-Sue, J.W.).
	local escapedName = ED.Globals.player_character_name:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1");
	return sourceText:gsub(escapedName, PlayerName.preferredName);
end

ED.PlayerName = PlayerName;
