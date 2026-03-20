-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class EavesdropperDebug
local Debug = {};

local printEnabled = false;

---Returns true if debug mode is currently active.
---@return boolean
function Debug:IsEnabled()
	return ED and ED.Globals and ED.Globals.DEBUG_MODE == true;
end

---Prints a prefixed debug message if debug mode and printEnabled are both active.
---@param ... any
function Debug:Print(...)
	if not self:IsEnabled() or not printEnabled then return; end
	print("|cnFRAMESTACK_REGION_COLOR:Eavesdropper|r", ...);
end

ED.Debug = Debug;
