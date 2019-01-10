func Init<Type>(_ object: Type, block: (Type) -> ()) -> Type {
    block(object)
    return object
}

func randomTrue() -> Bool {
    return Int.random(in: 0...1) == 1 ? true : false
}
