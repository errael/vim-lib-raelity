vim9script

# Like a "dict_ok<IObjKey, any>" where key:IObjKey, type:any type
# See below to create a dictionary with strict type checking (compile time).

# var dok = DictObjKey.new()

#import autoload './obj_key.vim'

export abstract class DictObjKeyBase 
    # The key in "_d" is "id(realkey); values in "_d" are "[ realkey, value ]"
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

# For strict type checking, import this file to get "DictObjKeyBase"
# copy the following and change KeyType/ValueType as needed.
#

##### ## Note: "KeyType" must implement "obj_key.IObjKey".

type KeyType = any #obj_key.IObjKey
type ValueType = any

export class DictObjKey extends DictObjKeyBase

    def Put(key: KeyType, value: ValueType)
        this._d[id(key)] = [ key, value ]
    enddef

    # If key not in dict, then return default.
    # Probably get an error if key not found and no default specified
    def Get(key: KeyType, default: any = null): ValueType
        var val = this._d->get(id(key), null)
        if val != null
            return val[1]
        endif
        return default
    enddef

    def HasKey(key: KeyType): bool
        return this._d->hasKey(id(key))
    enddef

    # Keys()/Values()/Items() don't lock can modify things deeper into dict
    def Keys(): list<KeyType>
        return this._d->values()->mapnew((i, k) => k[0])
    enddef

    def Values(): list<ValueType>
        return this._d->values()->mapnew((i, k) => k[1])
    enddef

    def Items(): list<any>
        return this._d->values()
    enddef

    def HasStringKey(stringkey: KeyType): bool
        return this._d->hasKey(stringkey)
    enddef

    def StringKeyToObj(stringkey: string): KeyType
        return this._d[stringkey][0]
    enddef
endclass
