vim9script

# Dictionary
#       DictUniqueCopy, DictUnique
#       PutIfAbsent (DEPRECATED)

###
### Dictionary
###

# Remove the common key/val from each dict.
# Note: the dicts are modified
export def DictUnique(d1: dict<any>, d2: dict<any>)
    # TODO: use items() from the smallest dict
    for [k2, v2] in d2->items()
        if d1->has_key(k2) && d1[k2] == d2[k2]
            d1->remove(k2)
            d2-> remove(k2)
        endif
    endfor
enddef

# return list of dicts with unique elements,
# returned dicts start as shallow copies
export def DictUniqueCopy(d1: dict<any>, d2: dict<any>): list<dict<any>>
    var d1_copy = d1->copy()
    var d2_copy = d2->copy()
    DictUnique(d1_copy, d2_copy)
    return [ d1_copy, d2_copy ]
enddef
