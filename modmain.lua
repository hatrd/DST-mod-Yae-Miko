PrefabFiles = {
	"yaemiko",
	"yaemiko_none",
  	"yaemiko_fx",
	"yaemiko_lightning",
  	"yushou",
	"yaeyubi",
	"yubi_projectile",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/yaemiko.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/yaemiko.xml" ),

    Asset( "IMAGE", "bigportraits/yaemiko.tex" ),
    Asset( "ATLAS", "bigportraits/yaemiko.xml" ),
	
	Asset( "IMAGE", "images/map_icons/yaemiko.tex" ),
	Asset( "ATLAS", "images/map_icons/yaemiko.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_yaemiko.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_yaemiko.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_yaemiko.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_yaemiko.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_yaemiko.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_yaemiko.xml" ),
	
	Asset( "IMAGE", "images/names_yaemiko.tex" ),
    Asset( "ATLAS", "images/names_yaemiko.xml" ),
	
	Asset( "IMAGE", "images/names_gold_yaemiko.tex" ),
    Asset( "ATLAS", "images/names_gold_yaemiko.xml" ),

	Asset( "IMAGE", "images/skills/yaemiko_skill_0.tex" ),
	Asset( "ATLAS", "images/skills/yaemiko_skill_0.xml" ),

	Asset( "IMAGE", "images/skills/yaemiko_skill_1.tex" ),
	Asset( "ATLAS", "images/skills/yaemiko_skill_1.xml" ),

	Asset( "IMAGE", "images/skills/yaemiko_skill_2.tex" ),
	Asset( "ATLAS", "images/skills/yaemiko_skill_2.xml" ),
  
	Asset( "IMAGE", "images/skills/yaemiko_skill_3.tex" ),
	Asset( "ATLAS", "images/skills/yaemiko_skill_3.xml" ),
  
	Asset( "ANIM", "anim/yaemiko_energy.zip" ),

    Asset("SOUNDPACKAGE", "sound/yaemiko_sfx.fev"),
	Asset("SOUND", "sound/yaemiko_sfx.fsb"),
}

AddMinimapAtlas("images/map_icons/yaemiko.xml")

--环境初始化
GLOBAL.setmetatable(env, {__index = function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local language = GetModConfigData("lang")
if language == 0 then
	-- if STRINGS.UI.OPTIONS.LANGUAGES == "Ngôn ngữ" then
	-- 	language = 3
	if STRINGS.UI.OPTIONS.LANGUAGES == "语言" then
		TUNING.LANG = 2
	else -- default fall back as English
		TUNING.LANG = 1
	end
end

-- The character select screen lines
if TUNING.LANG == 1 then
	STRINGS.CHARACTER_TITLES.yaemiko = "Smug fox"
	STRINGS.CHARACTER_NAMES.yaemiko = "Yae Miko"
	STRINGS.CHARACTER_DESCRIPTIONS.yaemiko = "Reborn as Guuji Yae..\nIn your dreams."
	STRINGS.CHARACTER_QUOTES.yaemiko = "\"crying and ranting and raving.\""
	STRINGS.CHARACTER_SURVIVABILITY.yaemiko = "Grim"
else
	STRINGS.CHARACTER_TITLES.yaemiko = "屑狐狸"
	STRINGS.CHARACTER_NAMES.yaemiko = "八重神子"
	STRINGS.CHARACTER_DESCRIPTIONS.yaemiko = "重生，然后化身八重宫司大人。\n想得美哦。"
	STRINGS.CHARACTER_QUOTES.yaemiko = "\"呜呜呜呜，好可怜呐\""
	STRINGS.CHARACTER_SURVIVABILITY.yaemiko = "严峻"
end

-- Custom speech strings
STRINGS.CHARACTERS.YAEMIKO = require "speech_wilson"

-- 游戏内名称
STRINGS.NAMES.YAEMIKO = "Yae Miko"
STRINGS.SKIN_NAMES.yaemiko_none = "Yae Miko"

--设置全局TUNING
TUNING.YAEMIKO_RECHARGE = GetModConfigData("er")
TUNING.YAEMIKO_CHARGE_KEY = GetModConfigData("charge")
TUNING.YAEMIKO_SKILL_KEY = GetModConfigData("skill")
TUNING.YAEMIKO_BURST_KEY = GetModConfigData("burst")

TUNING.YAEYUBI_REFINE_LIMIT=GetModConfigData("yaeyubi_limit")
  -- 每级（相较于起始倍率）对伤害的提升的倍率。1.0为原倍率。由于原倍率偏高，默认为0.5倍
  -- 例如若为0.5，则每级对伤害的提升为原倍率的一半，若为2，则每级对伤害的提升为原倍率的2倍。
TUNING.YAEMIKO_SKILL_LEVELING_MULTIPLY = GetModConfigData("yaemiko_skill_leveling_multiply_config")

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

--添加御守、御币图片
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.yushou = {
	atlas = "images/inventoryimages/yushou.xml",
	image = "yushou.tex"
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.yaeyubi = {
	atlas = "images/inventoryimages/yaeyubi.xml",
	image = "yaeyubi.tex"
}
--技能图标
local energy = require("widgets/yaemiko_energy")
AddClassPostConstruct("widgets/controls", function(self)
	if self.owner and self.owner:HasTag("yaemiko") then
		self.status:AddChild(energy(self.owner))
	end
end)

local skill = require("widgets/yaemiko_skill")
AddClassPostConstruct("widgets/controls", function(self)
	if self.owner and self.owner:HasTag("yaemiko") then
		self.status:AddChild(skill(self.owner))
	end
end)

--添加合成
local yaemikotab = AddRecipeTab(STRINGS.NAMES.YAEMIKO, 88, nil, nil, "yaemiko")
AddRecipe("yushou",{Ingredient("papyrus", 2),Ingredient("boards", 1),},
yaemikotab, TECH.NONE, nil, nil, nil, 1, "yaemiko", "images/inventoryimages/yushou.xml")
AddRecipe("yaeyubi",{Ingredient("papyrus", 2),Ingredient("purplegem", 1),Ingredient("twigs", 1),},
yaemikotab, TECH.NONE, nil, nil, nil, 1, "yaemiko", "images/inventoryimages/yaeyubi.xml")

---------------技能
AddModRPCHandler("yaemiko", "yaemiko_burst", function(inst) inst:PushEvent("yaemiko_burst") end)
AddAction("YAEMIKO_BURST", "Elemental Burst", function(act)
	act.doer:PushEvent("yaemiko_burst")
	return true
end)

AddModRPCHandler("yaemiko", "yaemiko_skill", function(inst) inst:PushEvent("yaemiko_skill") end)
AddAction("YAEMIKO_SKILL", "Elemental Skill", function(act)
	act.doer:PushEvent("yaemiko_skill")
	return true
end)

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("yaemiko", "FEMALE", skin_modes)

modimport("scripts/yaemiko_postinit.lua")