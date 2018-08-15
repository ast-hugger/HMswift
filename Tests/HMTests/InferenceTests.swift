import XCTests
@testable import HM

final class InferenceTests : XCTestCase {

    func testInteger() {
        let (type, subst) = inferType(IntLiteral(value: 3))
        
    }
}