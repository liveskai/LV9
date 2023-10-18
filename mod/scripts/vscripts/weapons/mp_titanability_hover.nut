global function MpTitanAbilityHover_Init
global function OnWeaponPrimaryAttack_TitanHover
const LERP_IN_FLOAT = 0.5

#if SERVER
global function NPC_OnWeaponPrimaryAttack_TitanHover
global function FlyerHovers
#endif

void function MpTitanAbilityHover_Init()
{
	PrecacheParticleSystem( $"P_xo_jet_fly_large" )
	PrecacheParticleSystem( $"P_xo_jet_fly_small" )
	
	RegisterSignal( "VTOLHoverBegin" )
}

var function OnWeaponPrimaryAttack_TitanHover( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity flyer = weapon.GetWeaponOwner()
	if ( !IsAlive( flyer ) )
		return

	if ( flyer.IsPlayer() )
		PlayerUsedOffhand( flyer, weapon )
	
	//ADDED
	const float DEFAULT_FLIGHT_TIME = 3 //飞行时间
	float fTime = GetCurrentPlaylistVarFloat("EF_FLIGHT_TIME", DEFAULT_FLIGHT_TIME)
	//END
	
	#if SERVER
		HoverSounds soundInfo
		soundInfo.liftoff_1p = "titan_flight_liftoff_1p"
		soundInfo.liftoff_3p = "titan_flight_liftoff_3p"
		soundInfo.hover_1p = "titan_flight_hover_1p"
		soundInfo.hover_3p = "titan_flight_hover_3p"
		soundInfo.descent_1p = "titan_flight_descent_1p"
		soundInfo.descent_3p = "titan_flight_descent_3p"
		soundInfo.landing_1p = "core_ability_land_1p"
		soundInfo.landing_3p = "core_ability_land_3p"
		float horizontalVelocity
		entity soul = flyer.GetTitanSoul()
		if ( IsValid( soul ) && SoulHasPassive( soul, ePassives.PAS_NORTHSTAR_FLIGHTCORE ) )
			horizontalVelocity = 350.0
		else
			horizontalVelocity = 250.0
		thread FlyerHovers( flyer, soundInfo, fTime, horizontalVelocity ) //flight time modification
	#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER

var function NPC_OnWeaponPrimaryAttack_TitanHover( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnWeaponPrimaryAttack_TitanHover( weapon, attackParams )
}

void function FlyerHovers( entity player, HoverSounds soundInfo, float flightTime = 3.0, float horizVel = 200.0 )
{
	player.Signal( "VTOLHoverBegin" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "VTOLHoverBegin" )
	thread AirborneThink( player, soundInfo )

	const float DEFAULT_HORIZ_SPEED = 350 // 水平速度限制
	const float DEFAULT_HORIZ_ACCEL = 540 //水平加速度
	
	const float DEFAULT_VERTI_SPEED = 300 //垂直速度限制
	const float DEFAULT_VERTI_ACCEL = 20 //垂直加速度
	
	const float DEFAULT_RISE_VEL = 450 //上升速度
	
	float hor = GetCurrentPlaylistVarFloat("EF_HORIZ_SPEED", DEFAULT_HORIZ_SPEED)
	float ver = GetCurrentPlaylistVarFloat("EF_VERTI_SPEED", DEFAULT_VERTI_SPEED)
	
	float horAcc = GetCurrentPlaylistVarFloat("EF_HORIZ_ACCEL", DEFAULT_HORIZ_ACCEL)
	float verAcc = GetCurrentPlaylistVarFloat("EF_VERTI_ACCEL", DEFAULT_VERTI_ACCEL)
	
	float riseVel = GetCurrentPlaylistVarFloat("EF_RISE_VEL", DEFAULT_RISE_VEL)
	
	entity pog = player.GetTitanSoul()
	float horizontalVelocity
	if ( IsValid( pog ) && SoulHasPassive( pog, ePassives.PAS_NORTHSTAR_FLIGHTCORE ) )
	{
		hor += 150//毒蛇推进器,增加水平速度限制
	}
	
	float additionalVerticalVel = 0 //added for the sake of vertical movement
	
	if ( player.IsPlayer() )
	{
		player.Server_TurnDodgeDisabledOn()
	    player.kv.airSpeed = hor
	    player.kv.airAcceleration = horAcc
	    player.kv.gravity = 0.0
	}

	CreateShake( player.GetOrigin(), 16, 150, 1.00, 400 )
	PlayFX( FLIGHT_CORE_IMPACT_FX, player.GetOrigin() )

	float startTime = Time()

	array<entity> activeFX

	player.SetGroundFrictionScale( 0 )

	OnThreadEnd(
		function() : ( activeFX, player, soundInfo )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, soundInfo.hover_1p )
				StopSoundOnEntity( player, soundInfo.hover_3p )
				player.SetGroundFrictionScale( 1 )
				if ( player.IsPlayer() )
				{
					player.Server_TurnDodgeDisabledOff()
					player.kv.airSpeed = player.GetPlayerSettingsField( "airSpeed" )
					player.kv.airAcceleration = player.GetPlayerSettingsField( "airAcceleration" )
					player.kv.gravity = player.GetPlayerSettingsField( "gravityScale" )
					if ( player.IsOnGround() )
					{
						EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.landing_1p )
						EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.landing_3p )
					}
				}
				else
				{
					if ( player.IsOnGround() )
						EmitSoundOnEntity( player, soundInfo.landing_3p )
				}
			}

			foreach ( fx in activeFX )
			{
				if ( IsValid( fx ) )
					fx.Destroy()
			}
		}
	)

	if ( player.LookupAttachment( "FX_L_BOT_THRUST" ) != 0 ) // BT doesn't have this attachment
	{
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_L_BOT_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_large" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_R_BOT_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_L_TOP_THRUST" ) ) )
		activeFX.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( $"P_xo_jet_fly_small" ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "FX_R_TOP_THRUST" ) ) )
	}

	EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.liftoff_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.liftoff_3p )
	EmitSoundOnEntityOnlyToPlayer( player, player,  soundInfo.hover_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.hover_3p )

	float movestunEffect = 1.0 - StatusEffect_Get( player, eStatusEffect.dodge_speed_slow )

	entity soul = player.GetTitanSoul()
	if ( soul == null )
		soul = player

	float fadeTime = 0.75
	StatusEffect_AddTimed( soul, eStatusEffect.dodge_speed_slow, 0.65, flightTime + fadeTime, fadeTime )

	vector startOrigin = player.GetOrigin()
	
	for ( ;; )
	{
		float timePassed = Time() - startTime
		if ( timePassed > flightTime )
			break

		float height
		if ( timePassed < LERP_IN_FLOAT )
		 	height = GraphCapped( timePassed, 0, LERP_IN_FLOAT, riseVel * 0.5, riseVel ) //Speed increases for 0.5 seconds
		 else
		 	height = GraphCapped( timePassed, LERP_IN_FLOAT, LERP_IN_FLOAT + 0.75, riseVel, 70 ) //Speed gets decreased

		height *= movestunEffect

		vector vel = player.GetVelocity()
		vel.z = height
		//MODIFICATIONS
		
		//An example of this in use would be: GraphCapped(4, 2, 6, 10, 20) = 15 as 4 is halfway between 2 and 6, 
		//so it gets mapped to halfway between 10 and 20, so 15
		
		additionalVerticalVel = calculateAdditionalVerticalVel(player, additionalVerticalVel, verAcc)
		vel.z += additionalVerticalVel
		vel = LimitVelocityVertical( vel, ver ) 
		//MODIFICATIONS END
		vel = LimitVelocityHorizontal( vel, hor + 50 )
		player.SetVelocity( vel )
		WaitFrame()
	}

	vector endOrigin = player.GetOrigin()

	// printt( endOrigin - startOrigin )
	EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.descent_1p )
	EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.descent_3p )
}

void function AirborneThink( entity player, HoverSounds soundInfo )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "DisembarkingTitan" )

	if ( player.IsPlayer() )
		player.SetTitanDisembarkEnabled( false )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) && player.IsPlayer() )
				player.SetTitanDisembarkEnabled( true )
		}
	)
	wait 0.1

	while( !player.IsOnGround() )
	{
		wait 0.1
	}

	if ( player.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, soundInfo.landing_1p )
		EmitSoundOnEntityExceptToPlayer( player, player, soundInfo.landing_3p )
	}
	else
	{
		EmitSoundOnEntity( player, soundInfo.landing_3p )
	}
}

vector function LimitVelocityHorizontal( vector vel, float speed )
{
	vector horzVel = <vel.x, vel.y, 0>
	if ( Length( horzVel ) <= speed )
		return vel

	horzVel = Normalize( horzVel )
	horzVel *= speed
	vel.x = horzVel.x
	vel.y = horzVel.y
	return vel
}

float function calculateAdditionalVerticalVel(entity player, float currentVerticalVel, float acceleration) //YOU CAN TWEAK DECELERATION RATIO BELOW
{
	float newVel = 0
	if(player.IsInputCommandHeld(IN_DODGE)) //Holding Spacebar
	{
		if(currentVerticalVel < 0) //If decelerating
			return currentVerticalVel + acceleration*3
			
		return currentVerticalVel + acceleration //If accelerating
	}
	else if(player.IsInputCommandHeld(IN_DUCK) || player.IsInputCommandHeld(IN_DUCKTOGGLE)) //Holding Crouch
	{
		if(currentVerticalVel > 0) //If decelerating
			return currentVerticalVel - acceleration*3
			
		return currentVerticalVel - acceleration //If acccelerating
	}
	else if(currentVerticalVel > (acceleration/2)) //Moving upwards, stabilize towards 0
	{
		newVel = currentVerticalVel - acceleration*2
		if(newVel < 0)
			return 0
		
		return newVel
	}
	else if(currentVerticalVel < (acceleration/2)) //Moving downwards, stabilize towards 0
	{
		newVel = currentVerticalVel + acceleration*2
		if(newVel > 0)
			return 0
		
		return newVel
	}
	return currentVerticalVel //if all else fails lmao
}

vector function LimitVelocityVertical( vector vel, float speed ) //Self-explainatory
{
	vector vertVel = <0, 0, vel.z>
	if ( Length( vertVel ) <= speed )
		return vel

	vertVel = Normalize( vertVel )
	vertVel *= speed
	vel.z = vertVel.z
	return vel
}


#endif // SERVER
