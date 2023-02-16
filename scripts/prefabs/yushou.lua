local assets={
Asset("ANIM", "anim/yushou.zip"),
Asset("ATLAS", "images/inventoryimages/yushou.xml"),
Asset("IMAGE", "images/inventoryimages/yushou.tex"),
}

local prefabs = {"yushou"}

local function OnEquip(inst, owner)
  owner.AnimState:OverrideSymbol("swap_hat", "yushou", "swap_yushou")
  owner.AnimState:Show("HAT")

--平时恢复san
  inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

--战斗恢复san
  inst:DoTaskInTime(0.2, function(inst)
      inst.battlesan=inst:DoPeriodicTask(4, function()
        if owner.components.combat and owner.components.combat.target and owner.components.sanity then
          -- print("回san-是否有攻击目标")
          owner.components.sanity:DoDelta(3)
        end
      end)
  end)

end

local function OnUnequip(inst, owner)


	owner.AnimState:ClearOverrideSymbol("swap_yushou")
  owner.AnimState:Hide("HAT")

  if inst.battlesan then
    inst.battlesan:Cancel()
    inst.battlesan = nil
  end

end

local function fn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  local anim = inst.entity:AddAnimState()
  local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)


  STRINGS.NAMES.YUSHOU = "御守"
  STRINGS.RECIPE_DESC.YUSHOU = "想我的时候也可以拿出来看看哦？"
  STRINGS.CHARACTERS.GENERIC.DESCRIBE.YUSHOU = "这是才智与美貌兼具的八重神子大人赠予我的！"

  anim:SetBank("yushou")
  anim:SetBuild("yushou")
  anim:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
  
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
      return inst
  end

  inst:AddComponent("inspectable")
  inst:AddComponent("tradable")
  inst:AddComponent("inventoryitem")
  inst.components.inventoryitem.imagename = "yushou"
  inst.components.inventoryitem.atlasname = "images/inventoryimages/yushou.xml"
  

  inst:AddComponent("equippable")
  inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
  inst.components.equippable:SetOnEquip(OnEquip)
  inst.components.equippable:SetOnUnequip(OnUnequip)
  return inst
end

return  Prefab("common/inventory/yushou", fn, assets, prefabs)
