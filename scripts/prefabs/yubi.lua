local assets={
Asset("ANIM", "anim/yubi.zip"),
Asset("ATLAS", "images/inventoryimages/yubi.xml"),
Asset("IMAGE", "images/inventoryimages/yubi.tex"),
}

local prefabs = {"yubi"}

local function OnEquip(inst, owner)



end

local function OnUnequip(inst, owner)



end

local function fn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  local anim = inst.entity:AddAnimState()
  local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)


  STRINGS.NAMES.YUBI = "御币"
  STRINGS.RECIPE_DESC.YUBI = "八重神子的武器。"
  STRINGS.CHARACTERS.GENERIC.DESCRIBE.YUBI = "似乎可以祓除邪恶。"

  anim:SetBank("yubi")
  anim:SetBuild("yubi")
  anim:PlayAnimation("idle")


  
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
      return inst
  end

  inst:AddComponent("inspectable")
  inst:AddComponent("tradable")
  inst:AddComponent("inventoryitem")
  inst.components.inventoryitem.imagename = "yubi"
  inst.components.inventoryitem.atlasname = "images/inventoryimages/yubi.xml"
  

  inst:AddComponent("equippable")
  inst.components.equippable:SetOnEquip(OnEquip)
  inst.components.equippable:SetOnUnequip(OnUnequip)
  return inst
end

return  Prefab("common/inventory/yubi", fn, assets, prefabs)
