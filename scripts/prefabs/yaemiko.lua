local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

-- 三值
TUNING.YAEMIKO_HEALTH = 100
TUNING.YAEMIKO_HUNGER = 150
TUNING.YAEMIKO_SANITY = 200

-- 基本技能伤害，技能基准伤害为<所持武器伤害+基本技能伤害>
TUNING.YAEMIKO_SKILL_DAMAGE_BASE = 10

-- 天赋等级保存上限，高于此等级的天赋等级不会被保存
-- 例如本项若设置为10，则八重虽可以在游戏内提升天赋等级到13级。但重新登入后，将会被回退到天赋等级10级。
-- 设置该项是为了在平衡性调整时，作为一个可以考虑的方向。这个数值不应低于1，不应高于13。
TUNING.YAEMIKO_KEEP_SKILL_LEVEL = 13

-- 初始道具
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.YAEMIKO = {
	"yushou","yaeyubi",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.YAEMIKO
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "yaemiko_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "yaemiko_speed_mod")
end

local function onsave(inst, data)
    -- 保存天赋等级
	data.skill_level = inst.components.yaemiko_skill:GetSkillLvl()
end

-- When loading or spawning the character
local function onload(inst,data)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end

    -- 读取保存的天赋等级
    if data and data.skill_level then
        -- 超出设置的限制，回退到限制值
        if data.skill_level>TUNING.YAEMIKO_KEEP_SKILL_LEVEL then
            inst.components.yaemiko_skill:SetSkillLvl(TUNING.YAEMIKO_KEEP_SKILL_LEVEL) 
        else
            inst.components.yaemiko_skill:SetSkillLvl(data.skill_level) 
        end
    end
end

----------人物技能区------------------------------------------
--计算技能基本伤害 参考Yus的代码
local function yaemiko_nowdamage(inst_f)
    local atkMult = 1 --圣遗物伤害倍率
    local atkBonus = 0 --圣遗物伤害加成
    local atkDamage = 30 --基准伤害
    --获取基准伤害
    --不会有人没有物品栏吧
    if inst_f.components.inventory then
        local item = inst_f.components.inventory.equipslots[EQUIPSLOTS.HANDS]
        --有的模组武器damage是个函数，需要避免它是其他东西，防止(万一的)哪个奇怪武器伤害低于10
        if item and item.components.weapon and type(item.components.weapon.damage)=="number" and item.components.weapon.damage>10 then
            if item.prefab == "yaeyubi" then
                --当主手是御币 补偿1.5倍的伤害，基准伤害为武器伤害 + 基本伤害
                atkDamage = item.components.weapon.damage * 1.5 + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            else
                --当主手持有非御币武器，基准伤害为武器伤害 + 基本伤害
                atkDamage = item.components.weapon.damage + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            end
        --奇奇怪怪模组武器的单独支持，尤其是原神相关
        elseif item and item.components.weapon and type(item.components.weapon.damage)=="function" then
            if item.prefab == "element_spear" then --元素反应：元素长矛
                --[[元素反应的damage函数，参数weapon,attacker,target
                    atkDamage = item.components.weapon:damage(nil,inst_f,nil) + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
                    目前元素反应的长矛伤害是固定的原版长矛伤害，保险起见先使用固定值，雷电将军的武器亦同]]
                    atkDamage = TUNING.SPEAR_DAMAGE + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            elseif item.prefab == "engulfinglightning" and type(TUNING.ENGULFINGLIGHTNING_DAMAGE)=="number" then --雷电将军：薙草之稻光
                atkDamage = TUNING.ENGULFINGLIGHTNING_DAMAGE + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            elseif item.prefab == "favoniuslance" and type(TUNING.FAVONIUSLANCE_DAMAGE)=="number" then --雷电将军：西风长枪
                atkDamage = TUNING.FAVONIUSLANCE_DAMAGE + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            elseif item.prefab == "thecatch" and type(TUNING.THECATCH_DAMAGE)=="number" then --雷电将军：渔获
                atkDamage = TUNING.THECATCH_DAMAGE + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            else
                -- 不认识的无法适配武器，给矛伤害
                atkDamage = TUNING.SPEAR_DAMAGE + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
            end
        else
            --其他情况给空手伤害
            atkDamage = 20 + TUNING.YAEMIKO_SKILL_DAMAGE_BASE
        end
    end
    if inst_f.components.combat then
        --获取圣遗物倍率加成，我真的怕了全做number检查算了
		if type(inst_f.components.combat.damagemultiplier)=="number" then
			atkMult = inst_f.components.combat.damagemultiplier
		end
        --获取圣遗物数值加成，我真的怕了全做number检查算了
		if type(inst_f.components.combat.damagebonus)=="number" then
			atkBonus = inst_f.components.combat.damagebonus
		end
	end
    return atkDamage * atkMult + atkBonus
end
local function MoveAndSummonSsy(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    
    local ssy = SpawnPrefab("shashengying")
    
    for v = 0,6,2 do
        -- 0,2,4,6逐步试探
        local tx = v * math.sin(angle)
        local tz = v * math.cos(angle)
        if TheWorld.Map:IsPassableAtPoint(x+tx,y,z+tz) then
            -- 使用Physics，客机不仅被拽回，还会反向
            -- inst.Physics:Teleport(x+tx,y,z+tz)
            inst.Transform:SetPosition(x+tx, y, z+tz)
            ssy.Transform:SetPosition(x+tx/2,y,z+tz/2)
        else
            break
        end
    end
    -- inst.components.playercontroller:Enable(true)

    --记录杀生樱信息
    ssy.components.yaemiko_skill:SsySetInit(inst,yaemiko_nowdamage(inst),inst.components.yaemiko_skill:GetSkillLvl())
    inst.components.sanity:DoDelta(-0.3)

    --寻找附近杀生樱，距离20不够。比如在屏幕边缘放
    local ssycnt = TheSim:FindEntities(x, y, z, 32, {"shashengying"}, nil,nil)
    local leastSsy = nil
    local amtSsy = 0
    for i,v in pairs(ssycnt) do
        --检查距离内同一玩家的杀生樱数量，并记录最少剩余时间的杀生樱  
        if v.components.yaemiko_skill:GetUID()==inst.userid then
            if leastSsy == nil or v.components.yaemiko_skill:GetRemainCnt() <= leastSsy.components.yaemiko_skill:GetRemainCnt() then
                leastSsy = v
            end
            amtSsy = amtSsy + 1
        end
        --因为已经生成了 所以爆数量时应该有4个杀生樱正在场上
        if amtSsy >3 then
            --摧毁记录的杀生樱
            leastSsy:DoTaskInTime(0,function(para)
                if para then
                local ix,iy,iz=para.Transform:GetWorldPosition()
                SpawnPrefab("lightning_rod_fx").Transform:SetPosition(ix,iy-3,iz)
                --清除杀生樱连线
                para.components.yaemiko_skill:CleanUpLine()
                para:Remove()
                end
            end)
        end
    end

    -- inst:Show()
    -- 这里取消无敌会导致玩家本来的无敌被删掉。
    -- if inst.components.health ~= nil then
    --     inst.components.health:SetInvincible(false)
    -- end
    -- if inst.DynamicShadow ~= nil then
    --     inst.DynamicShadow:Enable(true)
    -- end
end

local function yaemiko_skill(inst)
    if not inst:HasTag("playerghost") and inst:HasTag("yaemiko") then
    if not (inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("doing") or inst.sg.statemem.heavy) then
        if inst.components.rider and inst.components.rider:IsRiding() then return 
        end
            if inst.components.yaemiko_skill.ecnt > 0 then
                inst.components.yaemiko_skill.ecnt=inst.components.yaemiko_skill.ecnt-1 
                inst:AddTag("ecd")
                
                if inst:HasTag("ecd") and not inst:HasTag("ecd_doing") then
                inst:AddTag("ecd_doing")
                inst.ECD = inst:DoPeriodicTask(4, function(inst)
                    inst.components.yaemiko_skill.ecnt=inst.components.yaemiko_skill.ecnt+1
                    if inst.components.yaemiko_skill.ecnt >= 3 then
                    inst.components.yaemiko_skill.ecnt = 3
                    inst:RemoveTag("ecd")
                    inst:RemoveTag("ecd_doing")
                    inst.ECD:Cancel()
                    end
                end)
                end

                -- inst.components.playercontroller:Enable(false)
                -- inst.components.locomotor:Stop()
                -- inst:Hide()
                -- if inst.DynamicShadow ~= nil then
                --     inst.DynamicShadow:Enable(false)
                -- end
                -- if inst.components.health ~= nil then
                --     inst.components.health:SetInvincible(true)
                -- end
                inst:DoTaskInTime(0,MoveAndSummonSsy)

            end
        end
    end
    
end

local function yaemiko_burst(inst)

  if inst.components.energy and inst.components.energy.current == 90 then
    if not inst:HasTag("playerghost") and inst:HasTag("yaemiko") then
		  if not (inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("doing") or inst.sg.statemem.heavy) then
			  if inst.components.rider and inst.components.rider:IsRiding() then return 
        end

          inst.components.yaemiko_skill:aoeQ(yaemiko_nowdamage(inst))
          -- inst.sg:GoToState("mounted_idle")
      end
    end
  end
  
end

local function Update(inst)
  inst._ecnt:set(inst.components.yaemiko_skill.ecnt)

end

-------------------------------------------------------------

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "yaemiko.tex" )
  
    inst:AddTag("yaemiko")
    inst:AddTag("genshin_character")
    inst:AddTag("electro")
	inst:AddTag("catalyst_class")

	inst.charge_rate = 1
	inst.skill_rate = 1
	inst.burst_rate = 1
	inst.heal_rate = 1
  
	inst.energy_max = net_ushortint(inst.GUID, "energy_max", "energy_maxdirty")
	inst.energy_current = net_ushortint(inst.GUID, "energy_current", "energy_currentdirty")
    inst._ecnt= net_ushortint(inst.GUID, "inst._ecnt", "inst._ecnt")

    -- 按键
	inst:AddComponent("genshinkey")
	inst.components.genshinkey:Press(_G[TUNING.YAEMIKO_SKILL_KEY], "yaemiko_skill")
	inst.components.genshinkey:Press(_G[TUNING.YAEMIKO_BURST_KEY], "yaemiko_burst")

    -- 描述
    if TUNING.LANG==1 then
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.PURPLEGEM = "Seems to contain the power of Electro?"
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.MOONROCKNUGGET = "Can be used to increase Talent to lv2"
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.MOONGLASS = "Can be used to increase Talent to lv6"
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.MOONGLASS_CHARGED = "Can be used to increase Talent to lv13"
    else
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.PURPLEGEM = "似乎蕴含着雷元素力？"
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.MOONROCKNUGGET = "可以用来提升天赋等级至2级"
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.MOONGLASS = "可以用来提升天赋等级至6级"
        STRINGS.CHARACTERS.YAEMIKO.DESCRIBE.MOONGLASS_CHARGED = "可以用来提升天赋等级至13级"
        -- 文案可太难写了
    end
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
    inst:AddComponent("energy")
    inst.components.energy:SetMax(90)
    inst.components.energy:Recharge(TUNING.YAEMIKO_RECHARGE)
    inst:AddComponent("yaemiko_skill")

    inst.components.yaemiko_skill:MikoSetInit(inst.userid)

    inst.soundsname = "willow"
    inst:AddComponent("talker")
    --将event与函数连接
	inst:ListenForEvent("yaemiko_skill", yaemiko_skill)
	inst:ListenForEvent("yaemiko_burst", yaemiko_burst)

	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- 设置状态
	inst.components.health:SetMaxHealth(TUNING.YAEMIKO_HEALTH)
	inst.components.hunger:SetMax(TUNING.YAEMIKO_HUNGER)
	inst.components.sanity:SetMax(TUNING.YAEMIKO_SANITY)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
    inst.OnSave = onsave
	inst.OnLoad = onload
    inst.OnNewSpawn = onload

	inst:DoPeriodicTask(0, Update)
end

return MakePlayerCharacter("yaemiko", prefabs, assets, common_postinit, master_postinit, prefabs)
