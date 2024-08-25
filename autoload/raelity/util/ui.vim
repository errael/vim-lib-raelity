vim9script

import autoload './strings.vim' as i_strings
import autoload './log.vim' as i_log

var ui_highlights: dict<string>

export const MIN_POPUP_WIDTH = 25
const PROP_POPUP_HEADING = 'ui_popupheading'

export def ConfigureUiHighlights(hl: dict<string>)
    ui_highlights->extend(hl)
    var d = prop_type_get(PROP_POPUP_HEADING)
    if d->empty() 
        d.highlight = ui_highlights.heading
        prop_type_add(PROP_POPUP_HEADING, d)
    endif
    if d.highlight != ui_highlights.heading
        d.highlight = ui_highlights.heading
        prop_type_change(PROP_POPUP_HEADING, d)
    endif
enddef

# Some initial values.

highlight UiUnderline term=underline cterm=underline gui=underline
ConfigureUiHighlights({
    heading: 'Todo',        # 'UiUnderline'
    popup: 'Todo',          # 'ColorColumn'
    alert_popup: 'Todo',    # 'PMenu'
})

#
# The "extras" parameter for PopupMessage() and PopupProperties may contain
#
#       tweak_options - used to extend the options given to popup_create
#       at_mouse: bool - if true popup at mouse; default false
#       header_line: number - >= 1, highlight that line with hl_heading
#       modal: bool     - if false, allow drag and moved does not dismiss


export def PopupMessage(msg: list<string>, extras: dict<any> = {}): number
    AddToTweakOptions(extras, {
        close: 'click',
    })
    return PopupMessageCommon(msg, extras)
enddef

# TODO: should probably be PopupDialog()
export def PopupDialog(msg: list<string>, extras: dict<any> = {}): number
    #var options: dict<any> = {
    AddToTweakOptions(extras, {
        close: 'button',
        filter: DialogClickOrClose,
        mapping: true,   # otherwise don't get <ScriptCmd>
    })
    return PopupMessageCommon(msg, extras)
enddef

# Update tweak_options with some default values.
# Don't change tweak_options that are already set.
export def AddToTweakOptions(extras: dict<any>, tweak_options: dict<any>, how = 'keep')
    if !extras->has_key('tweak_options')
        extras.tweak_options = {}
    endif
    extras.tweak_options->extend(tweak_options, how)
enddef

def DialogClickOrClose(winid: number, key: string): bool
    if char2nr(key) == char2nr("\<ScriptCmd>")
        return false    # wan't these handled
    endif
    if key == 'x' || key == "\x1b"
        popup_close(winid)
        return true
    endif

    return true
enddef

# dismiss on any key
def FilterCloseAnyKey(winid: number, key: string): bool
    popup_close(winid)
    return true
enddef

# msg - popup's buffer contents
# extras - see top of this file
# return: popup's winid
def PopupMessageCommon(msg: list<string>, extras: dict<any> = {}): number

    var options: dict<any> = {
        minwidth: MIN_POPUP_WIDTH,
        tabpage: -1,
        zindex: 300,
        border: [],
        padding: [1, 2, 1, 2],
        highlight: ui_highlights.popup,
        drag: true,
        mapping: false,
    }

    if extras->has_key('tweak_options')
        options->extend(extras.tweak_options)
    endif

    if extras->has_key('at_mouse') && extras.at_mouse
        var mp = getmousepos()
        options->extend({line: mp.screenrow, col: mp.screencol})
    endif

    var out_msg: list<string> = msg->copy()
    var append_msgs: list<string>
    if options->get('close', '') == 'click'
        append_msgs->add('Click on Popup to Dismiss.')
    endif
    if options->get('drag', false)
        append_msgs->add('Drag border to move')
    endif

    if extras->has_key('append_msgs')
        append_msgs->extend(extras.append_msgs)
    endif

    if !append_msgs->empty()
        out_msg += [''] + append_msgs
    endif

    var winid = popup_create(out_msg, options)
    var bnr = winid->winbufnr()
    if extras->has_key('header_line') && extras.header_line > 0
        prop_add(extras.header_line, 1,
            {length: len(msg[extras.header_line - 1]), bufnr: bnr, type: PROP_POPUP_HEADING})
    endif

    return winid
enddef


#
# The "extras" parameter for PopupAlert
#
#       center: bool    - if true, strings.Pad center the message; default true
#       logit: bool     - if true, log the message; default true
#       modal: bool     - if false, allow drag and moved does not dismiss, default true.
#       tweak_options - used to extend the options given to popup_create
#
# TODO: should title override tweak_options title
#
export def PopupAlert(msg_: list<string>, title: string = '', extras: dict<any> = {})
    var center: bool = extras->get('center', true)
    var logit: bool = extras->get('logit', true)
    var modal: bool = extras->get('modal', true)

    if logit
        i_log.Log(() => printf('ALERT: %s %s', title, msg_->join(';')))
    endif

    var tweak_options = {
        highlight: ui_highlights.alert_popup,
        close: 'none',
        drag: false,
        moved: 'any',
        mousemoved: 'any',
        filter: FilterCloseAnyKey
        }
    if ! modal
        tweak_options->extend({
            close: 'click',
            drag: true,
            moved: [0, 0, 0],
            mousemoved: [0, 0, 0],
            filter: (_, _) => false,    # Pass through all the keys.
        })
    endif

    if ! title->empty()
        tweak_options.title = ' ' .. title .. ' '
    endif

    AddToTweakOptions(extras, tweak_options)

    var msg = center ? i_strings.Pad(msg_, 'c', - MIN_POPUP_WIDTH) : msg_

    PopupMessageCommon(msg, extras)
enddef

# vim:ts=8:sts=4:
