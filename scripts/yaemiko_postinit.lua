AddPrefabPostInit("moonrocknugget",function(inst)
  inst:AddComponent("yaemiko_skilllevelingusable")
end)
AddPrefabPostInit("moonglass",function(inst)
  inst:AddComponent("yaemiko_skilllevelingusable")
end)
AddPrefabPostInit("moonglass_charged",function(inst)
  inst:AddComponent("yaemiko_skilllevelingusable")
end)

-- 升级阈值的指定。它们不应该高于13，且前一级不应高于后一级。可以作为平衡性调整的考虑项目
TUNING.YAEMIKO_SKILL_STAGE_1_MAXIMUM_LEVEL = 2 -- 使用月岩可到达的最高天赋等级
TUNING.YAEMIKO_SKILL_STAGE_2_MAXIMUM_LEVEL = 6 -- 使用月亮碎片可到达的最高天赋等级
TUNING.YAEMIKO_SKILL_STAGE_3_MAXIMUM_LEVEL = 13 -- 使用注能月亮碎片可到达的最高天赋等级，也是最后的上限，他不应高于13

AddAction("YAEMIKO_SKILLLEVELING",STRINGS.ACTIONS.USEITEM, function(act)
  if act.invobject then
    if act.invobject.components.stackable then
        if act.doer.components.yaemiko_skill:GetSkillLvl()<TUNING.YAEMIKO_SKILL_STAGE_1_MAXIMUM_LEVEL and act.invobject.prefab=="moonrocknugget" then
          act.doer.components.yaemiko_skill:DeltaSkillLvl(1)
          act.invobject.components.stackable:Get():Remove()
          return true
        elseif  act.doer.components.yaemiko_skill:GetSkillLvl()<TUNING.YAEMIKO_SKILL_STAGE_2_MAXIMUM_LEVEL and act.invobject.prefab=="moonglass" then
          act.doer.components.yaemiko_skill:DeltaSkillLvl(1)
          act.invobject.components.stackable:Get():Remove()
          return true
        elseif  act.doer.components.yaemiko_skill:GetSkillLvl()<TUNING.YAEMIKO_SKILL_STAGE_3_MAXIMUM_LEVEL and act.invobject.prefab=="moonglass_charged" then
          act.doer.components.yaemiko_skill:DeltaSkillLvl(1)
          act.invobject.components.stackable:Get():Remove()
          return true
        end
    end
    return true
  end
end)

AddComponentAction("INVENTORY","yaemiko_skilllevelingusable",function(inst, doer, actions, right)
  if doer ~= nil and doer.prefab == "yaemiko" and inst~=nil then
    ACTIONS.YAEMIKO_SKILLLEVELING.priority = 1
    table.insert(actions,ACTIONS.YAEMIKO_SKILLLEVELING)
  end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.YAEMIKO_SKILLLEVELING,"doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.YAEMIKO_SKILLLEVELING,"doshortaction"))