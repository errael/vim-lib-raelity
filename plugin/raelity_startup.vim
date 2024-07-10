vim9script

#echo 'RUNNING raelity_startup.vim'

export const instance_key: string = expand('<script>')

#
# There may be more than one copy of this lib.
# But there is only one global structure for all copies.
#
# TODO: There's g:['raelity'][instance_key] for each copy of raelity lib.
#       Still need to sort out how multiple versions share stuff and
#       interact; especially can each copy have it's own generated file dir...?
#

def Startup()
    if !exists("g:['raelity']")
        g:['raelity'] = {}
        g:['raelity'].lib_instances = {}
        InitStructure()
    endif
    if !exists("g:['raelity'].lib_instances[instance_key]")
        g:['raelity'].lib_instances[instance_key] = {}
    else
        echom printf("RAELITY_STARTUP: IMPOSSIBLE: '%s'", instance_key)
        echom g:['raelity']
    endif
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
        preserve_generated_files: false,
        lib_instances: {}
    })
enddef

Startup()
