vim9script

import autoload './ui.vim' as i_ui
import autoload './strings.vim' as i_strings
import autoload './log.vim' as i_log

# at_mouse - defaults to false
export def DisplayTextPopup(text: list<string>, extras: dict<any> = null_dict)
    i_ui.PopupMessage(text, extras)
enddef

# Property Sheet, typically modal
#
# Checkboxes, Radio Checkbox Groups.
# Items keyed by displayed value. Item names should be unique among all popups.
# TODO: handle text fields
# 
# The dialog is split into two parts, components and text.
# Click on a button to toggle between 'X'/' '.
#       -----------------
#       | [ ] Checkbox  |
#       | [X] Checkbox  |
#       |               |
#       | [ ] Checkbox  |
#       -----------------
#       |   Text        |
#       |    Text       |
#       -----------------
# popup_close is called with a dict of how it was closed, by default the keys
# 'x', 'ESC', 'CTRL-C' close it; if the dialog is closed by clicking in the
# text area (the bottom), the index in the text is avaialable. After the
# dialog is dismissed, grab a dictionary using winid with the resulting state
# of the checkboxes.
#
# The callback is passed the result, or -1 if CTRL-C, the result looks like
#       line:   mp.line or 0
#       idx:    index into extras.append_msgs or -1
#       key:    str2list() of key passed to filter callback or [-2]
#       mp:     mouse position may be null_dict
# See filter "PropertyDialogClickOrClose" below for more details.

# DisplayPropertyPopup  - Start the popup, returns the "winid" of the popup.
# PropertyDialogClose   - Must call, frees resources, called with "winid".
#                         Typically called from the popup's close callback.
# AddRadioBtnGroup      - List of buttons in a group.
# GetPropertyState      - Returns dict of final button state.
#                         Use before doing "PropertyDialogClose"
# DummyPropertyDialogResult - might be useful

# map winid to list of properties it contains
var winid_properties: dict<list<string>>
var winid_extras: dict<dict<any>>

#
# properties    - list of properties, in display order,
#                 may have blank items displayed as empty lines
# state         - dictionary with initial state of buttons,
#                 every button must have a value
# extras        - dictionary for options/features
#       append_msgs         - List of the text lines at the end.
#       close_click_idx     - If set and append_msgs, then a click on this
#                             text line index or later closes the dialog.
#       at_mouse            - bool: if true popup at mouse; default true
#       header_line: number - >= 1, highlight that line with hl_heading
#       tweak_options       - extends the options given to popup_create
#
export def DisplayPropertyPopup(properties: list<string>,
                                state: dict<any>,
                                extras: dict<any> = {}): number
    if !extras->has_key('at_mouse')
        extras.at_mouse = true
    endif

    # Can't remove 'close' with popup_setoptions
    # Insure no 'X' to dismiss. Clicking caused weird selections.
    extras.no_close = true

    # TODO: should probably invoke something like i_ui.PopupDialog()
    var winid = i_ui.PopupDialog(FormattedProperties(properties, state), extras)
    popup_setoptions(winid, { filter: PropertyDialogClickOrClose })
    winid_properties[winid] = properties
    winid_extras[winid] = extras
    i_log.Log(() => printf("DisplayPropertyPopup: %s %s", winid, winid_properties))
    return winid
enddef

export def PropertyDialogClose(winid: number)
    i_log.Log(() => printf("PropertyDialogClose: %s %s", winid, winid_properties), 'diffopts')
    winid_properties->remove(winid)
    winid_extras->remove(winid)
enddef

# Sets of radio buttons

var radio_btn_groups: list<list<string>> = [ ]

export def AddRadioBtnGroup(radio_btn_group: list<string>)
    if radio_btn_groups->index(radio_btn_group) < 0
        i_log.Log(() => printf("AddRadioBtnGroup: %s", radio_btn_group))
        radio_btn_groups->add(radio_btn_group)
        PopulateRadioButtons()

    endif
enddef

# return state for each property
export def GetPropertyState(winid: number): dict<any>
    var state: dict<any>
    if winid != 0
        var bnr = getwininfo(winid)[0].bufnr
        for s in bnr->getbufline(1, '$')
            if len(s) > 4 && s[0] == '[' && s[2] == ']'
                state[s[4 : ]] = s[1] != ' '
            endif
        endfor
    endif
    return state
enddef

# This is what a result for popup_close looks like if nothing happened.
export def DummyPropertyDialogResult(): dict<any>
    return {line: 0, idx: -1, key: [-2], mp: null_dict}
enddef

# If extra.close_click_idx exists and it is a number and a mouse click
# in the append_extra >= close_click_idx will close dialog
#
# NOTE: always returning true prevents border drag
#
def PropertyDialogClickOrClose(winid: number, key: string): bool
    # TODO: why The check for RET/NL ends up causing window scroll
    #if key == "\r" || key == "\n"
    #    return false
    #endif

    var mp = getmousepos()
    if key == "\<LeftRelease>" && mp.winid == winid
        var isProp = CheckClickProperty(winid, mp)
        # if it wasn't a property, possibly close if close_click_idx
        if !isProp && winid_extras->has_key(winid) # actually, must have extras
            var extras = winid_extras[winid]
            if extras->has_key('close_click_idx') && extras->has_key('append_msgs')
                # if line clicked in append_msgs after "close_click_idx" then close
                if mp.line > winid_properties[winid]->len()
                    # -2 is -1 to skip blank line, and -1 to change line number to idx
                    var idx = mp.line - winid_properties[winid]->len() - 2
                    if idx >= extras.close_click_idx
                            && idx < extras.append_msgs->len()
                        popup_close(winid,
                            {line: mp.line, idx: idx, key: key->str2list(), mp: mp})
                    endif
                endif
            endif
        endif
    elseif key == 'x' || key == "\x1b"
        var rc = {line: mp.line, idx: -1, key: key->str2list(), mp: mp}
        popup_close(winid, rc)
    endif
    return true
enddef


# Put the checkbox "[ ] " or "[X] " in front of each diff options.
#
# TODO: maybe should precede property with '*'
#       or something so that arbitrary text can be easily included.
def FormattedProperties(properties: list<string>, state: dict<any>): list<string>
    return properties->mapnew((_, val) =>
        val->empty() ? ''
            : printf('[%s] %s', state[val] ? 'X' : ' ', val)
    )
enddef

# The radio buttons with the group they belond to
var radioButtons: dict<list<string>> = {}

def PopulateRadioButtons()
    for l in radio_btn_groups
        for opt in l
            #echo 'ADD RADIO:' opt l
            radioButtons[opt] = l
        endfor
    endfor
    #echo 'RADIO BUTTONS:' radioButtons
enddef

# If its a radio button, handle it and return true.
# line must be a valid button
def HandleRadioButton(winid: number, bnr: number, line: number): bool
    var s = bnr->getbufoneline(line)
    var opt = s[4 : ]
    var l = radioButtons->get(opt, null_list)
    if l->empty()
        return false
    endif
    for opt2 in l
        if opt == opt2
            SetProperty(bnr, line, true)
        else
            var property_list = winid_properties->get(winid, null_list)
            if property_list != null
                SetProperty(bnr, property_list->index(opt2) + 1, false)
            endif
        endif
    endfor
    return true
enddef

# line must be a valid button
def SetProperty(bnr: number, line: number, enable: bool)
    var s = bnr->getbufoneline(line)
    s = (enable ? '[X]' : '[ ]') .. s[3 : ]
    # TODO: find out why following causes window 2 to scroll
    s->setbufline(bnr, line)
enddef

# line must be a valid button
def FlipProperty(bnr: number, line: number)
    var s = bnr->getbufoneline(line)
    var enabled = s[1] != ' '
    SetProperty(bnr, line, !enabled)
enddef

# If a boolean property is clicked, then flip it to other state
def CheckClickProperty(winid: number, mp: dict<number>): bool
    if mp.winid == winid
        var property_list = winid_properties->get(winid, null_list)
        if property_list != null
            var bnr = getwininfo(winid)[0].bufnr
            if mp.line >= 1 && mp.line <= len(property_list)
                var s = bnr->getbufoneline(mp.line)

                # skip line if doesn't look like a property "[ ]"/"[X]"
                if len(s) <= 4 || s[0] != '[' || s[2] != ']'
                    return false
                endif
                if ! HandleRadioButton(winid, bnr, mp.line)
                    FlipProperty(bnr, mp.line)
                endif
                return true
            endif
        endif
    endif
    return false
enddef

