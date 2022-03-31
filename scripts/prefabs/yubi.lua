local assets={
Asset("ANIM", "anim/yubi.zip"),
Asset("ANIM", "anim/swap_yubi.zip"),
Asset("ATLAS", "images/inventoryimages/yubi.xml"),
Asset("IMAGE", "images/inventoryimages/yubi.tex"),
}

local prefabs = {"yubi"}

local function OnEquip(inst, owner)
    -- owner.AnimState:OverrideSymbol("swap_hat", "yushou", "swap_yushou")
    -- owner.AnimState:OverrideSymbol("swap_object", "custom_handitem", "swap_object")
    -- owner.AnimState:OverrideSymbol("swap_object", "swap_yubi", "swap_object")
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
	inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)


  STRINGS.NAMES.YUBI = "御币"
  STRINGS.RECIPE_DESC.YUBI = "似乎可以祓除邪恶。"
  STRINGS.CHARACTERS.GENERIC.DESCRIBE.YUBI = "八重神子的武器。"

  anim:SetBank("yubi")
  anim:SetBuild("yubi")
  anim:PlayAnimation("idle",true)

  inst:AddComponent("weapon")
  inst.components.weapon:SetDamage(12)
  inst.components.weapon:SetRange(8, 12)
  -- inst.components.weapon:SetOnAttack(onattack_yubi)

  
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
  inst.components.equippable.restrictedtag = "yaemiko"
  inst.components.equippable:SetOnEquip(OnEquip)
  inst.components.equippable:SetOnUnequip(OnUnequip)
  return inst
end

return  Prefab("common/inventory/yubi", fn, assets, prefabs)
