vim9script

# Strings and lists of strings
#       Pad, IndentLtoS, IndentLtoL
#       Replace, ReplaceBuf

###
### Strings and lists of strings
###


# Overwrite characters in string, if doesn't fit print error, do nothing.
# Return new string, input string not modified.
# NOTE: col starts at 0
export def Replace(s: string, col0: number, newtext: string): string
    if col0 + len(newtext) > len(s)
            echoerr 'Replace: past end' s col0 newtext
            return s->copy()
    endif
    return col0 != 0
        ? s[ : col0 - 1] .. newtext .. s[col0 + len(newtext) : ]
        : newtext .. s[len(newtext) : ]
enddef
#export def Replace(s: string,
#        pos1: number, pos2: number, newtext: string): string
#    return pos1 != 0
#        ? s[ : pos1 - 1] .. newtext .. s[pos2 + 1 : ]
#        : newtext .. s[pos2 + 1 : ]
#enddef

# NOTE: setbufline looses text properties.

# Overwrite characters in a buffer, if doesn't fit print error and do nothing.
# NOTE: col starts at 1
export def ReplaceBuf(bnr: number, lino: number,
        col: number, newtext: string)
    if bnr != bufnr()
        echoerr printf('ReplaceBuf(%d): different buffer: curbuf %d', bnr, bufnr())
        return
    endif
    if col - 1 + len(newtext) > len(getbufoneline(bnr, lino))
            echoerr printf(
                "ReplaceBuf: past end: bnr %d, lino %d '%s', col %d '%s'",
                bnr, lino, getbufoneline(bnr, lino), col, newtext)
            return
    endif
    setpos('.', [bnr, lino, col, 0])
    execute('normal R' .. newtext)
enddef


# Indent each element of list<string>, return a single string
export def IndentLtoS(l: list<string>, nIndent: number = 4): string
    if !l
        return ''
    endif
    var indent = repeat(' ', nIndent)
    l[0] = indent .. l[0]
    return l->join("\n" .. indent)
enddef

# indent each element of l in place
def IndentLtoL(l: list<string>, nIndent: number = 4): list<string>
    if !l
        return l
    endif
    var indent = repeat(' ', nIndent)
    return l->map((_, v) => indent .. v)
enddef

#export def MaxW(l: list<string>): number
#    return max(l->mapnew((_, v) => len(v)))
#enddef

# The list is transformed, do a copy first if you want the original
# a     - alignment (first char), 'l' - left (default), 'r' - right, 'c' - center
# w     - width, default 0 means width of longest string;
#         if negative, then max of longest string and -w, so at least -w.
# ret_off - only centering, if not null, the calculated offsets returned
# can be used with chaining

export def Pad(l: list<string>, a: string = 'l',
        _w: number = 0,
        ret_off: list<number> = null_list): list<string>
    var w: number
    if _w > 0
        w = _w
    else
        # need to know the longest string
        w = max(l->mapnew((_, v) => len(v)))
        # if param is 0, use the longest string;
        # otherwise param w might override longest string.
        w = _w == 0 ? w : max([-_w, w])
    endif
    if a[0] != 'c'
        var justify = a[0] == 'r' ? '' : '-'
        return l->map((_, v) => printf("%" .. justify .. w .. "s", v))
    else
        return l->map((_, v) => {
            if len(v) > w
                throw "Pad: string '" .. v .. "' larger that width '" .. w .. "' "
            endif
            var _w1 = (w - len(v)) / 2
            var _w2 = w - len(v) - _w1
            if ret_off != null | ret_off->add(_w1) | endif
            #like: printf("%-15s%5s", str, '')
            return printf("%" .. (_w1 + len(v)) .. "s%" .. _w2 .. "s", v, '')
            })
    endif
enddef

#for l1 in Pad(['x', 'dd', 'sss', 'eeee', 'fffff', 'gggggg'], 'c', 12)
#    echo l1
#endfor
#for l1 in Pad(['x', 'dd', 'sss', 'eeee', 'fffff', 'gggggg', 'ccccccc'], 'c', 12)
#    echo l1
#endfor
