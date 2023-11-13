global function player_Init

void function player_Init()
{
	AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	AddCallback_OnPlayerGetsNewPilotLoadout( OnPlayerChangeLoadout)
}
void function OnPlayerRespawned( entity player )
{
	player.TakeWeaponNow( player.GetMainWeapons()[1].GetWeaponClassName())
	player.GiveWeapon( "mp_weapon_shotgun_doublebarrel_tfo")
	
	foreach (entity weapon in player.GetMainWeapons())
	{
		weapon.AddMod( "extended_ammo" )
		weapon.AddMod( "pas_fast_reload" )
		weapon.AddMod( "pas_fast_ads" )
		weapon.AddMod( "pas_fast_swap" )
		weapon.AddMod( "tactical_cdr_on_kill" )	
		weapon.AddMod( "pas_run_and_gun" )
		weapon.AddMod( "ricochet" )//弹射子弹
		weapon.AddMod( "at_unlimited_ammo" )//反泰坦无限子弹
		weapon.AddMod( "ar_trajectory" )//磁能榴弹炮抛物线
	}
	
	player.GetOffhandWeapon( OFFHAND_RIGHT ).AddMod( "pas_ordnance_pack" )
}

void function OnPlayerChangeLoadout( entity player , PilotLoadoutDef p)
{
	player.TakeWeaponNow( player.GetMainWeapons()[1].GetWeaponClassName())
	player.GiveWeapon( "mp_weapon_shotgun_doublebarrel_tfo")
	
	foreach (entity weapon in player.GetMainWeapons())
	{
		weapon.AddMod( "extended_ammo" )
		weapon.AddMod( "pas_fast_reload" )
		weapon.AddMod( "pas_fast_ads" )
		weapon.AddMod( "pas_fast_swap" )
		weapon.AddMod( "tactical_cdr_on_kill" )	
		weapon.AddMod( "pas_run_and_gun" )
		weapon.AddMod( "ricochet" )//弹射子弹
		weapon.AddMod( "at_unlimited_ammo" )//反泰坦无限子弹
		weapon.AddMod( "ar_trajectory" )//磁能榴弹炮抛物线
	}
	
	player.GetOffhandWeapon( OFFHAND_RIGHT ).AddMod( "pas_ordnance_pack" )
}
