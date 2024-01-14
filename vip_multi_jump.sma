#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <vip_manager>

//
// optimizated version of this:
// https://forums.alliedmods.net/showthread.php?t=10159
//

new jumpNum[33] = 0
public plugin_init()
{
	register_plugin("VIP Multi Jump", "1.2", "twistedeuphoria")
}

public vip_putinserver(id, level)
{
	jumpNum[id] = 0
}

public vip_disconnected(id, level)
{
	jumpNum[id] = 0
}

public client_PreThink(id)
{
	if (!is_user_vip(id))
		return PLUGIN_CONTINUE

	if (!is_user_alive(id))
		return PLUGIN_CONTINUE

	if (get_user_button(id) & IN_JUMP)
	{
		if (get_entity_flags(id) & FL_ONGROUND)
			jumpNum[id] = 0
		else if (!(get_user_oldbutton(id) & IN_JUMP))
		{
			new numJumps = get_user_vip_level(id) == 0 ? 1 : 2 // 0 is default vip level, upper vip levels have a triple jump
			if (jumpNum[id] < numJumps)
			{
				new Float:velocity[3]
				entity_get_vector(id, EV_VEC_velocity, velocity)
				velocity[2] = random_float(265.0, 285.0)
				entity_set_vector(id, EV_VEC_velocity, velocity)
				jumpNum[id]++
				return PLUGIN_CONTINUE
			}
		}
	}

	return PLUGIN_CONTINUE
}
