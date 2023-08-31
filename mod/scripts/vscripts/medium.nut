untyped //entity.s need this
global function medium_Init

const DAMAGE_AGAINST_TITANS 			= 40
const DAMAGE_AGAINST_PILOTS 			= 12

const EMP_DAMAGE_TICK_RATE = 0.1
const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"

void function medium_Init()
{
	AddSpawnCallback( "npc_titan", OnTitanfall )
	AddCallback_OnPilotBecomesTitan( SetPlayerTitanTitle )
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
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )	//检查玩家的模型
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为野兽，取消至尊泰坦以使用原版北极星",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "野獸"	//众所周知，当玩家上泰坦时不会按照我们的意愿设置标题的，所以这边整个变量让玩家上泰坦时读取这个然后写上
		soul.soul.titanLoadout.titanExecution = "execution_northstar_prime"

        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream",["sp_s2s_settings"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL,["slow_recovery_vortex"] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER )
      	titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["extended_smart_ammo_range"] )
		titan.GiveOffhandWeapon( "mp_titancore_flight_core", OFFHAND_EQUIPMENT )

		array<int> passives = [ ePassives.PAS_NORTHSTAR_WEAPON,
								ePassives.PAS_NORTHSTAR_CLUSTER,
								ePassives.PAS_NORTHSTAR_TRAP,
								ePassives.PAS_NORTHSTAR_FLIGHTCORE,
								ePassives.PAS_NORTHSTAR_OPTICS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为远征，取消\"边境帝王\"皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "遠征"
		
        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["fast_reload"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL,["slow_recovery_vortex"] )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER,["burn_mod_titan_smoke"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["extended_smart_ammo_range"] )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT )

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "取消至尊泰坦以使用原版军团",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "至尊軍團"

        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty", [ "accelerator" ] )
		
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveOffhandWeapon( "mp_weapon_frag_drone", OFFHAND_TITAN_CENTER,["pas_ordnance_pack","all_ticks"])
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL)
		titan.GiveOffhandWeapon( "mp_titanweapon_orbital_strike", OFFHAND_ORDNANCE,["burn_mod_titan_salvo_rockets"] )
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT )
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "至尊強力"

        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_sticky_40mm", [ "splasher_rounds","extended_ammo","burn_mod_titan_40mm","fast_reload","sur_level_1"] )
		
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL)
		titan.GiveOffhandWeapon( "mp_ability_holopilot_nova", OFFHAND_TITAN_CENTER,["dev_mod_low_recharge"])
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE,["burn_mod_titan_homing_rockets","mod_ordnance_core"] )
		titan.GiveOffhandWeapon( "mp_titancore_salvo_core", OFFHAND_EQUIPMENT)

		array<int> passives = [ ePassives.PAS_TONE_WEAPON,
								ePassives.PAS_TONE_ROCKETS,
								ePassives.PAS_TONE_SONAR,
								ePassives.PAS_TONE_WALL,
								ePassives.PAS_TONE_BURST ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "取消至尊泰坦以使用原版离子",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "至尊離子"

        titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_arc_cannon",["splitter"] )
		titan.GiveWeapon( "mp_titanweapon_arc_cannon",["capacitor","burn_mod_titan_arc_cannon"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL)
		titan.GiveOffhandWeapon( "mp_ability_shifter", OFFHAND_TITAN_CENTER,["long_last_shifter","pas_power_cell","all_phase"])
		titan.GiveOffhandWeapon( "mp_titanweapon_stun_laser", OFFHAND_ORDNANCE)
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT,["dash_core"])

		array<int> passives = [ ePassives.PAS_ION_WEAPON,
								ePassives.PAS_ION_TRIPWIRE,
								ePassives.PAS_ION_VORTEX,
								ePassives.PAS_ION_LASERCANNON,
								ePassives.PAS_ION_WEAPON_ADS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl"  && titan.GetCamo() == 1 )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "切换为疾风，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "疾風"
	
		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_vanguard",["battle_rifle","battle_rifle_icon"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["vortex_extended_effect_and_no_use_penalty"] )
		titan.GiveOffhandWeapon( "mp_titanability_phase_dash", OFFHAND_TITAN_CENTER,["pas_defensive_core"])
		titan.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE,["burn_mod_titan_salvo_rockets","dev_mod_low_recharge"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT,["dash_core"])
		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() ==  2 )
	{//离子装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用离子装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT離子"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["electric_rounds"] )
		titan.GiveWeapon( "mp_titanweapon_particle_accelerator",["burn_mod_titan_particle_accelerator"] )		
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","pas_defensive_core","sur_level_3"] )
		titan.GiveOffhandWeapon( "mp_titanability_laser_trip", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_laser_lite", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_laser_cannon", OFFHAND_EQUIPMENT,["super_laser_core"])

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == 3 )
	{//强力装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用强力装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT強力"

         titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["extended_ammo"] )
		titan.GiveWeapon( "mp_titanweapon_sticky_40mm",["mortar_shots","sur_level_3","fast_reload"] )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL,["pas_defensive_core"] )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE,["burn_mod_titan_homing_rockets"] )
		titan.GiveOffhandWeapon( "mp_titancore_salvo_core", OFFHAND_EQUIPMENT)

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() ==  30 )
	{//烈焰装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用烈焰装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT烈焰"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["burn_mod_titan_xo16"] )
		titan.GiveWeapon( "mp_titanweapon_meteor",["fd_wpn_upgrade_1"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_heat_shield", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_slow_trap", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_flame_wall", OFFHAND_ORDNANCE,["dev_mod_low_recharge"] )
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT)

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo()== 18 )
	{//北极星装备
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用北极星装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT北極星"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["burst"] )
		titan.GiveWeapon( "mp_titanweapon_sniper",["fd_upgrade_charge","power_shot","burn_mod_titan_sniper"] )
		titan.GiveOffhandWeapon( "mp_titanability_tether_trap", OFFHAND_SPECIAL,["fd_trap_charges"] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets", OFFHAND_ORDNANCE,["burn_mod_titan_dumbfire_rockets"] )
		titan.GiveOffhandWeapon( "mp_titancore_flight_core", OFFHAND_EQUIPMENT)

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "切换为野牛，取消至尊泰坦以使用原版烈焰",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "野牛"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		
		titan.GiveOffhandWeapon( "mp_ability_cloak", OFFHAND_SPECIAL,["pas_power_cell"])
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_TITAN_CENTER,["bc_super_stim","bc_long_stim1","bc_long_stim2","amped_tacticals","pas_power_cell"])
		titan.GiveOffhandWeapon( "mp_ability_holopilot_nova", OFFHAND_ORDNANCE,["dev_mod_low_recharge"])
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT,["ground_slam"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, ["berserker", "allow_as_primary"] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )

		array<int> passives = [ ePassives.PAS_SCORCH_WEAPON,
								ePassives.PAS_SCORCH_FIREWALL,
								ePassives.PAS_SCORCH_SHIELD,
								ePassives.PAS_SCORCH_SELFDMG,
								ePassives.PAS_SCORCH_FLAMECORE ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl"&& titan.GetCamo()== 1)
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为电弧，取消当前皮肤以使用原版浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "電弧"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveWeapon( "mp_titanweapon_leadwall",["instaload"] )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL,["pm0"] )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_arc_wave", OFFHAND_ORDNANCE,["dev_mod_low_recharge"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, ["tcp_arc_wave"] )
		thread EMPThink_Thread( titan )
		array<int> passives = [ ePassives.PAS_RONIN_WEAPON,
								ePassives.PAS_RONIN_ARCWAVE,
								ePassives.PAS_RONIN_PHASE,
								ePassives.PAS_RONIN_SWORDCORE,
								ePassives.PAS_RONIN_AUTOSHIFT ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl"  && titan.GetCamo()== 97 )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "使用浪人装备，取消当前皮肤以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "BT浪人"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty",["electric_rounds"] )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_phase_dash", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_arc_wave", OFFHAND_ORDNANCE,["dev_mod_low_recharge"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT)
		titan.GiveOffhandWeapon( "melee_titan_sword", OFFHAND_MELEE )

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
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
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl"&& titan.GetCamo()== 3)
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已切换为影杀，取消当前皮肤以使用原版浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "影殺"

		titan.TakeWeaponNow( weapon.GetWeaponClassName() )
		titan.GiveWeapon( "mp_titanweapon_triplethreat", [ "rolling_rounds","burn_mod_titan_triple_threat","impact_fuse"] )
		
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL,["pm0"] )
		titan.GiveOffhandWeapon( "mp_titanability_phase_dash", OFFHAND_TITAN_CENTER)
		titan.GiveOffhandWeapon( "mp_titanweapon_arc_wave", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, ["dash_core"] )
		array<int> passives = [ ePassives.PAS_RONIN_WEAPON,
								ePassives.PAS_RONIN_ARCWAVE,
								ePassives.PAS_RONIN_PHASE,
								ePassives.PAS_RONIN_SWORDCORE,
								ePassives.PAS_RONIN_AUTOSHIFT ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
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
	DisableTitanRodeo( titan )
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
				EnableTitanRodeo( titan ) //Make the arc titan rodeoable now that it is no longer electrified.
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