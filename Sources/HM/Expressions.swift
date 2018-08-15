/**
    The basic lambda calculus.
*/

protocol Expression {

}

class Variable : Expression {
    let name: String

    init(name: String) {
        self.name = name
    }
}

extension Variable : CustomStringConvertible {
    var description: String {
        return name;
    }
}

class Literal : Expression {

}

class IntLiteral : Literal {
    let value: Int

    init(value: Int) {
        self.value = value
    }
}

extension IntLiteral : CustomStringConvertible {
    var description: String {
        return String(value);
    }
}

class BoolLiteral : Literal {
    let value: Bool

    init(value: Bool) {
        self.value = value
    }
}

extension BoolLiteral : CustomStringConvertible {
    var description: String {
        return value ? "true" : "false";
    }
}

class Application : Expression {
    let function: Expression
    let argument: Expression

    init(function: Expression, argument: Expression) {
        self.function = function
        self.argument = argument
    }
}

extension Application : CustomStringConvertible {
    var description: String {
        return "\(function) \(argument)";
    }
}

class Abstraction : Expression {
    let variableName: String
    let body: Expression

    init(variableName: String, body: Expression) {
        self.variableName = variableName
        self.body = body
    }
}

extension Abstraction : CustomStringConvertible {
    var description: String {
        return "\u{03BB}\(variableName).\(body)"
    }
}

class Let : Expression {
    let variableName: String
    let initializer: Expression
    let body: Expression

    init(variableName: String, initializer: Expression, body: Expression) {
        self.variableName = variableName
        self.initializer = initializer
        self.body = body
    }
}

extension Let : CustomStringConvertible {
    var description: String {
        return "let \(variableName) = \(initializer) in \(body)"
    }
}