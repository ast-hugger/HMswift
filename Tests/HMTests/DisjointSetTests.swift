import XCTest
@testable import HM

final class DisjointSetTests : XCTestCase {

    let numbers: DisjointSet<Int> = DisjointSet(1, 2, 3, 4, 5)

    func testRepresentative() {
        XCTAssertEqual(1, numbers.representative(1))
        XCTAssertEqual(2, numbers.representative(2))
    }

    func unionOfTwo() {
        numbers.unify(1, 2)
        XCTAssertTrue(numbers.representative(1) == numbers.representative(2))
        XCTAssertFalse(numbers.representative(1) == numbers.representative(3))
        XCTAssertFalse(numbers.representative(2) == numbers.representative(3))
    }

    func unionOfThree() {
        numbers.unify(1, 2)
        numbers.unify(2, 3)
        XCTAssertTrue(numbers.representative(1) == numbers.representative(2))
        XCTAssertTrue(numbers.representative(2) == numbers.representative(3))
        XCTAssertFalse(numbers.representative(1) == numbers.representative(4))
        XCTAssertFalse(numbers.representative(2) == numbers.representative(4))
        XCTAssertFalse(numbers.representative(3) == numbers.representative(4))
    }

    static var allTests = [
        ("testRepresentative", testRepresentative),
        ("unionOfTwo", unionOfTwo),
        ("unionOfThree", unionOfThree)
    ]
}