local assets={
Asset("ANIM", "anim/yushou.zip"),
Asset("ANIM", "anim/swap_yushou.zip"),
Asset("ATLAS", "images/inventoryimages/yushou.xml"),
Asset("IMAGE", "images/inventoryimages/yushou.tex"),
}

local prefabs = {"yushou"}

local function OnEquip(inst, owner)

  owner.AnimState:OverrideSymbol("swap_object", "swap_yushou", "swap_yushou")

  owner.AnimState:Show("ARM_carry")

  owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)

  owner.AnimState:Hide("ARM_carry")

  owner.AnimState:Show("ARM_normal")
end

local function fn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  local anim = inst.entity:AddAnimState()
  local sound = inst.entity:AddSoundEmitter()
  MakeInventoryPhysics(inst)
  
  STRINGS.NAMES.YUSHOU = "御守"
  STRINGS.RECIPE_DESC.YUSHOU = "想我的时候也可以拿出来看看哦？"
  STRINGS.CHARACTERS.GENERIC.DESCRIBE.YUSHOU = "这是才智与美貌兼具的八重神子大人赠与我的！"

  anim:SetBank("yushou")
  anim:SetBuild("yushou")
  anim:PlayAnimation("idle")
  inst:AddComponent("inspectable")
  inst:AddComponent("tradable")
  inst:AddComponent("inventoryitem")
  inst.components.inventoryitem.imagename = "yushou"
  inst.components.inventoryitem.atlasname = "images/inventoryimages/yushou.xml"
  

  -- inst:AddComponent("equippable")
  -- inst.components.equippable:SetOnEquip( OnEquip )
  -- inst.components.equippable:SetOnUnequip( OnUnequip )
  return inst
end
return  Prefab("common/inventory/yushou", fn, assets, prefabs)
