#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <vip_manager>

// original: https://forums.alliedmods.net/showthread.php?p=164803

forward zp_user_humanized_post(id, survivor)
forward zp_user_infected_post(id, infector, nemesis)
forward event_infect(victim, attacker)

#define PLUGIN_VERSION "0.1"
#define MAXP 33
#define NUM_SPRITES 12

new minLevel
new trailLife
new allowZombie

new hasTrail[MAXP]
new isZombie[MAXP]
new Float:trailTimer[MAXP]
new gl_trail_type[MAXP]
new gl_trail_id[MAXP]
new gl_player_colors[MAXP][3]
new gl_sprite[NUM_SPRITES]
new gl_def_sprite_size[NUM_SPRITES] = {4, 10, 3, 12, 12, 5, 7, 3, 12, 11, 13, 15}
new gl_def_sprite_brightness[NUM_SPRITES] = {160, 255, 200, 255, 255, 230, 150, 150, 240, 220, 200, 200}

#define MENU_KEYS MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

public plugin_init()
{
	register_plugin("VIP Trail", PLUGIN_VERSION, "EfeDursun125")
	register_cvar("amx_vm_trail_version", PLUGIN_VERSION)
	allowZombie = register_cvar("amx_vm_trail_allow_zombie", "0")
	minLevel = register_cvar("amx_vm_trail_minimum_level", "0")
	trailLife = register_cvar("amx_vm_trail_life", "10")
	register_clcmd("say !vm_trail_menu", "show_trail_menu")
	register_menu("Trail Menu", MENU_KEYS, "menu_trail")
	register_menu("Trail Set", MENU_KEYS, "menu_set")
	register_menu("Trail Set 2", MENU_KEYS, "menu_set2")
#if AMXX_VERSION_NUM <= 182
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
#else
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1, true)
#endif
}

public plugin_precache()
{
	new gl_sprite_name[NUM_SPRITES][] = {
		"sprites/laserbeam.spr",
		"sprites/blueflare1.spr",
		"sprites/dot.spr",
		"sprites/flare5.spr",
		"sprites/flare6.spr",
		"sprites/plasma.spr",
		"sprites/smoke.spr",
		"sprites/xbeam5.spr",
		"sprites/xenobeam.spr",
		"sprites/xssmke1.spr",
		"sprites/zbeam3.spr",
		"sprites/zbeam2.spr"
	}

	new i
	for (i = 0; i < NUM_SPRITES; i++)
		gl_sprite[i] = precache_model(gl_sprite_name[i])
}

stock kill_trail(id)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)
	write_short(id)
	message_end()
}

public client_putinserver(id)
{
	hasTrail[id] = false
	trailTimer[id] = 0.0
}

public vip_putinserver(id, level)
{
	gl_player_colors[id][0] = random_num(0, 255)
	gl_player_colors[id][1] = random_num(0, 255)
	gl_player_colors[id][2] = random_num(0, 255)
}

#if AMXX_VERSION_NUM > 182
public client_disconnected(id)
#else
public client_disconnect(id)
#endif
{
	kill_trail(id)
}

stock Float:get_speed(entity)
{
	new Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	return vector_length(velocity)
}

public client_PostThink(id)
{
	// fastest check goes first
	if (!hasTrail[id])
		return PLUGIN_CONTINUE

	if (trailTimer[id] > get_gametime())
		return PLUGIN_CONTINUE

	if (isZombie[id])
		return PLUGIN_CONTINUE

	if (!is_user_alive(id))
		return PLUGIN_CONTINUE

	if (get_speed(id) == 0.0)
		return PLUGIN_CONTINUE

	kill_trail(id)

	new life = get_pcvar_num(trailLife)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(22)
	write_short(id)
	write_short(gl_trail_type[id])
	write_byte(life)
	write_byte(gl_def_sprite_size[gl_trail_id[id]])
	write_byte(gl_player_colors[id][0])
	write_byte(gl_player_colors[id][1])
	write_byte(gl_player_colors[id][2])
	write_byte(gl_def_sprite_brightness[gl_trail_id[id]])
	message_end()

	trailTimer[id] = get_gametime() + life
	return PLUGIN_CONTINUE
}

public player_spawn(id)
{
	if (!is_user_vip(id))
		return

	if (get_user_vip_level(id) < get_pcvar_num(minLevel))
		return

	if (!is_user_alive(id))
		return

	if (is_user_bot(id))
	{
		// sometimes we don't want glow
		if (random_num(1, 4) == 1)
		{
			hasTrail[id] = false
			return
		}
		else
		{
			hasTrail[id] = true
			gl_player_colors[id][0] = random_num(0, 255)
			gl_player_colors[id][1] = random_num(0, 255)
			gl_player_colors[id][2] = random_num(0, 255)
		}
	}
}

public zp_user_humanized_post(id, survivor)
{
	isZombie[id] = false
}

public zp_user_infected_post(id, infector, nemesis)
{
	if (get_pcvar_num(allowZombie) != 1)
	{
		isZombie[id] = true
		kill_trail(id)
	}
}

public event_infect(victim, attacker)
{
	if (get_pcvar_num(allowZombie) != 1)
	{
		isZombie[victim] = true
		kill_trail(victim)
	}
}

#if AMXX_VERSION_NUM <= 182
// from the zp 4.3
stock client_print_color(target, sender, const message[], any:...)
{
	new buffer[512], i, argscount
	argscount = numargs()

	// send to everyone
	if (!target)
	{
		new cache = get_user_msgid("SayText")
		new player
		new changed[5], changedcount
		new maxPlayers = get_maxplayers()
		for (player = 1; player <= maxPlayers; player++)
		{
			// not connected
			if (!is_user_connected(player))
				continue

			// remember changed arguments
			// [5] = max LANG_PLAYER occurencies
			changedcount = 0

			// replace LANG_PLAYER with player id
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}

			// format message for player
			vformat(buffer, charsmax(buffer), message, 3)

			// send it
			message_begin(MSG_ONE, cache, _, player)
			write_byte(sender)
			write_string(buffer)
			message_end()

			// replace back player id's with LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	else // send to specific target
	{
		/*
		// not needed since you should set the ML argument
		// to the player's id for a targeted print message
		
		// replace LANG_PLAYER with player id
		for (i = 2; i < argscount; i++)
		{
			if (getarg(i) == LANG_PLAYER)
				setarg(i, 0, target)
		}
		*/

		// format message for player
		vformat(buffer, charsmax(buffer), message, 3)

		// send it
		message_begin(MSG_ONE, get_user_msgid("SayText"), _, target)
		write_byte(sender)
		write_string(buffer)
		message_end()
	}
}
#endif

public show_trail_menu(id)
{
	// vip check is faster, it goes first
	if (!is_user_vip(id))
		return

	// second fast
	if (get_user_vip_level(id) < get_pcvar_num(minLevel))
		return

	if (!is_user_connected(id))
		return

	new menu[255]
	new len = 0

	len += formatex(menu[len], charsmax(menu) - len, "\yTrail Menu^n^n")

	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Set Trail^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Red^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Green^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Blue^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Yellow^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r6.\w Pink^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r7.\w Aqua^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r8.\w White^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r9.\w Random RGB^n", id)

	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Exit", id)

	if (pev_valid(id) == 2)
		set_pdata_int(id, 205, 0, 5)

	show_menu(id, MENU_KEYS, menu, -1, "Trail Menu")
}

stock first_page(id)
{
	new menu[255]
	new len = 0

	len += formatex(menu[len], charsmax(menu) - len, "\yTrail Menu (1/2)^n^n")

	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Off^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Laserbeam^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Blueflare^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Dot^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Flare 5^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r6.\w Flare 6^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r7.\w Plasma^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r8.\w Smoke^n", id)

	len += formatex(menu[len], charsmax(menu) - len, "^n\r9.\w Next^n", id)

	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Exit", id)

	if (pev_valid(id) == 2)
		set_pdata_int(id, 205, 0, 5)

	show_menu(id, MENU_KEYS, menu, -1, "Trail Set")
}

public menu_trail(id, key)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED

	switch (key)
	{
		case 0:
			first_page(id)
		case 1:
		{
			gl_player_colors[id][0] = 255
			gl_player_colors[id][1] = 0
			gl_player_colors[id][2] = 0
		}
		case 2:
		{
			gl_player_colors[id][0] = 0
			gl_player_colors[id][1] = 255
			gl_player_colors[id][2] = 0
		}
		case 3:
		{
			gl_player_colors[id][0] = 0
			gl_player_colors[id][1] = 0
			gl_player_colors[id][2] = 255
		}
		case 4:
		{
			gl_player_colors[id][0] = 255
			gl_player_colors[id][1] = 255
			gl_player_colors[id][2] = 0
		}
		case 5:
		{
			gl_player_colors[id][0] = 255
			gl_player_colors[id][1] = 105
			gl_player_colors[id][2] = 180
		}
		case 6:
		{
			gl_player_colors[id][0] = 0
			gl_player_colors[id][1] = 255
			gl_player_colors[id][2] = 255
		}
		case 7:
		{
			gl_player_colors[id][0] = 250
			gl_player_colors[id][1] = 250
			gl_player_colors[id][2] = 250
		}
		case 8:
		{
			gl_player_colors[id][0] = random_num(0, 255)
			gl_player_colors[id][1] = random_num(0, 255)
			gl_player_colors[id][2] = random_num(0, 255)
		}
	}

	return PLUGIN_HANDLED
}

stock second_page(id)
{
	new menu[255]
	new len = 0

	len += formatex(menu[len], charsmax(menu) - len, "\yTrail Menu (2/2)^n^n")

	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w XBeam 5^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Xenobeam^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w XS Smoke^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w ZBeam 3^n", id)
	len += formatex(menu[len], charsmax(menu) - len, "\r5.\w ZBeam 2^n^n^n^n", id)

	len += formatex(menu[len], charsmax(menu) - len, "^n\r9.\w Back^n", id)

	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w Exit", id)

	if (pev_valid(id) == 2)
		set_pdata_int(id, 205, 0, 5)

	show_menu(id, MENU_KEYS, menu, -1, "Trail Set 2")
}

public menu_set(id, key)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED

	switch (key)
	{
		case 0:
		{
			hasTrail[id] = false
			client_print_color(id, id, "^x04[VIP Manager]^x01 Your trail has been turned off!")
		}
		case 1:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[0]
			gl_trail_id[id] = 0
		}
		case 2:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[1]
			gl_trail_id[id] = 1
		}
		case 3:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[2]
			gl_trail_id[id] = 2
		}
		case 4:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[3]
			gl_trail_id[id] = 3
		}
		case 5:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[4]
			gl_trail_id[id] = 4
		}
		case 6:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[5]
			gl_trail_id[id] = 5
		}
		case 7:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[6]
			gl_trail_id[id] = 6
		}
		case 8:
			second_page(id)
	}

	return PLUGIN_HANDLED
}

public menu_set2(id, key)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED

	switch (key)
	{
		case 0:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[7]
			gl_trail_id[id] = 7
		}
		case 1:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[8]
			gl_trail_id[id] = 8
		}
		case 2:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[9]
			gl_trail_id[id] = 9
		}
		case 3:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[10]
			gl_trail_id[id] = 10
		}
		case 4:
		{
			hasTrail[id] = true
			gl_trail_type[id] = gl_sprite[11]
			gl_trail_id[id] = 11
		}
		case 5:
			second_page(id)
		case 6:
			second_page(id)
		case 7:
			second_page(id)
		case 8:
			first_page(id)
	}

	return PLUGIN_HANDLED
}