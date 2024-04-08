vim9script

# Lists, nested lists
#       ListRandomize
#       FindInList, FetchFromList

###
### working with lists
###

def ListRandomize(l: list<any>): list<any>
    srand()
    var v_list: list<func> = l->copy()
    var random_order_list: list<any>
    while v_list->len() > 0
        random_order_list->add(v_list->remove(rand() % v_list->len()))
    endwhile
    return random_order_list
enddef

###
### working with nested lists
###     A path is used to traverse the nested list, see FetchFromList.
###

# FindInList: find target in list using '==' (not 'is'), return false if not found
# Each target found is identified by a list of indexes into the search list,
# and that is added to path (if path is provided).
export def FindInList(target: any, l: list<any>, path: list<list<number>> = null_list): bool
    var path_so_far: list<number> = []
    var found = false
    def FindInternal(lin: list<any>)
        var i = 0
        var this_one: any
        while i < len(lin)
            this_one = lin[i]
            if EQ(this_one, target)
                if path != null
                    path->add(path_so_far + [i])
                endif
                found = true
            elseif type(this_one) == v:t_list
                path_so_far->add(i)
                FindInternal(this_one)
                path_so_far->remove(-1)
            endif
            i += 1
        endwhile
    enddef
    if EQ(l, target)
        path->add([])
        return true
    endif
    FindInternal(l)
    return found
enddef

export def FetchFromList(path: list<number>, l: list<any>): any
    var result: any = l
    for idx in path
        result = result[idx]
    endfor
    return result
enddef
