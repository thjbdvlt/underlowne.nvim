-- underlowne
--
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

-- note on string length:
-- in most casse, i use `vim.fn.strdisplaywidth(s)` and not lua 
-- standard `string.len(s)` because it count byte and not visual char
-- (and i want visual char count: i.e. à has length 1, not 2).
-- but in one case (for vim.api.nvim_buf_set_text(), i use 
-- string.len(), because the byte length is required.

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
    return vim.fn.strdisplaywidth(nofirst) == 0
    and vim.fn.strdisplaywidth(nospace) ~= 0
end

local function isemptyline(line_nr)
    -- check if a line is only fitted with spaces
    --
    local nospace = string.gsub(vim.fn.getline(line_nr), '%s', '')
    return vim.fn.strdisplaywidth(nospace) == 0
end

local function trailingspace(s)
    local y, n = "", 0
    for i=1, vim.fn.strdisplaywidth(s), 1 do
        local x = string.sub(s, i, i)
        if x == ' ' then
            y = y .. x
            n = n + 1
        else break
        end
    end
    return y, n
end

local function linetochar(line, char)
    -- get a representation of a line in which every character is 
    -- replace by `char`, starting at first non-space character and 
    -- ending at last non-space character.
    --
    local line_start, n_start = trailingspace(line)
    local _, n_end = trailingspace(string.reverse(line))
    local n_margins = n_start + n_end
    local n_text = vim.fn.strdisplaywidth(line) - n_margins
    local text = string.rep(char, n_text)
    local underline = line_start .. text
    return underline
end

local function underline(line_nr, char)
    --         =========
    -- 
    local line = vim.fn.getline(line_nr)
    -- here i use strlen() and not ...displaywith() because it's 
    -- the byte length that is used for nvim_buf_set_text().
    local len = vim.fn.strlen(line)
    local buffer = 0
    local row = line_nr - 1
    local underline_text = linetochar(line, char)
    vim.api.nvim_buf_set_text(
        buffer, row, len, row, len, {"", underline_text}
    )
    return row
end

local function tablelen(t)
    local len for i, _ in pairs(t) do len = i end return len
end

local function starts_with_which(line, chars)
    -- check with which element of an array a string
    -- startswith (if any). 
    --
    local first = string.sub(string.gsub(line, " ", ""), 1, 1)
    local setchars = {}
    for n, i in pairs(chars) do setchars[i] = n end
    return setchars[first]  -- returns index (not element) or nil.
end

local function cyclingnextchar(chars, n)
    -- when n reach the end of a table, it returns the
    -- first elements (to simulate a cycling iteration).
    --
    local nextn = 0
    local len = tablelen(chars)
    if n < len then nextn = n+1 else nextn = 1 end
    return chars[nextn]
end


function Underlowne(chars, c)
    local line, line_nr, char_n, nextchar, text_line
    local _underlined = nil
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
            _underlined = underline(text_line, nextchar, c)
            -- TODO: il faudrait call underline plus tard, le plus tard possible. comme ça je fais que une seule fois le test des chars...
            break
        end
    end

    -- if still no underlining, then add a new one without deleting anything.
    if _underlined == nil and isemptyline(cur_line_nr) == false then
        line_nr = cur_line_nr + 1
        _underlined = underline(cur_line_nr, chars[1], c)
    end

    -- add empty line after underline (if no empty line)
    if isemptyline(line_nr+1) == false  and _underlined ~= nil then
        vim.api.nvim_buf_set_text(0, line_nr, 0, line_nr, 0, {"", ""})
    end

    -- go back to cursor position
    vim.cmd(tostring(cur_line_nr))
end
