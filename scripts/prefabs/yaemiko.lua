local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

-- 三值
TUNING.YAEMIKO_HEALTH = 100
TUNING.YAEMIKO_HUNGER = 150
TUNING.YAEMIKO_SANITY = 220


-- 初始道具
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.YAEMIKO = {
	"yushou",
  "yubi",
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

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

----------人物技能区------------------------------------------

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
              inst:RemoveTag("ecd")
              inst:RemoveTag("ecd_doing")
              inst.ECD:Cancel()
            end
          end)
        end

      local x, y, z = inst.Transform:GetWorldPosition()
      local angle = (inst.Transform:GetRotation() + 90) * DEGREES
      local tx = 3 * math.sin(angle)
      local tz = 3 * math.cos(angle)
      inst.Transform:SetPosition(x+tx, y, z+tz)
      SpawnPrefab("shashengying").Transform:SetPosition(x+tx/2,y,z+tz/2)
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
        
          inst.components.yaemiko_skill:aoeQ()
          -- inst.sg:GoToState("mounted_idle")
      end
    end
  end
  
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

  --按键

	inst:AddComponent("genshinkey")
	inst.components.genshinkey:Press(_G[TUNING.YAEMIKO_SKILL_KEY], "yaemiko_skill")
	inst.components.genshinkey:Press(_G[TUNING.YAEMIKO_BURST_KEY], "yaemiko_burst")
  
  -- inst.ecnt=3
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
  inst:AddComponent("energy")
  inst.components.energy:SetMax(90)
  inst.components.energy:Recharge(TUNING.YAEMIKO_RECHARGE)
  inst:AddComponent("yaemiko_skill")
  --设置声音
	inst.soundsname = "willow"

  --将event与函数连接
	inst:ListenForEvent("yaemiko_skill", yaemiko_skill)
	inst:ListenForEvent("yaemiko_burst", yaemiko_burst)


	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- -- 动态设置状态，目前不需要。	
	-- inst.components.health:SetMaxHealth(TUNING.YAEMIKO_HEALTH)
	-- inst.components.hunger:SetMax(TUNING.YAEMIKO_HUNGER)
	-- inst.components.sanity:SetMax(TUNING.YAEMIKO_SANITY)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
  inst.OnNewSpawn = onload


end

return MakePlayerCharacter("yaemiko", prefabs, assets, common_postinit, master_postinit, prefabs)
