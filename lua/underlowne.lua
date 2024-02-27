local function islineonechar(line)
    -- check if a line is make of one char (repeated or not)
    --
    -- line without spaces
    local nospace = string.gsub(line, '%s', '')
    -- line without first char
    local nofirst = string.gsub(nospace, string.sub(nospace, 1, 1), '')
    -- two conditions to be true: 
    -- 1. line without spaces and without first char repeated is 0
    -- 2. line without spaces is not 0 (so empty lines return false)
    return string.len(nofirst) == 0 and string.len(nospace) ~= 0
end

local function isemptyline(line_nr)
    -- check if a line is only fitted with spaces
    --
    local line = vim.fn.getline(line_nr)
    local nospace = string.gsub(line, '%s', '')
    return string.len(nospace) == 0
end

local function underline(line_nr, char)
    -- underline a line like this
    -- ==========================
    -- 
    -- this function doesn't use nvim_win_get_cursor
    -- because i want it be able to be called also 
    -- from the underlining line (which i don't want to 
    -- be underlined).
    local line = vim.fn.getline(line_nr)
    local len = string.len(line)
    -- in current buffer
    local buffer = 0
    -- under current line
    -- local start_row = line_nr + 1
    local start_row = line_nr
    -- at the beginning of the line
    local start_col = 0
    -- no line is replaced
    local end_row = line_nr
    local end_col = 0
    -- the underline is the char multiplied by the length of line
    local underline_text = string.rep(char, len)
    -- do underline
    vim.api.nvim_buf_set_text(
        buffer,
        start_row,
        start_col,
        end_row,
        end_col,
        {underline_text, ""}
    )
    return start_col
end

local function tablelen(t)
    -- returns the length of a table
    --
    local len
    for i, _ in pairs(t) do len = i end
    return len
end

local function starts_with_which(line, chars)
    -- check with which element of an array a string
    -- startswith (if any).
    -- (returns index, not element.)
    local first
    local setchars
    -- get line without spaces and tabs, and get first non-space char
    first = string.sub(line, 1, 1)
    setchars = {}
    for n, i in pairs(chars) do
        setchars[i] = n
    end
    -- return a number (n-pos of char) or nil
    return setchars[first]
end

local function cyclingnextchar(chars, n)
    -- when n reach the end of a table, it returns the
    -- first elements (to simulate a cycling iteration).
    --
    local nextn = 0
    local len = tablelen(chars)
    if n < len then
        nextn = n+1
    else
        nextn = 1
    end
    return chars[nextn]
end


function Underlowne(chars)
    -- underlining for markdown
    -- rotates over styles to underline the current line
    -- typically, it would be:
    --
    -- this
    -- ----
    --
    -- and this
    -- ========
    --
    -- but as in parameter chars, any single character may be put,
    -- it could also rotate (for example) in:
    --
    -- this
    -- ////
    --
    -- and this
    -- ........
    --
    -- and also this
    -- ?????????????
    -- 
    local line
    local line_nr
    local char_n
    local nextchar
    local text_line
    local _underlined
    local cur_line_nr = vim.api.nvim_win_get_cursor(0)[1]
    for _, i in pairs({0, 1}) do
        line_nr = cur_line_nr + i
        text_line = line_nr - 1
        line = vim.fn.getline(line_nr)
        char_n = starts_with_which(line, chars)
        if char_n ~= nil and islineonechar(line) then
            nextchar = cyclingnextchar(chars, char_n)
            vim.cmd(tostring(line_nr))
            vim.api.nvim_del_current_line()
            _underlined = underline(text_line, nextchar)
            break
        end
    end
    -- if still no underlining, then add a new one without deleting anything.
    if _underlined == nil then
        line_nr = cur_line_nr + 1
        _underlined = underline(cur_line_nr, chars[1])
    end
    -- add empty line after underline (if no empty line)
    if isemptyline(line_nr+1) == false then
        vim.api.nvim_buf_set_text(0, line_nr, 0, line_nr, 0, {"", ""})
    end

    -- go back to cursor position
    vim.cmd(tostring(cur_line_nr))
end
