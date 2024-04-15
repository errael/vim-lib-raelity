vim9script

#echo 'RUNNING raelity_config.vim'

import '../../plugin/raelity_startup.vim' as startup

#############################################################################
#
# General configuration and assist

# The directory where this file is found.
export const lib_dir: string = fnamemodify(
    getscriptinfo(
        {sid: str2nr(matchstr(expand('<SID>'), '\v\d+'))}
    )[0].name, ':p:h')

# Get a full path to a lib file and avoid path search.
# If you would normally do
#       "import autoload raelity/util/strings.vim",
# then do
#       "import autoload Rlib(util/strings.vim)"
export def Rlib(raelity_autoload_fname: string): string
    return lib_dir .. '/' .. raelity_autoload_fname
enddef

import autoload Rlib('util/log.vim') as i_log
import autoload Rlib('util/stack.vim') as i_stack

# empty means no autogen directory
var gen_files_dir_parent = ''

#############################################################################
#
# Generated/temporary files
#
# WARNING: by default, the generated files and/or files created under
#          the "generated_vim_files_directory" are deleted when vim exits.
#          Can set "g:['raelity'].preserve_generated_files" to true
#          after importing this file.
# NOTE:    Since this may be changed, the developer either must set it
#          every time it is used, or read it after setting the parent.
#          Read it with GenFilesDir(); note exception is thrown if not set

#
# SetGenFilesDirParent(dirname: string)
# GenFilesDir(): string
#
# GenFilePath(fname: string): string
# GenFilePathInfo(fname: string): list<any>
#
# Return absolute path name of "fname" under the generated files directory
# when "fname" is a relative path not starting with ".".

# If "fname" is not relative or it starts with '.', then return the
# "fname" expanded to full path; and perform no other operations
#
# When the file is under the generated files directory,
# then subdirectories are created as needed.
#
# Can be used like:
#   - var fname = GenFilePath("subdir1/subdir2/some_name")
#     Then create the file "fname".
#   - import autoload GenFilePath(subdir1/subdir2/some_name) as i_xxx
#     The file should already exist.
# "subdir1/subdir2" are created if needed.
#

export def GenFilePath(fname: string): string
    return GenFilePathInfo(fname)[0]
enddef

# This must be done first, before the creation of any generated files.
# Name must be absolute path, unless it is being cleared.
#
# Example: after doing "SetGenFilesDirParent('/a/b/') generated files end up
#          under "/a/b/generated_vim_files_directory/"
# TODO: any special checking? Don't allow this after a file is generated (throw?).

# parent_directories used as a set
var parent_directories: dict<bool>

export def SetGenFilesDirParent(dirname: string)
    if ! (isabsolutepath(dirname) || dirname->empty())
        throw 'RLIB:' .. dirname .. ' is not an absolute path or empty'
    endif
    parent_directories[dirname] = true
    gen_files_dir_parent = dirname
enddef

# Specialized version of "GenFilePath(fname)" that returns additional info.
# The return value is a two element list with first element the full path,
# and the second element is a flag where true indicates generated.
export def GenFilePathInfo(fname: string): list<any>
    if isabsolutepath(fname) || fname[0] == '.'
        return [ fnamemodify(fname, ':p'), false ]
    endif
    var name = fnamemodify(GenFilesDir() .. '/' .. fname, ':p')
    name->fnamemodify(":h")->mkdir("p")
    return [ name, true ]
enddef

export def GenFilesDir(): string
    if gen_files_dir_parent->empty()
        throw 'RLIB: directory not set.'
    endif
    return gen_files_dir_parent .. '/' .. gen_files_dirname
enddef

const gen_files_dirname = 'generated_vim_files_directory'


def CleanupGeneratedFiles()
    #if v:dying != 0 || g:['raelity'].preserve_generated_files
    if g:['raelity'].preserve_generated_files
        return
    endif

    var fnc = i_stack.Func()
    parent_directories->foreach((parent_dir, _) => {
        var gen_dir = parent_dir .. '/' .. gen_files_dirname
        i_log.Log(() => printf("%s: %s", fnc, gen_dir))
        delete(gen_dir, "rf")
    })
enddef

autocmd VimLeave * CleanupGeneratedFiles()

# DO NOT USE THIS
export def DebugReset()
    CleanupGeneratedFiles()
    startup.DebugInitStructure()
enddef
