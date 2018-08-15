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

    func substitute(_ subst: Substitution) -> Type {
        return self
    }

    func mostGeneralUnifier(_ other: Type) -> Substitution? {
        if let otherVar = other as? TVariable {
            return bindVariable(otherVar.name, self)
        } else {
            return nil
        }
    }
}

func & (left: Type, right: Type) -> Substitution? {
    return left.mostGeneralUnifier(right)
}

class TInteger : Type, CustomStringConvertible {
    override func mostGeneralUnifier(_ other: Type) -> Substitution? {
        return other is TInteger ? Substitution.empty : super.mostGeneralUnifier(other)
    }

    var description: String {
        return "Int"
    }
}

class TBool : Type, CustomStringConvertible {
    override func mostGeneralUnifier(_ other: Type) -> Substitution? {
        return other is TBool ? Substitution.empty : super.mostGeneralUnifier(other)
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

    override func substitute(_ subst: Substitution) -> Type {
        return subst.lookup(name: name) ?? self
    }

    override func mostGeneralUnifier(_ other: Type) -> Substitution? {
        return bindVariable(name, other)
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

func bindVariable(_ name: String, _ type: Type) -> Substitution? {
    if (type as? TVariable)?.name == name {
        return Substitution.empty
    }
    if type.freeVariables().contains(name) {
        return nil // error; circular type
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

    override func substitute(_ subst: Substitution) -> Type {
        return TFunction(from: from.substitute(subst), to: to.substitute(subst))
    }

    override func mostGeneralUnifier(_ other: Type) -> Substitution? {
        if let otherFun = other as? TFunction {
            if let s1 = from & otherFun.from {
                if let s2 = to.substitute(s1) & otherFun.to.substitute(s1) {
                    return s1 + s2
                }
            }
            return nil
        } else {
            return super.mostGeneralUnifier(other)
        }
    }

    var description: String {
        return "\(from) -> \(to)"
    }
}
