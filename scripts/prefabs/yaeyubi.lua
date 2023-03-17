local assets={
    Asset("ANIM", "anim/yaeyubi.zip"),
    Asset("ATLAS", "images/inventoryimages/yaeyubi.xml"),
    Asset("IMAGE", "images/inventoryimages/yaeyubi.tex"),
}

local prefabs = {"yaeyubi"}

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

-- 进行精炼
local function onRefine(inst, giver, item)
    if TUNING.YAEYUBI_REFINE_LIMIT == 0 or inst.components.yaeyubi_info:GetRefine()<TUNING.YAEYUBI_REFINE_LIMIT then
        inst.components.yaeyubi_info:RefineDoDelta(1)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
end

-- 判断给予的物品是否符合要求；是否现在还可以精炼
local function canRefine(inst, item)
    if item == nil or item.prefab ~= "purplegem" or (TUNING.YAEYUBI_REFINE_LIMIT ~= 0 and inst.components.yaeyubi_info:GetRefine()>=TUNING.YAEYUBI_REFINE_LIMIT) then
        return false
    end
    return true
end

local function onattack_yubi(inst, attacker, target, skipsanity)
    -- if not skipsanity and attacker ~= nil then
    --     if attacker.components.staffsanity then
    --         attacker.components.staffsanity:DoCastingDelta(-TUNING.SANITY_SUPERTINY)
    --     elseif attacker.components.sanity ~= nil then
    --         attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    --     end
    -- end

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
  
    STRINGS.NAMES.YAEYUBI = "御币"
    STRINGS.RECIPE_DESC.YAEYUBI = "驱魔好帮手（物理）。合成的御币可以用紫水晶进一步强化。"
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.YAEYUBI = "紫水晶给了它雷的力量，这很科学。"
  
    anim:SetBank("yubi")
    anim:SetBuild("yubi") --编译时的名称是yubi.zip，但是可以改名/anim/yaeyubi.zip并正常工作
    anim:PlayAnimation("idle")
    
    inst:AddTag("yaemiko_weapon")
    inst:AddTag("yaeyubi")
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
    inst.components.inventoryitem.imagename = "yaeyubi"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/yaeyubi.xml"

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(20)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_yubi)
    inst.components.weapon:SetProjectile("yubi_projectile")
    inst.components.weapon:SetElectric()

    inst:AddComponent("equippable")
    
    -- 考虑是限定为神子才能装备，还是给其他角色加debuff
    -- inst.components.equippable.restrictedtag = "yaemiko"
    inst.components.equippable:SetOnEquip(function(inst, owner)
        -- 只有神子能打出狐灵
        if owner:HasTag("yaemiko") then
            inst.components.weapon:SetProjectile("yubi_projectile")
            inst.components.weapon:SetRange(8, 10)
        else
            inst.components.weapon:SetProjectile(nil)
            inst.components.weapon:SetRange(0, 0)
        end
        owner.AnimState:OverrideSymbol("swap_object", "yubi", "swap_yubi")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("yaeyubi_info")

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(canRefine)
    inst.components.trader.onaccept = onRefine

    return inst
end

return  Prefab("common/inventory/yaeyubi", fn, assets, prefabs)