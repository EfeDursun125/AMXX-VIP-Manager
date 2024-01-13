# AMXX-VIP-Manager
Configurable vip manager with native and forward for amxmodx with some built-in vip plugins, it has auto deletion after remaining days end

# HOW TO USE?
- amx_vm_add <player name | steamid | ip> - <infinite | expire day> - <vip level | 0 by default>
- amx_vm_remove <player name | steamid | ip>

# CVars
- amx_vm_version // returns the plugin version
- amx_vm_list // lists the all vip players with remaining days to expire
- amx_vm_tag_use_custom_folder "0" // to save custom dir, multi server support (2 servers 1 save file, players will be happy)
- amx_vm_custom_folder_dest "C:\ExampleFolder\cstrike\addons\amxmodx\configs" // path for custom dir, multiple servers can acces this path
- amx_vm_save_type "0" // 0 = player name, 1 = steamid, 2 = ip
- !vm_show_rt // say command, shows how many days remaining to expire (only vip players can use it)

# Natives
is_user_vip(id) = returns 1 if is user vip, 0 otherwise
get_user_vip_level(id) = as the native name says

# Forwards
vip_putinserver(id, level) = called after player is registered as vip, use PLUGIN_HANDLED for block player being vip
vip_disconnected(id, level) = Called after vip disconnected from the server
