PrefabFiles = {
	"yaemiko",
	"yaemiko_none",
  "yushou",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/yaemiko.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/yaemiko.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/yaemiko.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/yaemiko.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/yaemiko_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/yaemiko_silho.xml" ),

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

    
	Asset( "IMAGE", "images/hud/paimon.tex" ),
	Asset( "ATLAS", "images/hud/paimon.xml" ),

}

AddMinimapAtlas("images/map_icons/yaemiko.xml")


--环境初始化
GLOBAL.setmetatable(env, {__index = function(t,k) return GLOBAL.rawget(GLOBAL,k) end})


-- The character select screen lines
STRINGS.CHARACTER_TITLES.yaemiko = "屑狐狸"
STRINGS.CHARACTER_NAMES.yaemiko = "八重神子"
STRINGS.CHARACTER_DESCRIPTIONS.yaemiko = "重生，然后化身八重宫司大人。\n想得美哦。"
STRINGS.CHARACTER_QUOTES.yaemiko = "\"呜呜呜呜，好可怜呐\""
STRINGS.CHARACTER_SURVIVABILITY.yaemiko = "严峻"

-- Custom speech strings
STRINGS.CHARACTERS.YAEMIKO = require "speech_wilson"

-- The character's name as appears in-game 
STRINGS.NAMES.YAEMIKO = "Yae Miko"
STRINGS.SKIN_NAMES.yaemiko_none = "Yae Miko"

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
--添加御守图片
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.yushou = {
	atlas = "images/inventoryimages/yushou.xml",
	image = "yushou.tex"
}

--添加合成
local yaemikotab = AddRecipeTab(STRINGS.NAMES.YAEMIKO, 88, "images/hud/paimon.xml", "paimon.tex", "yaemiko")
AddRecipe("yushou",{Ingredient("papyrus", 2),Ingredient("boards", 1),},
yaemikotab, TECH.NONE, nil, nil, nil, 1, "yaemiko", "images/inventoryimages/yushou.xml")



-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("yaemiko", "FEMALE", skin_modes)
