local shell = require('shell')

-- UNINSTALL
function uninstall(scripts)
    for i=1, #scripts do
        shell.execute(string.format('rm %s', scripts[i]))
        print(string.format('Uninstalled %s', scripts[i]))
    end
end

if require("util").is_main({...}, 'uninstall') then
    local scripts = require('setup').scripts
    uninstall(scripts)
end