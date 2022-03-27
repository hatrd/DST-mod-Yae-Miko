local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local yaemiko_energy = Class(Widget, function(self, owner)
	Widget._ctor(self, "yaemiko_energy")
	self.owner = owner

	self:SetHAnchor(2)
	self:SetVAnchor(2)
	self:SetPosition(-180, 150, 0)
	self:SetScale(0.3, 0.3, 0.3)

	self.num = self:AddChild(Text(BODYTEXTFONT, 80))
	self.num:SetHAlign(ANCHOR_MIDDLE)
	self.num:MoveToFront()

	self.num.current = owner.energy_current:value()
	self.num.max = owner.energy_max:value()
	self.percent = self.num.current / self.num.max

	self.anim = self:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("energy")
	self.anim:GetAnimState():SetBuild("yaemiko_energy")
	self.anim:GetAnimState():SetPercent("anim", self.percent)

	self.skillcd = self:AddChild(Text(BODYTEXTFONT, 80))
	self.skillcd:SetHAlign(ANCHOR_MIDDLE)
	self.skillcd:MoveToFront()

	self:StartUpdating()

	owner:ListenForEvent("energy_maxdirty", function(owner, data)
		self.num.max = owner.energy_max:value()
		self.percent = self.num.current / self.num.max
	end)

	owner:ListenForEvent("energy_currentdirty", function(owner, data)
		self.num.current = owner.energy_current:value()
		self.percent = self.num.current / self.num.max
	end)
end)

function yaemiko_energy:OnUpdate(dt)
	--self.num:SetString(self.num.current)
	self.anim:GetAnimState():SetPercent("anim", self.percent)
	-- self.skillcd:SetString(self.owner._yaemiko_q:value())

	-- if self.owner:HasTag("yaemiko_q") then
	-- 	self.skillcd:Show()
	-- else
	-- 	self.skillcd:Hide()
	-- end

	if self.owner:HasTag("playerghost") then
		self.anim:Hide()
		self.num:Hide()
		-- self.skillcd:Hide()
	else
		self.anim:Show()
		self.num:Show()
	end
end

return yaemiko_energy