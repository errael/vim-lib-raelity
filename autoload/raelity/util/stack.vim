vim9script

import autoload './vim_extra.vim'

const ScriptFileNameLookup = vim_extra.ScriptFileNameLookup

#
# TODO: problems if parsing a lambda
#

# TODO: Use FixStack
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
# TODO: problems if lambda
export def Func(): string
    var frame = expand('<stack>')->split('\.\.')[-2]
    return matchlist(frame, '\v\<SNR\>\d+_([[:alnum:]_.]+)')[1]
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
