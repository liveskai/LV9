global function Titan_Shield_Damage_Init
global function TrackTitanShieldDamageInPlayerGameStat

struct
{
    int titanDamageGameStat = -1
} file

void function Titan_Shield_Damage_Init()
{
    AddSpawnCallback( "npc_titan", OnTitanSpawn )
}

void function TrackTitanShieldDamageInPlayerGameStat( int playerGameStat )
{
    file.titanDamageGameStat = playerGameStat
}

void function OnTitanSpawn( entity titan )
{
	AddEntityCallback_OnPostShieldDamage( titan, OnPostShieldDamage )
}

void function OnPostShieldDamage( entity ent, var damageInfo, float actualShieldDamage )
{
    if ( file.titanDamageGameStat == -1 )
        return
    entity victim
	if ( ent.IsTitan() )
		victim = ent.GetTitanSoul()
	else
		victim = ent

    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if ( IsValid( attacker ) && attacker.IsPlayer() && DamageInfo_GetDamage( damageInfo ) != actualShieldDamage ) // Shield empty
        attacker.AddToPlayerGameStat( file.titanDamageGameStat, actualShieldDamage )
}