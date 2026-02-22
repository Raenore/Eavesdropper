-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperDebug
local Debug = {};

local printEnabled = false;

---@return boolean
function Debug:IsEnabled()
	return ED and ED.Globals and ED.Globals.DEBUG_MODE == true;
end

---@param ... any Values to print
---@return nil
function Debug:Print(...)
	if not self or not self:IsEnabled() or not printEnabled then return; end;
	print("|cnFRAMESTACK_REGION_COLOR:Eavesdropper|r", ...);
end

ED.Debug = Debug;
