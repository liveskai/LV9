global function MpTitanWeaponPunch_Fighter_Init

const MELEE_SHIELD_REGEN_HEAVY = 600
const MELEE_SHIELD_REGEN_OTHER = 300

void function MpTitanWeaponPunch_Fighter_Init()
{
    #if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.melee_titan_punch_fighter, Punch_DamagedTarget )
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_ground_slam, Punch_DamagedTarget )
    #endif
}

#if SERVER
void function Punch_DamagedTarget( entity target, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity soul = attacker.GetTitanSoul()

	if ( IsValid( soul ) )
	{
		int shieldRestoreAmount = target.GetArmorType() == ARMOR_TYPE_HEAVY ? MELEE_SHIELD_REGEN_HEAVY : MELEE_SHIELD_REGEN_OTHER
		soul.SetShieldHealth( min( soul.GetShieldHealth() + shieldRestoreAmount, soul.GetShieldHealthMax() ) )
	}
}
#endif