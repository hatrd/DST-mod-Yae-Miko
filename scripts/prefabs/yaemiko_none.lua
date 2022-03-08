local assets =
{
	Asset( "ANIM", "anim/yaemiko.zip" ),
	Asset( "ANIM", "anim/ghost_yaemiko_build.zip" ),
}

local skins =
{
	normal_skin = "yaemiko",
	ghost_skin = "ghost_yaemiko_build",
}

return CreatePrefabSkin("yaemiko_none",
{
	base_prefab = "yaemiko",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"YAEMIKO", "CHARACTER", "BASE"},
	build_name_override = "yaemiko",
	rarity = "Character",
})