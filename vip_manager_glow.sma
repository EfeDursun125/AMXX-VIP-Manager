#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <vip_manager>

forward zp_user_humanized_post(id, survivor)
forward zp_user_infected_post(id, infector, nemesis)
forward event_infect(victim, attacker)

#define PLUGIN_VERSION "0.1"
#define CVAR_ALLOW_ZOMBIE "amx_vm_glow_allow_zombie"
#define CVAR_GLOW_SIZE "amx_vm_glow_size"
#define CVAR_FORCE_LOOP "amx_vm_glow_force_loop"

new minLevel

#define MAXP 33
new isZombie[MAXP]
new Float:glowColor[MAXP][3]

#define MENU_KEYS MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
#define TASK_GLOW 464589

public plugin_init()
{
	register_plugin("VIP Glow", PLUGIN_VERSION, "EfeDursun125")
	register_cvar("amx_vm_glow_version", PLUGIN_VERSION)
	register_cvar(CVAR_ALLOW_ZOMBIE, "0")
	register_cvar(CVAR_GLOW_SIZE, "24")
	register_cvar(CVAR_FORCE_LOOP, "0")
	minLevel = register_cvar("amx_vm_glow_minimum_level", "0")
	register_clcmd("say !vm_glow_menu", "show_glow_menu")
	register_menu("Glow Menu", MENU_KEYS, "menu_glow")
#if AMXX_VERSION_NUM <= 182
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
#else
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1, true)
#endif
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
		if (random_num(1, 4) == 1)
		{
			glowColor[id][0] = 255.0
			glowColor[id][1] = 255.0
			glowColor[id][2] = 255.0
			return
		}
		else
		{
			glowColor[id][0] = random_float(0.0, 255.0)
			glowColor[id][1] = random_float(0.0, 255.0)
			glowColor[id][2] = random_float(0.0, 255.0)
		}
	}
	else if (glowColor[id][0] == 255.0 && glowColor[id][1] == 255.0 && glowColor[id][2] == 255.0)
		return

	if (!task_exists(TASK_GLOW + id))
		set_task(3.0, "set_player_glow", TASK_GLOW + id)
}

public set_player_glow(id)
{
	id -= TASK_GLOW
	if (!is_user_vip(id))
		return

	if (get_user_vip_level(id) < get_pcvar_num(minLevel))
		return

	if (pev_valid(id) != 2)
		return

	if (!is_user_alive(id))
		return

	set_rendering(id, kRenderFxGlowShell, glowColor[id], kRenderNormal, get_cvar_float(CVAR_GLOW_SIZE))
	isZombie[id] = false

	if (get_cvar_num(CVAR_FORCE_LOOP))
		set_task(9.0, "set_player_glow", TASK_GLOW + id)
}

public zp_user_humanized_post(id, survivor)
{
	isZombie[id] = false
	if (!survivor && !task_exists(TASK_GLOW + id))
		set_task(3.0, "set_player_glow", TASK_GLOW + id)
}

public zp_user_infected_post(id, infector, nemesis)
{
	if (!get_cvar_num(CVAR_ALLOW_ZOMBIE))
	{
		remove_task(TASK_GLOW + id)
		if (!nemesis)
			set_rendering(id)
		isZombie[id] = true
	}
}

public event_infect(victim, attacker)
{
	if (get_cvar_num(CVAR_ALLOW_ZOMBIE) != 1)
	{
		remove_task(TASK_GLOW + victim)
		set_rendering(victim)
		isZombie[victim] = true
	}
}

#if AMXX_VERSION_NUM <= 182
stock client_print_color(target, sender, const message[], any:...)
{
	new buffer[512], i, argscount
	argscount = numargs()
	if (!target)
	{
		new cache = get_user_msgid("SayText")
		new player
		new changed[5], changedcount
		new maxPlayers = get_maxplayers()
		for (player = 1; player <= maxPlayers; player++)
		{
			if (!is_user_connected(player))
				continue

			changedcount = 0

			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}

			vformat(buffer, charsmax(buffer), message, 3)

			message_begin(MSG_ONE, cache, _, player)
			write_byte(sender)
			write_string(buffer)
			message_end()

			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	else 
	{
		vformat(buffer, charsmax(buffer), message, 3)

		message_begin(MSG_ONE, get_user_msgid("SayText"), _, target)
		write_byte(sender)
		write_string(buffer)
		message_end()
	}
}
#endif

public show_glow_menu(id)
{
	if (!is_user_vip(id))
		return

	if (get_user_vip_level(id) < get_pcvar_num(minLevel))
		return

	if (!is_user_connected(id))
		return

	new menu[250]
	new len = 0

	len += formatex(menu[len], charsmax(menu) - len, "\yGlow Menu^n^n")

	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Off^n", id)
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

	show_menu(id, MENU_KEYS, menu, -1, "Glow Menu")
}

public menu_glow(id, key)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED

	switch (key)
	{
		case 0:
		{
			glowColor[id][0] = 255.0
			glowColor[id][1] = 255.0
			glowColor[id][2] = 255.0
		}
		case 1:
		{
			glowColor[id][0] = 255.0
			glowColor[id][1] = 0.0
			glowColor[id][2] = 0.0
		}
		case 2:
		{
			glowColor[id][0] = 0.0
			glowColor[id][1] = 255.0
			glowColor[id][2] = 0.0
		}
		case 3:
		{
			glowColor[id][0] = 0.0
			glowColor[id][1] = 0.0
			glowColor[id][2] = 255.0
		}
		case 4:
		{
			glowColor[id][0] = 255.0
			glowColor[id][1] = 255.0
			glowColor[id][2] = 0.0
		}
		case 5:
		{
			glowColor[id][0] = 255.0
			glowColor[id][1] = 105.0
			glowColor[id][2] = 180.0
		}
		case 6:
		{
			glowColor[id][0] = 0.0
			glowColor[id][1] = 255.0
			glowColor[id][2] = 255.0
		}
		case 7:
		{
			glowColor[id][0] = 250.0
			glowColor[id][1] = 250.0
			glowColor[id][2] = 250.0
		}
		case 8:
		{
			glowColor[id][0] = random_float(0.0, 255.0)
			glowColor[id][1] = random_float(0.0, 255.0)
			glowColor[id][2] = random_float(0.0, 255.0)
		}
	}

	if (glowColor[id][0] == 255.0 && glowColor[id][1] == 255.0 && glowColor[id][2] == 255.0)
	{
		set_rendering(id)
		client_print_color(id, id, "^x04[VIP Manager]^x01 Your glow has been turned off!")
	}
	else if (isZombie[id] && get_cvar_num(CVAR_ALLOW_ZOMBIE) != 1)
	{
		set_rendering(id)
		client_print_color(id, id, "^x04[VIP Manager]^x01 Glow is disabled for the zombies!")
	}
	else
		set_rendering(id, kRenderFxGlowShell, glowColor[id], kRenderNormal, get_cvar_float(CVAR_GLOW_SIZE))

	return PLUGIN_HANDLED
}

stock set_rendering(entity, fx = kRenderFxNone, Float:color[3] = {255.0, 255.0, 255.0}, render = kRenderNormal, Float:amount = 24.0)
{
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, amount)
}
