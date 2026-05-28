-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3, Sippy Cup
-- SPDX-License-Identifier: Apache-2.0

ED.Flyway.Patches = {};

ED.Flyway.Patches["1"] = {
	run = function()
		if not EavesdropperDB then return; end

		if EavesdropperDB.profiles then
			local themeEnabled = true;

			for _, profileData in pairs(EavesdropperDB.profiles) do
				if profileData["ElvUITheme"] ~= nil then
					-- If theme was disabled in one profile, assume it as global
					if profileData["ElvUITheme"] == false then
						themeEnabled = false;
					end
					profileData["ElvUITheme"] = nil;
				end
			end

			EavesdropperDB.global.ElvUITheme = themeEnabled;
		end
	end,

	description = "Migrate profile-specific ElvUITheme to global, if disabled (default was enabled), we disable it globally.",
};
