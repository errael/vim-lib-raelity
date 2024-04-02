# DictObjectKeyTemplate

#
# This is like a dict that accepts a class-object/enum-value as an index.
# For most type checking, need one of these per value type.
#
# Copy it, change the class name and customize the ":type" statements.
# Typically copy this file after the corresponding class definition.
# 

# See IDictKey.vim for information on keys.

#
# KeyType is the object type that will be used to index the dict.
# KeyType must have an immutable "as_key" variable; and it must be
# unique among all objects used as a key; for example:
#       "<SNR>123_ExampleClass@456"
#

#
# KeyType could be an interface if different types of enums/objects
# are used as keys.
#

import '.../DictObjectKey.vim'

type KeyType = KEY_TYPE
type ValueType = VALUE_TYPE

export class DictObjectKeyTemplate extends DictObjectKey.DictObjectKeyBase

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

