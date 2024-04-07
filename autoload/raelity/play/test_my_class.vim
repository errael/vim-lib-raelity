vim9script

set runtimepath+=/src/lib/vim

import autoload 'raelity/raelity_config.vim' as i_config
echo 'raelity init:' exists("g:['raelity']")
i_config.DebugReset()
echo 'raelity init:' exists("g:['raelity']")
echo g:['raelity']

import autoload 'raelity/container/create_dok.vim'
var target = 'dict_my_class_generated.vim'
create_dok.CreateDOK(target, 'DictMyClass',
    'my_class.MyClass', 'number', ["import './my_class.vim'"])

echo "creating:" fnamemodify(target, ":p")

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
