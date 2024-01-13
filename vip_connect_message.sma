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

public vip_putinserver(id, level)
{
	new name[32]
	get_user_name(id, name, charsmax(name))
	client_print_color(0, id, "^x04[VIP Manager]^x01^x03 %s^x01 has^x04 connected^x01 to the server!", name)
	set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.35, 2)
	show_hudmessage(0, "%s welcome to the server!", name)
	set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, -0.35, 2)
	show_hudmessage(0, "Enjoy your game, have fun!", name)
}

public vip_disconnected(id, level)
{
	new name[32]
	get_user_name(id, name, charsmax(name))
	client_print_color(0, id, "^x04[VIP Manager]^x01^x03 %s^x01 has^x04 disconnected^x01 from the server!", name)
}