local GenshinKey = Class(function(self, inst)
	self.inst = inst
end)

function GenshinKey:Press(Key, Action, Target, arg)
	TheInput:AddKeyDownHandler(Key, function()
		if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if TheWorld.ismastersim then
				BufferedAction(self.inst, Target, ACTIONS[string.upper(Action)]):Do()
			else
				SendModRPCToServer(MOD_RPC[self.inst.prefab][Action], arg)
			end
		end
	end)
end

function GenshinKey:Hold(Key, Start, Stop, Target, arg)
	TheInput:AddKeyDownHandler(Key, function()
		if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if not self.inst:HasTag("act_holding") then
				if TheWorld.ismastersim then
					BufferedAction(self.inst, Target, ACTIONS[string.upper(Start)]):Do()
				else
					SendModRPCToServer(MOD_RPC[self.inst.prefab][Start], arg)
				end
				self.inst:AddTag("act_holding")
			end
		end
	end)
	TheInput:AddKeyUpHandler(Key, function()
		if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if self.inst:HasTag("act_holding") then
				if TheWorld.ismastersim then
					BufferedAction(self.inst, Target, ACTIONS[string.upper(Stop)]):Do()
				else
					SendModRPCToServer(MOD_RPC[self.inst.prefab][Stop], arg)
				end
				self.inst:RemoveTag("act_holding")
			end
		end
	end)
end

function GenshinKey:Event(Key, Press, Hold, Target, arg)
	TheInput:AddKeyDownHandler(Key, function()
		if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if not self.inst:HasTag("hold_event") then
				self.inst:AddTag("act_event")
				self.inst:DoTaskInTime(0.3, function()
					self.inst:RemoveTag("act_event")
					self.inst:AddTag("hold_event")
				end)
			end
		end
	end)
	TheInput:AddKeyUpHandler(Key, function()
		if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if self.inst:HasTag("act_event") then
				if TheWorld.ismastersim then
					BufferedAction(self.inst, Target, ACTIONS[string.upper(Press)]):Do()
				else
					SendModRPCToServer(MOD_RPC[self.inst.prefab][Press], arg)
				end
				self.inst:DoTaskInTime(0.3, function() self.inst:RemoveTag("hold_event") end)
			else
				if TheWorld.ismastersim then
					BufferedAction(self.inst, Target, ACTIONS[string.upper(Hold)]):Do()
				else
					SendModRPCToServer(MOD_RPC[self.inst.prefab][Hold], arg)
				end
				self.inst:RemoveTag("hold_event")
			end
		end
	end)
end

return GenshinKey