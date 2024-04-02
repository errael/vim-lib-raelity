vim9script

# A dictionary with "IDictKey" keys and "any" type
# If you want strict type checking (compile time)
# copy dict_ok_template and customize the ":type" 

# copied from 'dict_ok_template'

import './IDictKey.vim'

type ValueType = any
type KeyType = IDictKey.IDictKey

# would like to implement a dict

export abstract class DictObjectKeyBase 

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

export class DictObjectKey extends DictObjectKeyBase

    def Put(key: KeyType, value: ValueType)
        this._d[key.as_key] = [ key, value ]
    enddef

    def Get(key: KeyType): ValueType
        return this._d[key.as_key][1]
    enddef

    def StringKeyToObj(key: string): KeyType
        return this._d[key][0]
    enddef

    def Keys(): list<KeyType>
        # can optimize, for loop, inline StringKeyToObj
        return this._d->keys()->mapnew((i, k) => this.StringKeyToObj(k))
    enddef

endclass
