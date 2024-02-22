# Amx Mod X VIP Manager
Configurable vip manager with native and forward for amxmodx with some built-in vip plugins, it has auto deletion after remaining days end

# HOW TO USE?
Note: vip_manager is the MAIN plugin, others are OPTIONAL!

- amx_vm_add <player name | steamid | ip> <infinite | expire day> <vip level | 0 by default>
- amx_vm_remove <player name | steamid | ip>

Example: "amx_vm_add EfeDursun125 infinite 1"

Result: EfeDursun125 is added to the vip_lists.ini with infinite time, you can infinite with days like: "amx_vm_add EfeDursun125 30 1" after that EfeDursun125 will be removed from the vip_lists.ini after 30 days

Note: The last 1 stands for vip levels, so you can sell more vips, like 0 = normal vip, 1 = mvp and 2 = mvp+ etc.

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
vip_disconnected(id, level) = called after vip disconnected from the server
