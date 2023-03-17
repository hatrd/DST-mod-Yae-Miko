
--技能的代码实现
local yaemiko_skill = Class(function(self, inst)
	self.inst = inst
	self.attacker = inst
  self.skill_level = 1

  -- 杀生樱与天狐显真的伤害倍率，数值目前完全参zhao考ban原神内原倍率。
  -- 在高天赋等级的情况下伤害偏高，可能需要平衡性调整。
	self.ssyDamageMultiply = {
    {0.61,0.65,0.70,0.76,0.80,0.85,0.91,0.97,1.03,1.09,1.15,1.21,1.29},-- 一阶杀生樱伤害倍率 (未升级空手时不到三阶连鸟都劈不死XD)
    {0.76,0.82,0.87,0.95,1.01,1.06,1.14,1.21,1.29,1.37,1.44,1.52,1.61},-- 二阶杀生樱伤害倍率
    {0.95,1.01,1.09,1.19,1.26,1.33,1.42,1.52,1.61,1.71,1.80,1.90,2.02} -- 三阶杀生樱伤害倍率
  } 
  self.thxzDamageMultiply = {
    {2.60,2.80,2.99,3.25,3.45,3.64,3.90,4.16,4.42,4.68,4.94,5.20,5.53},-- 天狐显真伤害倍率
    {3.34,3.59,3.84,4.17,4.42,4.67,5.01,5.34,5.68,6.01,6.34,6.68,7.09} -- 天狐霆雷伤害倍率
  } 

  self.ssyCreatorId = nil --释放本杀生樱的玩家uid/玩家uid

	self.dmg = 10

	self.engenr = false
	self.jden = false
	self.sanity = false
	self.spark = false
	self.burn = false
	
	self.remainCnt = 14000 --杀生樱计时(以毫秒计)
  self.savedSsy = {} --附近的杀生樱 表
  self.savedSsyLine = {} --连接附近杀生樱的线 表
	
	--玩家信息字段
	
	self.ecnt = 3 --玩家元素战技层数
end)

-- 重置杀生樱存在统计
function yaemiko_skill:InitLineRecord()
  for i,v in pairs(self.savedSsy) do
    self.savedSsy[i] = 0
  end
end

-- 记录杀生樱存在
function yaemiko_skill:RecordLine(target)
  local ssyGUID = target.GUID
	-- 原来的划线方式，会向自己也画一次线，在ssyline有高度时就多余了。
  if ssyGUID==self.inst.GUID then
    return
  end
  -- 如果是没被记录在案的GUID
  if self.savedSsy[ssyGUID] == nil then
    
    -- 生成连线
    local line = SpawnPrefab("ssyline")
    local x,y,z =self.inst.Transform:GetWorldPosition()
    line.Transform:SetPosition(x,1.5,z)
    line:FacePoint(target:GetPosition())
    line.components.stretcher:SetStretchTarget(target)
    self.savedSsyLine[ssyGUID] = line

  end
  self.savedSsy[ssyGUID] = 1
end

-- 移除没统计到的线
function yaemiko_skill:RemoveLine()
  for i,v in pairs(self.savedSsy) do
    if v == 0 then
      if self.savedSsyLine[i] ~= nil then
        self.savedSsyLine[i]:Remove()
        table.remove(self.savedSsyLine,i)
      end
      table.remove(self.savedSsy,i)
    end
  end
end

-- 移除所有线
function yaemiko_skill:CleanUpLine()
  for i,v in pairs(self.savedSsy) do
    if self.savedSsyLine[i]~=nil then
      self.savedSsyLine[i]:Remove()
      table.remove(self.savedSsyLine,i)
    end
    table.remove(self.savedSsy,i)
  end
end

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
	return self.dmg
end

--获取天赋等级
function yaemiko_skill:GetSkillLvl()
	return self.skill_level
end

--设置天赋等级
function yaemiko_skill:SetSkillLvl(val)
	self.skill_level = val
end

--修改天赋等级
function yaemiko_skill:DeltaSkillLvl(delta)
	self.skill_level = self.skill_level + delta
end

--初始化杀生樱参数
function yaemiko_skill:SsySetInit(creator,damage,creatorSkill)
  self.dmg = damage
  self.attacker = creator
  self.ssyCreatorId = creator.userid
  self.skill_level = creatorSkill
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
TUNING.YAE_SSY_STRIKE_RADIUS=12
TUNING.YAE_BURST_RECYCLE_RADIUS=10
TUNING.YAE_BURST_AOE_RADIUS=5
local CANT_TAGS = {"INLIMBO", "player", "chester", "companion","wall","abigail"}
local MUST_TAGS = {"_combat"}
function yaemiko_skill:luolei(x,y,z,amtSsy)
    --为了打避雷针，MUST_TAGS为nil
    local ents = TheSim:FindEntities(x, y, z, TUNING.YAE_SSY_STRIKE_RADIUS, nil, CANT_TAGS,nil)
    local damage = self:GetDamage()

    -- 充能特效
    SpawnPrefab("electricchargedfx"):SetTarget(self.inst)
    damage = damage*self.ssyDamageMultiply[amtSsy][self.skill_level]

	for i, v in pairs(ents) do
    --打避雷针
    if v:HasTag("lightningrod") then
        -- 用于检验伏特羊，避免挂了还在挨雷劈
        if v.components.combat and (v.components.health and v.components.health:IsDead()) then
            return false
        end
        SpawnPrefab("yaemiko_lightning").Transform:SetPosition(v.Transform:GetWorldPosition())
        if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
		      -- 给包含(伏特羊)Tag的目标伤害时，将攻击者设置为空。
          -- 鉴于有的地方存在不会进行攻击者的空校验的情况，最好还是单独仅排除伏特羊
          -- 同时，部分模组（例如海难模组）的水母也会造成反雷，但伤害属实不怎么样，就暂时不管
          if v:HasTag("lightninggoat") then
            v.components.combat:GetAttacked(nil, damage, nil, "electro")
            -- 手动设置仇恨。虽然伏特羊被雷击后进入攻击状态，但玩家太远会原地发呆。
            v.components.combat:SuggestTarget(self.attacker)
          else
            v.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
          end
          v:PushEvent("lightningstrike")
          yaemiko_skill:FireCheck(v,damage)
          return true
        end
        --打避雷针，未有效命中
        v:PushEvent("lightningstrike")
        return false
    end
		if v ~= self.inst and v:IsValid() and not v:IsInLimbo() then
			if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
				v:AddTag("yaemikotarget")
				v:DoTaskInTime(0.1, function() v:RemoveTag("yaemikotarget") end)
			end
		end
	end
    
	local tgt = GetRandomInstWithTag("yaemikotarget", self.inst, TUNING.YAE_SSY_STRIKE_RADIUS)
	if tgt == nil then
      return false
	else
      SpawnPrefab("yaemiko_lightning").Transform:SetPosition(tgt.Transform:GetWorldPosition())
      tgt.components.combat:GetAttacked(self.attacker, damage, nil, "electro")
      yaemiko_skill:FireCheck(tgt,damage)
	end
  --有效命中
  return true
end

function yaemiko_skill:aoeQ(damage)
  local nearest = FindClosestEntity(self.inst, TUNING.YAE_SSY_STRIKE_RADIUS, true, MUST_TAGS, CANT_TAGS, nil, nil)
  -- local nearest = GetClosestInstWithTag({"hostile"}, self.inst, 12)
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
  local ssycnt = TheSim:FindEntities(x, y, z, TUNING.YAE_BURST_RECYCLE_RADIUS, {"shashengying"}, nil,nil)
  for i,v in pairs(ssycnt) do
    --检查距离内同一玩家的杀生樱数量
    if v.components.yaemiko_skill:GetUID()==self.inst.userid then
      attackcnt = attackcnt + 1
      v:DoTaskInTime(0,function(inst)
        if inst then
          local ix,iy,iz=inst.Transform:GetWorldPosition()
          SpawnPrefab("lightning_rod_fx").Transform:SetPosition(ix,iy-3,iz)
          --清除杀生樱连线
          inst.components.yaemiko_skill:CleanUpLine()
          inst:Remove()
        end
      end)
    end
  end
  --防止爆数量
  if attackcnt >3 then
    attackcnt = 3
  end
  -- 一命效果。每株杀生樱恢复8点能量。
  self.inst.components.energy:DoDelta(8*attackcnt)
  -- 天赋 神篱之御荫效果，返还摧毁杀生樱数量的元素战技层数
  -- 原本的效果其实是每摧毁一株杀生樱，就重置一次元素战技CD，但是对于现有的CD计算实现太复杂了，遂采用直接返还层数的方式来等效
  local should_ecnt=self.ecnt + attackcnt
  -- 够充满了，直接设置3层然后取消ECD计算
  if should_ecnt >= 3 then
    self.ecnt = 3
    self.inst:RemoveTag("ecd")
    self.inst:RemoveTag("ecd_doing")
    if self.inst.ECD then
      self.inst.ECD:Cancel()
    end
  else
    self.ecnt = should_ecnt
  end
  
  --根据坐标范围伤害
  local suppostDamage = damage*self.thxzDamageMultiply[1][self.skill_level]
  x,y,z=nearest.Transform:GetWorldPosition()
  self.inst.sg:GoToState("cookbook_close")     
  SpawnPrefab("yaemiko_lightning").Transform:SetPosition(x,y,z)
  local ents = TheSim:FindEntities(x, y, z, TUNING.YAE_BURST_AOE_RADIUS, MUST_TAGS, CANT_TAGS,nil)
    for i, v in pairs(ents) do
        if v:IsValid() and not v:IsInLimbo() then
          if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
            -- 给包含(伏特羊)Tag的目标伤害时，将攻击者设置为空。
            -- 鉴于有的地方存在不会进行攻击者的空校验的情况，最好还是单独仅排除伏特羊
            -- 同时，部分模组（例如海难模组）的水母也会造成反雷，但伤害属实不怎么样，就暂时不管
            if v:HasTag("lightninggoat") then
              v.components.combat:GetAttacked(nil, suppostDamage, nil, "electro")
              -- 手动设置仇恨。虽然伏特羊被雷击后进入攻击状态，但玩家太远会原地发呆。
              v.components.combat:SuggestTarget(self.attacker)
            else
              v.components.combat:GetAttacked(self.attacker, suppostDamage, nil, "electro")
            end
            yaemiko_skill:FireCheck(v,suppostDamage)
          end
        end
    end
  --根据attackcnt召唤落雷。天狐霆雷会略晚于天狐显真发生
  suppostDamage = damage*self.thxzDamageMultiply[2][self.skill_level]
  nearest:DoTaskInTime(0.5,function(nearest)
    nearest.aoetask=nearest:DoPeriodicTask(0.3,function(nearest)
      --闪电
      local x1,y1,z1=nearest.Transform:GetWorldPosition()
      SpawnPrefab("yaemiko_lightning").Transform:SetPosition(x1,y1,z1)
      --伤害
      local ents = TheSim:FindEntities(x1, y1, z1, TUNING.YAE_BURST_AOE_RADIUS, MUST_TAGS, CANT_TAGS,nil)
      for i, v in pairs(ents) do
        if v:IsValid() and not v:IsInLimbo() then
          if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
            -- 给包含(伏特羊)Tag的目标伤害时，将攻击者设置为空。
            -- 鉴于有的地方存在不会进行攻击者的空校验的情况，最好还是单独仅排除伏特羊
            -- 同时，部分模组（例如海难模组）的水母也会造成反雷，但伤害属实不怎么样，就暂时不管
            if v:HasTag("lightninggoat") then
              v.components.combat:GetAttacked(nil, suppostDamage, nil, "electro")
              -- 手动设置仇恨。虽然伏特羊被雷击后进入攻击状态，但玩家太远会原地发呆。
              v.components.combat:SuggestTarget(self.attacker)
            else
              v.components.combat:GetAttacked(self.attacker, suppostDamage, nil, "electro")
            end
          end
          yaemiko_skill:FireCheck(v,suppostDamage)
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