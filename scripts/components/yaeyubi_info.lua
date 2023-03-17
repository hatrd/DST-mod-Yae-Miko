-- 御币信息类
local yaeyubi_info = Class(function(self, inst)
    self.inst = inst
    self.refine = 1
    self.damage = 20
    -- 1阶基础伤害，每阶精炼增加伤害
    -- 御币是电属性伤害，受1.5倍加成(潮湿目标2.5倍加成)，不建议面板伤害过高。技能伤害计算时会单独判断御币并乘上1.5的乘数
    self.basedamage = 20
    -- 每阶精炼的伤害提升，该数值正好使得满强化、6级天赋下的三阶杀生樱一下秒不掉蜘蛛，且伤害略逊于玻璃刀、暗影剑
    self.refineMultiply = 5
end,
nil,
{
})

function yaeyubi_info:OnSave()
    local data = {
        refine = self.refine,
        damage = self.damage
    }
    return data
end

function yaeyubi_info:OnLoad(data)
    self.refine = data.refine or 1
    self.damage = data.damage or 20
    -- 保险起见还原伤害
	self.inst.components.weapon:SetDamage(self.damage)
end

function yaeyubi_info:GetRefine()
    return self.refine
end

function yaeyubi_info:RefineDoDelta(delta)
    self.refine = self.refine + delta
    if self.inst.components.weapon then
        -- 目前想法是简单的线性伤害
        self.damage = self.basedamage + (self.refine - 1) * self.refineMultiply
        -- 更改伤害
		self.inst.components.weapon:SetDamage(self.damage)
    end
    self.inst:PushEvent("RefineYaeYubi")
end

return yaeyubi_info