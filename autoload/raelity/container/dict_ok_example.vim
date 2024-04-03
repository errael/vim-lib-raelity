vim9script

import './obj_key.vim'
import './dict_ok.vim'

export class ExampleClass implements obj_key.IObjKey
    const unique_object_id = obj_key.GenerateKey()
endclass

# if you don't want a dictionary with strict type checking, use DictObjKey as:
#       export class ExampleClassDict extends dict_ok.DictObjKey
#       endclass
# otherwise do the following for compile type checking and best performance.

## Following copied from dict_ok_template.vim.
## With KeyType/ValueType modified 

type ValueType = string
type KeyType = ExampleClass


export class ExampleClassDict extends dict_ok.DictObjKeyBase

    def Put(key: KeyType, value: ValueType)
        this._d[key.unique_object_id] = [ key, value ]
    enddef

    def Get(key: KeyType): ValueType
        return this._d[key.unique_object_id][1]
    enddef

    def StringKeyToObj(key: string): KeyType
        return this._d[key][0]
    enddef

    def Keys(): list<KeyType>
        # can optimize: for loop, inline StringKeyToObj
        return this._d->keys()->mapnew((i, k) => this.StringKeyToObj(k))
    enddef

endclass

# end of copy
#
###############################################################################

# The following stuff can be in a different file which imports this file

finish

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

