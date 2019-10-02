local name, addon = ...
local broker = addon:NewModule('DataBroker')

-- Localise global variables
local _G = _G
local TRACKING, MINIMAP_TRACKING_NONE = _G.TRACKING, _G.MINIMAP_TRACKING_NONE

function broker:OnInitialize()
	self.type = 'data source'
	self:SetValue(TRACKING, 132328)

	LibStub('LibDataBroker-1.1'):NewDataObject(name, self)
end

function broker:OnEnable()
	addon:Subscribe('TRACKING_CHANGED', self, 'OnTrackingChanged')
	addon:TriggerTrackingChanged()
end

function broker:OnDisable()
	addon:Unsubscribe('TRACKING_CHANGED', self, 'OnTrackingChanged')
end

function broker:OnTrackingChanged()
	local id, name, icon = addon:GetTracking()

	if not name then
		name = TRACKING .. ': ' .. MINIMAP_TRACKING_NONE
	end

	if not icon then
		icon = 132328
	end

	self:SetValue(name, icon)
end

function broker:SetValue(value, icon)
	self.text = value
	self.value = value
	self.icon = icon
end

function broker.OnEnter(frame)
	if broker.enabledState then
		addon:Publish('MOUSE_ENTER', frame)
	end
end

function broker.OnLeave(frame)
	if broker.enabledState then
		addon:Publish('MOUSE_LEAVE', frame)
	end
end

function broker.OnClick(frame, ...)
	if broker.enabledState then
		addon:Publish('MOUSE_CLICK', frame, ...)
	end
end
