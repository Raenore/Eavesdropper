-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

function ED.Init()
	EventUtil.ContinueOnPlayerLogin(function()
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

			if msg == "show" then
				ED.Frame:Show();
				ED.Frame.closed = false;
				return;
			elseif msg == "hide" then
				ED.Frame:Hide();
				ED.Frame.closed = true;
				return;
			elseif msg == "toggle" then
				ED.Frame:SetShown(not ED.Frame:IsShown());
				ED.Frame.closed = not ED.Frame:IsShown();
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
			ED.Magnifier:HandleUpdate(0);
			ED.Minimap:SetupMinimapButtons();
		end);
	end);
end

EventUtil.ContinueOnAddOnLoaded("Eavesdropper", ED.Init);
