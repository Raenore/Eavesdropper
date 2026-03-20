-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@type EavesdropperPlayerName
local PlayerName = ED.PlayerName;

---@class EavesdropperGossipText
local GossipText = {};

function GossipText.GetPlayerPreferredName()
	return PlayerName.preferredName;
end

function GossipText.RefreshPlayerPreferredName()
	if not ED.MSP.IsEnabled() then
		return;
	end
	PlayerName.RefreshPlayerPreferredName();
end

---@param gossipText string
function GossipText.SubstitutePlayerPreferredName(gossipText)
	if ED.Database:GetSetting("QuestTextNameDisplayMode") == 3 then
		return gossipText;
	end

	return PlayerName:SubstitutePlayerPreferredName(gossipText);
end

function GossipText:Init()
	self:RefreshPlayerPreferredName();
end

ED.GossipText = GossipText;
