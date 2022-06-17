
lockout = {}

lockout.modpath = minetest.get_modpath("lockout")
lockout.store = minetest.get_mod_storage()

lockout.settings = {}
dofile(lockout.modpath.."/settings.lua")
dofile(lockout.modpath.."/tools.lua")

lockout.save_settings = function ()
    if lockout.settings.whitelist_mode == true then
        lockout.store:set_int("lockout_whitelist_mode", 1)
    else
        lockout.store:set_int("lockout_whitelist_mode", 0)
    end
    lockout.store:set_string("lockout_whitelist", lockout.settings.whitelist)
    lockout.store:set_string("lockout_server_pass", lockout.settings.server_pass)
    if lockout.settings.demand_server == true then
        lockout.store:set_int("lockout_demand_server", 1)
    else
        lockout.store:set_int("lockout_demand_server", 0)
    end
end

lockout.load_settings = function ()
    if lockout.store:get("lockout_demand_server") ~= nil then
        if lockout.store:get_int("lockout_whitelist_mode") == 1 then
            lockout.settings.whitelist_mode = true
        else
            lockout.settings.whitelist_mode = false
        end
        lockout.settings.whitelist = lockout.store:get_string("lockout_whitelist")
        lockout.settings.server_pass = lockout.store:get_string("lockout_server_pass")
        if lockout.store:get_int("lockout_demand_server") == 1 then
            lockout.settings.demand_server = true
        else
            lockout.settings.demand_server = false
        end
    else
        lockout.settings.whitelist_mode = false
        lockout.settings.whitelist = ""
        lockout.settings.server_pass = ""
        lockout.settings.demand_server = true
    end
end

lockout.load_settings()

lockout.formspec = function ()
    lockout.load_settings()

    local demand_server = ""
    if lockout.settings.demand_server == true then
        demand_server = "Demand 'server' priv: ON"
    else
        demand_server = "Demand 'server' priv: OFF"
    end

    local whitelist_mode = ""
    if lockout.settings.whitelist_mode == true then
        whitelist_mode = "Whitelist: ON"
    else
        whitelist_mode = "Whitelist: OFF"
    end
    local whitelist = lockout.settings.whitelist

    local server_pass = lockout.settings.server_pass

    local gui = ""
    .."size[9, 10]"
    .."button[1, 1; 7, 1;demand_server;".. minetest.formspec_escape(demand_server) .."]"

    .."button[1, 2; 7, 1;whitemode;".. minetest.formspec_escape(whitelist_mode) .."]"
    if lockout.settings.whitelist_mode == true then
       gui = gui .."textarea[1, 3.5;8, 5;whitelist;;"..minetest.formspec_escape(whitelist).."]"
    else
        gui = gui .."textarea[1, 3.5;8, 5;;;"..minetest.formspec_escape(whitelist).."]"
    end
    gui = gui .. ""

    .."field[2, 8;5, 1;server_pass;;"..minetest.formspec_escape(server_pass).."]"

    .."field_close_on_enter[whitelist;false]"
    .."field_close_on_enter[server_pass;false]"

    .."button_exit[3, 9;3, 1;save;Save]"

    return gui
end

lockout.formspec_pass = function ()
    local gui = ""
    .."size[5, 2]"
    .."field[0.5,1; 4,1;pass;Server Password;]"
    .."field_close_on_enter[pass;true]"

    return gui
end

lockout.show = function (name)
    minetest.show_formspec(name, "lockout:lock", lockout.formspec())
end

lockout.show_svr_pass = function (name)
    minetest.show_formspec(name, "lockout:svr_pass", lockout.formspec_pass())
end

-- Config
minetest.register_chatcommand("lockout", {
    privs = {
        server = true
    },
    func = function (name)
        lockout.show(name)
    end
})

-- Test of password prompt (will kick if you misstype password too)
minetest.register_chatcommand("lockout_pass", {
    privs = {
        server = true
    },
    func = function (name)
        lockout.show_svr_pass(name)
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    lockout.load_settings()
    if formname == "lockout:lock" then
        if fields.demand_server then
            lockout.settings.whitelist = tostring(fields.whitelist)
            lockout.settings.server_pass = tostring(fields.server_pass)
            if lockout.settings.demand_server == true then
                lockout.settings.demand_server = false
                lockout.save_settings()
                lockout.show(player:get_player_name())
            else
                lockout.settings.demand_server = true
                lockout.save_settings()
                lockout.show(player:get_player_name())
            end
        end
        if fields.whitemode then
            lockout.settings.whitelist = tostring(fields.whitelist)
            lockout.settings.server_pass = tostring(fields.server_pass)
            if lockout.settings.whitelist_mode == true then
                lockout.settings.whitelist_mode = false
                lockout.save_settings()
                lockout.show(player:get_player_name())
            else
                lockout.settings.whitelist_mode = true
                lockout.save_settings()
                lockout.show(player:get_player_name())
            end
        end
        if fields.save then
            lockout.settings.whitelist = tostring(fields.whitelist)
            lockout.settings.server_pass = tostring(fields.server_pass)
            lockout.save_settings()
        end
    elseif formname == "lockout:svr_pass" then
        if fields.pass ~= nil then
            if lockout.settings.server_pass ~= "" and string.byte(fields.pass) ~= string.byte(lockout.settings.server_pass) then
                local pname = player:get_player_name()
                if not minetest.check_player_privs(pname, {server = true}) and pname ~= "singleplayer" then
                    minetest.kick_player(pname, lockout.settings.wrong_server_pass_txt)
                end
                minetest.log("warning", "[lockout] '"..pname.."' attempted to login with invalid server password, '"..fields.pass.."'.")
            end
        end
    end
end)

-- If in demand server priv mode or whitelist mode then perform these pre-checks
minetest.register_on_joinplayer(function (name, ip)
    lockout.load_settings()
    local pname = name:get_player_name()
    if minetest.check_player_privs(pname, {server = true}) and string.byte(pname) == string.byte("singleplayer") then
        return
    end
    if lockout.settings.demand_server == true then
        if not minetest.check_player_privs(pname,  {server=true}) then
            minetest.kick_player(pname, lockout.settings.demand_server_txt)
        end
    else
        if lockout.settings.whitelist_mode == true then
            local names = lockout.tools.split(lockout.settings.whitelist, "\n")
            local check = false
            for _, n in ipairs(names) do
                if string.byte(pname) == string.byte(n) then
                    check = true
                    break
                end
            end
            if check == false then
                minetest.kick_player(pname, lockout.settings.whitelisted_txt)
            end
        end
        if lockout.settings.server_pass ~= "" then
            if not minetest.check_player_privs(pname, {server = true}) and pname ~= "singleplayer" then
                minetest.log("action", "[lockout] Showing Server Password to '"..pname.."'...")
                lockout.show_svr_pass(pname)
            end
        end
    end
end)

minetest.log("action", "[lockout] Version: 0.0.1")
minetest.log("action", "[lockout] Ready!")
