local assets = {
	Asset("ANIM", "anim/ganyu_arrow.zip")
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
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("ganyu_arrow")
	inst.AnimState:SetBuild("ganyu_arrow")
	inst.AnimState:PlayAnimation("normal")

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
	inst.components.projectile:SetSpeed(30)
	-- inst.components.projectile.range = 20
	-- inst.components.projectile.has_damage_set = true
	-- inst.components.projectile:SetLaunchOffset(Vector3(1, 1, 0))
	-- inst.components.projectile:SetHoming(false)
	-- inst.components.projectile:SetHitDist(1.5)
	inst.components.projectile:SetOnHitFn(OnHit)

	return inst
end

return Prefab("yubi_projectile", fn, assets, prefabs)