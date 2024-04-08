vim9script

import autoload '../util/stack.vim' as i_stack

const FixStack = i_stack.FixStack

def F()
    i_stack.Test()
enddef
F()

var str = i_stack.stackString
echo str
var stack: list<string> = FixStack(str)

def Dump(stk: list<string>)
    stk->foreach((i, v) => {
        echo v
    })
enddef

Dump(stack)

echo ' '

stack->reverse()
Dump(stack)

