vim9script

var testing = false

# Keystrokes
#       Keys2str
# Text properties
#       PropRemoveIds
# General
#       Scripts
#       EQ, IS
#       BounceMethodCall,   (WORKAROUND)
#       IsSameType (TEMP WORKAROUND, instanceof on the way)
# ##### HexString

# experimental, would need another version that returns a value
def WrapCall(fcall: string): func
    var x =<< trim eval [CODE]
        g:SomeRandomFunction = () => {{
            {fcall}
            }}
    [CODE]

    execute(x)
    var t = g:SomeRandomFunction    
    unlet g:SomeRandomFunction
    return t
enddef
#var X = WrapCall('inScript.M1("Wrap Lambda")')
#X()

###
### General
###

# Minor error, not worthy of a popup
export def Bell(force = true)
    if force || &errorbells
        normal \<Esc>
    endif
    echohl ErrorMsg
    echomsg "Oops!"
    echohl None
enddef

# Create/update scripts dictionary.
var scripts_cache: dict<string> = {}

# return '' if not found
export def ScriptFileNameLookup(sid: string): string
    var path = scripts_cache->get(sid, '')
    if !! path
        return path
    endif
    ScriptFiles()
    return scripts_cache->get(sid, '')
enddef

# TODO: seperate method that returns readonly copy/version.

# Update and return current dictionary
export def ScriptFiles(): dict<string>
    if scripts_cache->empty()
        for info in getscriptinfo()
            scripts_cache[info.sid] = info.name
        endfor
    else
        for info in getscriptinfo()
            if ! scripts_cache->has_key(info.sid)
                scripts_cache[info.sid] = info.name
            endif
        endfor
    endif
    return scripts_cache
enddef
#def DumpScripts(scripts: dict<string>)
#    for i in scripts->keys()->sort('N')
#        echo i scripts[i]
#    endfor
#enddef

# https://github.com/vim/vim/issues/10022 (won't fix)
export def EQ(lhs: any, rhs: any): bool
    return type(lhs) == type(rhs) && lhs == rhs
enddef
export def IS(lhs: any, rhs: any): bool
    return type(lhs) == type(rhs) && lhs is rhs
enddef

################################### moved to with.vim

################### moved to dicts.vim

################## moved to lists.vim

###
### Text properties
###

# not correctly implememnted, if it should be...
#export def DeleteHighlightType(type: string, d: dict<any> = null_dict)
#    prop_remove({type: prop_command, bufnr: hudbufnr, all: true})
#enddef

export def PropRemoveIds(ids: list<number>, d: dict<any> = null_dict)
    var props: dict<any> = { all: true }
    props->extend(d)
    ids->filter( (_, v) => {
        props['id'] = v
        prop_remove(props)
        return false
        })
enddef

###
### Keystrokes
###

#
# if a character is > 0xff, this will probably fail
# There's experiment/vim/Keys2Str.vim with tests
#
def StripCtrlV(k: string): list<number>
    var result: list<number>
    var i = 0
    var l = str2list(k)
    while i < len(l)
        var n = l[i]
        if false
            var c = k[i]
            var l = str2list(c)
            echo 'c: ' c 'list:' l 'hex:' printf("%x", l[0])
                        \'n:' n 'char:' nr2char(l[0])
        endif
        if n == 0x16
            # Skip ^v. If it's the last char, then keep it
            if i + 1 < len(l)
                i += 1
                n = l[i]
            endif
        endif
        result->add(n)
        i += 1
    endwhile
    return result
enddef

const up_arrow_nr: number = char2nr('^')
const back_slash_nr: number = char2nr('\')

export def Keys2Str(k: string, do_escape = true): string
    def OneChar(x: number): string
        if x == 0x20
            return '<Space>'
        elseif do_escape && x == up_arrow_nr
            return '\^'
        elseif do_escape && x == back_slash_nr
            return '\\'
        elseif x < 0x20
            return '^' .. nr2char(x + 0x40)
        endif
        return nr2char(x)
    enddef

    var result: string
    var l = StripCtrlV(k)
    for n in l
        if n < 0x80
            result = result .. OneChar(n)
        else
            result = result .. '<M-' .. OneChar(n - 0x80) .. '>'
        endif
    endfor
    return result
enddef

############## moved to strings.vim

###
### Expected to be deprecated, 
###

export def IsSameType(o: any, type: string): bool
    return type(o) == v:t_object && type == typename(o)[7 : -2]
    #return type(o) == v:t_object && type == string(o)->split()[2]
enddef

### BounceMethodCall
#
# The idea is to do invoke an object method with args where the
# args and method are passed in as a single string. For example:
# BounceMethodCall(obj, 'M' .. '1' .. '("stuff")') does obj.M1("stuff")
# (see https://github.com/vim/vim/issues/12054)
#
# If a constructed string is not required, 'M, better to
# use a lambda that invokes the object and method, "() => obj.method",
#
# And now you can do (where obj.F takes varargs)
#       def F0(X: func(...list<string>): void, ...args: list<string>)
#           call(X, args)
#       enddef
#       F0(obj.F, 'x', 'y')
#       
var bounce_obj: any = null_object
export def BounceMethodCall(obj: any, method_and_args: string)
    bounce_obj = obj
    execute "bounce_obj." .. method_and_args
enddef

#finish

# just use echo 
#export def HexString(in: string, space: bool = false, quot: bool = false): string
#    var out: string
#    for c in str2list(in)
#        if space
#            if out != '' | out ..= ' ' | endif
#        endif
#        out ..= printf('%2x', c)
#    endfor
#    return quot ? "'" .. out .. "'" : out
#enddef

if  !testing
    finish
endif

############################################################################
############################################################################
############################################################################

# With these 3 lines in a buffer (starting with 0) source this from that buffer
# -->12345678
# -->12345678
# -->12345678
# -->12345678

def RepStr(inp: string, col: number, repStr: string)
    var rv = Replace(inp, col, repStr)
    echo printf("col %d '%s', '%s' --> '%s'", col, repStr, inp, rv)
enddef

def T1()
    var inp = '12345678'
    RepStr(inp, 3, 'foo')
    RepStr(inp, 5, 'foo')
    RepStr(inp, 6, 'foo') # one char too many
enddef

def T2()
    ReplaceBuf(bufnr(), 1, 3, 'foo') # somewhere in the middle
    ReplaceBuf(bufnr(), 2, 6, 'foo') # fits, to end of line
    ReplaceBuf(bufnr(), 3, 7, 'foo') # overlaps end of line
    ReplaceBuf(bufnr(), 3, 6, 'X')
    ReplaceBuf(bufnr(), 3, 6, 'Z')
    ReplaceBuf(bufnr(), 3, 0, 'Y') # there is no column 0, ends up at 1

enddef

T1()

# vim:ts=8:sts=4:
