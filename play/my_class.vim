vim9script

export class MyClass
    static var count = 1
    const val: number
    def new()
        this.val = count
        count += 1
    enddef
endclass

