-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

function ED.Init()
	EventUtil.ContinueOnPlayerLogin(function()
		-- Automatically set preferred locale (respects GAME_LOCALE)
		ED.Localization:SetCurrentLocale(ED.Localization:GetPreferredLocale(), true);

		-- DB must be ready first
		ED.Database:Init();

		ED.Keywords:ParseList();

		-- Now safe to initialize everything else
		ED.FrameModule:Init();
		ED.ChatHandler:Init();
		ED.Config:Init();
		ED.Magnifier:Setup();

		SLASH_EAVESDROPPER1, SLASH_EAVESDROPPER2 = "/ed", "/eavesdropper";
		SlashCmdList["EAVESDROPPER"] = function(msg)
			msg = type(msg) == "string" and msg:lower() or "";

			if msg == "help" then
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
