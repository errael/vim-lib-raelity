vim9script

# DictObjectKeyTemplate example/test

import './IDictKey.vim'
import './DictObjectKey.vim'

export class ExampleClass implements IDictKey.IDictKey
    const as_key = IDictKey.GenerateKey()
endclass


###############################################################################
#
# Copied from dict_ok_template.vim.
# With KeyType/ValueType modified 
#

# if you don't care about strict type checking
export class YYYExampleClassDict extends DictObjectKey.DictObjectKey
endclass


type ValueType = string
type KeyType = ExampleClass


export class ExampleClassDict extends DictObjectKey.DictObjectKeyBase

    def Put(key: KeyType, value: ValueType)
        this._d[key.as_key] = [ key, value ]
    enddef

    def Get(key: KeyType): ValueType
        return this._d[key.as_key][1]
    enddef

    def StringKeyToObj(key: string): KeyType
        return this._d[key][0]
    enddef

    def Keys(): list<KeyType>
        # can optimize, for loop, inline StringKeyToObj
        return this._d->keys()->mapnew((i, k) => this.StringKeyToObj(k))
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
def F()
    var xxx: string = d.Get(o1)
enddef
F()

echo '=== Keys()'
var keys = d.Keys()
echo keys

echo '=== StringKeys()'
var skeys = d.StringKeys()
echo skeys

echo ' '
echo d.StringKeyToObj(skeys[0])
echo d.StringKeyToObj(skeys[1])

echo 'len:' d->len()
echo 'empty:' d->empty()

echo d

