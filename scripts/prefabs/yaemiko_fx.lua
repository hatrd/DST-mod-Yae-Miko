local assets =
{
	Asset( "ANIM", "anim/yaemiko_fx.zip" ),
    Asset("ANIM", "anim/lightning_rod_fx.zip"),
}


local function summonssy()
  
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
	inst.entity:AddNetwork()

  -- inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")
 
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(1.0)
    inst.Light:SetColour(130/255, 0/255, 255/255)
    inst.Light:Enable(true)
    

	inst.AnimState:SetBank("fx")
	inst.AnimState:SetBuild("yaemiko_fx")
	inst.AnimState:PlayAnimation("shashengying",true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")
    inst.AnimState:SetLightOverride(.1)
	inst.AnimState:SetFinalOffset(3)


	inst:AddTag("FX")
    inst:AddTag("shashengying")
	inst.entity:SetPristine()


	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	inst:AddComponent("yaemiko_skill")
		inst:DoPeriodicTask(0.1, function()
			inst.components.yaemiko_skill:StepRemainCnt()
			local remainCnt = inst.components.yaemiko_skill:GetRemainCnt()
			local x, y, z = inst.Transform:GetWorldPosition()
			--寻找附近杀生樱，距离7
			local amtSsy = 0
			local ssycnt = TheSim:FindEntities(x, y, z, 7, {"shashengying"}, nil,nil)
			--初始化杀生樱存在记录
			inst.components.yaemiko_skill:InitLineRecord()
			for i,v in pairs(ssycnt) do
				--检查距离内同一玩家的杀生樱数量
				if v.components.yaemiko_skill:GetUID()==inst.components.yaemiko_skill:GetUID() then
					amtSsy = amtSsy + 1
					-- 记录杀生樱存在
					inst.components.yaemiko_skill:RecordLine(v)
				end
			end
			--移除没统计到的线
			inst.components.yaemiko_skill:RemoveLine()
			-- print(self:GetUID(),"有效杀生樱数量：",amtSsy)
			--防止爆数量
			if amtSsy >3 then
				amtSsy = 3
			end

			if (remainCnt%3000) == 0 then
				local flg = inst.components.yaemiko_skill:luolei(x,y,z,amtSsy)
				--如果产生有效命中
				if flg then
				--恢复元素能量
					for i, v in ipairs(AllPlayers) do
						if v.components.energy then
							v.components.energy:DoDelta(1)
						end
					end
				end
			end
			if remainCnt <= 0 then
				local ix,iy,iz=inst.Transform:GetWorldPosition()
				SpawnPrefab("lightning_rod_fx").Transform:SetPosition(ix,iy-3,iz)
				--清除杀生樱连线
				inst.components.yaemiko_skill:CleanUpLine()
				inst:Remove()
			end
		end)
	return inst
end

local function createline()
	-- shadowhand.lua
	local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("fx")
	inst.AnimState:SetBuild("yaemiko_fx")
	
	-- 不应该在地面,但不在地面，拉伸组件就不起作用
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
	
    inst.AnimState:PlayAnimation("ssyline", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stretcher")
    inst.components.stretcher:SetRestingLength(4.75)
    inst.components.stretcher:SetWidthRatio(.35)

    inst.persists = false

    return inst
end

return Prefab("shashengying",summonssy,assets),
	Prefab("ssyline",createline,assets)