name = "Yae Miko"
description = [[
Genshin Impact character.
Press "Z" to use ELemental Skill.
Press "X" to use Elemental Burst.
]]
author = "NaNaN & SekkaSKS"
version = "2.0.4"
forumthread = ""
api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
all_clients_require_mod = true 
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {"character",}


local keys = {"B","C","G","H","J","K","L","N","O","R","T","V","X","Z","LAlt","RAlt","LCtrl","RCtrl","LShift","RShift","E","Q"}
local list = {}
local string = ""
for i = 1, #keys do
	list[i] = {description = "Key "..string.upper(keys[i]), data = "KEY_"..string.upper(keys[i])}
end

configuration_options = {
	{
		name = "language",
		label = "Language  语言",
		hover = "In-game display language.\n游戏内显示语言。",
		options = {
			{description = "English", data = 1, hover = ""},
			{description = "中文", data = 2, hover = ""}
		},
		default = 2
	},
	{
		name = "Stats",
		hover = "",
		options={{description = "", data = 0}},
		default = 0
	},
	-- {
	-- 	name = "hp",
	-- 	label = "Health",
	-- 	hover = "",
	-- 	options = {
	-- 		{description = "140", data = 140},
	-- 		{description = "150", data = 150},
	-- 		{description = "200", data = 200},
	-- 		{description = "250", data = 250},
	-- 	},
	-- 	default = 140
	-- },
	{
		name = "er",
		label = "Recharge Rate 充能效率",
		hover = "Energy Recharge Rate.\n元素充能效率",
		options = {
			{description = "100%", data = 1},
			{description = "150%", data = 1.5},
			{description = "200%", data = 2},
		},
		default = 1
	},
	{
		name="yaeyubi_limit",
		hover="Gohei Refinement Level Limit, use Purple Gem to Refine.\n御币的精炼等阶限制，使用紫水晶精炼。\n",
		label="Gohei Refinement 御币强化",
		options={
			{description="Unlimited 无限制",data=2147483647,hover="Maximum Damage Unknown  最大伤害未知"},
			{description="Disabled 不能精炼",data=1,hover="Initital 20 Electric Damage  初始的20带电伤害"},
			{description="3",data=3,hover="Max of 30 Electric Damage  最高30带电伤害"},
			{description="5",data=5,hover="Max of 40 Electric Damage  最高40带电伤害"},
			{description="10",data=10,hover="Max of 65 Electric Damage  最高65带电伤害"},
			{description="20",data=20,hover="Max of 115 Electric Damage  最高115带电伤害"},
		},
		default=5
	},
	{
		name="yaemiko_skill_leveling_multiply_config",
		hover="Multiplier for talents leveling damaged increased, compared with original in Genshin.\n相比于原神的原数值，提升天赋等级对伤害的提高的倍率。",
		label="Talents Multiplier 天赋倍率",
		options={
			{description="0.0",data=0,hover="No Increase   没有提升"},
			{description="0.2",data=0.2,hover="DST is TOO EASY   非常简单"},
			{description="0.5",data=0.5,hover="Recommended   推荐倍率"},
			{description="0.8",data=0.8,hover="Want to relax   我想放松"},
			{description="1.0",data=1,hover="Just same as Genshin   原神联机版"},
			{description="1.4",data=1.4,hover="They are Overpowered!   队友超模了！"},
			{description="2.0",data=2,hover="Seriously?   轮椅人"},
		},
		default=0.5
	},
	{
		name = "Key",
		hover = "",
		options={{description = "", data = 0}},
		default = 0
	},
	{
		name = "skill",
		label = "Elemental Skill 元素战技",
		hover = "Keybinding for Elemental Skill.\n元素战技键位绑定。",
		options = list,
		default = "KEY_Z",	
	},
	{
		name = "burst",
		label = "Elemental Burst 元素爆发",
		hover = "Keybinding for Elemental Burst.\n元素爆发键位绑定。",
		options = list,
		default = "KEY_X",	
	},
}