/**
    A type environment. Maps names to type schemes.
*/
class Environment {
    let mapping: Dictionary<String, Scheme>

    init(_ mapping: Dictionary<String, Scheme>) {
        self.mapping = mapping
    }

    func without(name: String) -> Environment {
        var copy = mapping // really, does this copy the underlying table?
        if let index = copy.index(forKey: name) {
            copy.remove(at: index)
        }
        return Environment(copy)
    }

    func with(name: String, scheme: Scheme) -> Environment {
        var copy = mapping
        copy[name] = scheme
        return Environment(copy)
    }

    func freeVariables() -> Set<String> {
        var union = Set<String>()
        for value in mapping.values {
            for freeVar in value.freeVariables() {
                union.insert(freeVar)
            }
        }
        return union
    }

    func substitute(_ subst: Substitution) -> Environment {
        let mapped = mapping.mapValues { each in each.substitute(subst) }
        return Environment(mapped)
    }

    func union(_ other: Environment) -> Environment {
        let merged = mapping.merging(other.mapping) { (x, _) in x }
        return Environment(merged)
    }

    func generalize(_ type: Type) -> Scheme {
        let freeInType = type.freeVariables()
        let free = freeInType.subtracting(freeVariables())
        return Scheme(variables: Array(free), type: type)
    }

    /**
        Algorithm W.
    */
    func inferType(_ exp: Expression) -> (type: Type, subst: Substitution)? {
        if exp is IntLiteral { 
            return (TInteger(), Substitution.empty) 
        }
        if exp is BoolLiteral {
            return (TBool(), Substitution.empty)
        }
        if let variable = exp as? Variable {
            if let scheme = mapping[variable.name] {
                return (scheme.instantiate(), Substitution.empty)
            } else {
                return nil
            }
        }
        if let application = exp as? Application {
            let (fType, fSubst) = inferType(application.function)!
            let (aType, aSubst) = substitute(fSubst).inferType(application.argument)!
            let a = newVariable()
            let mgu = fType.substitute(aSubst) & TFunction(from: aType, to: a)
            return (a.substitute(mgu!), mgu! + aSubst + fSubst)
        }
        if let abstraction = exp as? Abstraction {
            let typeVar = newVariable()
            let name = abstraction.variableName
            let functionEnv = self.without(name: name)
            let argEnv = Environment([name: Scheme(variables: [], type: typeVar)])
            let env2 = functionEnv.union(argEnv)
            let (t1, s1) = env2.inferType(abstraction.body)!
            return (TFunction(from: typeVar.substitute(s1), to: t1), s1)
        }
        if let letExp = exp as? Let {
            let (initType, initSubst) = inferType(letExp.initializer)!
            let envWithoutVar = self.without(name: letExp.variableName)
            let genScheme = self.substitute(initSubst).generalize(initType)
            let envWithVar = envWithoutVar.with(name: letExp.variableName, scheme: genScheme)
            let (bodyType, bodySubst) = envWithVar.substitute(initSubst).inferType(letExp.body)!
            return (bodyType, bodySubst + initSubst)
        }
        return nil
    }
}