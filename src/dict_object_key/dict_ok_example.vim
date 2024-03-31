vim9script

# DictObjectKeyTemplate example/test


###############################################################################
#
# helper stuff for generating key from object

# Can consider how best to refactor/share after the following issue resolved.
# [vim9class] SEGV: problem with static in superclass #14352 
# https://github.com/vim/vim/issues/14352
#

# would like a builtin method to generate the key
# There is both simple_class_name: "ExampleClass"
# There is both class_name: "<SNR>123_ExampleClass"

# GenerateKey is a good candidate for a builtin,
# so that we don't have to generate a unique numer.

export interface DictObject
    #var simple_class_name: string
    #var class_name: string
    var as_key: string
endinterface

var _obj_id_count = 1
def GenerateKey(simple_class_name: string, sid: string): string
    var x = sid .. simple_class_name .. '@' .. string(_obj_id_count)
    _obj_id_count += 1
    return x
enddef
# end helpers
###############################################################################


export class ExampleClass implements DictObject
    const as_key = GenerateKey('ExampleClass', expand('<SID>'))
endclass


###############################################################################
#
# Copied from dict_ok_template.vim.
# With KeyType/ValueType modified 
#

type ValueType = string
type KeyType = ExampleClass

export class ExampleClassDict   # would like to implement a dict

    var _d: dict<list<any>>

    def Put(key: KeyType, value: ValueType)
        this._d[key.as_key] = [ key, value ]
    enddef

    def Get(key: KeyType): ValueType
        return this._d[key.as_key][1]
    enddef

    def KeyToObj(key: string): KeyType
        return this._d[key][0]
    enddef

    ############
    # BaseDict #
    ############

    def len(): number
        return this._d->len()
    enddef

    def empty(): bool
        return this._d->len() == 0
    enddef

    def Keys(): list<string>
        return this._d->keys()
    enddef
endclass

# end of copy
#
###############################################################################

# The following stuff can be in a different file which imports this file

### finish

### vim9script

### import './dict_ok_example.vim' as ex

### type C = ex.ExampleClass
### type D = ex.ExampleClassDict

type C = ExampleClass
type D = ExampleClassDict

var d = D.new()
echo 'len:' d->len()
echo 'empty:' d->empty()

var o1 = C.new()
var o2 = C.new()
echo o1

d.Put(o1, "1-val")
d.Put(o2, "2-val")
echo d.Get(o2)
var keys = d.Keys()
echo keys
echo d.KeyToObj(keys[0])
echo d.KeyToObj(keys[1])

echo 'len:' d->len()
echo 'empty:' d->empty()

echo d

