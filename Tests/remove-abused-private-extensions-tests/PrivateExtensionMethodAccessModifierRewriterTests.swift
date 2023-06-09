import SwiftSyntaxParser
import XCTest
@testable import remove_abused_private_extensions

final class PrivateExtensionMethodAccessModifierRewriterTests: XCTestCase {
    func test_visit_adds_private_access_modifiers_to_methods() throws {
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
            }
            extension Foo {
                func bar() {}
            }
            private extension Foo {
                private func baz() {}
            }
            private extension Foo {
                private func qux() {}
            }
            """
        let syntax = try SyntaxParser.parse(source: original)
        let rewriter = PrivateExtensionMethodAccessModifierRewriter()
        let modified = String(describing: rewriter.visit(syntax))
        XCTAssertEqual(modified, expected)
    }

    func test_visit_adds_private_access_modifiers_to_properties() throws {
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
            }
            extension Foo {
                var bar: Int { 0 }
            }
            private extension Foo {
                private var baz: Int { 0 }
            }
            private extension Foo {
                private var qux: Int { 0 }
            }
            """
        let syntax = try SyntaxParser.parse(source: original)
        let rewriter = PrivateExtensionMethodAccessModifierRewriter()
        let modified = String(describing: rewriter.visit(syntax))
        XCTAssertEqual(modified, expected)
    }

    func test_visit_does_not_change_access_modifier_of_external_extensions() throws {
        let original = """
            class Foo {
            }
            private extension Bar {
                var bar: Int { 0 }
            }
            """
        let expected = """
            class Foo {
            }
            private extension Bar {
                var bar: Int { 0 }
            }
            """
        let syntax = try SyntaxParser.parse(source: original)
        let rewriter = PrivateExtensionMethodAccessModifierRewriter()
        let modified = String(describing: rewriter.visit(syntax))
        XCTAssertEqual(modified, expected)
    }
}
