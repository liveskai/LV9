global function OnWeaponPrimaryAttack_DoNothing

global function Shift_Core_Init
#if SERVER
global function Shift_Core_UseMeter
#endif

global function OnCoreCharge_Shift_Core
global function OnCoreChargeEnd_Shift_Core
global function OnAbilityStart_Shift_Core

void function Shift_Core_Init()
{
	RegisterSignal( "RestoreWeapon" )
	#if SERVER
	AddCallback_OnPlayerKilled( SwordCore_OnPlayedOrNPCKilled )
	AddCallback_OnNPCKilled( SwordCore_OnPlayedOrNPCKilled )
	#endif
}

#if SERVER
void function SwordCore_OnPlayedOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsTitan() )
		return

	if ( !attacker.IsPlayer() || !PlayerHasPassive( attacker, ePassives.PAS_SHIFT_CORE ) )
		return

	entity soul = attacker.GetTitanSoul()
	if ( !IsValid( soul ) || !SoulHasPassive( soul, ePassives.PAS_RONIN_SWORDCORE ) )
		return

	float curTime = Time()
	float highlanderBonus = 8.0
	float remainingTime = highlanderBonus + soul.GetCoreChargeExpireTime() - curTime
	float duration = soul.GetCoreUseDuration()
	float coreFrac = min( 1.0, remainingTime / duration )
	//Defensive fix for this sometimes resulting in a negative value.
	if ( coreFrac > 0.0 )
	{
		soul.SetTitanSoulNetFloat( "coreExpireFrac", coreFrac )
		soul.SetTitanSoulNetFloatOverTime( "coreExpireFrac", 0.0, remainingTime )
		soul.SetCoreChargeExpireTime( remainingTime + curTime )
	}
}
#endif

var function OnWeaponPrimaryAttack_DoNothing( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

bool function OnCoreCharge_Shift_Core( entity weapon )
{
	if ( !OnAbilityCharge_TitanCore( weapon ) )
		return false

#if SERVER
	entity owner = weapon.GetWeaponOwner()
	if ( weapon.HasMod( "dash_core" ) )
	{
		// From DashCoreThink, Sound Effects
		if ( owner.IsPlayer() )
		{
			EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Legion_Smart_Core_Activated_1P" )
			EmitSoundOnEntityOnlyToPlayer( owner, owner, "Titan_Legion_Smart_Core_ActiveLoop_1P" )
			EmitSoundOnEntityExceptToPlayer( owner, owner, "Titan_Legion_Smart_Core_Activated_3P" )
		}
		else // npc
			EmitSoundOnEntity( owner, "Titan_Legion_Smart_Core_Activated_3P" )
	}
	else
	{
		// Normal Shift Core
		string swordCoreSound_1p
		string swordCoreSound_3p
		if ( weapon.HasMod( "fd_duration" ) )
		{
			swordCoreSound_1p = "Titan_Ronin_Sword_Core_Activated_Upgraded_1P"
			swordCoreSound_3p = "Titan_Ronin_Sword_Core_Activated_Upgraded_3P"
		}
		else
		{
			swordCoreSound_1p = "Titan_Ronin_Sword_Core_Activated_1P"
			swordCoreSound_3p = "Titan_Ronin_Sword_Core_Activated_3P"
		}
		if ( owner.IsPlayer() )
		{
			owner.HolsterWeapon() //TODO: Look into rewriting this so it works with HolsterAndDisableWeapons()
			thread RestoreWeapon( owner, weapon )
			EmitSoundOnEntityOnlyToPlayer( owner, owner, swordCoreSound_1p )
			EmitSoundOnEntityExceptToPlayer( owner, owner, swordCoreSound_3p )
		}
		else
		{
			EmitSoundOnEntity( weapon, swordCoreSound_3p )
		}
	}
#endif

	return true
}

void function OnCoreChargeEnd_Shift_Core( entity weapon )
{
	#if SERVER
	entity owner = weapon.GetWeaponOwner()
	OnAbilityChargeEnd_TitanCore( weapon )
	// Pass Other Process
	if ( weapon.HasMod( "dash_core" ) )
		return

	if ( IsValid( owner ) && owner.IsPlayer() )
		owner.DeployWeapon() //TODO: Look into rewriting this so it works with HolsterAndDisableWeapons()
	else if ( !IsValid( owner ) )
		Signal( weapon, "RestoreWeapon" )
	#endif
}

#if SERVER
void function RestoreWeapon( entity owner, entity weapon )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "CoreBegin" )

	WaitSignal( weapon, "RestoreWeapon", "OnDestroy" )

	if ( IsValid( owner ) && owner.IsPlayer() )
	{
		owner.DeployWeapon() //TODO: Look into rewriting this so it works with DeployAndEnableWeapons()
	}
}
#endif

var function OnAbilityStart_Shift_Core( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnAbilityStart_TitanCore( weapon )

	entity owner = weapon.GetWeaponOwner()

	if ( !owner.IsTitan() )
		return 0

	if ( !IsValid( owner ) )
		return

	entity offhandWeapon = owner.GetOffhandWeapon( OFFHAND_MELEE )
	if ( !IsValid( offhandWeapon ) )
		return 0

	// if ( offhandWeapon.GetWeaponClassName() != "melee_titan_sword" )
	// 	return 0

#if SERVER
	if ( !weapon.HasMod( "tcp_arc_wave" ) )
	{
		if ( owner.IsPlayer() )
		{
			if ( weapon.HasMod( "dash_core" ) )
			{
				owner.Server_SetDodgePower( 100.0 )
				owner.SetPowerRegenRateScale( 40.0 )
				owner.SetDodgePowerDelayScale( 0.1 )
				GivePassive( owner, ePassives.PAS_FUSION_CORE )
			}
			else
			{
				owner.Server_SetDodgePower( 100.0 )
				owner.SetPowerRegenRateScale( 6.5 )
				GivePassive( owner, ePassives.PAS_FUSION_CORE )
				GivePassive( owner, ePassives.PAS_SHIFT_CORE )
			}
		}

		entity soul = owner.GetTitanSoul()
		if ( soul != null )
		{
			entity titan = soul.GetTitan()

			if ( titan.IsNPC() )
			{
				if ( weapon.HasMod( "dash_core" ) )
					titan.SetAISettings( "npc_titan_stryder_rocketeer_dash_core" )
				else
				{
					titan.SetAISettings( "npc_titan_stryder_leadwall_shift_core" )
					titan.EnableNPCMoveFlag( NPCMF_PREFER_SPRINT )
					titan.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, false )
					AddAnimEvent( titan, "shift_core_use_meter", Shift_Core_UseMeter_NPC )
				}
			}

			if ( !weapon.HasMod( "dash_core" ) )
			{
				titan.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "super_charged" )

				if ( IsSingleplayer() )
				{
					titan.GetOffhandWeapon( OFFHAND_MELEE ).AddMod( "super_charged_SP" )
				}

				titan.SetActiveWeaponByName( "melee_titan_sword" )

				entity mainWeapon = titan.GetMainWeapons()[0]
				mainWeapon.AllowUse( false )
			}
		}
	}

	if ( weapon.HasMod( "tcp_arc_wave" ) )
	{
		weapon.AddMod( "triple_wave" )
		OnWeaponPrimaryAttack_titanweapon_arc_wave( weapon, attackParams )
		weapon.RemoveMod( "triple_wave" )
	}
	float delay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
	if ( weapon.HasMod( "dash_core" ) )
	{
		ScreenFade( owner, 0, 0, 100, 10, 0.1, delay, FFADE_OUT | FFADE_PURGE )
		thread Dash_Core_End( weapon, owner, delay )
	}
	else
		thread Shift_Core_End( weapon, owner, delay )
#endif

	return 1
}

#if SERVER
void function Dash_Core_End( entity weapon, entity player, float delay )
{
	weapon.EndSignal( "OnDestroy" )

	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )
	if ( IsAlive( player ) )
	{
		player.EndSignal( "OnDeath" )
		player.EndSignal( "TitanEjectionStarted" )
		player.EndSignal( "DisembarkingTitan" )
		player.EndSignal( "OnSyncedMelee" )
	}
	else if ( player.IsNPC() )
	{
		return // no need to do this if the npc is dead
	}

	OnThreadEnd(
	function() : ( weapon, player )
		{
			OnAbilityEnd_Dash_Core( weapon, player )

			if ( IsValid( player ) )
			{
				entity soul = player.GetTitanSoul()
				if ( soul != null )
					CleanupCoreEffect( soul )
			}
		}
	)

	wait delay
}

void function OnAbilityEnd_Dash_Core( entity weapon, entity player )
{
	OnAbilityEnd_TitanCore( weapon )

	EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Legion_Smart_Core_Deactivated_1P" )

	entity soul = player.GetTitanSoul()

	if ( player.IsPlayer() )
	{
		int conversationID = GetConversationIndex( "swordCoreOffline" )
		Remote_CallFunction_Replay( player, "ServerCallback_PlayTitanConversation", conversationID )
		ScreenFade( player, 0, 0, 0, 0, 0.1, 0.1, FFADE_OUT | FFADE_PURGE )
		TakePassive( player, ePassives.PAS_FUSION_CORE )
		player.SetPowerRegenRateScale( 1.0 )
		player.SetDodgePowerDelayScale( 1.0 )
		soul = GetSoulFromPlayer( player )
	}

	CoreDeactivate( player, weapon )

	if ( soul != null )
	{
		entity titan = soul.GetTitan()

		if ( titan.IsNPC() )
		{
			string settings = GetSpawnAISettings( titan )
			if ( settings != "" )
				titan.SetAISettings( settings )
		}
	}
}

void function Shift_Core_End( entity weapon, entity player, float delay )
{
	weapon.EndSignal( "OnDestroy" )

	if ( player.IsNPC() && !IsAlive( player ) )
		return

	player.EndSignal( "OnDestroy" )
	if ( IsAlive( player ) )
		player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "DisembarkingTitan" )
	player.EndSignal( "OnSyncedMelee" )
	player.EndSignal( "InventoryChanged" )

	OnThreadEnd(
	function() : ( weapon, player )
		{
			OnAbilityEnd_Shift_Core( weapon, player )

			if ( IsValid( player ) )
			{
				entity soul = player.GetTitanSoul()
				if ( soul != null )
					CleanupCoreEffect( soul )
			}
		}
	)

	entity soul = player.GetTitanSoul()
	if ( soul == null )
		return

	while ( 1 )
	{
		if ( soul.GetCoreChargeExpireTime() <= Time() )
			break;
		wait 0.1
	}
}

void function OnAbilityEnd_Shift_Core( entity weapon, entity player )
{
	OnAbilityEnd_TitanCore( weapon )

	if ( player.IsPlayer() )
	{
		player.SetPowerRegenRateScale( 1.0 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Ronin_Sword_Core_Deactivated_1P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "Titan_Ronin_Sword_Core_Deactivated_3P" )
		int conversationID = GetConversationIndex( "swordCoreOffline" )
		Remote_CallFunction_Replay( player, "ServerCallback_PlayTitanConversation", conversationID )
	}
	else
	{
		DeleteAnimEvent( player, "shift_core_use_meter" )
		EmitSoundOnEntity( player, "Titan_Ronin_Sword_Core_Deactivated_3P" )
	}

	RestorePlayerWeapons( player )
}

void function RestorePlayerWeapons( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( player.IsNPC() && !IsAlive( player ) )
		return // no need to fix up dead NPCs

	entity soul = player.GetTitanSoul()

	if ( player.IsPlayer() )
	{
		TakePassive( player, ePassives.PAS_FUSION_CORE )
		TakePassive( player, ePassives.PAS_SHIFT_CORE )

		soul = GetSoulFromPlayer( player )
	}

	if ( soul != null )
	{
		entity titan = soul.GetTitan()

		entity meleeWeapon = titan.GetOffhandWeapon( OFFHAND_MELEE )
		if ( IsValid( meleeWeapon ) )
		{
			meleeWeapon.RemoveMod( "super_charged" )
			if ( IsSingleplayer() )
			{
				meleeWeapon.RemoveMod( "super_charged_SP" )
			}
		}

		array<entity> mainWeapons = titan.GetMainWeapons()
		if ( mainWeapons.len() > 0 )
		{
			entity mainWeapon = titan.GetMainWeapons()[0]
			mainWeapon.AllowUse( true )
		}

		if ( titan.IsNPC() )
		{
			string settings = GetSpawnAISettings( titan )
			if ( settings != "" )
				titan.SetAISettings( settings )

			titan.DisableNPCMoveFlag( NPCMF_PREFER_SPRINT )
			titan.SetCapabilityFlag( bits_CAP_MOVE_SHOOT, true )
		}
	}
}

void function Shift_Core_UseMeter( entity player )
{
	if ( IsMultiplayer() )
		return

	entity soul = player.GetTitanSoul()
	float curTime = Time()
	float remainingTime = soul.GetCoreChargeExpireTime() - curTime

	if ( remainingTime > 0 )
	{
		const float USE_TIME = 5

		remainingTime = max( remainingTime - USE_TIME, 0 )
		float startTime = soul.GetCoreChargeStartTime()
		float duration = soul.GetCoreUseDuration()

		soul.SetTitanSoulNetFloat( "coreExpireFrac", remainingTime / duration )
		soul.SetTitanSoulNetFloatOverTime( "coreExpireFrac", 0.0, remainingTime )
		soul.SetCoreChargeExpireTime( remainingTime + curTime )
	}
}

void function Shift_Core_UseMeter_NPC( entity npc )
{
	Shift_Core_UseMeter( npc )
}
#endif