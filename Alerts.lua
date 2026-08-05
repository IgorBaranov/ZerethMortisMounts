-- Zereth Mortis Mounts :: "you can craft this now" toast
-- Deliberately quiet: no sound, no screen-centre banner, auto-fades, draggable.

local ADDON, ns = ...

local seen = {}
local primed = false
local toast, hideToken

-- Craftable for real: you own the recipe, you have every reagent, and you do
-- not already have the mount.
function ns.IsCraftable(mount)
	if ns.IsCollected(mount.spellID) then return false end
	if not ns.HasRecipe(mount) then return false end
	local _, _, ready = ns.Requirements(mount)
	return ready
end

local function CurrentSet()
	local set = {}
	for _, mount in ipairs(ns.mounts) do
		if ns.IsCraftable(mount) then
			set[mount] = true
		end
	end
	return set
end

--------------------------------------------------------------------------------
-- toast
--------------------------------------------------------------------------------

local function BuildToast()
	local f = CreateFrame("Frame", "ZerethMortisMountsToast", UIParent, "BackdropTemplate")
	f:SetSize(320, 50)
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 14,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	f:SetBackdropColor(0.04, 0.06, 0.10, 0.94)
	f:SetBackdropBorderColor(0.95, 0.78, 0.30, 1)
	f:SetFrameStrata("DIALOG")
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(self)
		self.dragged = true
		self:StartMoving()
	end)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, _, x, y = self:GetPoint()
		ZerethMortisMountsDB.toastPos = { point = point, x = x, y = y }
		-- cleared next frame so the mouse-up that ends the drag does not
		-- also count as a click
		C_Timer.After(0, function() self.dragged = nil end)
	end)

	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetSize(30, 30)
	f.icon:SetPoint("LEFT", 10, 0)
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.title:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 9, -1)
	f.title:SetJustifyH("LEFT")
	f.title:SetText("|cffffd100Ready to craft|r")

	f.body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.body:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -3)
	f.body:SetPoint("RIGHT", f, "RIGHT", -26, 0)
	f.body:SetJustifyH("LEFT")
	f.body:SetWordWrap(false)

	f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.close:SetSize(22, 22)
	f.close:SetPoint("TOPRIGHT", -1, -1)
	f.close:SetScript("OnClick", function() f:Hide() end)

	-- clicking the toast opens the addon on the relevant mount
	f:SetScript("OnMouseUp", function(self, button)
		if button ~= "LeftButton" or self.dragged then return end
		if #self.mounts == 1 then
			for i, mount in ipairs(ns.mounts) do
				if mount == self.mounts[1] then
					ZerethMortisMountsDB.tab = "mounts"
					ZerethMortisMountsDB.filter = "all"
					ZerethMortisMountsDB.selected = i
					break
				end
			end
		else
			ZerethMortisMountsDB.tab = "mounts"
			ZerethMortisMountsDB.filter = "ready"
			ZerethMortisMountsDB.selected = nil
		end
		if not ns.window:IsShown() then ns.window:Show() end
		ns.Refresh()
		self:Hide()
	end)

	f:SetScript("OnEnter", function(self)
		if hideToken then hideToken.cancelled = true end
		UIFrameFadeRemoveFrame(self)
		self:SetAlpha(1)
	end)
	f:SetScript("OnLeave", function(self)
		ns.ScheduleToastHide(4)
	end)

	f:Hide()
	return f
end

function ns.ScheduleToastHide(seconds)
	if hideToken then hideToken.cancelled = true end
	local token = {}
	hideToken = token
	C_Timer.After(seconds, function()
		if token.cancelled or not toast or not toast:IsShown() then return end
		if toast:IsMouseOver() then
			ns.ScheduleToastHide(3)
			return
		end
		UIFrameFadeOut(toast, 1.2, toast:GetAlpha(), 0)
		C_Timer.After(1.3, function()
			if not token.cancelled then toast:Hide() end
		end)
	end)
end

local function ShowToast(mounts)
	toast = toast or BuildToast()
	toast.mounts = mounts

	local pos = ZerethMortisMountsDB.toastPos
	toast:ClearAllPoints()
	if pos then
		toast:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
	else
		toast:SetPoint("TOP", UIParent, "TOP", 0, -140)
	end

	toast.icon:SetTexture(ns.MountIcon(mounts[1].spellID))
	if #mounts == 1 then
		toast.body:SetText(mounts[1].name)
	else
		toast.body:SetText(("%s |cff888888+%d more|r"):format(mounts[1].name, #mounts - 1))
	end

	UIFrameFadeRemoveFrame(toast)
	toast:SetAlpha(0)
	toast:Show()
	UIFrameFadeIn(toast, 0.25, 0, 1)
	ns.ScheduleToastHide(8)
end

--------------------------------------------------------------------------------
-- detection
--------------------------------------------------------------------------------

-- Called once, a few seconds after login, so that bag and quest data is cached.
-- Without this, the first bag update would report everything as newly craftable.
function ns.PrimeCraftable()
	seen = CurrentSet()
	primed = true
end

function ns.CheckCraftable()
	if not primed or ZerethMortisMountsDB.alerts == false then
		if primed then seen = CurrentSet() end -- keep the baseline fresh while muted
		return
	end

	local set = CurrentSet()
	local fresh = {}
	for mount in pairs(set) do
		if not seen[mount] then
			table.insert(fresh, mount)
		end
	end
	seen = set

	if #fresh > 0 then
		table.sort(fresh, function(a, b) return a.motes > b.motes end)
		ShowToast(fresh)
	end
end
