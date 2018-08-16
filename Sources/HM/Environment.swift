/**
    A type environment (context). 
    Maps (program, not type) variable names to type schemes.
    Type schemes as the target are used as a generalization of
    monotypes.
*/
class Environment {
    let bindings: Dictionary<String, Scheme>

    init(_ bindings: Dictionary<String, Scheme>) {
        self.bindings = bindings
    }

    func without(name: String) -> Environment {
        var copy = bindings // really, does this copy the underlying table?
        if let index = copy.index(forKey: name) {
            copy.remove(at: index)
        }
        return Environment(copy)
    }

    func with(name: String, scheme: Scheme) -> Environment {
        var copy = bindings
        copy[name] = scheme
        return Environment(copy)
    }

    func freeVariables() -> Set<String> {
        var union = Set<String>()
        for value in bindings.values {
            for freeVar in value.freeVariables() {
                union.insert(freeVar)
            }
        }
        return union
    }

    func apply(_ subst: Substitution) -> Environment {
        let mapped = bindings.mapValues { each in each.apply(subst) }
        return Environment(mapped)
    }

    func union(_ other: Environment) -> Environment {
        let merged = bindings.merging(other.bindings) { (x, _) in x }
        return Environment(merged)
    }

    func generalize(_ type: Type) -> Scheme {
        let freeInType = type.freeVariables()
        let free = freeInType.subtracting(freeVariables())
        return Scheme(variables: Array(free), type: type)
    }

    /**
        Hindley-Milner algorithm W.
    */
    func inferTypeW(_ exp: Expression) throws -> (type: Type, subst: Substitution) {
        switch exp {
            case is IntLiteral:
                return (TInteger.instance, Substitution.empty)
            case is BoolLiteral:
                return (TBool.instance, Substitution.empty)
            case let variable as Variable:
                if let scheme = bindings[variable.name] {
                    return (scheme.instantiate(), Substitution.empty)
                } else {
                    throw InferenceError("Unbound variable \(variable.name)")
                }
            case let application as Application:
                let a = newVariable()
                let (fType, fSubst) = try inferTypeW(application.function)
                let (aType, aSubst) = try apply(fSubst).inferTypeW(application.argument)
                let mguSubst = try fType.apply(aSubst).mostGeneralUnifier(TFunction(from: aType, to: a))
                return (a.apply(mguSubst), mguSubst + aSubst + fSubst)
            case let abstraction as Abstraction:
                let a = newVariable()
                let name = abstraction.variableName
                let functionEnv = self.without(name: name)
                let argEnv = Environment([name : Scheme(unquantified: a)])
                let env2 = functionEnv.union(argEnv)
                let (t1, s1) = try env2.inferTypeW(abstraction.body)
                return (TFunction(from: a.apply(s1), to: t1), s1)
            case let letExp as Let:
                let (initType, initSubst) = try inferTypeW(letExp.initializer)
                let envWithoutVar = self.without(name: letExp.variableName)
                let genScheme = self.apply(initSubst).generalize(initType)
                let envWithVar = envWithoutVar.with(name: letExp.variableName, scheme: genScheme)
                let (bodyType, bodySubst) = try envWithVar.apply(initSubst).inferTypeW(letExp.body)
                return (bodyType, bodySubst + initSubst)
            default:
                throw InferenceError("Unrecognized expression: \(exp)")
        }
    }

/*
    /**
        Hindley-Milner algorithm J.
    */
    func inferTypeJ(_ exp: Expression) throws -> Type {
        if exp is IntLiteral { 
            return TInteger.instance
        }
        if exp is BoolLiteral {
            return TBool.instance
        }
        if let variable = exp as? Variable {
            if let scheme = bindings[variable.name] {
                return scheme.instantiate()
            } else {
                throw InferenceError("Unbound variable \(variable.name)")
            }
        }

    }
*/
}

struct InferenceError : Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}