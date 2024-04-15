vim9script

# StackTrace, FixStack, Func
# ScriptFileNameLookup, ScriptFiles

#
# TODO: problems if parsing a lambda
#

export def StackTrace(nPath = 3): list<string>
    # slice(1): don't include this function in trace
    return FixStack(expand('<stack>'), nPath)->reverse()->slice(1)
enddef

export def FixStack(argStack: string, nPath = 3): list<string>
    var stack = argStack->split('\.\.')
    stack->map((_, frame) => {
        return FixStackFrame(frame, nPath)
    })
    return stack
enddef

# Return the function/class.method name of the caller
export def Func(): string
    var l = expand('<stack>')->split('\.\.')

    var idx = -1                # -1 is this function, -2 is caller.
    var frame = '<lambda>'      # to get in the loop
    # Skip any lambda frame, or skip if in util.log.Log invoking lambda.
    while stridx(frame, '<lambda>') >= 0 || stridx(frame, 'util#log#Log') >= 0
        idx -= 1
        frame = l[idx]
    endwhile

    if stridx(frame, '#') >= 0
        var f = frame->split('#')[-1]
        return  matchstr(f, '\v[[:alnum:]_.]+')

    else
        return matchlist(frame, '\v\<SNR\>\d+_([[:alnum:]_.]+)')[1]
    endif
enddef

#export def FixStackFrames(frames: list<string>): list<string>
#    var stack = argStack->split('\.\.')->reverse()->slice(1)
#    stack->map((_, frame) => {
#        return FixStackFrame(frame)
#    })
#    return stack
#enddef

# nPath is the number of path components of file name to include
def FixStackFrame(frame: string, nPath = 3): string
    var m = matchlist(frame, '\v\<SNR\>(\d+)_')
    if !!m
        var path = ScriptFileNameLookup(m[1])
        if !!path
            var p = path->split('[/\\]')[- nPath : ]->join('/')
            return substitute(frame, '\v\<SNR\>\d+_', p .. '::', '')
        endif
    elseif frame->stridx('#') >= 0
        var path = frame->split('#')
        var function = path->remove(-1)
        return '#' .. path[- nPath : ]->join('/') .. '.vim::' .. function
    endif
    return frame
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

######################################################################

#finish

export var stackString: string

def F0()
    var str = expand('<stack>')
    stackString = str
enddef

def F1()
    F0()
enddef

def F2()
    F1()
enddef

def F3()
    F2()
enddef

export def Test()
    F3()
enddef
