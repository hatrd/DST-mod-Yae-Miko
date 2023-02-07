local GenshinKey = Class(function(self, inst)
	self.inst = inst
end)

function GenshinKey:Press(Key, Action, target)
	TheInput:AddKeyDownHandler(Key, function()
		if self.inst == ThePlayer and TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			SendModRPCToServer(MOD_RPC[self.inst.prefab][Action], target)
		end
	end)
end

function GenshinKey:Charge(Key, Start, Stop, target)
	TheInput:AddKeyDownHandler(Key, function()
		if self.inst == ThePlayer and TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if not self.ishold then
				SendModRPCToServer(MOD_RPC[self.inst.prefab][Start], target)
				self.ishold = true
				self.inst:AddTag("charging")
			end
		end
	end)
	TheInput:AddKeyUpHandler(Key, function()
		if self.inst == ThePlayer and TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if self.ishold then
				SendModRPCToServer(MOD_RPC[self.inst.prefab][Stop], target)
				self.ishold = false
				self.inst:RemoveTag("charging")
			end
		end
	end)
end

function GenshinKey:Event(Key, Press, Hold, target)
	TheInput:AddKeyDownHandler(Key, function()
		if self.inst == ThePlayer and TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if not self.holding then
				self.pending = true
				self.holding = true
				self.inst:DoTaskInTime(0.6, function()
					if self.holding then
						SendModRPCToServer(MOD_RPC[self.inst.prefab][Hold], target)
					end
				end)
			end
		end
	end)
	TheInput:AddKeyUpHandler(Key, function()
		if self.inst == ThePlayer and TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if self.pending then
				SendModRPCToServer(MOD_RPC[self.inst.prefab][Press], target)
				self.pending = false
				if self.holding then
					self.holding = false
				end
			end
		end
	end)
end

return GenshinKey