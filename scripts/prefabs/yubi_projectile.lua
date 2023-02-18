local assets = {
	Asset("ANIM", "anim/yubi_projectile.zip")
}

local prefabs = {"moose_nest_fx_hit"}

local function OnHit(inst, attacker, target)
	local impactfx = SpawnPrefab("moose_nest_fx_hit")
	if impactfx ~= nil then
		if target ~= nil and target.components.combat ~= nil then
			local follower = impactfx.entity:AddFollower()
			follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
			if attacker ~= nil then
				impactfx:FacePoint(attacker.Transform:GetWorldPosition())
                impactfx.Transform:SetScale(0.6, 0.6, 0.6)
			end
		end
	end
	inst:Remove()
	if attacker and attacker.components.energy then
		attacker.components.energy:DoDelta(0.3)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("yubi_projectile")
	inst.AnimState:SetBuild("yubi_projectile")
	inst.AnimState:PlayAnimation("huli")

	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

	inst:AddTag("weapon")
	inst:AddTag("projectile")
	inst:AddTag("NOCLICK")

	inst:AddTag("genshin_projectile")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	inst:AddComponent("weapon")

	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(60)
	inst.components.projectile.range = 12
	-- inst.components.projectile.has_damage_set = true
	-- Vector中第一个值代表发射半径，太大会导致打不中近处的东西。为0依然可能打不中近处
	inst.components.projectile:SetLaunchOffset(Vector3(0, 1, 0))
	inst.components.projectile:SetHoming(false)
	inst.components.projectile:SetHitDist(1.5)
	inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetOnMissFn(inst.Remove)

	return inst
end

return Prefab("yubi_projectile", fn, assets, prefabs)