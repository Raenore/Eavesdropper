-- Copyright The Eavesdropper Authors
-- SPDX-License-Identifier: Apache-2.0

---@class ED
ED = select(2, ...);

ED.Globals = {
	--@debug@
	-- Debug mode is enable when the add-on has not been packaged by Curse
	DEBUG_MODE = true;
	--@end-debug@

	--[===[@non-debug@
	-- Debug mode is disabled when the add-on has been packaged by Curse
	DEBUG_MODE = false;
	--@end-non-debug@]===]
};
