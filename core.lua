local name, addon = ...
LibStub('AceAddon-3.0'):NewAddon(addon, name, 'AceEvent-3.0', 'LibPubSub-1.0')

-- Localise global variables
local _G = _G
local GetNumSpellTabs, GetSpellCooldown, UnitIsDeadOrGhost = _G.GetNumSpellTabs, _G.GetSpellCooldown, _G.UnitIsDeadOrGhost
local ToggleFrame, ToggleWorldMap, WorldMapFrame = _G.ToggleFrame, _G.ToggleWorldMap, _G.WorldMapFrame
local After, NewTimer, GetTime = _G.C_Timer.After, _G.C_Timer.NewTimer, _G.GetTime

function addon:OnInitialize()
	self.spells = {}
	self.tracking = nil
	self.timer = nil

	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateSpells')
	self:RegisterEvent('SKILL_LINES_CHANGED', 'UpdateSpells')
	self:RegisterEvent('UNIT_AURA', 'OnUnitAura')
	self:RegisterEvent('PLAYER_ALIVE', 'OnPlayerResurrect')
	self:RegisterEvent('PLAYER_UNGHOST', 'OnPlayerResurrect')
end

function addon:OnEnable()
	addon:Subscribe('MOUSE_CLICK', self, 'OnClick')
	self:UpdateSpells()
end

function addon:OnDisable()
	addon:Unsubscribe('MOUSE_CLICK', self, 'OnClick')
end

function addon:OnClick(frame, button)
	if button == 'RightButton' then
		if ToggleWorldMap then
			ToggleWorldMap()
		else
			ToggleFrame(WorldMapFrame)
		end
	end
end

function addon:OnUnitAura(event, unit)
	if unit == 'player' then
		self:CheckTracking()
	end
end

function addon:OnPlayerResurrect()
	if self.tracking and not UnitIsDeadOrGhost('player') then
		local tracking = self.tracking
		self.tracking = nil
		self:SetTracking(tracking)
	end
end

function addon:CheckTracking()
	local tracking = self:GetTracking()
	if tracking == nil then
		-- Wait a second in case we're (supposed to be) dead, event order is unpredictable
		After(1, function()
			local tracking = self:GetTracking()
			if self.tracking ~= tracking then
				self:TriggerTrackingChanged()
			end
		end)
	elseif self.tracking ~= tracking then
		self:TriggerTrackingChanged()
	end
end

function addon:TriggerTrackingChanged()
	if not UnitIsDeadOrGhost('player') then
		self.tracking = self:GetTracking()
	end
	self:Publish('TRACKING_CHANGED')
end

function addon:UpdateSpells()
	local spells = {
		1494, -- Track Beasts (Hunter)
		2383, -- Find Herbs
		2481, -- Find Treasure (Dwarf)
		2580, -- Find Minerals
		5225, -- Track Humanoids (Druid)
		5500, -- Sense Demons (Warlock)
		5502, -- Sense Undead (Paladin)
		19878, -- Track Demons (Hunter)
		19879, -- Track Dragonkin (Hunter)
		19880, -- Track Elementals (Hunter)
		19882, -- Track Giants (Hunter)
		19883, -- Track Humanoids (Hunter)
		19884, -- Track Undead (Hunter)
		19885, -- Track Hidden (Hunter)
	}

	self.spells = {}

	local _, offset, spellCount, name, icon, id

	local tabs = GetNumSpellTabs()
	for tab = 1, tabs do
		_, _, offset, spellCount = GetSpellTabInfo(tab)
		for index = 1, spellCount do
			_, id = GetSpellBookItemInfo(offset + index, 'spell')
			for i = 1, #spells do
				if id == spells[i] then
					name, _, icon = GetSpellInfo(id)
					table.insert(self.spells, {id, name, icon})
					break
				end
			end
		end
	end

	self:CheckTracking()
end

function addon:GetSpells()
	return self.spells
end

function addon:GetTracking()
	local icon = GetTrackingTexture()
	local id, name

	for i = 1, #self.spells do
		if self.spells[i][3] == icon then
			id, name = unpack(self.spells[i])
			break
		end
	end

	return id, name, icon
end

function addon:SetTracking(id)
	if self.timer then
		self.timer:Cancel()
		self.timer = nil
	end

	if not id or id == 0 then
		CancelTrackingBuff()
	elseif id ~= self:GetTracking() then
		local cooldownStart, cooldownDuration = GetSpellCooldown(id)
		if cooldownStart > 0 and cooldownDuration > 0 then
			self.timer = NewTimer(0.01 + cooldownStart + cooldownDuration - GetTime(), function() self:SetTracking(id) end)
		else
			CastSpellByID(id)
		end
	end
end
