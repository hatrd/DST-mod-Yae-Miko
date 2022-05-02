
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
  self.ecnt = 3
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



function yaemiko_skill:chaozai(tgt,damage)
  local x,y,z=tgt.Transform:GetWorldPosition()
  --爆炸特效
  local inst=SpawnPrefab("explosivehit").Transform:SetPosition(tgt.Transform:GetWorldPosition())
	
  local ents = TheSim:FindEntities(x, y, z, 3, nil, nil)
  
	for i, v in pairs(ents) do
		if v ~= self.inst and v:IsValid() and not v:IsInLimbo() then
			if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
        --爆炸伤害
        v.components.combat:GetAttacked(self.attacker, damage, nil, "pyro")
      
      end
		end
	end

end

function yaemiko_skill:FireCheck(v,damage)
  if v.components.burnable then
    if v.components.burnable:IsBurning() then
      --着火则爆炸
      yaemiko_skill:chaozai(v,damage)
      v.components.burnable:Extinguish()
      -- v.components.burnable.burning=false
    elseif v.components.burnable:IsSmoldering() then
      --过热则点燃
      v.components.burnable:Ignite()      
      v.components.burnable:SetBurnTime(4)
    end
  end
end

local CANT_TAGS = {"INLIMBO", "player", "chester", "companion","wall"}

-- local LIGHTNINGSTRIKE_ONEOF_TAGS = { "lightningrod", "lightningtarget", "blows_air" }
function yaemiko_skill:luolei()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 12, nil, CANT_TAGS,nil)
	local damage = self:GetDamage()

	-- if not target then
	-- 	-- SpawnPrefab("thunder").Transform:SetPosition(x+math.random(-5, 5), y, z+math.random(-5, 5))
	-- 	return
	-- end

	for i, v in pairs(ents) do
    --打避雷针
    if v:HasTag("lightningrod") then
      SpawnPrefab("lightning").Transform:SetPosition(v.Transform:GetWorldPosition())
      v:PushEvent("lightningstrike")
      return
    end
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
		SpawnPrefab("lightning").Transform:SetPosition(tgt.Transform:GetWorldPosition())
		-- self.attacker:AddTag("noenergy")
 
		tgt.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
		-- self.attacker:RemoveTag("noenergy")
    
    --受到杀生樱攻击的生物会定位玩家攻击或者远离杀生樱
    local players = FindPlayersInRange(x, y, z, 15,true)
    if players ~= nil then
      for i, v in pairs(players) do
        if v then 
          tgt.components.combat:SuggestTarget(v)
        end
      end
    else
      --远离暂时没做
      -- RunAway(tgt.inst, "shashengying", 12, 15)
    end
  

		if tgt.components.sleeper and tgt.components.sleeper:IsAsleep() then
			tgt.components.sleeper:WakeUp()
		end
    yaemiko_skill:FireCheck(tgt,damage)
	end
end

function yaemiko_skill:aoeQ()
    local nearest = GetClosestInstWithTag({"monster"}, self.inst, 12)
    if nearest == nil then
            -- inst.components.talker:Say("附近没有有趣的东西呢")
        return
    end
        
    self.inst.components.energy:DoDelta(-90)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local attackcnt=0
    local ssycnt = TheSim:FindEntities(x, y, z, 12, {"shashengying"}, nil,nil)
  
  for i,v in pairs(ssycnt) do
    if attackcnt<3 then
      attackcnt=attackcnt+1
      v:DoTaskInTime(0,function(inst)
        if inst then
          local ix,iy,iz=inst.Transform:GetWorldPosition()
          SpawnPrefab("lightning_rod_fx").Transform:SetPosition(ix,iy-3,iz)
          inst:Remove()
        end
      end)
    else break
    end
  end

  local damage=self:GetDamage()*1.5
  --根据attackcnt召唤落雷。

  x,y,z=nearest.Transform:GetWorldPosition()
  
  
  --根据坐标范围伤害
  self.inst.sg:GoToState("cookbook_close")     
  SpawnPrefab("lightning").Transform:SetPosition(x,y,z)
  local ents = TheSim:FindEntities(x, y, z, 3, nil, CANT_TAGS,nil)
    for i, v in pairs(ents) do
        if v:IsValid() and not v:IsInLimbo() then
          if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
            v.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
            -- v.sg:GoToState("electrocute")
            yaemiko_skill:FireCheck(v,damage)

          end
        end
    end

  nearest.aoetask=nearest:DoPeriodicTask(0.3,function(nearest)
    --闪电
    local x1,y1,z1=nearest.Transform:GetWorldPosition()
    SpawnPrefab("lightning").Transform:SetPosition(x1,y1,z1)
    
    --伤害
    local ents = TheSim:FindEntities(x1, y1, z1, 3, nil, CANT_TAGS,nil)
    for i, v in pairs(ents) do
        if v:IsValid() and not v:IsInLimbo() then
          if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
            v.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
          end
            yaemiko_skill:FireCheck(v,damage)
        end
    end

  end)
  nearest:DoTaskInTime(attackcnt/3,function(nearest)
  if nearest.aoetask ~=nil then
    nearest.aoetask:Cancel()
    nearest.aoetask = nil
  end
  end)
end

return yaemiko_skill