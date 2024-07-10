vim9script

set runtimepath^=/src/lib/vim
#set runtimepath+=/src/lib/vim

import autoload 'raelity/config.vim' as i_config
echo 'raelity init:' exists("g:['raelity']")
i_config.DebugReset()
echo 'raelity init:' exists("g:['raelity']")
echo g:['raelity']

#g:['raelity'].preserve_generated_files = true
i_config.SetGenFilesDirParent('/tmp')

import autoload 'raelity/container/create_dok.vim'
echo 'imported create_dok'

#var target = 'dict_my_class_generated.vim'
var target = './dict_my_class_generated.vim'
create_dok.CreateDOK(target, 'DictMyClass',
    'my_class.MyClass', 'number', ["import './my_class.vim'"])

var gen_file_path = i_config.GenFilePath(target)
#echo "creating:" fnamemodify(target, ":p")
echo "creating:" fnamemodify(gen_file_path, ":p")

import './my_class.vim'
import './dict_my_class_generated.vim'
#import i_config.GenFilePath(target)

type MyClass = my_class.MyClass
type DictMyClass = dict_my_class_generated.DictMyClass

var d = DictMyClass.new()
var o1 = MyClass.new()
var o2 = MyClass.new()
d.Put(o1, 13)
d.Put(o2, 17)

echo d

echo d.Get(o1)
echo d.Get(o2)

var o3 = MyClass.new()
echo d.Get(o3, 5)

#echo d->items()->join("\n")
#var xxx = d->items()
#echo xxx->join("\n")

echo "Keys:\n    " .. d.Keys()->join("\n    ")
echo "Values:" d.Values()
echo printf("Items:\n    %s", d.Items()->join("\n    "))

finish
echo dok.default_base_import

var sid = expand('<SID>')
echo sid

echo matchstr(sid, '\d\+', 5)

#echo expand('<sfile>')

echo getscriptinfo({sid: str2nr(matchstr(sid, '\d\+', 5))})
