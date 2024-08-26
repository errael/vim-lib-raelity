vim9script

# Dictionary
#       DictUnique

###
### Dictionary
###

# Remove the common key/val from each dict.
# Note: the dicts are modified
export def DictUnique(d1_: dict<any>, d2_: dict<any>,
        options: dict<any> = {}): list<dict<any>>
    var d1: dict<any>
    var d2: dict<any>
    if options->get('copy', false)
        d1 = d1_->copy()
        d2 = d2_->copy()
    else
        d1 = d1_
        d2 = d2_
    endif
    # TODO: use items() from the smallest dict
    for [k2, v2] in d2->items()
        # TODO: should use EQ in following since type is unknown
        if d1->has_key(k2) && d1[k2] == d2[k2]
            d1->remove(k2)
            d2-> remove(k2)
        endif
    endfor
    return [ d1, d2]
enddef

# return list of dicts with unique elements,
# returned dicts start as shallow copies
# DEPRECATED - use DictUnique(a1, a2, true)
def DictUniqueCopy(d1: dict<any>, d2: dict<any>): list<dict<any>>
    var d1_copy = d1->copy()
    var d2_copy = d2->copy()
    DictUnique(d1_copy, d2_copy)
    return [ d1_copy, d2_copy ]
enddef
