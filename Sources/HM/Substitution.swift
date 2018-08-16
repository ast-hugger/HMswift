/**
    A mapping of type variable names to monotypes which are to replace them.
*/
class Substitution {

    static let empty = Substitution([:])

    /// Maps type variable names to the types replacing them.
    let replacements: Dictionary<String, Type>

    init(_ replacements: Dictionary<String, Type>) {
        self.replacements = replacements
    }

    func lookup(name: String) -> Type? {
        return replacements[name]
    }

    /**
        Return a new substitution which leaves variables with the specified
        names untouched.
    */
    func without(names: [String]) -> Substitution {
        let filtered = replacements.filter { some in !names.contains(some.key) }
        return Substitution(filtered)
    }
}

/**
    Compose two substitutions. Importantly, the composition is not commutative,
    as the `left` substitution is applied to all types in the `right`
    substitution prior to combining all replacements.
*/
func + (left: Substitution, right: Substitution) -> Substitution {
    let rightSubstituted = right.replacements.mapValues { each in each.apply(left) }
    let merged = left.replacements.merging(rightSubstituted) { (x, _) in x}
    return Substitution(merged)
}

extension Substitution: CustomStringConvertible {
    var description: String {
        var result = "{"
        var first = true
        for each in replacements {
            if first {
                first = false
            } else {
                result.append(", ")
            }
            result.append(each.key)
            result.append(": ")
            result.append(String(describing: each.value))
        }
        result.append("}")
        return result
    }
}