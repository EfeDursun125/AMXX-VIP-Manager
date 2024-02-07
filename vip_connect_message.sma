#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#define PLUGIN_VERSION "0.1"

public plugin_init()
{
	register_plugin("VIP Connect/Disconnect Message", PLUGIN_VERSION, "EfeDursun125")
	register_cvar("amx_vm_version", PLUGIN_VERSION)
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
			message_begin(MSG_ONE_UNRELIABLE, cache, _, player)
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
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, target)
		write_byte(sender)
		write_string(buffer)
		message_end()
	}
}
#endif

public vip_putinserver(id, level)
{
	new name[32], sname[128], ip[32]
	get_user_name(id, name, charsmax(name))
	client_print_color(0, id, "^x04[VIP Manager]^x01^x03 %s^x01 has^x04 connected^x01 to the server!", name)
	get_user_name(0, sname, charsmax(sname))
	get_user_ip(0, ip, charsmax(ip))
	set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.35, 2)
	show_hudmessage(id, "%s welcome to the %s!^n^n^n^n^n^n^n^n^n^n^n^nEnjoy your game, have fun!^n%s", name, sname, ip)
}

public vip_disconnected(id, level)
{
	new name[32]
	get_user_name(id, name, charsmax(name))
	client_print_color(0, id, "^x04[VIP Manager]^x01^x03 %s^x01 has^x04 left^x01 from the server!", name)
}