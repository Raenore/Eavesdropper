-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

function ED.ProcessCommand(msg)
	local originalMsg = type(msg) == "string" and msg or "";
	local subcommand = originalMsg:lower():match("^%s*(%S+)") or ""; -- Extract first word as subcommand (e.g. show from "/ed show")
	local args = originalMsg:match("^%s*%S+%s+(.-)%s*$") or ""; -- Extract everything after subcommand as args

	if ED.Globals.DEBUG_MODE and subcommand == "testclear" then
		ED.Debug:HandleTestClear(args);
		return;
	elseif ED.Globals.DEBUG_MODE and subcommand == "test" then
		ED.Debug:HandleTest(args);
		return;
	elseif subcommand == "help" then
		ED.Utils.WriteCommandTable({
			[ED.Localization.SLASH_COMMAND_ED] = "/ed",
			[ED.Localization.SLASH_COMMAND_ED_SHOW] = "/ed show",
			[ED.Localization.SLASH_COMMAND_ED_HIDE] = "/ed hide",
			[ED.Localization.SLASH_COMMAND_ED_TOGGLE] = "/ed toggle",
			[ED.Localization.SLASH_COMMAND_ED_MENTIONS] = "/ed mentions",
		});
		return;
	elseif subcommand == "show" then
		ED.Frame:Show();
		ED.Database:SetCharSetting("WindowVisible", true);
		return;
	elseif subcommand == "hide" then
		ED.Frame:Hide();
		ED.Database:SetCharSetting("WindowVisible", false);
		return;
	elseif subcommand == "toggle" then
		ED.Frame:SetShown(not ED.Frame:IsShown());
		ED.Database:SetCharSetting("WindowVisible", ED.Frame:IsShown());
		return;
	elseif subcommand == "mentions" then
		if ED.MentionsFrame:IsShown() then
			ED.MentionsFrame:Hide();
		else
			ED.MentionsFrame:Open();
		end
		return;
	end

	ED.Settings.ToggleSettings();
	return;
end

function ED.Init()
	EventUtil.ContinueOnPlayerLogin(function()
		-- Automatically set preferred locale (respects GAME_LOCALE)
		ED.Localization:Initialize();

		-- DB must be ready first
		ED.Database:Init();
		ED.Flyway.ApplyPatches();
		ED.PlayerCache:BackfillFromGroupRoster();
		if IsInGuild() then
			C_GuildInfo.GuildRoster();
			if ED.PlayerCache:HasBareNames() then
				ED.Events:RegisterEvent("GUILD_ROSTER_UPDATE");
			end
		end

		ED.QuestText.Init();
		ED.MSP.Init();
		ED.Keywords:ParseList();

		-- Now safe to initialize everything else
		ED.FrameModule.Init();
		ED.MentionsFrameModule.Init();
		ED.DedicatedFrame:RestoreFromCharDB();
		ED.GroupFrame:RestoreFromCharDB();
		ED.ChatHandler:Init();
		ED.Config.Init();
		ED.Magnifier:Setup();
		ED.UnitPopups:Init();

		SLASH_EAVESDROPPER1, SLASH_EAVESDROPPER2 = "/ed", "/eavesdropper";
		SlashCmdList["EAVESDROPPER"] = function(msg) ED.ProcessCommand(msg); end;

		EventRegistry:RegisterCallback("SetItemRef", function(_owner, link, _text, _button, _frame)
			--[[ if ED.Globals.DEBUG_MODE then
				print("[ED] SetItemRef: " .. tostring(link));
			end --]]
			local cmd = link:match("^addon:Eavesdropper:cmd:(.*)$");
			if cmd then ED.ProcessCommand(cmd); end
		end);

		if ED.Globals.DEBUG_MODE then
			-- Register /rl for reloading if it hasn't already (other addons can/will overwrite).
			SLASH_EAVESDROPPER_RELOAD1 = "/rl";
			SlashCmdList["EAVESDROPPER_RELOAD"] = function()
				ReloadUI();
			end;
		end

		-- Login-time setup is complete; deferred callbacks may now touch the DB and modules.
		ED.Globals.initialized = true;

		C_Timer.After(1, function()
			ED.Frame:RefreshChat();
			ED.Magnifier:HandleUpdate(ED.Enums.MAGNIFIER_REASON.LOGIN);
			ED.Minimap.SetupMinimapButtons();

			-- Catches chat logs an addon like Chattynator restored from a prior session.
			if ED.Database:GetSetting("ApplyOnMainChat") then
				ED.AdvancedFormatter:RefreshMainChat();
			end

			if ED.Database:GetGlobalSetting("WelcomeMessage") then
				ED.Utils.Write(ED.Localization.WELCOMEMSG_VERSION:format(ED.Database:GetProfileName(), ED.Globals.addon_version));
				ED.Utils.Write(ED.Localization.WELCOMEMSG_SETTINGS:format(
					ED.Utils.CommandHyperlink("", ED.Localization.SLASH_COMMAND_ED_SETTINGS),
					ED.Utils.CommandHyperlink("help", ED.Localization.SLASH_COMMAND_ED_HELP)
				));
			end
		end);
	end);
end

EventUtil.ContinueOnAddOnLoaded("Eavesdropper", ED.Init);
