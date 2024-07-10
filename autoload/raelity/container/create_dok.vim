vim9script

import '../config.vim' as i_config

# Exported functions
#       CreateDOK - generate a file that defines a dictionary
#       ResetDefaults - 

# Create a file that is a subclass of DictObjKeyBase, then it can be imported.
# This can be used dynamically (beware import but not yet created),
# or wrapped in a script to create dictionaries that are checked in.
#
# Arguments are
# - target_file_name: string - relative and no initial '.' ==> generated dir.
#                              See raelity/config.GenFilePath().
# - DictClassName: string
# - KeyType: string
# - ValueType: string
# - header: list<string> = []  - additional text for file, typically imports.
# - base_import = "import autoload 'raelity/container/dict_ok.vim'"
# - base_name = "dict_ok.DictObjKeyBase"
# - get_default = "null" -  What Get returns if no default specified;
#                           if not specified, tries to guess a zero/null type.
#
#       var fname = CreateDOK('mystuff/foo.vim', 'SomeClassDict',
#           'bar.SomeClass', 'list<string>',
#           ['import "./bar.vim"'])
# returns
#       "/designated/loc/generated_vim_files_directory/mystuff/foo.vim"
#
# generates
#       vim9script
#       
#       import autoload 'raelity/container/dict_ok.vim'
#       import "./bar.vim"
#       
#       type KeyType = bar.SomeClass
#       type ValueType = list<string>
#       
#       export class SomeClassDict extends dict_ok.DictObjKeyBase
#       ...

const NO_DEFAULT = "NO_DEFAULT"

# ResetDefaults restores these
var reset_default_header: list<string> = []
var reset_default_base_import = "import autoload 'raelity/container/dict_ok.vim'"
var reset_default_base_name = "dict_ok.DictObjKeyBase"
var reset_default_get_default = NO_DEFAULT

# These can be individually changed
export var default_header = reset_default_header
export var default_base_import = reset_default_base_import
export var default_base_name   = reset_default_base_name
export var default_get_default   = reset_default_get_default

export def CreateDOK(
        arg_target_fn: string,
        dict_class_name: string,
        key_type: string,
        value_type: string,
        header: list<string> = default_header,
        base_import: string = default_base_import,
        base_name: string = default_base_name,
        get_default: string = default_get_default)

    # TODO: guess at "get_default" if not specified

    var lines = Interpolate(dict_class_name, key_type, value_type, header,
                base_import, base_name,
                get_default != NO_DEFAULT ? get_default : "null")

    var pathinfo = i_config.GenFilePathInfo(arg_target_fn)
    var target_fn = pathinfo[0]

    var same = CompareFile(target_fn, lines)
    if ! same
        writefile(lines, target_fn)
    endif
    var d: dict<bool> = g:['raelity'][
        pathinfo[1] ? "generated_dir" : "generated_other" ]
    d[target_fn] = true

enddef

export def ResetDefaults()
    default_header = reset_default_header
    default_base_import = reset_default_base_import
    default_base_name   = reset_default_base_name
    default_get_default   = reset_default_get_default
enddef

def Interpolate(
        dict_class_name: string,
        key_type: string,
        value_type: string,
        header: list<string>,
        base_import: string,
        base_name: string
        get_default: string
): list<string>

    var lines =<< trim eval END
        vim9script

        type KeyType = {key_type}
        type ValueType = {value_type}

        export class {dict_class_name} extends {base_name}

            def Put(key: KeyType, value: ValueType)
                this._d[id(key)] = [ key, value ]
            enddef

            # If key not in dict, then return default.
            # Probably get an error if key not found and no default specified
            def Get(key: KeyType, default: any = {get_default}): ValueType
                var val = this._d->get(id(key), null)
                if val != null
                    return val[1]
                endif
                return default
            enddef

            def HasKey(key: KeyType): bool
                return this._d->hasKey(id(key))
            enddef

            # Keys()/Values()/Items() don't lock can modify things deeper into dict
            def Keys(): list<KeyType>
                return this._d->values()->mapnew((i, k) => k[0])
            enddef

            def Values(): list<ValueType>
                return this._d->values()->mapnew((i, k) => k[1])
            enddef

            def Items(): list<any>
                return this._d->values()
            enddef

            def HasStringKey(stringkey: KeyType): bool
                return this._d->hasKey(stringkey)
            enddef

            def StringKeyToObj(stringkey: string): KeyType
                return this._d[stringkey][0]
            enddef
        endclass
    END

    return flattennew([lines[0], ['', base_import], header, lines[1 :]])

enddef

def ReadFile(fn: string): list<string>
    var l: list<string>
    try
        l = readfile(fn, '')
    catch /E484:\|E485/
        DebugMsg(() => printf("ReadFile Exception: %s", v:exception))
        return null_list
    endtry
    return l
enddef

def IsDebug(): bool
    return g:['raelity'].is_debug
enddef

def DebugMsg(Msg: func(): string)
    if g:['raelity'].is_debug
        echomsg Msg()
    endif
enddef

# Return true if new contents same as contents of given file
def CompareFile(fn: string, new_contents: list<string>): bool
    var data: list<string> = ReadFile(fn)
    var is_same = false
    #var is_same = data != null && data == new_contents
    if data == null
        DebugMsg(() => printf('CompareFile: new file %s', fn))
    elseif data != new_contents
        DebugMsg(() => printf('CompareFile: %s is different', fn))
    else
        DebugMsg(() => printf('CompareFile: %s is the same', fn))
        is_same = true
    endif
    #if ! is_same
    #    echo 'file:' data
    #    echo ' new:' new_contents
    #endif
    return is_same
enddef

############################################################################

finish


i_config.DebugReset()
g:['raelity'].is_debug = true

CreateDOK('foo.vim', 'SomeClassDict', 'bar.SomeClass', 'list<string>',
    ["import './bar.vim'"])
CreateDOK('subdir/foo.vim', 'SomeClassDict', 'bar.SomeClass', 'list<string>',
    ["import './bar.vim'"])

CreateDOK('/tmp/foo0.vim', 'SomeClassDict', 'bar.SomeClass', 'list<string>',
    ['import "./bar.vim"'])
CreateDOK('/tmp/foo1.vim', 'SomeClassDict', 'bar.SomeClass', 'list<string>',
    ['import "./bar.vim"'],
    "import /bar/baz/my_dict_stuff.vim", "'my_dict_stuff.MyDictObjKeyBase'")
default_header = [ "import 'one'", "import 'two'", "import 'three'" ]
default_base_import = "import '/tmp/foo' as xxx"
default_base_name = "xxx.DictKeyBase"
CreateDOK('/tmp/foo2.vim', 'SomeClassDict', 'SomeClass', 'list<string>')
ResetDefaults()
CreateDOK('/tmp/foo3.vim', 'SomeClassDict', 'SomeClass', 'list<string>')
CreateDOK('../play/foo5.vim', 'SomeClassDict', 'SomeClass', 'list<string>')

DebugMsg(() => string(g:['raelity'].generated_dir->keys()))
DebugMsg(() => string(g:['raelity'].generated_other->keys()))
