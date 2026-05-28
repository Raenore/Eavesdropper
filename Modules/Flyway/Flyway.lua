-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3, Sippy Cup
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperFlyway
local Flyway = {};

local SCHEMA_VERSION = 1;

local function ApplyPatches(fromBuild, toBuild)
	local patched = false;
	for i = fromBuild, toBuild do
		local patch = Flyway.Patches[tostring(i)];
		local patchFn = type(patch) == "table" and patch.run or nil;

		if type(patchFn) == "function" then
			local desc = "Applying patch " .. i .. (patch.description and (": " .. patch.description) or "");
			ED.Debug:Print(desc);
			patchFn();
			patched = true;
		end
	end

	if patched then
		local logText = ("Patch applied from %s to %s on %s"):format(fromBuild - 1, toBuild, date("%d/%m/%y %H:%M:%S"));
		ED.Database:SetGlobalSetting("Flyway", { Log = logText });
	end
end

---ApplyPatches runs any outstanding Flyway migration patches against the current saved data.
---@return nil
function Flyway.ApplyPatches()
	local flyway = ED.Database:GetGlobalSetting("Flyway");
	local currentBuild = flyway and flyway.CurrentBuild or 0;

	-- Prevent running patches if saved data is from a newer version than we support
	if currentBuild > SCHEMA_VERSION then
		ED.Debug:Print("Saved data is from a newer version (" .. currentBuild .. "), skipping Flyway.");
		return;
	end

	if currentBuild < SCHEMA_VERSION then
		ApplyPatches(currentBuild + 1, SCHEMA_VERSION);
	end

	ED.Database:SetGlobalSetting("Flyway", { CurrentBuild = SCHEMA_VERSION });
end

ED.Flyway = Flyway;
