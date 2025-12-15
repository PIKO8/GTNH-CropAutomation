local shell = require('shell')
local args = {...}
local branch
local repo
local scripts = {
    'action.lua',
    'database.lua',
    'events.lua',
    'gps.lua',
    'scanner.lua',
    'config.lua',
    'autoStat.lua',
    'autoTier.lua',
    'autoSpread.lua',
    'storage.lua',
    'util.lua',
    'uninstall.lua',
}

-- BRANCH
if #args >= 1 then
    branch = args[1]
else
    branch = 'main'
end

-- REPO
if #args >= 2 then
    repo = args[2]
else
    repo = 'https://raw.githubusercontent.com/PIKO8/GTNH-CropAutomation/'
end

function is_main(args, file_name)
    local n = select("#", args)
    if n ~= 1 then return true end
    local first = select(1, args)
    return first ~= file_name
end

function install(repo1, branch1, scripts1)
    for i=1, #scripts1 do
        shell.execute(string.format('wget -f %s%s/%s', repo1, branch1, scripts1[i]))
    end
end

-- INSTALL
if is_main(args, 'setup') then
    install( repo, branch, scripts)
end
return {
    install = install,
    scripts = scripts,
    repo = repo,
    branch = branch,
}