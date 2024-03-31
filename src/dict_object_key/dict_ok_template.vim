# DictObjectKeyTemplate

#
# This is like a dict that accepts a class-object/enum-value as an index.
# Need one of these per value type.
#
# Copy it, change the class name and customize the ":type" statements.
# Typically copy this file after the corresponding class definition.
# 

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

type KeyType = KEY_TYPE
type ValueType = VALUE_TYPE

export class DictObjectKeyTemplate

    var _d: dict<list<any>>

    def Put(key: KeyType, value: ValueType)
        this._d[key.as_key] = [ key, value ]
    enddef

    def Get(key: KeyType): ValueType
        return this._d[key.as_key][1]
    enddef

    def KeyToObj(key: string): KeyType
        return this._d[key][0]
    enddef

    ############
    # BaseDict #
    ############

    def len(): number
        return this._d->len()
    enddef

    def empty(): bool
        return this._d->len() == 0
    enddef

    def Keys(): list<string>
        return this._d->keys()
    enddef
endclass

