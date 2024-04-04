vim9script

import autoload '../util/stack.vim' as i_stack

const FixStack = i_stack.FixStack

i_stack.Test()
var str = i_stack.stackString
var stack: list<string> = i_stack.FixStack(str)

def Dump(stk: list<string>)
    stk->foreach((i, v) => {
        echo v
    })
enddef

Dump(stack)

echo ' '

stack->reverse()
Dump(stack)

