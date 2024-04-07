vim9script

echo 'RUNNING raelity_config.vim'

import '../../plugin/raelity_startup.vim' as startup

#############################################################################
#
# General configuration



#############################################################################
#
# Generated/temporary files
#
# WARNING: by default, the generated files and/or files created under
#          the "generated_vim_files_directory" are deleted when vim exits.
#          Can set "g:['raelity'].preserve_generated_files" to true
#          after importing this file.

# TODO: probably need a way to specify the generated file directory

#
# GenFilePath
# GenFilePathInfo
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

# This should be done first, before the creation of any generated files,
# otherwise generated files may appear in multiple locations.
# Name must be absolute path.
#
# Example: after doing "SetGenFilesDirParent('/a/b/') generated files end up
#          under "/a/b/generated_vim_files_directory/"
# TODO: any special checking? Don't allow this after a file is generated (throw?).
def SetGenFilesDirParent(dirname: string)
    if ! isabsolutepath(dirname)
        throw dirname .. ' is not an absolute path'
    endif
    # gen_files_dir_parent = dirname
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
    return gen_files_dir_parent .. '/' .. gen_files_dirname
enddef

def InternalGenFilesDirParent(): string
    var sid = matchstr(expand('<SID>'), '\v\d+')
    var thisname = getscriptinfo({sid: str2nr(sid)})[0].name
    var dir = fnamemodify(thisname, ':p:h')
    return dir
enddef

var gen_files_dir_parent = InternalGenFilesDirParent()
const gen_files_dirname = 'generated_vim_files_directory'


def CleanupGeneratedFiles()
    #if v:dying != 0 || g:['raelity'].preserve_generated_files
    if g:['raelity'].preserve_generated_files
        return
    endif
    var dir = GenFilesDir()
    delete(dir, "rf")

    #var fxxx = '/tmp/TEST_FLAG'
    #var m = "CLEANUP_GENERATED_FILES: " .. dir
    #writefile([ m, strftime("%c") ], fxxx)
enddef

autocmd VimLeave * CleanupGeneratedFiles()

# DO NOT USE THIS
export def DebugReset()
    CleanupGeneratedFiles()
    startup.DebugInitStructure()
enddef
