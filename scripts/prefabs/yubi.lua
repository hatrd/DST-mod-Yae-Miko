local assets={
    Asset("ANIM", "anim/yubi.zip"),
    Asset("ATLAS", "images/inventoryimages/yubi.xml"),
    Asset("IMAGE", "images/inventoryimages/yubi.tex"),
}

local prefabs = {"yubi"}

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end


local function onattack_yubi(inst, attacker, target, skipsanity)
    if not skipsanity and attacker ~= nil then
        if attacker.components.staffsanity then
            attacker.components.staffsanity:DoCastingDelta(-TUNING.SANITY_SUPERTINY)
        elseif attacker.components.sanity ~= nil then
            attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
        end
    end

    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
    end

    -- if target.components.freezable ~= nil then
    --     target.components.freezable:AddColdness(1)
    --     target.components.freezable:SpawnShatterFX()
    -- end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
  
    MakeInventoryPhysics(inst)
  
    STRINGS.NAMES.YUBI = "御币"
    STRINGS.RECIPE_DESC.YUBI = "驱魔好帮手（物理）"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.YUBI = "紫水晶给了它雷的力量，这很科学。"
  
    anim:SetBank("yubi")
    anim:SetBuild("yubi")
    anim:PlayAnimation("idle")
    
    inst:AddTag("yaemiko_weapon")
    inst:AddTag("yubi")
    inst:AddTag("rangedweapon")
    -- 攻击时御币纸片应该挥舞，加whip标签，做whipline。
    -- inst:AddTag("whip")
    
    inst.projectiledelay = FRAMES

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
    -- 考虑是限定为神子才能装备，还是给其他角色加debuff
    -- inst.components.equippable.restrictedtag = "yaemiko"

    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "yubi", "swap_yubi")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(onunequip)

    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(30)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_yubi)
    inst.components.weapon:SetProjectile("yubi_projectile")
    inst.components.weapon:SetElectric()

    return inst
end

return  Prefab("common/inventory/yubi", fn, assets, prefabs)