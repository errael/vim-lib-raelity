vim9script

# Generated key is of the form "<SNR>45_SomeClass@17".

export interface IObjKey
    var unique_object_id: string
endinterface

# This is a helper sub-class. Or use the interface directly
export abstract class ObjKey implements IObjKey
    const unique_object_id: string
    # Following fails, see
    #   [vim9class] vim9 seems to get confused about what file is executing
    #   https://github.com/vim/vim/issues/14402
    # const unique_object_id = GenerateKey() 
endclass

# Return unique key for calling object. Must be called from class "new*".
export def GenerateKey(): string
    return GenerateKeyFromStack(expand('<stack>'))
enddef

######################################################################

# following requires at least vim 9.1.255

# Parse the argument stack and find the caller,
# which is a constructor,"new*", (if caller is not a new, error)
# and return the caller's unique id.
def ExtractCaller(stack: string): string
    # The caller's frame is the second from the end
    var s = stack->split('\.\.')[-2]

    # From 'function <SNR>45_C0.Fun[1]', l[1] == "<SNR>45_C0", l[2] == "Fun"
    #var pat = '\v(\<[^\.]+)\.?([^\[]*)?'
    var l = matchlist(s, '\v(\<[^\.]+)\.?([^\[]*)?')
    if l->empty()
        echoerr "No stack match"
    elseif l[2]->empty()
        echoerr printf("'%s' '%s' not a class", s, l[ : 2])
    elseif l[2] !~ 'new.*'
        echoerr printf("'%s' '%s' not invoked from new", s, l[ : 2])
    endif

    return l[1]
enddef

var obj_id_count_script = 1

def GenerateKeyFromStack(stack: string): string
    var the_key = ExtractCaller(stack) .. '@' .. string(obj_id_count_script)
    obj_id_count_script += 1
    return the_key
enddef

######################################################################
#
finish

def Info(arg1: any, arg2: any)
    echo "NEW STACK:" arg1      ### s
    echo "NEW KEY:" arg2        ### l
enddef

# Using the helper abstract class: ObjKey

class C0 extends ObjKey
    def new()
        this.unique_object_id = GenerateKey()
    enddef
endclass

class C1 extends C0
    def new()
        this.unique_object_id = GenerateKey()
    enddef
endclass

# Using the interface directly: IObjKey

class C2 implements IObjKey
    const unique_object_id:  string
    def new()
        this.unique_object_id = GenerateKey()
    enddef
endclass

class C3 extends C2
    def new()
        this.unique_object_id = GenerateKey()
    enddef
    static def CreateError()
        GenerateKey()
    enddef
endclass

def F0(): C0
    return C0.new()
enddef

def F1(): C1
    return C1.new()
enddef

def F2(): C2
    return C2.new()
enddef

def F3(): C3
    return C3.new()
enddef

echo F0()
echo F1()
echo F2()
echo F3()
echo C0.new()
echo C1.new()
echo C2.new()
echo C3.new()

def FF()
    try
        C3.CreateError()
    catch
        echo v:exception
    endtry
    try
        GenerateKey()
    catch
        echo v:exception
    endtry
enddef
FF()
