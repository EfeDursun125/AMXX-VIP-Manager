#include <amxmodx>
#include <hamsandwich>
#include <vip_manager>

new cvar_damage_vip
new cvar_damage_mvp
public plugin_init()
{
	register_plugin("VIP Damage Multiplier", "0.1", "EfeDursun125")
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage", 0, true)
	cvar_damage_vip = register_cvar("amx_vm_damage_mul_vip", "1.1")
	cvar_damage_mvp = register_cvar("amx_vm_damage_mul_mvp", "1.2")
}

public OnTakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!is_user_vip(attacker))
		return HAM_IGNORED

	SetHamParamFloat(4, damage * get_user_vip_level(attacker) == 0 ? get_pcvar_float(cvar_damage_vip) : get_pcvar_float(cvar_damage_mvp))
	return HAM_IGNORED
}