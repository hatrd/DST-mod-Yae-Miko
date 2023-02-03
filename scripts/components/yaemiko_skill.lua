
--技能的代码实现
local yaemiko_skill = Class(function(self, inst)
	self.inst = inst
	self.attacker = inst

  --杀生樱与天狐显真的伤害倍率 可能需要平衡性调整
	self.ssyDamageMultiply = {0.6,0.75,0.94} --一/二/三阶杀生樱伤害倍率 (空手时不到三阶连鸟都劈不死XD)
  self.thxzDamageMultiply = {2.6,3.34} --天狐显真/天狐霆雷伤害倍率

  self.ssyCreatorId = nil --释放本杀生樱的玩家uid/玩家uid

	self.dmg = 10
	self.mult = 1
	self.bonus = 0

	self.engenr = false
	self.jden = false
	self.sanity = false
	self.spark = false
	self.burn = false
	
	self.remainCnt = 14000 --杀生樱计时(以毫秒计)
	
	--玩家信息字段
	
	self.ecnt = 3 --玩家元素战技层数
end)

--获取杀生樱计时
function yaemiko_skill:GetRemainCnt()
	return self.remainCnt
end

--杀生樱计时前进100毫秒
function yaemiko_skill:StepRemainCnt()
	self.remainCnt = self.remainCnt - 100
end

--返回玩家UID
function yaemiko_skill:GetUID()
  return self.ssyCreatorId
end

--获取杀生樱基本伤害
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

--初始化杀生樱参数
function yaemiko_skill:SsySetInit(creatorId,damage)
  self.dmg = damage
  self.ssyCreatorId = creatorId
end

--初始化神子参数
function yaemiko_skill:MikoSetInit(uid)
  self.ssyCreatorId = uid
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

local CANT_TAGS = {"INLIMBO", "player", "chester", "companion","wall","abigail"}

-- local LIGHTNINGSTRIKE_ONEOF_TAGS = { "lightningrod", "lightningtarget", "blows_air" }
function yaemiko_skill:luolei()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 14, nil, CANT_TAGS,nil)--杀生樱索敌距离
	local damage = self:GetDamage()
  local amtSsy = 0

  --寻找附近杀生樱，距离4
  local ssycnt = TheSim:FindEntities(x, y, z, 4, {"shashengying"}, nil,nil)
  for i,v in pairs(ssycnt) do
    --检查距离内同一玩家的杀生樱数量
    if v.components.yaemiko_skill:GetUID()==self:GetUID() then
      amtSsy = amtSsy + 1
    end
  end
  --防止爆数量
  if amtSsy >3 then
    amtSsy = 3
  --附近没找到同一玩家的杀生樱
  --在落雷时如果此语句被触发必然是有BUG了
  elseif amtSsy == 0 then
    print("YaeMiko[ERROR]:Requested Luolei but cannot found Sessyouusakura created by player with userid:",self.inst.userid)
    return false
  end
  
  --乘算杀生樱伤害
  damage = damage*self.ssyDamageMultiply[amtSsy]
	-- if not target then
	-- 	-- SpawnPrefab("thunder").Transform:SetPosition(x+math.random(-5, 5), y, z+math.random(-5, 5))
	-- 	return
	-- end

	for i, v in pairs(ents) do
    --打避雷针
    if v:HasTag("lightningrod") then
      SpawnPrefab("lightning").Transform:SetPosition(v.Transform:GetWorldPosition())
      v:PushEvent("lightningstrike")
      --未有效命中
      return false
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
		--SpawnPrefab("thunder").Transform:SetPosition(x+math.random(-5, 5), y, z+math.random(-5, 5))
    --未有效命中
    return false
	else
		SpawnPrefab("lightning").Transform:SetPosition(tgt.Transform:GetWorldPosition())
		-- self.attacker:AddTag("noenergy")
 
		tgt.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
		-- self.attacker:RemoveTag("noenergy")
    
    --受到杀生樱攻击的生物会定位玩家攻击或者远离杀生樱
    local players = FindPlayersInRange(x, y, z, 15,true)
    if players ~= nil then
      for i, v in pairs(players) do
        --寻找杀生樱的释放者，若找到则设置仇恨
        if v and v.userid == self.ssyCreatorId then
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
  --有效命中
  return true
end

function yaemiko_skill:aoeQ(damage)
  local nearest = GetClosestInstWithTag({"hostile"}, self.inst, 12)
  if nearest == nil then
    self.inst:DoTaskInTime(0.1, function()
      if self.inst.components.talker then
        self.inst.components.talker:Say("附近没有什么有趣的东西呢。")
      end
    end)
		return
  end
       
  self.inst.components.energy:DoDelta(-90)
  local x, y, z = self.inst.Transform:GetWorldPosition()
  local attackcnt=0
  --寻找附近杀生樱，距离8
  local ssycnt = TheSim:FindEntities(x, y, z, 8, {"shashengying"}, nil,nil)
  for i,v in pairs(ssycnt) do
    --检查距离内同一玩家的杀生樱数量
    if v.components.yaemiko_skill:GetUID()==self.inst.userid then
      attackcnt = attackcnt + 1
      v:DoTaskInTime(0,function(inst)
        if inst then
          local ix,iy,iz=inst.Transform:GetWorldPosition()
          SpawnPrefab("lightning_rod_fx").Transform:SetPosition(ix,iy-3,iz)
          inst:Remove()
        end
      end)
    end
  end
  --防止爆数量
  if attackcnt >3 then
    attackcnt = 3
  end
  --记录攻击发生位置
  x,y,z=nearest.Transform:GetWorldPosition()
  
  --根据坐标范围伤害
  self.inst.sg:GoToState("cookbook_close")     
  SpawnPrefab("lightning").Transform:SetPosition(x,y,z)
  local ents = TheSim:FindEntities(x, y, z, 3, nil, CANT_TAGS,nil)
    for i, v in pairs(ents) do
        if v:IsValid() and not v:IsInLimbo() then
          if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
            v.components.combat:GetAttacked(self.attacker, damage*self.thxzDamageMultiply[1], nil, "electro")
            -- v.sg:GoToState("electrocute")
            yaemiko_skill:FireCheck(v,damage*self.thxzDamageMultiply[1])

          end
        end
    end
  --根据attackcnt召唤落雷。天狐霆雷会略晚于天狐显真发生
  damage=damage*self.thxzDamageMultiply[2]
  nearest:DoTaskInTime(0.5,function(nearest)
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
  end)
end

return yaemiko_skill