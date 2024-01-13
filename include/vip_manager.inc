#if defined _vip_manager_included
	#endinput
#endif
#define _vip_manager_included

/**
 * Returns whether a player is a vip.
 *
 * @param id	Player index.
 * @return		True if it is, false otherwise.
 */
native is_user_vip(id)

/**
 * Returns a player's vip level, do not use it without is_user_vip native.
 *
 * @param id	Player index.
 * @return		Player's vip level, 0 by default.
 */
native get_user_vip_level(id)

/**
 * Called when user set as vip after put in server.
 *
 * @note Use PLUGIN_HANDLED for block it.
 *
 * @param id	Player index.
 * @param level	Player's vip level.
 */
forward vip_putinserver(id, level)

/**
 * Called when vip disconnected from the server.
 *
 * @param id	Player index.
 * @param level	Player's vip level.
 */
forward vip_disconnected(id, level)
