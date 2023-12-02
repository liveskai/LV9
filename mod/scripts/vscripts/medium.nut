untyped
global function medium_Init

global function Replace_OFFHAND_RIGHT
global function Replace_OFFHAND_ANTIRODEO
global function Replace_OFFHAND_LEFT
global function Replace_OFFHAND_EQUIPMENT
global function TakeTitanPassives

const DAMAGE_AGAINST_TITANS 			= 45
const DAMAGE_AGAINST_PILOTS 			= 12

const EMP_DAMAGE_TICK_RATE = 0.1
const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"

void function medium_Init()
{
	AddSpawnCallback( "npc_titan", OnTitanfall )
	AddCallback_OnPilotBecomesTitan( SetPlayerTitanTitle )
	AddCallback_OnTitanBecomesPilot( OnTitanBecomesPilot )
	AddCallback_OnTitanGetsNewTitanLoadout( TitanEnhance )
}

void function Replace_OFFHAND_RIGHT( entity titan, string offhandName, array<string> mods = [] )
{
	titan.TakeOffhandWeapon( OFFHAND_RIGHT )
	titan.GiveOffhandWeapon( offhandName, OFFHAND_RIGHT, mods )
}
void function Replace_OFFHAND_ANTIRODEO( entity titan, string offhandName, array<string> mods = [] )
{
	titan.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
	titan.GiveOffhandWeapon( offhandName, OFFHAND_ANTIRODEO, mods )
}
void function Replace_OFFHAND_LEFT( entity titan, string offhandName, array<string> mods = [] )
{
	titan.TakeOffhandWeapon( OFFHAND_LEFT )
	titan.GiveOffhandWeapon( offhandName, OFFHAND_LEFT, mods )
}
void function Replace_OFFHAND_EQUIPMENT( entity titan, string offhandName, array<string> mods = [] )
{
	titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
	titan.GiveOffhandWeapon( offhandName, OFFHAND_EQUIPMENT, mods )
}
function TakeTitanPassives( entity titan )
{
	entity soul = titan.GetTitanSoul()
	array<int> passives = [ 
		ePassives.PAS_RONIN_WEAPON,
		ePassives.PAS_NORTHSTAR_WEAPON,
		ePassives.PAS_ION_WEAPON,
		ePassives.PAS_TONE_WEAPON,
		ePassives.PAS_SCORCH_WEAPON,
		ePassives.PAS_LEGION_WEAPON,
		ePassives.PAS_ION_TRIPWIRE,
		ePassives.PAS_ION_VORTEX,
		ePassives.PAS_ION_LASERCANNON,
		ePassives.PAS_TONE_ROCKETS,
		ePassives.PAS_TONE_SONAR,
		ePassives.PAS_TONE_WALL,
		ePassives.PAS_RONIN_ARCWAVE,
		ePassives.PAS_RONIN_PHASE,
		ePassives.PAS_RONIN_SWORDCORE,
		ePassives.PAS_NORTHSTAR_CLUSTER,
		ePassives.PAS_NORTHSTAR_TRAP,
		ePassives.PAS_NORTHSTAR_FLIGHTCORE,
		ePassives.PAS_SCORCH_FIREWALL,
		ePassives.PAS_SCORCH_SHIELD,
		ePassives.PAS_SCORCH_SELFDMG,
		ePassives.PAS_LEGION_SPINUP,
		ePassives.PAS_LEGION_GUNSHIELD,
		ePassives.PAS_LEGION_SMARTCORE,
		ePassives.PAS_ION_WEAPON_ADS,
		ePassives.PAS_TONE_BURST,
		ePassives.PAS_LEGION_CHARGESHOT,
		ePassives.PAS_RONIN_AUTOSHIFT,
		ePassives.PAS_NORTHSTAR_OPTICS,
		ePassives.PAS_SCORCH_FLAMECORE,
		ePassives.PAS_VANGUARD_COREMETER,
		ePassives.PAS_VANGUARD_SHIELD,
		ePassives.PAS_VANGUARD_REARM,
		ePassives.PAS_VANGUARD_DOOM,
		ePassives.PAS_VANGUARD_CORE1,
		ePassives.PAS_VANGUARD_CORE2,
		ePassives.PAS_VANGUARD_CORE3,
		ePassives.PAS_VANGUARD_CORE4,
		ePassives.PAS_VANGUARD_CORE5,
		ePassives.PAS_VANGUARD_CORE6,
		ePassives.PAS_VANGUARD_CORE7,
		ePassives.PAS_VANGUARD_CORE8,
		ePassives.PAS_VANGUARD_CORE9
		]
	foreach( passive in passives )
		TakePassive( soul, passive )
}
void function SetPlayerTitanTitle( entity player, entity titan )
{
	entity soul = player.GetTitanSoul()
	if( IsValid( soul ) )
		if( "titanTitle" in soul.s )
			if( soul.s.titanTitle != "" )
				player.SetTitle( soul.s.titanTitle )	//设置玩家的小血条上的标题（也就是你瞄准敌人时，顶上会显示泰坦名，玩家名，血量剩余的一个玩意，这里我们改的是泰坦名）

	if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl"&& titan.GetCamo()== 1)
		thread DelayEMPThread( soul )
}

void function TitanEnhance( entity titan, TitanLoadoutDef loadout )
{
    entity soul = titan.GetTitanSoul()
	if ( !IsValid( soul ) )
		return
    if ( SoulHasPassive( soul, ePassives.PAS_MOBILITY_DASH_CAPACITY  ) )
    {
		loadout.setFileMods.fastremovebyvalue( "pas_mobility_dash_capacity" )
		loadout.setFileMods.append( "sflag_bc_dash_capacity" )
		loadout.setFileMods.append( "pas_dash_recharge" )
    }	
    if ( !SoulHasPassive( soul, ePassives.PAS_MOBILITY_DASH_CAPACITY  ) )
    {
		loadout.setFileMods.append( "pas_mobility_dash_capacity" )
    }
 }
 
void function OnTitanfall( entity titan )
{
	entity player = titan
	entity soul = titan.GetTitanSoul()
	if( !IsValid( player ) )	//anti crash
		return
	if( !titan.IsPlayer() )	//如果实体"titan"不是玩家
		player = GetPetTitanOwner( titan )	//所以获得实体"titan"的主人"玩家"赋值给实体"player"
	if( IsValid( soul ) )	//如果soul != null
		if( "TitanHasBeenChange" in soul.s )	//检测是否有这个sting在soul.s里
			if( soul.s.TitanHasBeenChange == true )	//如果已经换过武器了，那么跳过
				return								//补充解释，为什么没有soul.s.TitanHasBeenChange <- false
													//因为当泰坦死亡或者摧毁时，它的soul会变成null，理所应当的，soul.s里的内容也会null
	if( !IsValid( soul ) )	//如果soul == null，我们应该直接return，防止执行后面的soul.s.TitanHasBeenChange <- true时报错
		return
	foreach ( entity weapon in titan.GetMainWeapons() )
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )	//检查泰坦的模型
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为野兽，取消至尊泰坦以使用原版北极星",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "野獸"	//众所周知，当玩家上泰坦时不会按照我们的意愿设置标题的，所以这边整个变量让玩家上泰坦时读取这个然后写上
		soul.soul.titanLoadout.titanExecution = "execution_northstar_prime"
		
		TakeTitanPassives(titan)
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream",["sp_s2s_settings"] )
		
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_shoulder_rockets",["extended_smart_ammo_range"] )
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_vortex_shield",["slow_recovery_vortex"] )
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为远征，取消\"边境帝王\"皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "遠征"
		
		TakeTitanPassives(titan)//移除所有被动
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["fast_reload"] )
		
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_shoulder_rockets",["extended_smart_ammo_range"] )
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_vortex_shield",["slow_recovery_vortex"] )
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_smoke",["burn_mod_titan_smoke","maelstrom"] )
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_amp_core" )		
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "取消至尊泰坦以使用原版军团",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "至尊軍團"
		
		TakeTitanPassives(titan)
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty", [ "accelerator","spread"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_titanability_particle_wall" )
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_orbital_strike",["burn_mod_titan_salvo_rockets"] )
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_smoke" )
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_flame_wave")		
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "至尊強力"
		
		TakeTitanPassives(titan)
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_sticky_40mm", [ "splasher_rounds","extended_ammo","burn_mod_titan_40mm","fast_reload","sur_level_1"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_vortex_shield_ion" )
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_homing_rockets",["burn_mod_titan_homing_rockets","mod_ordnance_core"] )
		Replace_OFFHAND_ANTIRODEO( titan, "mp_ability_holopilot_nova",["dev_mod_low_recharge"] )
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_salvo_core")
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "取消至尊泰坦以使用原版离子",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "至尊離子"
		
		TakeTitanPassives(titan)
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_arc_cannon",["capacitor"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_vortex_shield",["burn_mod_titan_vortex_shield"] )
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_stun_laser" )
		Replace_OFFHAND_ANTIRODEO( titan, "mp_ability_shifter",["long_last_shifter","pas_power_cell"] )
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_shift_core",["dash_core"])				
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl"  && titan.GetCamo() == 1 )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "切换为疾风，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "疾風"
		
		TakeTitanPassives(titan)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )		
		titan.GiveWeapon( "mp_titanweapon_xo16_vanguard",["battle_rifle","battle_rifle_icon"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_vortex_shield",["vortex_extended_effect_and_no_use_penalty"] )
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_salvo_rockets" ,["burn_mod_titan_salvo_rockets"])
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_phase_dash")
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_shift_core",["dash_core"])	
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() ==  2 )
	{//离子装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用离子装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT離子"

		TakeTitanPassives(titan)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )	
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["electric_rounds","spread"] )
		titan.GiveWeapon( "mp_titanweapon_particle_accelerator",["burn_mod_titan_particle_accelerator"] )		
		titan.SetActiveWeaponByName("mp_titanweapon_particle_accelerator")
		
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_vortex_shield",["slow_recovery_vortex","pas_defensive_core","sur_level_3"])
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_laser_lite")
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_laser_trip")
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_laser_cannon",["super_laser_core"])			
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == 3 )
	{//强力装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用强力装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT強力"

		TakeTitanPassives(titan)
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["extended_ammo"] )
		titan.GiveWeapon( "mp_titanweapon_sticky_40mm",["mortar_shots","sur_level_3","fast_reload"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_titanability_particle_wall",["pas_defensive_core"])
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_homing_rockets",["burn_mod_titan_homing_rockets"])
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_sonar_pulse")
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_salvo_core")					
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() ==  30 )
	{//烈焰装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用烈焰装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT烈焰"

		TakeTitanPassives(titan)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["burn_mod_titan_xo16"] )
		titan.GiveWeapon( "mp_titanweapon_meteor",["fd_wpn_upgrade_1"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_titanweapon_heat_shield")
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_flame_wall",["dev_mod_low_recharge"])
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_slow_trap")
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_flame_wave")		
		GivePassive( soul, ePassives.PAS_SCORCH_SELFDMG )
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo()== 18 )
	{//北极星装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用北极星装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT北極星"

		TakeTitanPassives(titan)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["burst","spread"] )
		titan.GiveWeapon( "mp_titanweapon_sniper",["fd_upgrade_charge","power_shot","burn_mod_titan_sniper"] )
		
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_hover")
		Replace_OFFHAND_LEFT( titan, "mp_titanability_tether_trap",["fd_trap_charges"])
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_dumbfire_rockets",["burn_mod_titan_dumbfire_rockets"])	
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_flight_core")
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "切换为野牛，取消至尊泰坦以使用原版烈焰",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "野牛"

		TakeAllWeapons( titan ) 
		TakeTitanPassives(titan)
		
		titan.GiveOffhandWeapon( "mp_ability_cloak", OFFHAND_SPECIAL,["pas_power_cell","amped_tacticals"])
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_TITAN_CENTER,["bc_super_stim","bc_long_stim1","bc_long_stim2","pas_power_cell","amped_tacticals"])
		titan.GiveOffhandWeapon( "mp_ability_holopilot_nova", OFFHAND_ORDNANCE,["dev_mod_low_recharge"])
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT,["ground_slam"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, ["berserker", "allow_as_primary"] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl"&& titan.GetCamo()== 1)
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为电弧，取消当前皮肤以使用原版浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "電弧"
		
		TakeTitanPassives(titan)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_leadwall",["sur_level_0"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_ability_swordblock",["pm0"])
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_arc_wave",["dev_mod_low_recharge"])
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_smoke")
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_shift_core", ["tcp_arc_wave"])
		thread EMPThink_Thread( titan )
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl"  && titan.GetCamo()== 97 )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用浪人装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT浪人"

		TakeAllWeapons( titan ) 
		TakeTitanPassives(titan)
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["electric_rounds","fast_reload"] )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_phase_dash", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_arc_wave", OFFHAND_ORDNANCE,["dev_mod_low_recharge"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT,["fd_duration"])
		titan.GiveOffhandWeapon( "melee_titan_sword", OFFHAND_MELEE,["fd_sword_upgrade"] )
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl"&& titan.GetCamo()== 3)
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为影杀，取消当前皮肤以使用原版浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "影殺"

		TakeTitanPassives(titan)
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_triplethreat", [ "rolling_rounds","burn_mod_titan_triple_threat","impact_fuse"] )
		
		Replace_OFFHAND_LEFT( titan, "mp_ability_swordblock",["pm0"])
		Replace_OFFHAND_RIGHT( titan, "mp_titanweapon_arc_wave")
		Replace_OFFHAND_ANTIRODEO( titan, "mp_titanability_phase_dash")
		Replace_OFFHAND_EQUIPMENT( titan, "mp_titancore_shift_core", ["dash_core"])
	}
}

void function DelayEMPThread( entity soul )
{
	wait 0.4
	if( IsValid( soul ) && IsValid (soul.GetTitan() ) )
	EMPThink_Thread( soul.GetTitan() )
}
void function EMPThink_Thread( entity titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "Doomed" )
	titan.EndSignal( "StopEMPField" )
	WaitTillHotDropComplete( titan )
	if ( HasSoul( titan ) )
	{
		entity soul = titan.GetTitanSoul()
		soul.EndSignal( "StopEMPField" )
	}

	if ( titan.IsPlayer() )
	{
		titan.EndSignal( "DisembarkingTitan" )
		titan.EndSignal( "TitanEjectionStarted" )
	}
	local attachment = "hijack"

	local attachID = titan.LookupAttachment( attachment )

	EmitSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )

	array<entity> particles = []

	//emp field fx
	vector origin = titan.GetAttachmentOrigin( attachID )
	if ( titan.IsPlayer() )
	{
		entity particleSystem = CreateEntity( "info_particle_system" )
		particleSystem.kv.start_active = 1
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
		particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD_1P )

		particleSystem.SetOrigin( origin )
		particleSystem.SetOwner( titan )
		DispatchSpawn( particleSystem )
		particleSystem.SetParent( titan, "hijack" )
		particles.append( particleSystem )
	}

	entity particleSystem = CreateEntity( "info_particle_system" )
	particleSystem.kv.start_active = 1
	if ( titan.IsPlayer() )
		particleSystem.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	else
		particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	particleSystem.SetValueForEffectNameKey( FX_EMP_FIELD )
	particleSystem.SetOwner( titan )
	particleSystem.SetOrigin( origin )
	DispatchSpawn( particleSystem )
	particleSystem.SetParent( titan, "hijack" )
	particles.append( particleSystem )

	// titan.SetDangerousAreaRadius( ARC_TITAN_EMP_FIELD_RADIUS )

	OnThreadEnd(
		function () : ( titan, particles )
		{
			if ( IsValid( titan ) )
			{
				StopSoundOnEntity( titan, "EMP_Titan_Electrical_Field" )
			}

			foreach ( particleSystem in particles )
			{
				if ( IsValid_ThisFrame( particleSystem ) )
				{
					particleSystem.ClearParent()
					particleSystem.Fire( "StopPlayEndCap" )
					particleSystem.Kill_Deprecated_UseDestroyInstead( 1.0 )
				}
			}
		}
	)

	wait RandomFloat( EMP_DAMAGE_TICK_RATE )

	while ( true )
	{
		origin = titan.GetAttachmentOrigin( attachID )

   		RadiusDamage(
   			origin,									// center
   			titan,									// attacker
   			titan,									// inflictor
   			DAMAGE_AGAINST_PILOTS,					// damage
   			DAMAGE_AGAINST_TITANS,					// damageHeavyArmor
   			ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
   			ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
   			SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
   			0,										// distanceFromAttacker
   			DAMAGE_AGAINST_PILOTS,					// explosionForce
   			DF_ELECTRICAL | DF_STOPS_TITAN_REGEN | DF_BYPASS_SHIELD,	// scriptDamageFlags
   			eDamageSourceId.titanEmpField )			// scriptDamageSourceIdentifier

		wait EMP_DAMAGE_TICK_RATE
	}
}
void function OnTitanBecomesPilot( entity player, entity titan )	//重新给予泰坦电弧场
{
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )		//如果因为不可抗力因素导致玩家的泰坦获取不到有效的soul
		return					//直接结束，不做任何操作
	
	if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl"&& titan.GetCamo()== 1)	//检查
		thread DelayEMPThread( soul )																	//如果是，那么重新给他电弧场
}