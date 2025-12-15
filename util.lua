
function is_main(args, file_name)
    local n = select("#", args)
    if n ~= 1 then return true end
    local first = select(1, args)
    return first ~= file_name
end