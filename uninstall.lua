local shell = require('shell')

-- UNINSTALL
function uninstall(scripts)
    for i=1, #scripts do
        shell.execute(string.format('rm %s', scripts[i]))
        print(string.format('Uninstalled %s', scripts[i]))
    end
end

local util = require("util")
if util.is_main({...}, 'uninstall') then
    local scripts = require('setup').scripts
    table.insert(scripts, 'setup.lua')
    uninstall(scripts)
end