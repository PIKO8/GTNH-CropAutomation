function save_config()
    local config = io.open("config.lua", "r")
    if not config then
      print("No 'config.lua' found.")
      return
    end

    local config_content = config:read("*a")
    config:close()

    local old_config = io.open("config.lua.old", "wb")
    if not old_config then
      print("Can't create 'config.lua.old'.")
      return
    end
    old_config:write(config_content)
    old_config:close()

    print("Save 'config.lua' to 'config.lua.old'")
end

function update()
    save_config()
    require("uninstall").uninstall(require("setup").scripts)
    local shell = require("shell")
    shell.execute("wget https://raw.githubusercontent.com/PIKO8/GTNH-CropAutomation/main/setup.lua")
    package.loaded["setup"] = nil
    local setup = require("setup")
    setup.install()
end

if require("util").is_main({...}, "update") then
    update()
end

return {
    update = update,
    save_config = save_config
}
