name = "Yae Miko"
description = [[
Genshin Impact character.
Press "Z" to use ELemental Skill.
Press "X" to use Elemental Burst.
]]
author = "NaNaN & SekkaSKS"
version = "2.0.2"
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


local keys = {"B","C","G","H","J","K","L","N","O","R","T","V","X","Z","LAlt","RAlt","LCtrl","RCtrl","LShift","RShift"}
local list = {}
local string = ""
for i = 1, #keys do
	list[i] = {description = "Key "..string.upper(keys[i]), data = "KEY_"..string.upper(keys[i])}
end

configuration_options = {
	{
		name = "language",
		label = "Language",
		hover = "",
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
		label = "Energy Recharge 充能效率",
		hover = "",
		options = {
			{description = "100%", data = 1},
			{description = "150%", data = 1.5},
			{description = "200%", data = 2},
		},
		default = 1
	},
	{
		name="yaeyubi_limit",
		label="Yubi Strengthen 御币强化",
		options={
			{description="No Limit 无限制",data=0},
			{description="Can't 不能强化",data=1},
			{description="3",data=3},
			{description="5",data=5},
			{description="10",data=10},
			{description="20",data=20},
		},
		default=5
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
		hover = "",
		options = list,
		default = "KEY_Z",	
	},
	{
		name = "burst",
		label = "Elemental Burst 元素爆发",
		hover = "",
		options = list,
		default = "KEY_X",	
	},
}