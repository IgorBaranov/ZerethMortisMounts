-- Zereth Mortis Mounts :: state, counts, map pins

local ADDON, ns = ...

local DEFAULTS = {
	minimapAngle = 205,
	filter = "all", -- all | missing | ready
	selected = 1,
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
	local collected, ready, motesNeeded = 0, 0, 0
	for _, mount in ipairs(ns.mounts) do
		if ns.IsCollected(mount.spellID) then
			collected = collected + 1
		else
			motesNeeded = motesNeeded + mount.motes
			local _, _, isReady = ns.Requirements(mount)
			if isReady then ready = ready + 1 end
		end
	end
	return collected, #ns.mounts, ready, motesNeeded
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
	else
		if ns.window and ns.window:IsShown() then
			ns.Refresh()
		end
	end
end)

SLASH_ZERETHMORTISMOUNTS1 = "/zmm"
SLASH_ZERETHMORTISMOUNTS2 = "/zerethmounts"
SlashCmdList.ZERETHMORTISMOUNTS = function()
	ns.Toggle()
end
