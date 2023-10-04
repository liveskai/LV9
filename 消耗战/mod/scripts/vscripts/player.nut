global function player_Init

void function player_Init()
{
	AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	AddCallback_OnPlayerGetsNewPilotLoadout( OnPlayerChangeLoadout)
}
void function OnPlayerRespawned( entity player )
{

	player.TakeWeaponNow( player.GetMainWeapons()[1].GetWeaponClassName())
	player.GiveWeapon( "mp_weapon_shotgun_doublebarrel_tfo",["pas_run_and_gun","pas_fast_ads","pas_fast_swap"])

	player.GetMainWeapons()
	{
		entity weapon = player.GetMainWeapons()[0]
		array<string> mods = weapon.GetMods()
		mods.append( "extended_ammo" )
		mods.append( "pas_fast_reload" )
		mods.append( "pas_fast_ads" )
		mods.append( "pas_fast_swap" )
		mods.append( "pas_run_and_gun" )
		mods.append( "tactical_cdr_on_kill" )
		weapon.SetMods( mods )
		
		weapon = player.GetMainWeapons()[2]
		mods = weapon.GetMods()
		mods.append( "extended_ammo" )
		mods.append( "pas_fast_reload" )
		mods.append( "pas_fast_ads" )
		mods.append( "pas_fast_swap" )
		mods.append( "pas_run_and_gun" )
		mods.append( "tactical_cdr_on_kill" )
		weapon.SetMods( mods )
	}
	
	entity weapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
	array<string> mods = weapon.GetMods()
	mods.append( "pas_ordnance_pack" )
	weapon.SetMods( mods )
	
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_arc_launcher")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		weapon.SetMods( mods )
	}	
		
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_defender")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		weapon.SetMods( mods )
	}	
	
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_mgl")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		mods.append( "ar_trajectory" )
		weapon.SetMods( mods )
	}	
	
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_rocket_launcher")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		weapon.SetMods( mods )
	}
	
	if (player.GetMainWeapons()[0].GetWeaponClassName()== "mp_weapon_sniper" ||player.GetMainWeapons()[0].GetWeaponClassName()=="mp_weapon_wingman_n"||player.GetMainWeapons()[0].GetWeaponClassName()=="mp_weapon_wingman_n")
	{
		entity weapon = player.GetMainWeapons()[0]
		array<string> mods = weapon.GetMods()
		mods.append( "ricochet" )
		weapon.SetMods( mods )
	}	
}


void function OnPlayerChangeLoadout( entity player , PilotLoadoutDef p)
{

	player.TakeWeaponNow( player.GetMainWeapons()[1].GetWeaponClassName())
	player.GiveWeapon( "mp_weapon_shotgun_doublebarrel_tfo",["pas_run_and_gun","pas_fast_ads","pas_fast_swap"])

	player.GetMainWeapons()
	{
		entity weapon = player.GetMainWeapons()[0]
		array<string> mods = weapon.GetMods()
		mods.append( "extended_ammo" )
		mods.append( "pas_fast_reload" )
		mods.append( "pas_fast_ads" )
		mods.append( "pas_fast_swap" )
		mods.append( "pas_run_and_gun" )
		mods.append( "tactical_cdr_on_kill" )
		weapon.SetMods( mods )
		
		weapon = player.GetMainWeapons()[2]
		mods = weapon.GetMods()
		mods.append( "extended_ammo" )
		mods.append( "pas_fast_reload" )
		mods.append( "pas_fast_ads" )
		mods.append( "pas_fast_swap" )
		mods.append( "pas_run_and_gun" )
		mods.append( "tactical_cdr_on_kill" )
		weapon.SetMods( mods )
	}
	
	entity weapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
	array<string> mods = weapon.GetMods()
	mods.append( "pas_ordnance_pack" )
	weapon.SetMods( mods )
	
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_arc_launcher")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		weapon.SetMods( mods )
	}	
		
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_defender")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		weapon.SetMods( mods )
	}	
	
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_mgl")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		mods.append( "ar_trajectory" )
		weapon.SetMods( mods )
	}	
	
	if (player.GetMainWeapons()[2].GetWeaponClassName()=="mp_weapon_rocket_launcher")
	{
		entity weapon = player.GetMainWeapons()[2]
		array<string> mods = weapon.GetMods()
		mods.append( "at_unlimited_ammo" )
		mods.append( "fast_lock" )
		weapon.SetMods( mods )
	}
	
	if (player.GetMainWeapons()[0].GetWeaponClassName()== "mp_weapon_sniper" ||player.GetMainWeapons()[0].GetWeaponClassName()=="mp_weapon_wingman_n"||player.GetMainWeapons()[0].GetWeaponClassName()=="mp_weapon_wingman_n")
	{
		entity weapon = player.GetMainWeapons()[0]
		array<string> mods = weapon.GetMods()
		mods.append( "ricochet" )
		weapon.SetMods( mods )
	}	
}