func inferType(_ expr: Expression) throws -> (type: Type, subst: Substitution) {
    return try Environment([:]).inferTypeW(expr)
}

func display(_ expr: Expression) {
    print("--------------------")
    print("expression = \(expr)")
    do {
        let (inferredType, subst) = try inferType(expr)
        print("type = \(inferredType)")
        print("substitution = \(subst)")
    } catch {
        print("error: \(error)")
    }
}

display(IntLiteral(value: 3))
display(BoolLiteral(value: true))
display(Abstraction(variableName: "x", body: Variable(name: "x")))
display(Abstraction(variableName: "x", body: IntLiteral(value: 3)))
display(
    Abstraction(variableName: "f", body: 
        Application(function: Variable(name: "f"), argument: IntLiteral(value: 3))))
display(
    Let(variableName: "id",
        initializer: Abstraction(variableName: "x", body: Variable(name: "x")),
        body: Variable(name: "id")))
display(Variable(name: "x"))
