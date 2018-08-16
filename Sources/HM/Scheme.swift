/**
    A type scheme (a polytype), with the listed variables quantified as `for all`.
*/
class Scheme {
    /// Quantified type variable names.
    let variables: [String]
    /// The monotype in which some or all of the quantified names are bound.
    let type: Type

    init(variables: [String], type: Type) {
        self.variables = variables
        self.type = type
    }

    init(unquantified type: Type) {
        self.variables = []
        self.type = type
    }

    func freeVariables() -> Set<String> {
        return type.freeVariables().subtracting(variables)
    }

    func apply(_ subst: Substitution) -> Scheme {
        let s = type.apply(subst.without(names: variables))
        return Scheme(variables: variables, type: s)
    }

    /**
        Produce a monotype by replacing every quantified variable in the
        type with a freshly allocated type variable.
    */
    func instantiate() -> Type {
        // not sure how idiomatic this is
        let newVars = variables.map { name in (name, newVariable()) }
        let quantifiedReplacement = Substitution(Dictionary(newVars) { (x, _) in x })
        return type.apply(quantifiedReplacement)
    }
}