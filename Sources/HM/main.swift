func inferType(_ expr: Expression) -> (type: Type, subst: Substitution) {
    return Environment([:]).inferType(expr)!
}

func display(_ expr: Expression) {
    let (inferredType, subst) = inferType(expr)
    print("--------------------")
    print("expression = \(expr)")
    print("type = \(inferredType)")
    print("substitution = \(subst)")
}

display(IntLiteral(value: 3))
display(BoolLiteral(value: true))
display(Abstraction(variableName: "x", body: Variable(name: "x")))
display(
    Abstraction(variableName: "f", body: 
        Application(function: Variable(name: "f"), argument: IntLiteral(value: 3))))
display(
    Let(variableName: "id",
        initializer: Abstraction(variableName: "x", body: Variable(name: "x")),
        body: Variable(name: "id")))
