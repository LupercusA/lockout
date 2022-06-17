
lockout.settings.demand_server_txt = minetest.settings:get("lockout.missing_server_text")
if lockout.settings.demand_server_txt == nil then
    lockout.settings.demand_server_txt = "Server is closed right now, try again a bit later."
    minetest.settings:set("lockout.missing_server_text", lockout.settings.demand_server_txt)
end

lockout.settings.whitelist_txt = minetest.settings:get("lockout.whitelisted_text")
if lockout.settings.whitelist_txt == nil then
    lockout.settings.whitelist_txt = "You don't appear to be allowed on this server at the moment."
    minetest.settings:set("lockout.whitelisted_text", lockout.settings.whitelist_txt)
end

lockout.settings.wrong_server_pass_txt = minetest.settings:get("lockout.invalid_server_password_text")
if lockout.settings.wrong_server_pass_txt == nil then
    lockout.settings.wrong_server_pass_txt = "Wrong Server Password, Try that again."
    minetest.settings:set("lockout.invalid_server_password_text", lockout.settings.wrong_server_pass_txt)
end
