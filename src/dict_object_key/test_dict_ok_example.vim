vim9script

import './dict_ok_example.vim' as ex

type C = ex.ExampleClass
#type D = ex.ExampleDictObjectKey
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

var skeys = d.StringKeys()
echo skeys
echo d.StringKeyToObj(skeys[0])
echo d.StringKeyToObj(skeys[1])

echo 'len:' d->len()
echo 'empty:' d->empty()

echo d
