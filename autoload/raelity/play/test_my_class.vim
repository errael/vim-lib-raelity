vim9script

set runtimepath+=/src/lib/vim

import autoload 'raelity/container/create_dok.vim'
create_dok.CreateDOK('dict_my_class_generated.vim', 'DictMyClass',
    'my_class.MyClass', 'number', ["import './my_class.vim'"])

import './my_class.vim'
import './dict_my_class_generated.vim'

type MyClass = my_class.MyClass
type DictMyClass = dict_my_class_generated.DictMyClass

var d = DictMyClass.new()
d.Put(MyClass.new(), 13)
d.Put(MyClass.new(), 17)

echo d

finish
echo dok.default_base_import

var sid = expand('<SID>')
echo sid

echo matchstr(sid, '\d\+', 5)

#echo expand('<sfile>')

echo getscriptinfo({sid: str2nr(matchstr(sid, '\d\+', 5))})
