vim9script

import autoload 'raelity/container/obj_key.vim'

export class MyClass implements obj_key.IObjKey
    const unique_object_id = obj_key.GenerateKey() 
endclass

