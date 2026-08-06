-- Zereth Mortis Mounts :: window + minimap button
-- Flat skin: dark panels, 1px borders, gold accent -- the ElvUI-adjacent look,
-- built from scratch (WHITE8x8 backdrops + custom flat buttons).

local ADDON, ns = ...

local WIDTH, HEIGHT = 880, 560
local LIST_WIDTH = 330
local ROW_HEIGHT = 26

local GREEN = { 0.35, 0.95, 0.45 }
local RED = { 1.00, 0.40, 0.40 }
local GOLD = { 0.98, 0.80, 0.28 }

-- flat-skin palette
local WHITE8 = "Interface\\Buttons\\WHITE8x8"
local C_BG      = { 0.070, 0.075, 0.095, 0.97 } -- window
local C_PANEL   = { 0.055, 0.060, 0.078, 1 }    -- inset boxes
local C_BTN     = { 0.120, 0.125, 0.155, 1 }    -- button fill
local C_BORDER  = { 0.22, 0.24, 0.30, 1 }
local C_TEXT    = { 0.92, 0.93, 0.96 }
local C_MUTED   = { 0.60, 0.62, 0.68 }

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
	f:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1 })
	f:SetBackdropColor(unpack(name and C_BG or C_PANEL))
	f:SetBackdropBorderColor(unpack(C_BORDER))
	return f
end

-- Flat replacement for UIPanelButtonTemplate. Exposes the same surface the
-- rest of this file already uses: SetText, SetEnabled, LockHighlight /
-- UnlockHighlight (as a selected state), plus a native highlight on hover so
-- tooltip OnEnter scripts do not fight the skin.
local function FlatButton(parent, width, height)
	local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
	b:SetSize(width or 52, height or 20)
	b:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1 })

	b.label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	b.label:SetPoint("CENTER", 0, 0)

	local hl = b:CreateTexture(nil, "HIGHLIGHT")
	hl:SetTexture(WHITE8)
	hl:SetVertexColor(1, 1, 1, 0.07)
	hl:SetAllPoints()

	function b:Paint()
		if self.selected then
			self:SetBackdropColor(GOLD[1] * 0.24, GOLD[2] * 0.24, GOLD[3] * 0.24, 1)
			self:SetBackdropBorderColor(GOLD[1], GOLD[2], GOLD[3], 0.9)
			self.label:SetTextColor(unpack(GOLD))
		else
			self:SetBackdropColor(unpack(C_BTN))
			self:SetBackdropBorderColor(unpack(C_BORDER))
			self.label:SetTextColor(unpack(self:IsEnabled() and C_TEXT or C_MUTED))
		end
		self.label:SetAlpha(self:IsEnabled() and 1 or 0.45)
	end

	function b:SetText(text) self.label:SetText(text) self:Paint() end
	function b:GetText() return self.label:GetText() end
	function b:LockHighlight() self.selected = true self:Paint() end
	function b:UnlockHighlight() self.selected = nil self:Paint() end
	b:SetScript("OnEnable", b.Paint)
	b:SetScript("OnDisable", b.Paint)
	-- pressed feedback: nudge the label like a real button
	b:SetScript("OnMouseDown", function(self)
		if self:IsEnabled() then
			self.label:SetPoint("CENTER", 1, -1)
		end
	end)
	b:SetScript("OnMouseUp", function(self)
		self.label:SetPoint("CENTER", 0, 0)
	end)

	b:Paint()
	return b
end

-- Flattens a UIPanelScrollFrameTemplate scrollbar: no arrow art, thin thumb.
local function SkinScrollBar(scroll)
	local name = scroll:GetName()
	local bar = name and _G[name .. "ScrollBar"]
	if not bar then return end
	for _, suffix in ipairs({ "ScrollUpButton", "ScrollDownButton" }) do
		local btn = _G[name .. "ScrollBar" .. suffix]
		if btn then
			btn:SetAlpha(0)
			btn:SetSize(10, 1)
		end
	end
	local thumb = _G[name .. "ScrollBarThumbTexture"]
	if thumb then
		thumb:SetTexture(WHITE8)
		thumb:SetVertexColor(1, 1, 1, 0.16)
		thumb:SetSize(4, 40)
	end
end

-- Flat X close button. A plain letter: the Unicode multiplication cross has no glyph in WoW's default fonts and renders blank.
local function FlatClose(parent, onClick)
	local close = CreateFrame("Button", nil, parent)
	close:SetSize(26, 26)
	close.x = close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	close.x:SetPoint("CENTER")
	close.x:SetText("X")
	close.x:SetTextColor(unpack(C_MUTED))
	close:SetScript("OnEnter", function(self) self.x:SetTextColor(0.95, 0.45, 0.40) end)
	close:SetScript("OnLeave", function(self) self.x:SetTextColor(unpack(C_MUTED)) end)
	close:SetScript("OnClick", onClick)
	return close
end

local function MakePinButton(parent)
	local b = FlatButton(parent, 52, 20)
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
	row.bg:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.10)
	row.bg:Hide()

	-- gold accent bar on the selected row, ElvUI-style
	row.accent = row:CreateTexture(nil, "BACKGROUND", nil, 1)
	row.accent:SetColorTexture(unpack(GOLD))
	row.accent:SetSize(2, ROW_HEIGHT - 6)
	row.accent:SetPoint("LEFT", 0, 0)
	row.accent:Hide()

	row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
	row.highlight:SetAllPoints()
	row.highlight:SetColorTexture(1, 1, 1, 0.05)

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

	-- Adventure Guide shortcut, shown only for raid-boss reagents
	b.boss = FlatButton(b, 52, 20)
	b.boss:SetText("Boss")
	b.boss:SetPoint("TOPRIGHT", b.pin, "TOPLEFT", -4, 0)
	b.boss:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Open the Adventure Guide", 1, 1, 1)
		if self.journal and self.journal.boss then
			GameTooltip:AddLine(self.journal.boss, 0.7, 0.8, 1)
		end
		GameTooltip:Show()
	end)
	b.boss:SetScript("OnLeave", GameTooltip_Hide)
	b.boss:SetScript("OnClick", function(self)
		ns.OpenBossJournal(self.journal)
	end)

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

	local close = FlatClose(f, function() f:Hide() end)
	close:SetPoint("TOPRIGHT", -6, -6)

	f.summary = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.summary:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 1, -6)
	f.summary:SetJustifyH("LEFT")

	-- tabs
	f.tabButtons = {}
	local tabSpecs = {
		{ key = "mounts", text = "Mounts" },
		{ key = "schematics", text = "Schematics" },
		{ key = "unlock", text = "Unlock chain" },
		{ key = "tips", text = "Tips" },
	}
	local prevTab
	for i = #tabSpecs, 1, -1 do -- lay out right-to-left so the row hugs the corner
		local spec = tabSpecs[i]
		local b = FlatButton(f, spec.key == "tips" and 60 or 104, 22)
		b:SetText(spec.text)
		if prevTab then
			b:SetPoint("RIGHT", prevTab, "LEFT", -4, 0)
		else
			b:SetPoint("TOPRIGHT", f, "TOPRIGHT", -34, -14)
		end
		b:SetScript("OnClick", function()
			ZerethMortisMountsDB.tab = spec.key
			ns.Refresh()
		end)
		b.key = spec.key
		table.insert(f.tabButtons, b)
		prevTab = b
	end

	-- filters
	local filters = {
		{ key = "all", text = "All" },
		{ key = "missing", text = "Not learned" },
		{ key = "ready", text = "Craftable now" },
	}
	f.filterButtons = {}
	local prev
	for _, spec in ipairs(filters) do
		local b = FlatButton(f, 96, 20)
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

	-- always-visible forge pin: the one place everything is crafted
	local forge = FlatButton(f, 232, 22)
	forge:SetPoint("TOPRIGHT", f.tabButtons[1], "BOTTOMRIGHT", 0, -6)
	forge:SetText(("Pin the forge  (%.1f, %.1f)"):format(ns.FORGE.x, ns.FORGE.y))
	forge:SetScript("OnClick", function()
		ns.Pin(ns.FORGE.x, ns.FORGE.y, ns.FORGE.name)
	end)
	forge:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(ns.FORGE.name, 1, 0.82, 0)
		GameTooltip:AddLine(ns.FORGE.note, 1, 1, 1, true)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Every mount is crafted here, and every schematic is handed in here.", 0.7, 0.8, 1, true)
		GameTooltip:AddLine("Click to drop a waypoint and start tracking it.", 0.6, 0.6, 0.6, true)
		GameTooltip:Show()
	end)
	forge:SetScript("OnLeave", GameTooltip_Hide)
	f.forgeButton = forge

	-- list
	local listBox = MakeBackdropFrame(f)
	f.listBox = listBox
	listBox:SetPoint("TOPLEFT", 12, -102)
	listBox:SetSize(LIST_WIDTH, HEIGHT - 118)
	listBox:SetBackdropColor(0, 0, 0, 0.35)

	local scroll = CreateFrame("ScrollFrame", "ZerethMortisMountsList", listBox, "UIPanelScrollFrameTemplate")
	SkinScrollBar(scroll)
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
	f.detailBox = detailBox
	detailBox:SetPoint("TOPLEFT", listBox, "TOPRIGHT", 10, 0)
	detailBox:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 16)
	detailBox:SetBackdropColor(0, 0, 0, 0.35)

	local dScroll = CreateFrame("ScrollFrame", "ZerethMortisMountsDetail", detailBox, "UIPanelScrollFrameTemplate")
	SkinScrollBar(dScroll)
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
	d.schematicHeader:SetText("|cffffd100Schematic|r  |cff808080(hand in at the forge to get the recipe)|r")

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

	ns.BuildUnlockPanel(f)
	ns.BuildTipsPanel(f)
	ns.BuildSchematicsPanel(f)
	ns.RegisterRefresh(ns.UpdateWindow)
end

--------------------------------------------------------------------------------
-- schematics tab -- where every recipe comes from, and whether you own it
--------------------------------------------------------------------------------

function ns.BuildSchematicsPanel(f)
	local box = MakeBackdropFrame(f)
	box:SetPoint("TOPLEFT", 12, -102)
	box:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 16)
	box:SetBackdropColor(0, 0, 0, 0.35)
	box:Hide()
	f.schematicsBox = box

	local scroll = CreateFrame("ScrollFrame", "ZerethMortisMountsSchematics", box, "UIPanelScrollFrameTemplate")
	SkinScrollBar(scroll)
	scroll:SetPoint("TOPLEFT", 10, -10)
	scroll:SetPoint("BOTTOMRIGHT", -28, 10)

	local child = CreateFrame("Frame", nil, scroll)
	local cWidth = WIDTH - 66
	child:SetSize(cWidth, 10)
	scroll:SetScrollChild(child)
	box.child = child
	box.width = cWidth

	box.legend = child:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	box.legend:SetPoint("TOPLEFT", 4, -2)
	box.legend:SetWidth(cWidth - 8)
	box.legend:SetJustifyH("LEFT")

	-- one header per source bucket, one row per mount
	box.groups = {}
	for _, group in ipairs(ns.SchematicGroups()) do
		local g = { rows = {} }

		g.header = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		g.header:SetJustifyH("LEFT")
		g.header:SetWidth(cWidth - 8)
		g.header:SetText("|cffffd100" .. group.spec.label .. "|r")

		g.hint = child:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		g.hint:SetJustifyH("LEFT")
		g.hint:SetWidth(cWidth - 90)
		g.hint:SetText(group.spec.hint)

		for _, mount in ipairs(group.mounts) do
			local row = CreateFrame("Frame", nil, child)
			row:SetWidth(cWidth)
			row.mount = mount

			row.status = row:CreateTexture(nil, "ARTWORK")
			row.status:SetSize(15, 15)
			row.status:SetPoint("TOPLEFT", 16, -2)

			row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			row.name:SetPoint("TOPLEFT", row.status, "TOPRIGHT", 7, 1)
			row.name:SetJustifyH("LEFT")
			row.name:SetWidth(232)
			row.name:SetWordWrap(false)
			row.name:SetText(mount.name)

			row.how = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			row.how:SetPoint("TOPLEFT", row.name, "TOPRIGHT", 8, 0)
			row.how:SetPoint("RIGHT", row, "RIGHT", -140, 0)
			row.how:SetJustifyH("LEFT")
			row.how:SetTextColor(0.72, 0.72, 0.78)
			row.how:SetText(mount.schematic.how)

			row.state = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			row.state:SetPoint("TOPRIGHT", row, "TOPRIGHT", -70, -2)
			row.state:SetJustifyH("RIGHT")

			row.pin = MakePinButton(row)
			row.pin:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, 0)
			SetPin(row.pin, mount.schematic.x, mount.schematic.y, "Schematic: " .. mount.name)

			table.insert(g.rows, row)
		end
		table.insert(box.groups, g)
	end
end

function ns.UpdateSchematicsPanel()
	local box = ns.window.schematicsBox
	local _, total, _, _, recipes = ns.Summary()
	box.legend:SetText(("You own |cffffd100%d|r of |cffffd100%d|r recipes. A schematic only becomes a recipe once you hand it in at the Servitor Interface in the Protoform Repository -- \"recipe\" below means that hand-in is done."):format(recipes, total))

	local anchor, anchorPoint = box.legend, "BOTTOMLEFT"
	local y = -14
	local totalH = box.legend:GetStringHeight() + 18

	for _, g in ipairs(box.groups) do
		g.header:ClearAllPoints()
		g.header:SetPoint("TOPLEFT", anchor, anchorPoint, 0, y)
		g.hint:ClearAllPoints()
		g.hint:SetPoint("TOPLEFT", g.header, "BOTTOMLEFT", 0, -2)
		totalH = totalH + 16 + g.hint:GetStringHeight() + 8
		anchor, anchorPoint, y = g.hint, "BOTTOMLEFT", -6

		for _, row in ipairs(g.rows) do
			local has = ns.HasRecipe(row.mount)
			local collected = ns.IsCollected(row.mount.spellID)
			row.status:SetTexture(has and ICON_READY or ICON_NOT)
			row.name:SetTextColor(unpack(has and GREEN or { 1, 1, 1 }))
			if collected then
				row.state:SetText("|cff55ee66mount collected|r")
			elseif has then
				row.state:SetText("|cff9fd8ffrecipe owned|r")
			else
				row.state:SetText("|cffff8888recipe missing|r")
			end

			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", anchor, anchorPoint, 0, y)
			local h = math.max(20, row.how:GetStringHeight() + 6)
			row:SetHeight(h)
			totalH = totalH + h + 3
			anchor, anchorPoint, y = row, "BOTTOMLEFT", -3
		end
		y = -16
		totalH = totalH + 16
	end

	-- group headers/hints are children of `child`, rows too; anchoring chains
	-- through them, so the last anchor determines the content height
	box.child:SetHeight(totalH + 14)
end

--------------------------------------------------------------------------------
-- tips tab
--------------------------------------------------------------------------------

function ns.BuildTipsPanel(f)
	local box = MakeBackdropFrame(f)
	box:SetPoint("TOPLEFT", 12, -102)
	box:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 16)
	box:SetBackdropColor(0, 0, 0, 0.35)
	box:Hide()
	f.tipsBox = box

	local scroll = CreateFrame("ScrollFrame", "ZerethMortisMountsTips", box, "UIPanelScrollFrameTemplate")
	SkinScrollBar(scroll)
	scroll:SetPoint("TOPLEFT", 10, -10)
	scroll:SetPoint("BOTTOMRIGHT", -28, 10)

	local child = CreateFrame("Frame", nil, scroll)
	local cWidth = WIDTH - 66
	child:SetSize(cWidth, 10)
	scroll:SetScrollChild(child)
	box.child = child

	box.rows = {}
	for i, tip in ipairs(ns.tips) do
		local row = CreateFrame("Frame", nil, child)
		row:SetWidth(cWidth)

		row.bullet = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		row.bullet:SetPoint("TOPLEFT", 4, -1)
		row.bullet:SetText("|cffffd100" .. i .. "|r")
		row.bullet:SetWidth(26)
		row.bullet:SetJustifyH("RIGHT")

		row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.title:SetPoint("TOPLEFT", row.bullet, "TOPRIGHT", 10, -2)
		row.title:SetJustifyH("LEFT")
		row.title:SetWidth(cWidth - 130)
		row.title:SetText(tip.title)
		row.title:SetTextColor(unpack(GOLD))

		row.pin = MakePinButton(row)
		row.pin:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, 0)
		SetPin(row.pin, tip.x, tip.y, tip.pinLabel or tip.title)

		row.body = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.body:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -4)
		row.body:SetWidth(cWidth - 120)
		row.body:SetJustifyH("LEFT")
		row.body:SetTextColor(0.78, 0.78, 0.84)
		row.body:SetText(tip.body)

		box.rows[i] = row
	end

	-- lay out once; nothing here depends on player state
	local anchor, total = nil, 8
	for i, row in ipairs(box.rows) do
		row:ClearAllPoints()
		if anchor then
			row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -14)
		else
			row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -6)
		end
		local h = 20 + row.body:GetStringHeight() + 6
		row:SetHeight(h)
		total = total + h + 14
		anchor = row
	end
	child:SetHeight(total + 10)
end

--------------------------------------------------------------------------------
-- unlock-chain tab
--------------------------------------------------------------------------------

local STATE_STYLE = {
	done   = { icon = ICON_READY,                                  color = { 0.55, 0.8, 0.55 } },
	active = { icon = "Interface\\RaidFrame\\ReadyCheck-Waiting",  color = { 1, 0.85, 0.3 } },
	next   = { atlas = "QuestNormal", color = { 1, 1, 1 } },
	locked = { icon = nil,                                          color = { 0.45, 0.45, 0.5 } },
	note   = { atlas = "QuestTurnin",                               color = { 0.85, 0.75, 1.00 } },
}

local STATE_TEXT = {
	done = "|cff55ee66done|r",
	active = "|cffffd100in progress -- you are here|r",
	next = "|cffffffffnext step|r",
	locked = "|cff777777locked|r",
	note = "|cffb9a4ffper mount|r",
}

function ns.BuildUnlockPanel(f)
	local box = MakeBackdropFrame(f)
	box:SetPoint("TOPLEFT", 12, -102)
	box:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 16)
	box:SetBackdropColor(0, 0, 0, 0.35)
	box:Hide()
	f.unlockBox = box

	local scroll = CreateFrame("ScrollFrame", "ZerethMortisMountsUnlock", box, "UIPanelScrollFrameTemplate")
	SkinScrollBar(scroll)
	scroll:SetPoint("TOPLEFT", 10, -10)
	scroll:SetPoint("BOTTOMRIGHT", -28, 10)

	local child = CreateFrame("Frame", nil, scroll)
	local cWidth = WIDTH - 66
	child:SetSize(cWidth, 10)
	scroll:SetScrollChild(child)
	box.child = child

	box.header = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	box.header:SetPoint("TOPLEFT", 4, -2)
	box.header:SetWidth(cWidth - 8)
	box.header:SetJustifyH("LEFT")

	box.steps = {}
	local questNo = 0
	for i, step in ipairs(ns.unlockChain) do
		local row = CreateFrame("Frame", nil, child)
		row:SetWidth(cWidth)

		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetSize(18, 18)
		row.icon:SetPoint("TOPLEFT", 4, -2)

		row.num = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
		row.num:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -2)
		if step.type == "quest" then
			questNo = questNo + 1
			row.num:SetText(questNo .. ".")
		end

		row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 30, -1)
		row.title:SetJustifyH("LEFT")
		row.title:SetText(step.title)

		row.state = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.state:SetPoint("TOPRIGHT", row, "TOPRIGHT", -70, -3)

		row.pin = MakePinButton(row)
		row.pin:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, 0)
		SetPin(row.pin, step.x, step.y, step.pinLabel or step.title)

		row.note = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.note:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -3)
		row.note:SetWidth(cWidth - 140)
		row.note:SetJustifyH("LEFT")
		row.note:SetTextColor(0.68, 0.68, 0.74)
		row.note:SetText(step.note)

		box.steps[i] = row
	end
end

local function FormatRemaining(seconds)
	local d = math.floor(seconds / 86400)
	local h = math.floor((seconds % 86400) / 3600)
	if d > 0 then return ("%dd %dh"):format(d, h) end
	local m = math.floor((seconds % 3600) / 60)
	if h > 0 then return ("%dh %dm"):format(h, m) end
	return ("%dm"):format(math.max(1, m))
end

function ns.UpdateUnlockPanel()
	local f = ns.window
	local box = f.unlockBox
	local states, unlocked, extras = ns.UnlockStates()

	if unlocked then
		box.header:SetText("|cff55ee66Mount crafting is UNLOCKED on this character.|r The Protoform Repository (68.5, 30.1) is open and every schematic below can drop for you.")
	else
		box.header:SetText("|cffff6666Mount crafting is NOT unlocked yet on this character.|r Work through the chain below. Everything starts at the Cypher Research Console in Exile's Hollow; quest progress is read live from your quest log.")
	end

	local anchor = box.header
	local total = box.header:GetStringHeight() + 16
	for i, row in ipairs(box.steps) do
		local state = states[i]
		local style = STATE_STYLE[state]

		if style.atlas and row.icon.SetAtlas then
			row.icon:SetAtlas(style.atlas)
			row.icon:Show()
		elseif style.icon then
			row.icon:SetTexture(style.icon)
			row.icon:Show()
		else
			row.icon:Hide()
		end
		row.title:SetTextColor(unpack(style.color))
		if state == "active" and extras and extras[i] then
			row.state:SetText(("|cffffd100researching -- %s left|r"):format(FormatRemaining(extras[i])))
		else
			row.state:SetText(STATE_TEXT[state])
		end

		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -14 or -10)
		local h = 18 + row.note:GetStringHeight() + 8
		row:SetHeight(h)
		total = total + h + 10
		anchor = row
	end
	box.child:SetHeight(total + 10)
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
	d.sub:SetText(("%s  ·  %s  ·  %s  ·  %s"):format(
		mount.family,
		mount.flying and "Flying" or "Ground",
		collected and "|cff55ee66Already learned|r" or "|cffff6666Not learned|r",
		ns.HasRecipe(mount) and "|cff9fd8ffrecipe owned|r" or "|cffaa8888no recipe|r"))

	local s = mount.schematic
	local recipeLine = ns.HasRecipe(mount)
		and "|cff55ee66You already own this recipe|r -- the schematic is handed in, it is in the forge."
		or "|cffff8888Recipe not in your forge yet.|r Get the schematic, then hand it in at the Servitor Interface."
	d.schematicText:SetText(recipeLine .. "\n" .. s.how)
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
		b.boss.journal = info.journal
		b.boss:SetShown(info.journal ~= nil)
		-- the count must not sit under the Boss button when it is visible
		b.have:ClearAllPoints()
		b.have:SetPoint("TOPRIGHT", info.journal and -114 or -58, -3)
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

	-- tab switching
	local tab = ZerethMortisMountsDB.tab or "mounts"
	for _, b in ipairs(f.tabButtons) do
		if b.key == tab then b:LockHighlight() else b:UnlockHighlight() end
	end
	local mountsTab = (tab == "mounts")
	f.listBox:SetShown(mountsTab)
	f.detailBox:SetShown(mountsTab)
	for _, b in ipairs(f.filterButtons) do b:SetShown(mountsTab) end
	f.unlockBox:SetShown(tab == "unlock")
	f.tipsBox:SetShown(tab == "tips")
	f.schematicsBox:SetShown(tab == "schematics")
	if not mountsTab then
		local collected, total, _, _, recipes = ns.Summary()
		if tab == "tips" then
			f.summary:SetText(("Learned |cffffd100%d|r of |cffffd100%d|r   ·   ways to get there faster"):format(collected, total))
		elseif tab == "schematics" then
			f.summary:SetText(("Recipes owned |cffffd100%d|r of |cffffd100%d|r   ·   mounts learned |cffffd100%d|r"):format(recipes, total, collected))
			ns.UpdateSchematicsPanel()
		else
			f.summary:SetText(("Learned |cffffd100%d|r of |cffffd100%d|r"):format(collected, total))
			ns.UpdateUnlockPanel()
		end
		return
	end

	local collected, total, ready, motesNeeded = ns.Summary()
	local motes = ns.CountOf(ns.MOTE_ITEM)
	f.summary:SetText(("Learned |cffffd100%d|r of |cffffd100%d|r   ·   craftable right now: |cff55ee66%d|r   ·   Genesis Motes: |cffffd100%s|r (|cffff8888%s|r still needed for the rest)")
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
			row.accent:SetShown(mount == selectedMount)
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
		GameTooltip:AddLine(("Learned %d/%d  ·  craftable now: %d"):format(collected, total, ready), 1, 1, 1)
		GameTooltip:AddLine(("Genesis Motes: %s"):format(Comma(ns.CountOf(ns.MOTE_ITEM))), 0.8, 0.8, 0.9)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Click to open  ·  drag to move", 0.6, 0.6, 0.6)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", GameTooltip_Hide)

	Reposition()
end
