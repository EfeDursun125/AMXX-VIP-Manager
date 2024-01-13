#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#define PLUGIN_VERSION "0.1"

//
// level is 0 by default
// you can set players vip by default
// but with the levels you can set them more like:
// (0 = normal vip by default)
// 1 = MVP
// 2 = MVP+
// etc.
//
// use get_user_vip_level to give more vip features
//

new isVIP[33]
new VIPLevel[33]
new saveCust
new saveDest
new saveType
new putin
new discon

public plugin_init()
{
	register_plugin("VIP Manager", PLUGIN_VERSION, "EfeDursun125")
	register_cvar("amx_vm_version", PLUGIN_VERSION)
	saveCust = register_cvar("amx_vm_tag_use_custom_folder", "0")
	saveDest = register_cvar("amx_vm_custom_folder_dest", "C:\ExampleFolder\cstrike\addons\amxmodx\configs")
	saveType = register_cvar("amx_vm_save_type", "0")
	putin = CreateMultiForward("vip_putinserver", ET_CONTINUE, FP_CELL, FP_CELL)
	discon = CreateMultiForward("vip_disconnected", ET_IGNORE, FP_CELL, FP_CELL)
	register_concmd("amx_vm_add", "cmd_add_vip", _, "<player name | steamid | ip> - <infinite | expire day> - <vip level | 0 by default>", 0)
	register_concmd("amx_vm_remove", "cmd_remove_vip", _, "<player name | steamid | ip>", 0)
	register_concmd("amx_vm_list", "cmd_list_vip", _, "Lists the all vip players with remaining days to expire", 0)
	register_clcmd("say vm_show_rt", "show_rt")
}

public plugin_natives()
{
	register_library("vip")
	register_native("is_user_vip", "isUserVIP")
	register_native("get_user_vip_level", "getVIPLevel")
}

public isUserVIP(plugin, params)
{
	return isVIP[get_param(1)]
}

public getVIPLevel(plugin, params)
{
	return VIPLevel[get_param(1)]
}

public client_putinserver(id)
{
	isVIP[id] = 0
	VIPLevel[id] = 0
	cs_set_user_vip(id, 0, 0, 0)
	set_task(2.222, "client_load_vip", id)
}

public show_rt(id)
{
	if (!is_user_connected(id))
		return
	
	if (!isVIP[id])
		return

	new playerName[255]
	if (get_pcvar_num(saveType) == 1)
		get_user_authid(id, playerName, charsmax(playerName))
	else if (get_pcvar_num(saveType) == 2)
		get_user_ip(id, playerName, charsmax(playerName))
	else
		get_user_name(id, playerName, charsmax(playerName))

	if (strlen(playerName) < 3)
		return

	new path[255]
	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		formatex(path, charsmax(path), "%s", name)
	}

	new filePath[256]
	formatex(filePath, charsmax(filePath), "%s/econf/vip_manager", path)
	if (!dir_exists(filePath))
		mkdir(filePath)

	new fileName[255]
	formatex(fileName, charsmax(fileName), "%s/vip_list.ini", filePath)
	new file = fopen(fileName, "rt")
	if (!file)
		return

	trim(playerName)
	
	new text[384], right[128], left[128], time[128]
	new size = charsmax(text)
	while (!feof(file))
	{
		fgets(file, text, size)
		replace(text, size, "^n", "")

		if (!text[0] || text[0] == ';')
			continue

		strtok(text, left, charsmax(left), right, charsmax(right), '&')
		trim(left)
		strtok(right, right, charsmax(right), time, charsmax(time), '&')
		trim(time)

		if (equal(left, playerName))
		{
			if (equali(time, "infinite"))
				client_print_color(id, id, "^x04[VIP Manager]^x01 You have ^x04infinite^x01 days remaining.")
			else
			{
				new value = floatround((str_to_float(time) - get_systime()) / (24.0 * 60.0 * 60.0), floatround_ceil)
				client_print_color(id, id, "^x04[VIP Manager]^x01 You have ^x04%i^x01 days remaining.", value)
			}
			break
		}
	}

	fclose(file)
}

#if AMXX_VERSION_NUM > 182
public client_disconnected(id)
#else
public client_disconnect(id)
#endif
{
	if (isVIP[id])
	{
		new ret
		ExecuteForward(discon, ret, id, VIPLevel[id])
	}
}

public client_load_vip(id)
{
	if (!is_user_connected(id))
		return

	new playerName[255]
	if (get_pcvar_num(saveType) == 1)
		get_user_authid(id, playerName, charsmax(playerName))
	else if (get_pcvar_num(saveType) == 2)
		get_user_ip(id, playerName, charsmax(playerName))
	else
		get_user_name(id, playerName, charsmax(playerName))

	if (strlen(playerName) < 3)
		return

	new path[255]
	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		formatex(path, charsmax(path), "%s", name)
	}

	new filePath[256]
	formatex(filePath, charsmax(filePath), "%s/econf/vip_manager", path)
	if (!dir_exists(filePath))
		mkdir(filePath)

	new fileName[255]
	formatex(fileName, charsmax(fileName), "%s/vip_list.ini", filePath)
	new file = fopen(fileName, "rt")
	if (!file)
		return

	trim(playerName)

	new Array:lines = ArrayCreate(384, 1)
	new text[384], right[128], left[128], time[128]
	new size = charsmax(text)
	while (!feof(file))
	{
		fgets(file, text, size)
		replace(text, size, "^n", "")

		if (!text[0] || text[0] == ';')
			continue

		strtok(text, left, charsmax(left), right, charsmax(right), '&')
		trim(left)
		trim(right)
		strtok(right, right, charsmax(right), time, charsmax(time), '&')
		trim(right)
		trim(time)

		if (equali(time, "infinite") || str_to_float(time) > get_systime())
		{
			if (equal(left, playerName))
			{
				new ret
				new lvl = str_to_num(right)
				ExecuteForward(putin, ret, id, lvl)
				if (ret < PLUGIN_HANDLED)
				{
					cs_set_user_vip(id, 0, 0, 1)
					isVIP[id] = 1
					VIPLevel[id] = lvl
					if (VIPLevel[id] < 0)
						VIPLevel[id] = 0
				}
			}

			ArrayPushString(lines, text)
		}
	}

	fclose(file)
	delete_file(fileName)

	file = fopen(fileName, "a+")
	if (!file)
		return

	size = ArraySize(lines)
	new i, temp[384], limit = charsmax(temp)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(lines, i, temp, limit)
		fprintf(file, "%s^n", temp)
	}

	fclose(file)
	ArrayDestroy(lines)
}

public cmd_list_vip(id, level, cid)
{
	if (!cmd_access(id, ADMIN_KICK, cid, 1))
		return PLUGIN_HANDLED

	new path[255]
	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		formatex(path, charsmax(path), "%s", name)
	}

	new filePath[256]
	formatex(filePath, charsmax(filePath), "%s/econf/vip_manager", path)
	if (!dir_exists(filePath))
		mkdir(filePath)

	new fileName[255]
	formatex(fileName, charsmax(fileName), "%s/vip_list.ini", filePath)
	new file = fopen(fileName, "rt")
	if (!file)
		return PLUGIN_HANDLED

	console_print(id, "^n^n---> VIP Manager V%s^n-->", PLUGIN_VERSION)

	new Array:lines = ArrayCreate(384, 1)
	new text[384], right[128], left[128], time[128]
	new size = charsmax(text)
	while (!feof(file))
	{
		fgets(file, text, size)
		replace(text, size, "^n", "")

		if (!text[0] || text[0] == ';')
			continue

		strtok(text, left, charsmax(left), right, charsmax(right), '&')
		trim(left)
		trim(right)
		strtok(right, right, charsmax(right), time, charsmax(time), '&')
		trim(right)
		trim(time)

		if (equali(time, "infinite"))
		{
			ArrayPushString(lines, text)
			console_print(id, "--> %s | level %s | vip for unlimited time", left, right)
		}
		else if (str_to_float(time) > get_systime())
		{
			ArrayPushString(lines, text)
			console_print(id, "--> %s | level %s | %i days remaining", left, right, floatround((str_to_float(time) - get_systime()) / (24.0 * 60.0 * 60.0), floatround_ceil))
		}
		else
			console_print(id, "--> %s | level %s | already ended", left, right)
	}

	console_print(id, "-->^n---> Made by EfeDursun125^n^n")

	fclose(file)
	delete_file(fileName)

	file = fopen(fileName, "a+")
	if (!file)
		return PLUGIN_HANDLED

	size = ArraySize(lines)
	new i, temp[384], limit = charsmax(temp)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(lines, i, temp, limit)
		fprintf(file, "%s^n", temp)
	}

	fclose(file)
	ArrayDestroy(lines)
	return PLUGIN_HANDLED
}

public cmd_add_vip(id, level, cid)
{
	if (!cmd_access(id, ADMIN_RCON, cid, 4))
		return PLUGIN_HANDLED

	new name[128]
	read_argv(1, name, charsmax(name))

	new days[128]
	read_argv(2, days, charsmax(days))

	new vlevel[128]
	read_argv(3, vlevel, charsmax(vlevel))

	if (equali(days, "infinite"))
		add_vip_data(name, vlevel, days)
	else
	{
		new buffer[128]
		new Float:time = get_systime() + (str_to_float(days) * 24.0 * 60.0 * 60.0)
		float_to_str(time, buffer, charsmax(buffer))
		add_vip_data(name, vlevel, buffer)
	}

	return PLUGIN_HANDLED
}

public cmd_remove_vip(id, level, cid)
{
	if (!cmd_access(id, ADMIN_RCON, cid, 2))
		return PLUGIN_HANDLED

	new name[128]
	read_argv(1, name, charsmax(name))

	new path[255]
	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		formatex(path, charsmax(path), "%s", name)
	}

	new filePath[256]
	formatex(filePath, charsmax(filePath), "%s/econf/vip_manager", path)
	if (!dir_exists(filePath))
		mkdir(filePath)

	new fileName[255]
	formatex(fileName, charsmax(fileName), "%s/vip_list.ini", filePath)
	new file = fopen(fileName, "rt")
	if (!file)
		return PLUGIN_HANDLED

	new Array:lines = ArrayCreate(384, 1)
	new text[384], right[128], left[128]
	new size = charsmax(text)
	while (!feof(file))
	{
		fgets(file, text, size)
		replace(text, size, "^n", "")

		if (!text[0] || text[0] == ';')
			continue

		strtok(text, left, charsmax(left), right, charsmax(right), '&')
		trim(left)
		if (equal(left, name))
			continue

		ArrayPushString(lines, text)
	}

	fclose(file)
	delete_file(fileName)

	file = fopen(fileName, "a+")
	if (!file)
		return PLUGIN_HANDLED

	size = ArraySize(lines)
	new i, temp[384], limit = charsmax(temp)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(lines, i, temp, limit)
		fprintf(file, "%s^n", temp)
	}

	fclose(file)
	ArrayDestroy(lines)
	return PLUGIN_HANDLED
}

stock add_vip_data(const playerName[], const vipLevel[], const expireTime[])
{
	if (strlen(playerName) < 3)
		return

	new path[255]
	if (get_pcvar_num(saveCust) != 1)
		get_configsdir(path, charsmax(path))
	else
	{
		new name[96]
		get_pcvar_string(saveDest, name, charsmax(name))
		formatex(path, charsmax(path), "%s", name)
	}

	new filePath[256]
	formatex(filePath, charsmax(filePath), "%s/econf/vip_manager", path)
	if (!dir_exists(filePath))
		mkdir(filePath)

	new fileName[255]
	formatex(fileName, charsmax(fileName), "%s/vip_list.ini", filePath)
	new file = fopen(fileName, "a+")
	if (!file)
		return

	if (str_to_num(vipLevel) < 0)
		fprintf(file, "%s&%s&%s^n", playerName, "0", expireTime)
	else
		fprintf(file, "%s&%s&%s^n", playerName, vipLevel, expireTime)

	fclose(file)
}