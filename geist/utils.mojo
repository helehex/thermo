# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

fn any_rebind[Source: AnyType, //, Target: AnyType](ref [_]value: Source) -> ref [__lifetime_of(value)]Target:
    return rebind[Reference[Target, __lifetime_of(value)]](Reference(value))[]