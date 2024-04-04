vim9script

# Like a "dict_ok<IObjKey, any>" where key:IObjKey, type:any type
# See below to create a dictionary with strict type checking (compile time).

# var dok = DictObjKey.new()

import autoload './obj_key.vim'

export abstract class DictObjKeyBase 

    var _d: dict<list<any>>

    def len(): number
        return this._d->len()
    enddef

    def empty(): bool
        return this._d->len() == 0
    enddef

    def StringKeys(): list<string>
        return this._d->keys()
    enddef
endclass

## For strict type checking, import this file to get "DictObjKeyBase"
## copy the following and change KeyType/ValueType as needed.
##
## Note: "KeyType" must implement "obj_key.IObjKey".

type KeyType = obj_key.IObjKey
type ValueType = any

export class DictObjKey extends DictObjKeyBase

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
