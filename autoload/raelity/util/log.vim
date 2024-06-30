vim9script

import autoload './strings.vim' as i_strings
import autoload './stack.vim' as i_stack

#
# Logging
#
# LogInit(fname) - enables logging, if first call output time stamp
# Log(string) - append string to Log if logging enabled
#
# NOTE: the log file is never trunctated, persists, grows without limit
#

var fname: string
var logging_enabled: bool = false
var logging_exclude: list<string>

# TODO: AddExclude/RemoveExclude methods in here.
export def SetExcludeCategories(excludes: list<string>)
    logging_exclude = excludes
enddef

# TODO: popup?
def Logging_problem(s: string, isException = false)
    var fullLogMsg = s
    var fullMsg = s

    if isException
        fullLogMsg = printf("%s.\n    Line: %s\n    Caught: %s",
            s, v:throwpoint, v:exception)
        fullMsg = printf("%s. Line: %s, Caught: %s",
            s, v:throwpoint, v:exception)
    endif

    Log(fullMsg, 'internal_error', true)
    echomsg expand("<stack>")
    echomsg fullMsg
enddef

#
# Conditionally log to a file based on logging enabled and optional category.
# The message is split by "\n" and passed to writefile()
# Output example: "The log msg"
# Output example: "CATEGORY: The log msg"
# NOTE: category is checked with ignore case, output as upper case
#
#   - Log(msg: string [, category = ''[, stack = false[, command = '']]])
#   - Log(func(): string [, category = ''[, stack = false[, command = '']]])
#
# If optional stack is true, the stacktrace from where Log is called
# is output to the log.
#
# If optional command, the command is run using execute() and the command
# output is output to the log.
#
export def Log(msgOrFunc: any, category: string = '',
        stack: bool = false, command: string = '')
    if ! logging_enabled
        return
    endif
    if !!category && logging_exclude->index(category, 0, true) >= 0
        return
    endif

    var msg: string
    if !!category
        msg = category->toupper() .. ': '
    endif

    var msg_type = type(msgOrFunc)
    if msg_type == v:t_string 
        msg ..= <string>msgOrFunc
    elseif msg_type == v:t_func
        try
            var F: func = msgOrFunc
            msg ..= F()
        catch
            Logging_problem(printf("LOGGING USAGE BUG: FUNC: %s", typename(msg)), true)
            return
        endtry
    else
            Logging_problem(printf("LOGGING USAGE BUG: msg TYPE: %s.", typename(msgOrFunc)))
            return
    endif

    if stack
        msg ..= "\n  stack:"
        var stack_info = i_stack.StackTrace()->slice(1)
        msg ..= "\n" .. i_strings.IndentLtoS(stack_info)
    endif

    if !!command
        msg ..= "\n" .. "  command '" .. command .. "' output:"
        try
            msg ..= "\n" .. execute(command)->split("\n")->i_strings.IndentLtoS()
        catch
            Logging_problem(printf("LOGGING USAGE BUG: command : %s", command), true)
            return
        endtry
    endif

    writefile(msg->split("\n"), fname, 'a')
enddef

export def LogStack(tag: string = '')
    Log(tag .. ': ' .. expand('<stack>'))
enddef

var log_init = false
export def LogInit(_fname: string)
    if !log_init
        fname = _fname
        logging_enabled = true
        writefile([ '', '', '=== ' .. strftime('%c') .. ' ===' ], fname, "a")
        log_init = true
    endif
enddef



