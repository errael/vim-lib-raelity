vim9script

import './ui.vim' as i_ui

#       Python ripoff: With
#           interface WithEE, With(EE,func), ModifiableEE(bnr)

### Simulate Python's "With"
#
#       WithEE - Interface for context management.
#                Implement this for different contexts.
#       With(ContextClass.new(), (contextClass) => { ... })
#
#       Usage example - modify a buffer where &modifiable might be false
#           ModifyBufEE implements WithEE
#           With(ModifyBufEE.new(bnr), (_) => {
#               # modify the buffer
#           })
#           # &modifiable is same state as before "With(ModifyBufEE.new(bnr)"

# Note that Enter can be empty, and all the "Enter" work done in constructor.
export interface WithEE
    def Enter(): void
    def Exit(): void
endinterface

# TODO: test how F can declare/cast ee to the right thing
#
export def With(ee: WithEE, F: func(WithEE): void)
    ee.Enter()
    defer ee.Exit()
    F(ee)
enddef

# Save/restore 

# Save/restore '&modifiable' if needed
export class ModifyBufEE implements WithEE
    var _bnr: number
    var _is_modifiable: bool

    def new(this._bnr)
        #echo 'ModifyBufEE: new(arg):' this._bnr
    enddef

    def Enter()
        this._is_modifiable = getbufvar(this._bnr, '&modifiable')
        #echo 'ModifyBufEE: Enter:' this._bnr
        if ! this._is_modifiable
            #echo 'ModifyBufEE: TURNING MODIFIABLE ON'
            setbufvar(this._bnr, '&modifiable', true)
        endif
    enddef

    def Exit(): void
        #echo 'ModifyBufEE: Exit'
        if ! this._is_modifiable
            #echo 'ModifyBufEE: RESTORING MODIFIABLE OFF'
            setbufvar(this._bnr, '&modifiable', false)
        endif
        #echo 'ModifyBufEE: Exit: restored window:'
    enddef
endclass

# Keep window
export class KeepWindowOnlyEE implements WithEE
    var _winid: number

    def new()
    enddef

    def Enter(): void
        this._winid = win_getid()
    enddef

    def Exit(): void
        this._winid->win_gotoid()
    enddef
endclass

# Keep buffer, cursor as possible
export class KeepBufferOnlyEE implements WithEE
    var _bnr: number

    def new()
    enddef

    def Enter(): void
        this._bnr = bufnr('%')
    enddef

    def Exit(): void
        execute 'buffer' this._bnr
    enddef
endclass

# Keep window, topline, cursor as possible
export class KeepWindowPosEE implements WithEE
    var _w: dict<any>
    var _pos: list<number>

    def new()
    enddef

    def Enter(): void
        this._w = win_getid()->getwininfo()[0]
        this._pos = getpos('.')
    enddef

    def Exit(): void
        this._w.winid->win_gotoid()
        if setpos('.', [0, this._w.topline, 0, 0]) == 0
            execute("normal z\r")
            setpos('.', this._pos)
        endif
        #execute('normal z.')
    enddef
endclass

# Keep buffer, cursor as possible; typically same window on enter/exit.
# TODO: Why would exit ever have a different buffer?
export class KeepBufferPosEE implements WithEE
    var _bnr: number
    var _pos: list<number>

    def new()
    enddef

    def Enter(): void
        this._bnr = bufnr('%')
        this._pos = getpos('.')
    enddef

    def Exit(): void
        if this._bnr != bufnr()
            i_ui.PopupAlert(['DEBUG:', printf('bnr: prev %d, cur %d', this._bnr, bufnr())],
                'KeepBufferPosEE')
        endif
        execute 'buffer' this._bnr
        setpos('.', this._pos)
    enddef
endclass

# Keep cursor as possible. Doesn't modify buffer or window!
export class KeepPosEE implements WithEE
    var _pos: list<number>

    def new()
    enddef

    def Enter(): void
        this._pos = getcurpos()
    enddef

    def Exit(): void
        setpos('.', this._pos)
    enddef
endclass

# The following saves/restores focused window
# to get the specified buffer current,
# it also does modifiable juggling.
# Not needed since can use [gs]etbufvar.
#class ModifiableEEXXX extends WithEE
#    this._bnr: number
#    this._prevId = -1
#    this._restore: bool
#    def new(this._bnr)
#        #echo 'ModifiableEE: new(arg):' this._bnr
#    enddef
#
#    def Enter(): number
#        #echo 'ModifiableEE: Enter:' this._bnr
#        # first find a window that holds this buffer, prefer current window
#        var curId = win_getid()
#        var wins = win_findbuf(this._bnr)
#        if wins->len() < 1
#            throw "ModifiableEE: buffer not in a window"
#        endif
#        var idx = wins->index(curId)
#        if idx < 0
#            # need to switch windows
#            #echo 'ModifiableEE: SWITCHING WINDOWS'
#            this._prevId = curId
#            if ! win_gotoid(wins[0])
#                throw "ModifiableEE: win_gotoid failed"
#            endif
#        endif
#        if ! &modifiable
#            #echo 'ModifiableEE: TURNING MODIFIABLE ON'
#            &modifiable = true
#            this._restore = true
#        endif
#        return this._bnr
#    enddef
#
#    def Exit(resource: number): void
#        #echo 'ModifiableEE: Exit'
#        if this._restore
#            #echo 'ModifiableEE: RESTORING MODIFIABLE OFF'
#            &modifiable = false
#        endif
#        if this._prevId < 0
#            #echo 'ModifiableEE: Exit: same window'
#            return
#        endif
#        if ! win_gotoid(this._prevId)
#            throw "ModifiableEE:Exit: win_gotoid failed"
#        endif
#        #echo 'ModifiableEE: Exit: restored window:' this._prevId
#    enddef
#endclass
