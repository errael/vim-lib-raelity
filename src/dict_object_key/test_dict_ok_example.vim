vim9script

import './dict_ok_example.vim' as ex

type C = ex.ExampleClass
type D = ex.ExampleDictObjectKey

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
