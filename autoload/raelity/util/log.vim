vim9script

import autoload './strings.vim' as i_strings
import autoload './stack.vim' as i_stack

# TODO: If logging has been previously fully initialized, see logging_initialized,
#       then allow logging_enabled to be toggled. Stack enable/disable?

#
# Logging
#
# enables logging, if first call output time stamp
# LogInit(_fname : string, excludes: list<string> = [],
#         add_excludes: list<string> = [], remove_excludes: list<string> = [])
# throwpoint: string - stack of failure during LogInit, valid after exception
#
# Log(msgOrFunc : any, category: any = '', stack: bool = false, command: string = '')
#
# IsEnabled(category : string = ''): bool
# GetExcludeCategories() : list<string>
#
# NOTE: the log file is never trunctated, persists, grows without limit
#

var fname: string
var logging_enabled: bool = false
var logging_exclude: list<string>
var logging_initialized: bool
export var throwpoint: string

# NOTE: PROBLEM: log_init == true && logging_initialized == false

var log_init = false
export def LogInit(_fname: string, excludes: list<string> = [],
        add_excludes: list<string> = [], remove_excludes: list<string> = [])
    if !log_init
        log_init = true
        # After initializing logging exclude categories: add some, then remove some
        logging_exclude = excludes->copy()
        AddExcludeCategories(add_excludes)
        RemoveExcludeCategories(remove_excludes)
        try
            fname = _fname
            writefile([ '', '', '=== NEW_LOG: ' .. strftime('%c') .. ' ===' ], fname, "a")
            logging_enabled = true
            Log('Logging Initialized')
        catch
            logging_enabled = false
            throwpoint = v:throwpoint
            throw v:exception
        endtry
        logging_initialized = true
    endif
enddef

export def GetExcludeCategories(): list<string>
    return logging_exclude->copy()
enddef

export def IsEnabled(category_: any = ''): bool
    var category: string = printf("%s", category_)
    return logging_enabled
        && (category->empty() || logging_exclude->index(category, 0, true) < 0)
enddef

#
# Conditionally log to a file based on logging enabled and optional category.
# The message is split by "\n" and passed to writefile()
#
# Example 1: Log("The log msg")               # Output: "The log msg"
# Example 2: Log("The message", 'category')   # Output: "CATEGORY: The log msg"
# Example 3: Log(() => "message", 'category') # Output: "message"
#
# NOTE: If the first arg is a function, it is not evaluated if logging is
#       disabled or if the optional category is excluded.
# NOTE: category is convered to a string (if not already a string).
# NOTE: category is checked with ignore case, output as upper case.
#
#   - Log(msgOrFunc: string, category = '', stack = false, command = '')
#
# If optional stack is true, the stacktrace from where Log is called
# is output to the log.
#
# If optional command, the command is run using execute() and the command
# output is output to the log.
#
export def Log(msgOrFunc: any, category_: any = '',
        stack: bool = false, command: string = '')
    if ! logging_enabled
        return
    endif
    if !!category_ && type(category_) != v:t_enumvalue
        Log('LOG CATEGORY NOT AN ENUMVALUE: ' .. category_, '', true)
    endif
    var category: string = printf("%s", category_)
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

def AddExcludeCategories(excludes: list<string>)
    for category in excludes
        var idx = logging_exclude->index(category)
        if idx < 0
            logging_exclude->add(category)
        endif
    endfor
enddef

def RemoveExcludeCategories(excludes: list<string>)
    for category in excludes
        var idx = logging_exclude->index(category)
        if idx >= 0
            logging_exclude->remove(idx)
        endif
    endfor
enddef
