local assets =
{
	Asset( "ANIM", "anim/yaemiko_fx.zip" ),
  	Asset("SOUND", "sound/perd.fsb"),
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
		end)
	end)
  
  inst:DoTaskInTime(14,
    inst.Remove
  )

	return inst

end

return Prefab("shashengying",summonssy,assets)