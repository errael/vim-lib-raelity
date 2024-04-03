vim9script

import './dict_ok_example.vim' as ex

type C = ex.ExampleClass
type D = ex.ExampleClassDict

var d = D.new()
echo 'len:' d->len()
echo 'empty:' d->empty()

var o1 = C.new()
var o2 = C.new()
echo o1

d.Put(o1, "1-val")
d.Put(o2, "2-val")
echo d.Get(o2)
# Change "F()" following to check strict type checking
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
