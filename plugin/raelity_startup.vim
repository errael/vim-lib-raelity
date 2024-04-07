vim9script

echo 'RUNNING raelity_startup.vim'

var initialized: bool

def Startup()
    if initialized
        return
    endif

    if exists("g:['raelity']")
        throw "Illegal State: config directory already initialized"
    endif
    g:['raelity'] = {}
    InitStructure()

    initialized = true
enddef

# DO NOT USE THIS
export def DebugInitStructure()
    InitStructure()
enddef

# There will be an exception if "g:['raelity']" does not exist.
def InitStructure()
    var is_debug = false
    if exists("g:['raelity'].is_debug")
        is_debug = g:['raelity'].is_debug
        #echo 'Propogating is_debug:' is_debug
    endif
    # clear the dictionary, never replace.
    var rdict = g:['raelity']
    rdict->filter((_, _) => false)
    rdict->extend({
        generated_dir: {},    ### A "set" of string file names
        generated_other: {},    ### A "set" of string file names
        is_debug: is_debug,
        preserve_generated_files: false
    })
enddef

Startup()
