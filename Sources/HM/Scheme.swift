/**
    A type scheme with the listed variables quantified as `for all`.
*/
class Scheme {
    let variables: [String]
    let type: Type

    init(variables: [String], type: Type) {
        self.variables = variables
        self.type = type
    }

    func freeVariables() -> Set<String> {
        return type.freeVariables().subtracting(variables)
    }

    func substitute(_ subst: Substitution) -> Scheme {
        let s = type.substitute(subst.copyWithout(names: variables))
        return Scheme(variables: variables, type: s)
    }

    func instantiate() -> Type {
        // not sure how idiomatic most of this is
        let typeVars = variables.map { name in (name, newVariable()) }
        let mapping = Dictionary(typeVars) { (x, _) in x }
        return type.substitute(Substitution(mapping))
    }
}