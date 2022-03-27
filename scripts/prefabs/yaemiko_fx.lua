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



	inst:AddTag("FX")
  inst:AddTag("shashengying")
	inst.entity:SetPristine()


	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	inst:AddComponent("yaemiko_skill")
  
  inst:DoTaskInTime(0, function()
		inst:DoPeriodicTask(3, function()
			inst.components.yaemiko_skill:luolei()
      --恢复元素能量
      for i, v in ipairs(AllPlayers) do
      if v.components.energy then
        v.components.energy:DoDelta(1)
      end

	end
		end)
	end)
  
  inst:DoTaskInTime(12,function(inst)
    if inst then
      local ix,iy,iz=inst.Transform:GetWorldPosition()
      SpawnPrefab("lightning_rod_fx").Transform:SetPosition(ix,iy-3,iz)
      inst:Remove()
    end
  end)

	return inst

end

return Prefab("shashengying",summonssy,assets)