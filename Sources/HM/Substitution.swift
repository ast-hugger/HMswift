class Substitution {

    static let empty = Substitution([:])

    let bindings: Dictionary<String, Type>

    init(_ bindings: Dictionary<String, Type>) {
        self.bindings = bindings
    }

    func lookup(name: String) -> Type? {
        return bindings[name]
    }

    func copyWithout(names: [String]) -> Substitution {
        let filtered = bindings.filter { some in !names.contains(some.key) }
        return Substitution(filtered)
    }
}

func + (left: Substitution, right: Substitution) -> Substitution {
    let applied = right.bindings.mapValues { each in each.substitute(left) }
    let merged = applied.merging(left.bindings) { (x, _) in x}
    return Substitution(merged)
}

extension Substitution: CustomStringConvertible {
    var description: String {
        var result = "{"
        var first = true
        for each in bindings {
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