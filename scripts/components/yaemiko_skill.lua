--技能的代码实现
local yaemiko_skill = Class(function(self, inst)
	self.inst = inst
	self.attacker = inst

	self.dmg = 30
	self.mult = 1
	self.bonus = 0

	self.engenr = false
	self.jden = false
	self.sanity = false
	self.spark = false
	self.burn = false

end)

function yaemiko_skill:GetDamage()
	if self.attacker.components.combat then
		if self.attacker.components.combat.damagemultiplier ~= nil then
			self.mult = self.attacker.components.combat.damagemultiplier
		end
		if self.attacker.components.combat.damagebonus then
			self.bonus = self.attacker.components.combat.damagebonus
		end
	end
	return self.dmg * self.mult + self.bonus
end

local CANT_TAGS = {"INLIMBO", "player", "chester", "companion"}



function yaemiko_skill:luolei()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 12, nil, CANT_TAGS)
	local damage = self:GetDamage()

	-- if not target then
	-- 	-- SpawnPrefab("thunder").Transform:SetPosition(x+math.random(-5, 5), y, z+math.random(-5, 5))
	-- 	return
	-- end

	for i, v in pairs(ents) do
		if v ~= self.inst and v:IsValid() and not v:IsInLimbo() then
			if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
				v:AddTag("yaemikotarget")
				v:DoTaskInTime(0.1, function() v:RemoveTag("yaemikotarget") end)
			end
		end
	end

	local tgt = GetRandomInstWithTag("yaemikotarget", self.inst, 12)
	if tgt == nil then
		-- SpawnPrefab("thunder").Transform:SetPosition(x+math.random(-5, 5), y, z+math.random(-5, 5))
    return
	else
		-- SpawnPrefab("thunder").Transform:SetPosition(tgt.Transform:GetWorldPosition())
		-- self.attacker:AddTag("noenergy")
		tgt.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
		-- self.attacker:RemoveTag("noenergy")

		if tgt.components.sleeper and tgt.components.sleeper:IsAsleep() then
			tgt.components.sleeper:WakeUp()
		end
		if tgt.components.burnable then
			if tgt.components.burnable:IsBurning() then
        --添加超载爆炸

				tgt.components.burnable:Extinguish()
			end
		end
	end
end



return yaemiko_skill