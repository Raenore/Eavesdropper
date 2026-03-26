-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

function ED.Init()
	EventUtil.ContinueOnPlayerLogin(function()
		-- Automatically set preferred locale (respects GAME_LOCALE)
		ED.Localization:SetCurrentLocale(ED.Localization:GetPreferredLocale(), true);

		-- DB must be ready first
		ED.Database:Init();

		ED.QuestText.Init();
		ED.MSP.Init();
		ED.Keywords:ParseList();

		-- Now safe to initialize everything else
		ED.FrameModule:Init();
		ED.GroupFrame:RestoreFromCharDB();
		ED.ChatHandler:Init();
		ED.Config:Init();
		ED.Magnifier:Setup();
		ED.UnitPopups:Init()

		SLASH_EAVESDROPPER1, SLASH_EAVESDROPPER2 = "/ed", "/eavesdropper";
		SlashCmdList["EAVESDROPPER"] = function(msg)
			local originalMsg = type(msg) == "string" and msg or "";
			msg = originalMsg:lower();

			if ED.Globals.DEBUG_MODE and (msg == "testclear" or msg:sub(1, 10) == "testclear ") then
				ED.Debug:HandleTestClear(originalMsg:sub(11));
				return;
			elseif ED.Globals.DEBUG_MODE and (msg == "test" or msg:sub(1, 5) == "test ") then
				ED.Debug:HandleTest(originalMsg:sub(6));
				return;
			elseif msg == "help" then
				ED.Utils.WriteCommandTable({
					[ED.Localization.SLASH_COMMAND_ED] = "/ed",
					[ED.Localization.SLASH_COMMAND_ED_SHOW] = "/ed show",
					[ED.Localization.SLASH_COMMAND_ED_HIDE] = "/ed hide",
					[ED.Localization.SLASH_COMMAND_ED_TOGGLE] = "/ed toggle",
				});
				return;
			elseif msg == "show" then
				ED.Frame:Show();
				ED.Database:SetCharSetting("WindowVisible", true);
				return;
			elseif msg == "hide" then
				ED.Frame:Hide();
				ED.Database:SetCharSetting("WindowVisible", false);
				return;
			elseif msg == "toggle" then
				ED.Frame:SetShown(not ED.Frame:IsShown());
				ED.Database:SetCharSetting("WindowVisible", ED.Frame:IsShown());
				return;
			end

			ED.Settings:ShowSettings();
			return;
		end

		if ED.Globals.DEBUG_MODE then
			-- Register /rl for reloading if it hasn't already (other addons can/will overwrite).
			SLASH_EAVESDROPPER_RELOAD1 = "/rl";
			SlashCmdList["EAVESDROPPER_RELOAD"] = function()
				ReloadUI();
			end;
		end

		C_Timer.After(1, function()
			ED.Frame:RefreshChat();
			ED.Magnifier:HandleUpdate(ED.Enums.MAGNIFIER_REASON.LOGIN);
			ED.Minimap:SetupMinimapButtons();

			if ED.Database:GetGlobalSetting("WelcomeMessage") then
				ED.Utils.Write(ED.Localization.WELCOMEMSG_VERSION:format(ED.Database:GetProfileName(), ED.Globals.addon_version));
				ED.Utils.Write(ED.Localization.WELCOMEMSG_SETTINGS);
			end
		end);
	end);
end

EventUtil.ContinueOnAddOnLoaded("Eavesdropper", ED.Init);
