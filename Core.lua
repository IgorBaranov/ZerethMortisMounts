-- Zereth Mortis Mounts :: state, counts, map pins

local ADDON, ns = ...

local DEFAULTS = {
	minimapAngle = 205,
	filter = "all", -- all | missing | ready
	selected = 1,
	tab = "mounts", -- mounts | schematics | unlock | tips
	alerts = true,
}

ns.callbacks = {}

function ns.RegisterRefresh(fn)
	table.insert(ns.callbacks, fn)
end

function ns.Refresh()
	for _, fn in ipairs(ns.callbacks) do
		fn()
	end
end

--------------------------------------------------------------------------------
-- item / mount helpers
--------------------------------------------------------------------------------

local getItemCount = (C_Item and C_Item.GetItemCount) or GetItemCount

-- Count across bags, bank, reagent bank and warband bank when the client supports it.
function ns.CountOf(itemID)
	local ok, n = pcall(getItemCount, itemID, true, false, true, true)
	if not ok or type(n) ~= "number" then
		ok, n = pcall(getItemCount, itemID, true)
	end
	return (ok and n) or 0
end

function ns.ReagentName(itemID)
	local info = ns.reagents[itemID]
	local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)
	return name or (info and info.label) or ("item:" .. itemID)
end

function ns.ReagentIcon(itemID)
	local icon = select(5, GetItemInfoInstant(itemID))
	return icon or 134400 -- question mark
end

function ns.MountIcon(spellID)
	local mountID = C_MountJournal.GetMountFromSpell(spellID)
	if mountID then
		local _, _, icon = C_MountJournal.GetMountInfoByID(mountID)
		if icon then return icon end
	end
	return 134400
end

-- The recipe is in the forge once the Schematic Reassimilation quest is done.
function ns.HasRecipe(mount)
	local q = mount.schematic and mount.schematic.quest
	return q and C_QuestLog.IsQuestFlaggedCompleted(q) or false
end

function ns.IsCollected(spellID)
	local mountID = C_MountJournal.GetMountFromSpell(spellID)
	if not mountID then return false end
	local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
	return isCollected and true or false
end

-- Returns the three requirement rows for a mount, plus rollup flags.
function ns.Requirements(mount)
	local motes = ns.CountOf(ns.MOTE_ITEM)
	local rows = {
		{ itemID = ns.MOTE_ITEM, need = mount.motes, have = motes },
		{ itemID = mount.lattice, need = 1, have = ns.CountOf(mount.lattice) },
		{ itemID = mount.rare, need = 1, have = ns.CountOf(mount.rare) },
	}
	local metCount, ready = 0, true
	for _, row in ipairs(rows) do
		row.met = row.have >= row.need
		if row.met then metCount = metCount + 1 else ready = false end
	end
	return rows, metCount, ready
end

function ns.Summary()
	local collected, ready, motesNeeded, recipes = 0, 0, 0, 0
	for _, mount in ipairs(ns.mounts) do
		if ns.HasRecipe(mount) then recipes = recipes + 1 end
		if ns.IsCollected(mount.spellID) then
			collected = collected + 1
		else
			motesNeeded = motesNeeded + mount.motes
			local _, _, isReady = ns.Requirements(mount)
			if isReady then ready = ready + 1 end
		end
	end
	return collected, #ns.mounts, ready, motesNeeded, recipes
end

-- Mounts grouped by schematic source bucket, in ns.SOURCE_TYPES order.
function ns.SchematicGroups()
	local byType = {}
	for _, mount in ipairs(ns.mounts) do
		local t = mount.schematic.srcType
		byType[t] = byType[t] or {}
		table.insert(byType[t], mount)
	end
	local out = {}
	for _, spec in ipairs(ns.SOURCE_TYPES) do
		local list = byType[spec.key]
		if list then
			table.insert(out, { spec = spec, mounts = list })
		end
	end
	return out
end

-- Unlock-chain step states: "done" | "active" | "next" | "locked"
-- Returns an array parallel to ns.unlockChain, plus true when crafting is unlocked.
function ns.UnlockStates()
	local unlocked = IsPlayerSpell(ns.UNLOCK_SPELL)
		or C_QuestLog.IsQuestFlaggedCompleted(65427)
	local states = {}

	local function touched(id)
		return C_QuestLog.IsQuestFlaggedCompleted(id) or C_QuestLog.IsOnQuest(id)
	end

	local prevDone = true
	for i, step in ipairs(ns.unlockChain) do
		local state
		if step.type == "note" then
			-- informational row, never gates anything
			state = "note"
		elseif step.type == "infer" then
			-- cannot be read from the API; certainly behind us once any of these exists
			local done = unlocked
			for _, id in ipairs(step.inferQuests) do
				if touched(id) then done = true break end
			end
			state = done and "done" or (prevDone and "next" or "locked")
		elseif C_QuestLog.IsQuestFlaggedCompleted(step.id) or unlocked then
			state = "done"
		elseif C_QuestLog.IsOnQuest(step.id) then
			state = "active"
		elseif prevDone then
			state = "next"
		else
			state = "locked"
		end
		states[i] = state
		if state ~= "note" then
			prevDone = (state == "done")
		end
	end
	return states, unlocked
end

function ns.MountList()
	local filter = ZerethMortisMountsDB.filter
	local out = {}
	for _, mount in ipairs(ns.mounts) do
		local collected = ns.IsCollected(mount.spellID)
		local _, _, isReady = ns.Requirements(mount)
		local show = true
		if filter == "missing" then
			show = not collected
		elseif filter == "ready" then
			show = (not collected) and isReady
		end
		if show then
			table.insert(out, mount)
		end
	end
	return out
end

--------------------------------------------------------------------------------
-- map pins
--------------------------------------------------------------------------------

function ns.Print(msg)
	print("|cff8ce0ffZereth Mortis Mounts|r: " .. msg)
end

function ns.Pin(x, y, label)
	if not (x and y) then
		ns.Print("no map location for " .. (label or "that") .. " -- see the description.")
		return
	end
	if not (C_Map and C_Map.SetUserWaypoint and UiMapPoint) then
		ns.Print(("%s -- Zereth Mortis %.1f, %.1f"):format(label or "Target", x, y))
		return
	end
	if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(ns.MAP_ID) then
		ns.Print(("cannot place a waypoint right now. %s is at Zereth Mortis %.1f, %.1f"):format(label or "Target", x, y))
		return
	end
	C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(ns.MAP_ID, x / 100, y / 100))
	if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
		C_SuperTrack.SetSuperTrackedUserWaypoint(true)
	end
	ns.Print(("pin set -- %s (Zereth Mortis %.1f, %.1f)"):format(label or "Target", x, y))
end

--------------------------------------------------------------------------------
-- boot
--------------------------------------------------------------------------------

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("BAG_UPDATE_DELAYED")
loader:RegisterEvent("NEW_MOUNT_ADDED")
loader:RegisterEvent("QUEST_TURNED_IN")
loader:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
loader:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		ZerethMortisMountsDB = ZerethMortisMountsDB or {}
		for k, v in pairs(DEFAULTS) do
			if ZerethMortisMountsDB[k] == nil then
				ZerethMortisMountsDB[k] = v
			end
		end
	elseif event == "PLAYER_LOGIN" then
		ns.BuildUI()
		ns.BuildMinimapButton()
		-- give bag and quest data time to cache before taking a baseline,
		-- otherwise the first bag update looks like everything just unlocked
		C_Timer.After(6, ns.PrimeCraftable)
	else
		ns.CheckCraftable()
		if ns.window and ns.window:IsShown() then
			ns.Refresh()
		end
	end
end)

SLASH_ZERETHMORTISMOUNTS1 = "/zmm"
SLASH_ZERETHMORTISMOUNTS2 = "/zerethmounts"
SlashCmdList.ZERETHMORTISMOUNTS = function(msg)
	msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	if msg == "alerts" then
		ZerethMortisMountsDB.alerts = not ZerethMortisMountsDB.alerts
		ns.Print(ZerethMortisMountsDB.alerts
			and "craft alerts |cff55ee66on|r."
			or "craft alerts |cffff6666off|r.")
	elseif msg == "reset" then
		ZerethMortisMountsDB.toastPos = nil
		ns.Print("alert popup position reset to the top of the screen.")
	else
		ns.Toggle()
	end
end
