local name, addon = ...
local tooltip = addon:NewModule('Tooltip')

-- Localise global variables
local _G = _G
local MINIMAP_TRACKING_NONE = _G.MINIMAP_TRACKING_NONE

local LibQTip = LibStub('LibQTip-1.0')

function tooltip:OnEnable()
	addon:Subscribe('MOUSE_ENTER', self, 'Show')
	addon:Subscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Subscribe('TRACKING_CHANGED', self, 'OnTrackingChanged')
end

function tooltip:OnDisable()
	self:Hide()
	addon:Unsubscribe('MOUSE_ENTER', self, 'Show')
	addon:Unsubscribe('MOUSE_CLICK', self, 'OnClick')
	addon:Unsubscribe('TRACKING_CHANGED', self, 'OnTrackingChanged')
end

function tooltip:OnClick(frame, button)
	if button == 'LeftButton' then
		self:Show(frame)
	end
end

function tooltip:OnTrackingChanged()
	self:Hide()
end

function tooltip:Show(anchor)
	self:Hide()

	if self.enabledState then
		self.tip = LibQTip:Acquire(name .. 'Tooltip', 3, 'LEFT', 'LEFT')
		self.tip:Clear()

		self:Populate()

		self.tip.OnRelease = function() self.tip = nil end
		self.tip:SetAutoHideDelay(0.1, anchor)
		self.tip:SmartAnchorTo(anchor)
		self.tip:Show()
	end
end

function tooltip:Hide()
	if self.tip then
		LibQTip:Release(self.tip)
	end
end

function tooltip:Populate()
	local tracking = addon:GetTracking()
	local spells = addon:GetSpells()

	self:AddLine(0, nil, MINIMAP_TRACKING_NONE, not tracking)

	local id, name, icon
	for i = 1, #spells do
		id, name, icon = unpack(spells[i])
		self:AddLine(id, icon, name, id == tracking)
	end
end

function tooltip:AddLine(id, icon, name, active)
	local line = self.tip:AddLine()
	local radio = '|T:0|t'

	if active then
		radio = '|TInterface\\Buttons\\UI-RadioButton:8:8:0:0:64:16:19:28:3:12|t'
	end

	self.tip:SetCell(line, 1, radio)
	if icon then
		self.tip:SetCell(line, 2, '|T' .. icon .. ':14|t')
	end
	self.tip:SetCell(line, 3, name)
	self.tip:SetLineScript(line, 'OnMouseUp', self:GetLineScript(id))
	return line
end

function tooltip:GetLineScript(id)
	return function()
		addon:SetTracking(id)
		self:Hide()
	end
end
