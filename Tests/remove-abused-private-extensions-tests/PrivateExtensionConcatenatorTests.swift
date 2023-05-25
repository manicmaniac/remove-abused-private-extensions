import SwiftSyntaxParser
import XCTest
@testable import remove_abused_private_extensions

final class PrivateExtensionConcatenatorTests: XCTestCase {
    func test_visit_moves_private_methods() throws {
        let original = """
            class Foo {
            }
            extension Foo {
                func bar() {}
            }
            private extension Foo {
                func baz() {}
            }
            private extension Foo {
                private func qux() {}
            }
            """
        let expected = """
            class Foo {
                func baz() {}
                private func qux() {}
            }
            extension Foo {
                func bar() {}
            }
            """
        let syntax = try SyntaxParser.parse(source: original)
        let rewriter = PrivateExtensionConcatenator()
        let modified = String(describing: rewriter.visit(syntax))
        XCTAssertEqual(modified, expected)
    }

    func test_visit_moves_private_properties() throws {
        let original = """
            class Foo {
            }
            extension Foo {
                var bar: Int { 0 }
            }
            private extension Foo {
                var baz: Int { 0 }
            }
            private extension Foo {
                private var qux: Int { 0 }
            }
            """
        let expected = """
            class Foo {
                var baz: Int { 0 }
                private var qux: Int { 0 }
            }
            extension Foo {
                var bar: Int { 0 }
            }
            """
        let syntax = try SyntaxParser.parse(source: original)
        let rewriter = PrivateExtensionConcatenator()
        let modified = String(describing: rewriter.visit(syntax))
        XCTAssertEqual(modified, expected)
    }
}
