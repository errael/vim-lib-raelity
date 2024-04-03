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
    # The caller's frame is the second to the last
    var s1 = stack->split('\.\.')[-2]

    # Extract '<SNR>45_C0.Fun' from 'function <SNR>45_C0.Fun[1]'
    # and split it into "['<SNR>45_C0', 'Fun']".
    var l1 = matchstr(s1, '<[^\[]*')->split('\.')

    if l1->len() != 2
        echoerr printf("'%s' not a class", l1)
    elseif l1[1] !~ 'new.*'
        echoerr printf("'%s' not invoked from new", l1)
    endif

    return l1[0]
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
    echo "NEW STACK:" arg1      ### s1
    echo "NEW KEY:" arg2        ### l1
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

