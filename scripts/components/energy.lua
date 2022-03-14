local function onmax(self, max)
	self.inst.energy_max:set(max)
end

local function oncurrent(self, current)
	self.inst.energy_current:set(current)
end

local Energy = Class(function(self, inst)
	self.inst = inst

	self.recharge = 1
	self.external_recharge = 0

	self.max = 100
	self.current = self.max
end,
nil,
{
	max = onmax,
	current = oncurrent,
})

function Energy:SetMax(amount)
	self.max = amount
	self.current = amount
end

function Energy:Recharge(amount)
	self.recharge = amount
end

function Energy:GetPercent()
	return self.current / self.max
end

function Energy:SetPercent(per)
	local target = per * self.max
	local delta = target - self.current
	self:DoDelta(delta)
end

function Energy:DoDelta(delta)
	local val = self.current + delta
	if val >= self.max then
		self.current = self.max
	elseif val <= 0 then
		self.current = 0
	else
		self.current = val
	end
end

function Energy:Gain(amount)
	local val = self.current + (amount * (self.recharge + self.external_recharge))
	if val >= self.max then
		self.current = self.max
	elseif val <= 0 then
		self.current = 0
	else
		self.current = val
	end
end

function Energy:OnSave()
	return
	{
		current = self.current,
		max = self.max,
	}
end

function Energy:OnLoad(data)
	self.current = data.current
	self.max = data.max
end

return Energy