vim9script

# A dictionary with "IDictKey" keys and "any" type

# See below to get a dictionary with strict type checking (compile time).

import './IDictKey.vim'

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

##########
########## For strict type checking,
##########
########## import this file to get "DictObjectKeyBase"
########## copy the following and change ValueType/KeyType as needed.
##########
########## Note: "KeyType" must implement "IDictKey.IDictKey".
##########

type ValueType = any
type KeyType = IDictKey.IDictKey

export class DictObjectKey extends DictObjectKeyBase

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
        # can optimize, for loop, inline StringKeyToObj
        return this._d->keys()->mapnew((i, k) => this.StringKeyToObj(k))
    enddef

endclass
