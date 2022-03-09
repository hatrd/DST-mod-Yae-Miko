local assets={
Asset("ANIM", "anim/yushou.zip"),
--Asset("ANIM", "anim/swap_yushou.zip"),
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

  anim:SetBank("yushou")
  anim:SetBuild("yushou")
  anim:PlayAnimation("idle")
  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")
  inst.components.inventoryitem.imagename = "yushou"
  inst.components.inventoryitem.atlasname = "images/inventoryimages/yushou.xml"

  inst:AddComponent("equippable")
  inst.components.equippable:SetOnEquip( OnEquip )
  inst.components.equippable:SetOnUnequip( OnUnequip )
  return inst
end
return  Prefab("common/inventory/yushou", fn, assets, prefabs)
