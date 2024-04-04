vim9script

import autoload './vim_assist.vim'

const Scripts = vim_assist.Scripts

var scripts_cache = Scripts()

# TODO: Use FixStack
export def StackTrace(): list<string>
    # slice(1): don't include this function in trace
    var stack = expand('<stack>')->split('\.\.')->reverse()->slice(1)
    stack->map((_, frame) => {
        return FixStackFrame(frame)
    })
    return stack
enddef

export def FixStack(argStack: string): list<string>
    #var stack = argStack->split('\.\.')->reverse()->slice(1)
    var stack = argStack->split('\.\.')
    stack->map((_, frame) => {
        return FixStackFrame(frame)
    })
    return stack
enddef

#export def FixStackFrames(frames: list<string>): list<string>
#    var stack = argStack->split('\.\.')->reverse()->slice(1)
#    stack->map((_, frame) => {
#        return FixStackFrame(frame)
#    })
#    return stack
#enddef

def FixStackFrame(frame: string): string
    # nPath is the number of path components to include
    const nPath = 2
    var m = matchlist(frame, '\v\<SNR\>(\d+)_')
    if !!m
        for _ in [1, 2]
            var path = scripts_cache->get(m[1], '')
            if !!path
                var p = path->split('[/\\]')[- nPath : ]->join('/')
                return substitute(frame, '\v\<SNR\>\d+_', p .. '::', '')
            endif
            Scripts(scripts_cache) # executes first iteration, 2nd breaks
        endfor
    elseif frame->stridx('#') >= 0
        var path = frame->split('#')
        var function = path->remove(-1)
        return '#' .. path[- nPath : ]->join('/') .. '.vim::' .. function
    endif
    return frame
enddef

#finish

######################################################################

export var stackString: string

def F0()
    #Scripts(scripts_cache) # executes first iteration, 2nd breaks
    #echo scripts_cache
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
