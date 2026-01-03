
function is_main(args, file_name)
    local n = select("#", args)
    if n ~= 1 then return true end
    local first = select(1, args)
    return first ~= file_name
end

function check_growth(is_full, crop)
    if is_full then
        return crop.size == crop.max
    else
        return crop.size >= crop.max - 1
    end
end

return {
    is_main = is_main,
    check_growth = check_growth,
}