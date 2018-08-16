/*
    The types, or more specifically monotypes.
    See also class Scheme for polytypes.
*/

class Type : Equatable {

    static func == (left: Type, right: Type) -> Bool {
        return type(of: left) == type(of: right)
            && left.isEqual(to: right)
    }

    func isEqual(to: Type) -> Bool {
        return false
    }

    func freeVariables() -> Set<String> {
        return Set()
    }

    func apply(_ subst: Substitution) -> Type {
        return self
    }

    func mostGeneralUnifier(_ other: Type) throws -> Substitution {
        if let otherVar = other as? TVariable {
            return try bindVariable(otherVar.name, self)
        } else {
            throw InferenceError("types \(self) and \(other) do not unify")
        }
    }
}

class TInteger : Type, CustomStringConvertible {
    static let instance = TInteger()

    override func mostGeneralUnifier(_ other: Type) throws -> Substitution {
        return other is TInteger ? Substitution.empty : try super.mostGeneralUnifier(other)
    }

    var description: String {
        return "Int"
    }
}

class TBool : Type, CustomStringConvertible {
    static let instance = TBool()

    override func mostGeneralUnifier(_ other: Type) throws -> Substitution {
        return other is TBool ? Substitution.empty : try super.mostGeneralUnifier(other)
    }

    var description: String {
        return "Bool"
    }
}

class TVariable : Type, CustomStringConvertible {
    let name: String

    init(name: String) {
        self.name = name
    }

    override func isEqual(to: Type) -> Bool {
        return name == (to as! TVariable).name
    }

    override func freeVariables() -> Set<String> {
        return Set([name])
    }

    override func apply(_ subst: Substitution) -> Type {
        return subst.lookup(name: name) ?? self
    }

    override func mostGeneralUnifier(_ other: Type) throws -> Substitution {
        return try bindVariable(name, other)
    }

    var description: String {
        return name;
    }
}

var serial: Int = 0

func newVariable(pref: String = "a") -> TVariable {
    serial = serial + 1
    return TVariable(name: pref + String(serial))
}

func bindVariable(_ name: String, _ type: Type) throws -> Substitution {
    if (type as? TVariable)?.name == name {
        return Substitution.empty
    }
    if type.freeVariables().contains(name) {
        throw InferenceError("free variable check fails for \(name) in \(type)")
    }
    return Substitution([name : type])
}

class TFunction : Type, CustomStringConvertible {
    let from: Type
    let to: Type

    init(from: Type, to: Type) {
        self.from = from
        self.to = to
    }

    override func isEqual(to other: Type) -> Bool {
        let otherFun = other as! TFunction
        return from == otherFun.from && to == otherFun.to
    }

    override func freeVariables() -> Set<String> {
        return from.freeVariables().union(to.freeVariables())
    }

    override func apply(_ subst: Substitution) -> Type {
        return TFunction(from: from.apply(subst), to: to.apply(subst))
    }

    override func mostGeneralUnifier(_ other: Type) throws -> Substitution {
        if let otherFun = other as? TFunction {
            let s1 = try from.mostGeneralUnifier(otherFun.from)
            let s2 = try to.apply(s1).mostGeneralUnifier(otherFun.to.apply(s1))
            return s1 + s2
        } else {
            return try super.mostGeneralUnifier(other)
        }
    }

    var description: String {
        // The -> type constructor is right-associative so we have to parenthesize
        // the left argument.
        return from is TFunction
            ? "(\(from)) -> \(to)"
            : "\(from) -> \(to)"
    }
}
