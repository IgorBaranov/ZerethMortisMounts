-- Zereth Mortis Mounts :: window + minimap button

local ADDON, ns = ...

local WIDTH, HEIGHT = 880, 560
local LIST_WIDTH = 330
local ROW_HEIGHT = 26

local GREEN = { 0.35, 0.95, 0.45 }
local RED = { 1.00, 0.40, 0.40 }
local GOLD = { 1.00, 0.82, 0.00 }

local ICON_READY = "Interface\\RaidFrame\\ReadyCheck-Ready"
local ICON_NOT = "Interface\\RaidFrame\\ReadyCheck-NotReady"

local Atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

local function Comma(n)
	local s = tostring(n)
	local k
	repeat
		s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return s
end

--------------------------------------------------------------------------------
-- small builders
--------------------------------------------------------------------------------

local function MakeBackdropFrame(parent, name)
	local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	f:SetBackdropColor(0.05, 0.06, 0.09, 0.95)
	f:SetBackdropBorderColor(0.35, 0.45, 0.6, 1)
	return f
end

local function MakePinButton(parent)
	local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	b:SetSize(52, 20)
	b:SetText("Pin")
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.x then
			GameTooltip:AddLine(self.label or "Set map pin", 1, 1, 1)
			GameTooltip:AddLine(("Zereth Mortis %.1f, %.1f"):format(self.x, self.y), 0.7, 0.8, 1)
			GameTooltip:AddLine("Click to drop a waypoint and start tracking it.", 0.6, 0.6, 0.6, true)
		else
			GameTooltip:AddLine("No map location", 1, 1, 1)
			GameTooltip:AddLine("This one is not out in the world -- read the description.", 0.6, 0.6, 0.6, true)
		end
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", GameTooltip_Hide)
	b:SetScript("OnClick", function(self)
		ns.Pin(self.x, self.y, self.label)
	end)
	return b
end

local function SetPin(button, x, y, label)
	button.x, button.y, button.label = x, y, label
	button:SetEnabled(x ~= nil)
end

--------------------------------------------------------------------------------
-- window
--------------------------------------------------------------------------------

local rows = {}
local detail

local function SelectMount(index)
	ZerethMortisMountsDB.selected = index
	ns.Refresh()
end

local function CreateRow(parent, i)
	local row = CreateFrame("Button", nil, parent)
	row:SetSize(LIST_WIDTH - 28, ROW_HEIGHT)

	row.bg = row:CreateTexture(nil, "BACKGROUND")
	row.bg:SetAllPoints()
	row.bg:SetColorTexture(1, 1, 1, 0.06)
	row.bg:Hide()

	row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(0.4, 0.6, 1, 0.15)

	row.status = row:CreateTexture(nil, "ARTWORK")
	row.status:SetSize(16, 16)
	row.status:SetPoint("LEFT", 4, 0)

	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(20, 20)
	row.icon:SetPoint("LEFT", row.status, "RIGHT", 6, 0)
	row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.name:SetPoint("RIGHT", row, "RIGHT", -46, 0)
	row.name:SetJustifyH("LEFT")
	row.name:SetWordWrap(false)

	row.progress = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.progress:SetPoint("RIGHT", -6, 0)

	row:SetScript("OnClick", function(self) SelectMount(self.index) end)
	row:SetScript("OnEnter", function(self)
		local mount = ns.mounts[self.index]
		if not mount then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(mount.itemID)
		GameTooltip:Show()
	end)
	row:SetScript("OnLeave", GameTooltip_Hide)

	return row
end

local function CreateReagentBlock(parent)
	local b = CreateFrame("Frame", nil, parent)
	b:SetHeight(40)

	b.icon = b:CreateTexture(nil, "ARTWORK")
	b.icon:SetSize(18, 18)
	b.icon:SetPoint("TOPLEFT", 0, -1)
	b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	b.title = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	b.title:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", 6, -2)
	b.title:SetJustifyH("LEFT")

	b.have = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	b.have:SetPoint("TOPRIGHT", -58, -3)
	b.have:SetJustifyH("RIGHT")

	b.pin = MakePinButton(b)
	b.pin:SetPoint("TOPRIGHT", 0, 0)

	b.how = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	b.how:SetPoint("TOPLEFT", b.icon, "BOTTOMLEFT", 0, -3)
	b.how:SetJustifyH("LEFT")
	b.how:SetTextColor(0.68, 0.68, 0.74)

	b.hit = CreateFrame("Frame", nil, b)
	b.hit:SetPoint("TOPLEFT")
	b.hit:SetPoint("BOTTOMRIGHT", b.pin, "BOTTOMLEFT", -4, 0)
	b.hit:SetScript("OnEnter", function(self)
		if not b.itemID then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetItemByID(b.itemID)
		GameTooltip:Show()
	end)
	b.hit:SetScript("OnLeave", GameTooltip_Hide)

	return b
end

function ns.BuildUI()
	if ns.window then return end

	local f = MakeBackdropFrame(UIParent, "ZerethMortisMountsFrame")
	f:SetSize(WIDTH, HEIGHT)
	f:SetPoint("CENTER")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetClampedToScreen(true)
	f:SetFrameStrata("HIGH")
	f:Hide()
	ns.window = f
	if UISpecialFrames then -- close on Escape
		table.insert(UISpecialFrames, "ZerethMortisMountsFrame")
	end

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -14)
	title:SetText("Zereth Mortis Mounts")
	title:SetTextColor(unpack(GOLD))

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)

	f.summary = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.summary:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -6)
	f.summary:SetJustifyH("LEFT")

	-- filters
	local filters = {
		{ key = "all", text = "All" },
		{ key = "missing", text = "Not learned" },
		{ key = "ready", text = "Craftable now" },
	}
	f.filterButtons = {}
	local prev
	for _, spec in ipairs(filters) do
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetSize(96, 20)
		b:SetText(spec.text)
		if prev then
			b:SetPoint("LEFT", prev, "RIGHT", 4, 0)
		else
			b:SetPoint("TOPLEFT", f.summary, "BOTTOMLEFT", -1, -8)
		end
		b:SetScript("OnClick", function()
			ZerethMortisMountsDB.filter = spec.key
			ZerethMortisMountsDB.selected = nil
			ns.Refresh()
		end)
		b.key = spec.key
		table.insert(f.filterButtons, b)
		prev = b
	end

	-- list
	local listBox = MakeBackdropFrame(f)
	listBox:SetPoint("TOPLEFT", 12, -102)
	listBox:SetSize(LIST_WIDTH, HEIGHT - 118)
	listBox:SetBackdropColor(0, 0, 0, 0.35)

	local scroll = CreateFrame("ScrollFrame", "ZerethMortisMountsList", listBox, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 8, -8)
	scroll:SetPoint("BOTTOMRIGHT", -28, 8)

	local listChild = CreateFrame("Frame", nil, scroll)
	listChild:SetSize(LIST_WIDTH - 28, 10)
	scroll:SetScrollChild(listChild)
	f.listChild = listChild

	for i = 1, #ns.mounts do
		local row = CreateRow(listChild, i)
		if i == 1 then
			row:SetPoint("TOPLEFT")
		else
			row:SetPoint("TOPLEFT", rows[i - 1], "BOTTOMLEFT", 0, 0)
		end
		rows[i] = row
	end

	-- detail
	local detailBox = MakeBackdropFrame(f)
	detailBox:SetPoint("TOPLEFT", listBox, "TOPRIGHT", 10, 0)
	detailBox:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 16)
	detailBox:SetBackdropColor(0, 0, 0, 0.35)

	local dScroll = CreateFrame("ScrollFrame", "ZerethMortisMountsDetail", detailBox, "UIPanelScrollFrameTemplate")
	dScroll:SetPoint("TOPLEFT", 10, -10)
	dScroll:SetPoint("BOTTOMRIGHT", -28, 10)

	local d = CreateFrame("Frame", nil, dScroll)
	local dWidth = WIDTH - LIST_WIDTH - 78
	d:SetSize(dWidth, 10)
	dScroll:SetScrollChild(d)
	detail = d
	d.width = dWidth

	d.icon = d:CreateTexture(nil, "ARTWORK")
	d.icon:SetSize(40, 40)
	d.icon:SetPoint("TOPLEFT")
	d.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	d.name = d:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	d.name:SetPoint("TOPLEFT", d.icon, "TOPRIGHT", 10, -2)
	d.name:SetPoint("RIGHT", d, "RIGHT", 0, 0)
	d.name:SetJustifyH("LEFT")

	d.sub = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	d.sub:SetPoint("TOPLEFT", d.name, "BOTTOMLEFT", 0, -4)
	d.sub:SetJustifyH("LEFT")

	d.schematicHeader = d:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	d.schematicHeader:SetPoint("TOPLEFT", d.icon, "BOTTOMLEFT", 0, -12)
	d.schematicHeader:SetText("|cffffd100Schematic|r  |cff808080(unlocks the recipe)|r")

	d.schematicPin = MakePinButton(d)
	d.schematicPin:SetPoint("TOPRIGHT", d, "TOPRIGHT", 0, -64)

	d.schematicText = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	d.schematicText:SetPoint("TOPLEFT", d.schematicHeader, "BOTTOMLEFT", 0, -4)
	d.schematicText:SetJustifyH("LEFT")
	d.schematicText:SetWidth(dWidth - 60)

	d.reagentHeader = d:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	d.reagentHeader:SetJustifyH("LEFT")
	d.reagentHeader:SetText("|cffffd100Reagents|r")

	d.blocks = {}
	for i = 1, 3 do
		local b = CreateReagentBlock(d)
		b:SetWidth(dWidth)
		d.blocks[i] = b
	end

	d.forgeHeader = d:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	d.forgeHeader:SetJustifyH("LEFT")
	d.forgeHeader:SetText("|cffffd100Where to craft|r")

	d.forgeText = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	d.forgeText:SetJustifyH("LEFT")
	d.forgeText:SetWidth(dWidth - 60)
	d.forgeText:SetText(("%s -- %s (%.1f, %.1f)"):format(ns.FORGE.name, ns.FORGE.note, ns.FORGE.x, ns.FORGE.y))

	d.forgePin = MakePinButton(d)
	SetPin(d.forgePin, ns.FORGE.x, ns.FORGE.y, ns.FORGE.name)

	d.empty = d:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
	d.empty:SetPoint("TOPLEFT", 0, -40)
	d.empty:SetWidth(dWidth)
	d.empty:SetText("Pick a mount on the left.")

	ns.RegisterRefresh(ns.UpdateWindow)
end

--------------------------------------------------------------------------------
-- refresh
--------------------------------------------------------------------------------

local function UpdateDetail(mount)
	local d = detail
	local elements = { d.icon, d.name, d.sub, d.schematicHeader, d.schematicPin, d.schematicText,
		d.reagentHeader, d.forgeHeader, d.forgeText, d.forgePin }

	if not mount then
		for _, e in ipairs(elements) do e:Hide() end
		for _, b in ipairs(d.blocks) do b:Hide() end
		d.empty:Show()
		d:SetHeight(120)
		return
	end
	d.empty:Hide()
	for _, e in ipairs(elements) do e:Show() end

	local collected = ns.IsCollected(mount.spellID)
	d.icon:SetTexture(ns.MountIcon(mount.spellID))
	d.name:SetText(mount.name)
	d.name:SetTextColor(unpack(collected and GREEN or GOLD))
	d.sub:SetText(("%s  •  %s  •  %s"):format(
		mount.family,
		mount.flying and "Flying" or "Ground",
		collected and "|cff55ee66Already learned|r" or "|cffff6666Not learned|r"))

	local s = mount.schematic
	d.schematicText:SetText(s.how)
	SetPin(d.schematicPin, s.x, s.y, "Schematic: " .. mount.name)

	-- reagents, laid out top-down with dynamic heights
	local rowsData = ns.Requirements(mount)
	local anchor, anchorPoint, gapY = d.schematicText, "BOTTOMLEFT", -14
	d.reagentHeader:ClearAllPoints()
	d.reagentHeader:SetPoint("TOPLEFT", anchor, anchorPoint, 0, gapY)
	anchor, anchorPoint, gapY = d.reagentHeader, "BOTTOMLEFT", -6

	for i, req in ipairs(rowsData) do
		local b = d.blocks[i]
		local info = ns.reagents[req.itemID] or {}
		b:Show()
		b:ClearAllPoints()
		b:SetPoint("TOPLEFT", anchor, anchorPoint, 0, gapY)
		b.itemID = req.itemID

		b.icon:SetTexture(ns.ReagentIcon(req.itemID))
		b.title:SetText(("%s%s"):format(req.need > 1 and (Comma(req.need) .. "x ") or "", ns.ReagentName(req.itemID)))
		b.have:SetText(("%s / %s"):format(Comma(req.have), Comma(req.need)))
		b.have:SetTextColor(unpack(req.met and GREEN or RED))
		b.how:SetWidth(d.width - 6)
		b.how:SetText(info.how or "")
		SetPin(b.pin, info.x, info.y, info.label)

		b:SetHeight(20 + b.how:GetStringHeight() + 6)
		anchor, anchorPoint, gapY = b, "BOTTOMLEFT", -8
	end

	d.forgeHeader:ClearAllPoints()
	d.forgeHeader:SetPoint("TOPLEFT", anchor, anchorPoint, 0, -6)
	d.forgeText:ClearAllPoints()
	d.forgeText:SetPoint("TOPLEFT", d.forgeHeader, "BOTTOMLEFT", 0, -4)
	d.forgePin:ClearAllPoints()
	d.forgePin:SetPoint("TOPRIGHT", d.forgeHeader, "TOPRIGHT", 0, 2)

	-- total content height so the scrollbar behaves
	local total = 40 + 12 + 16 + d.schematicText:GetStringHeight() + 14 + 16 + 6
	for i = 1, 3 do
		total = total + d.blocks[i]:GetHeight() + 8
	end
	total = total + 6 + 16 + 4 + d.forgeText:GetStringHeight() + 10
	d:SetHeight(total)
end

function ns.UpdateWindow()
	local f = ns.window
	if not f then return end

	local collected, total, ready, motesNeeded = ns.Summary()
	local motes = ns.CountOf(ns.MOTE_ITEM)
	f.summary:SetText(("Learned |cffffd100%d|r of |cffffd100%d|r   •   craftable right now: |cff55ee66%d|r   •   Genesis Motes: |cffffd100%s|r (|cffff8888%s|r still needed for the rest)")
		:format(collected, total, ready, Comma(motes), Comma(motesNeeded)))

	for _, b in ipairs(f.filterButtons) do
		if b.key == ZerethMortisMountsDB.filter then
			b:LockHighlight()
		else
			b:UnlockHighlight()
		end
	end

	local list = ns.MountList()
	local visible = {}
	for i, mount in ipairs(list) do
		visible[mount] = i
	end

	-- keep selection valid
	local selected = ZerethMortisMountsDB.selected
	local selectedMount = selected and ns.mounts[selected]
	if selectedMount and not visible[selectedMount] then
		selectedMount = nil
		ZerethMortisMountsDB.selected = nil
	end
	if not selectedMount and list[1] then
		for i, mount in ipairs(ns.mounts) do
			if mount == list[1] then
				ZerethMortisMountsDB.selected = i
				selectedMount = mount
				break
			end
		end
	end

	local shown = 0
	for i, row in ipairs(rows) do
		local mount = list[i]
		if mount then
			shown = shown + 1
			-- index into ns.mounts, for selection
			for j, m in ipairs(ns.mounts) do
				if m == mount then row.index = j break end
			end
			local isCollected = ns.IsCollected(mount.spellID)
			local _, metCount = ns.Requirements(mount)

			row.status:SetTexture(isCollected and ICON_READY or ICON_NOT)
			row.icon:SetTexture(ns.MountIcon(mount.spellID))
			row.name:SetText(mount.name)
			if isCollected then
				row.name:SetTextColor(0.55, 0.75, 0.55)
				row.progress:SetText("done")
				row.progress:SetTextColor(0.45, 0.6, 0.45)
			else
				row.name:SetTextColor(1, 1, 1)
				row.progress:SetText(metCount .. "/3")
				row.progress:SetTextColor(unpack(metCount == 3 and GREEN or RED))
			end
			row.bg:SetShown(mount == selectedMount)
			row:Show()
		else
			row:Hide()
		end
	end

	f.listChild:SetHeight(math.max(shown * ROW_HEIGHT, 10))
	UpdateDetail(selectedMount)
end

function ns.Toggle()
	if not ns.window then return end
	if ns.window:IsShown() then
		ns.window:Hide()
	else
		ns.window:Show()
		ns.Refresh()
	end
end

--------------------------------------------------------------------------------
-- minimap button
--------------------------------------------------------------------------------

function ns.BuildMinimapButton()
	if ns.minimapButton then return end

	local b = CreateFrame("Button", "ZerethMortisMountsMinimapButton", Minimap)
	b:SetSize(31, 31)
	b:SetFrameStrata("MEDIUM")
	b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	b:RegisterForDrag("LeftButton")
	ns.minimapButton = b

	local icon = b:CreateTexture(nil, "ARTWORK")
	icon:SetSize(19, 19)
	icon:SetPoint("CENTER", -1, 1)
	icon:SetTexture(ns.ReagentIcon(ns.MOTE_ITEM))
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	b.icon = icon

	local border = b:CreateTexture(nil, "OVERLAY")
	border:SetSize(53, 53)
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetPoint("TOPLEFT")

	local function Reposition()
		local angle = math.rad(ZerethMortisMountsDB.minimapAngle or 205)
		local radius = 80
		b:ClearAllPoints()
		b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
	end
	ns.RepositionMinimapButton = Reposition

	b:SetScript("OnDragStart", function(self)
		self.dragging = true
		self:SetScript("OnUpdate", function()
			local mx, my = Minimap:GetCenter()
			local scale = Minimap:GetEffectiveScale()
			local cx, cy = GetCursorPosition()
			cx, cy = cx / scale, cy / scale
			ZerethMortisMountsDB.minimapAngle = math.deg(Atan2(cy - my, cx - mx))
			Reposition()
		end)
	end)
	b:SetScript("OnDragStop", function(self)
		self.dragging = nil
		self:SetScript("OnUpdate", nil)
	end)

	b:SetScript("OnClick", function()
		ns.Toggle()
	end)

	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine("Zereth Mortis Mounts", 1, 0.82, 0)
		local collected, total, ready = ns.Summary()
		GameTooltip:AddLine(("Learned %d/%d  •  craftable now: %d"):format(collected, total, ready), 1, 1, 1)
		GameTooltip:AddLine(("Genesis Motes: %s"):format(Comma(ns.CountOf(ns.MOTE_ITEM))), 0.8, 0.8, 0.9)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Click to open  •  drag to move", 0.6, 0.6, 0.6)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", GameTooltip_Hide)

	Reposition()
end
