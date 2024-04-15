vim9script

export var rlib_dir: string

try
    import './rlib/autoload/raelity/config.vim'
    rlib_dir = config.lib_dir
    lockvar rlib_dir
    echomsg '(1) rlib_dir:' rlib_dir
    finish
catch /E1053/
    echomsg v:exception
    echomsg v:throwpoint
    echomsg 'NOT PACKAGED WITH LIB'
endtry

set runtimepath+=/src/lib/vim

import autoload 'raelity/config.vim'
rlib_dir = config.lib_dir
lockvar rlib_dir
echomsg '(2) rlib_dir:' rlib_dir
