# vim-lib-raelity

A hodgepodge of useful vim9.1 functions and classes; (at least I find them useful). It was developed primarily for [Splice9](https://github.com/errael/splice9). The containers were developed as an exercise.

The library has some builtin usability support to
- Prevent `import autoload` from repeatedly searching `runtimepath`.
- Handle bundling the library with the app that is using it.

See [rlib.vim](https://github.com/errael/splice9/blob/main/autoload/splice9dev/rlib.vim), a short file from another project, which
1. looks for the bundled library or if not found
2. looks for autoload library
3. exports a function, `Rlib(string): string`, which is the full path of the specified library file. The function is used like
   ```vim
   import Rlib('util/log.vim') as i_log
   ```
Note that the autoload path is at most searched once; being when the library is not bundled.

-----

### containers

The library has builtin classes that provides dictionary containers that take an `object`, `list`, or any type accepted by the vim builtin `id()` as a key. These containers have keys based on identity and not equals.


In addition, there are functions that create source files for strongly typed, both keys and values, containers. Alternately these source files can be created dynamically, imported, and automatically deleted when vim exits. These containers keep references to the keys so they are not garbage collected while in use.

All expected methods on a container object are available, for example,
```
def Get(key: KeyType, default: any = {get_default}): ValueType
```
Note that `KeyType`, `get_default`, and `ValueType` are provided when the container source codes is defined.

-----

### utility functions

Overview of functions by file. The source code is reasonably documented, click on the file name to see the source code.

[**util/log.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/log.vim)
```
Log(msgOrFunc : any, category: any = '', stack: bool = false, command: string = '')
IsEnabled(category : string = ''): bool
LogInit(_fname : string, excludes: list<string> = [],
        add_excludes: list<string> = [], remove_excludes: list<string> = [])
```
If logging is not enabled the `Log` function returns immediately. The `Log` function arguments

| argument | description |
| --------- | ----------- |
| msgOrFunc | either a string or funcref `func(void): string`; only executed if logging enabled for the category |
| category | either empty or typically an enum; if not empty converted to a string, if the category is excluded then return without logging
| stack | if true then output the stack, from where `Log` is called, as part of the log entry
| command | if not empty then execute command and add its output to the log entry, e.g. `:ls`


[**util/map_mode_filters.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/map_mode_filters.vim) - Build and return efficient functions to filter maplist().

[**util/ui.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/ui.vim) - `Popup*(msg: list<string>, extras: dict<any>)`
```
PopupMessage, PopupDialog, PopupAlert
AddToTweakOptions
ConfigureHighlights
```

[**util/property_sheet.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/property_sheet.vim) - supports checkboxes, radio checkbox groups

[**util/with.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/with.vim) - like Python's "with", the free

WithEE - Interface for context management. Implement this for different contexts.<br>
With(ContextClass.new(...), (contextClass) => { ... })

Usage example - modify a `buffer` where `&modifiable` _might_ be false
```
ModifyBufEE implements WithEE
With(ModifyBufEE.new(bufnr), (_) => {
    # modify the buffer "bufnr"
})
# &modifiable is same state as before "With(ModifyBufEE.new(bufnr)"
```
There are a variety of context classes defined in this file

[**util/strings.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/strings.vim) - strings and lists of strings

Pad has option left/center/right.
```
Pad, IndentLtoS, IndentLtoL
Replace, ReplaceBuf
```

[**util/lists.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/lists.vim)
```
ListRandomize
FindInList, FetchFromList
```

[**util/dicts.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/dicts.vim) - TODO: intersect, union, ...
```
DictUnique - remove common key/val from each dict
```

[**util/vim_extra.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/vim_extra.vim)
```
General
    Bell
    EQ, IS
    IsExactType
Text properties
    PropRemoveIds
Keystrokes
    Keys2str
```

[**util/stack.vim**](https://github.com/errael/vim-lib-raelity/blob/main/autoload/raelity/util/stack.vim)
```
StackTrace, FixStack, CallerFuncName
ScriptFileNameLookup, ScriptFiles
```

