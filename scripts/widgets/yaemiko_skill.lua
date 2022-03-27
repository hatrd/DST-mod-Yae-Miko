--inst.ecnt
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local  yaemiko_skill = Class(Widget, function(self, owner)
	Widget._ctor(self, "yaemiko_skill")
	self.owner = owner


	self:SetHAnchor(2)
	self:SetVAnchor(2)
	self:SetPosition(-270, 139, 0)
	self:SetScale(0.3, 0.3, 0.3)


	self.yaemiko_skill_0 = self:AddChild(Image("images/skills/yaemiko_skill_0.xml", "yaemiko_skill_0.tex"))
	self.yaemiko_skill_1 = self:AddChild(Image("images/skills/yaemiko_skill_1.xml", "yaemiko_skill_1.tex"))
	self.yaemiko_skill_2 = self:AddChild(Image("images/skills/yaemiko_skill_2.xml", "yaemiko_skill_2.tex"))
	self.yaemiko_skill_3 = self:AddChild(Image("images/skills/yaemiko_skill_3.xml", "yaemiko_skill_3.tex"))
	-- self.skillcd1 = self:AddChild(Text(BODYTEXTFONT, 60))
	-- self.skillcd1:SetHAlign(ANCHOR_MIDDLE)
	-- self.skillcd1:MoveToFront()

	-- self.skillcd2 = self:AddChild(Text(BODYTEXTFONT, 60))
	-- self.skillcd2:SetHAlign(ANCHOR_MIDDLE)
	-- self.skillcd2:MoveToFront()

	self:StartUpdating()
end)

function yaemiko_skill:OnUpdate(dt)
	-- self.skillcd1:SetString(self.owner._yaemiko_e1:value())
	-- self.skillcd2:SetString(self.owner._yaemiko_e2:value())
  -- print("e可用次数：",self.owner.components.yaemiko_skill.ecnt)
  
	if self.owner.components.yaemiko_skill.ecnt then
    if self.owner.components.yaemiko_skill.ecnt==3 then
      self.yaemiko_skill_3:Show()
      self.yaemiko_skill_2:Hide()
    elseif self.owner.components.yaemiko_skill.ecnt==2 then
      self.yaemiko_skill_3:Hide()
      self.yaemiko_skill_2:Show()
      self.yaemiko_skill_1:Hide()
    elseif self.owner.components.yaemiko_skill.ecnt==1 then
      self.yaemiko_skill_2:Hide()
      self.yaemiko_skill_1:Show()
      self.yaemiko_skill_0:Hide()
    elseif self.owner.components.yaemiko_skill.ecnt==0 then
      self.yaemiko_skill_1:Hide()
      self.yaemiko_skill_0:Show()    
    end
  end
	-- if self.owner:HasTag("playerghost") then

	-- 	self.yaemiko_skill_0:Hide()
	-- 	self.yaemiko_skill_1:Hide()
	-- 	self.yaemiko_skill_2:Hide()
	-- 	self.yaemiko_skill_3:Hide()

  -- elseif self.owner.components.yaemiko_skill.ecnt then
	-- 	if self.owner.components.yaemiko_skill.ecnt==3 then
	-- 		self.yaemiko_skill_3:Show()
  --     self.yaemiko_skill_2:Hide()
	-- 	elseif self.owner.components.yaemiko_skill.ecnt==2
  --     -- self.skillcd1:Hide()
	-- 		-- self.skillcd2:Show()
	-- 		-- self.yaemiko_skill_0:Hide()
	-- 		self.yaemiko_skill_2:Show()
	-- 		self.yaemiko_skill_3:Hide()
  --   elseif self.owner.components.yaemiko_skill.ecnt==1
  --     -- self.skillcd1:Hide()
	-- 		-- self.skillcd2:Show()
	-- 		-- self.yaemiko_skill_0:Hide()
	-- 		self.yaemiko_skill_1:Show()
	-- 		self.yaemiko_skill_2:Hide()
  --   elseif self.owner.components.yaemiko_skill.ecnt==0
  --     self.yaemiko_skill_0:Show()
	-- 		self.yaemiko_skill_1:Hide()
	-- 	end
	-- end


end

return yaemiko_skill