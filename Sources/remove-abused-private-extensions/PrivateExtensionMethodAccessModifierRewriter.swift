import SwiftSyntax

/**
 * Modifies all methods in a private extension as private.
 */
final class PrivateExtensionMethodAccessModifierRewriter: SyntaxRewriter {
    private var isInPrivateExtension = false

    override func visitPre(_ node: Syntax) {
        if let modifiers = node.as(ExtensionDeclSyntax.self)?.modifiers,
           modifiers.contains(where: { $0.name.tokenKind == .privateKeyword }) {
            isInPrivateExtension = true
        }
    }

    override func visitPost(_ node: Syntax) {
        if isInPrivateExtension && node.is(ExtensionDeclSyntax.self) {
            isInPrivateExtension = false
        }
    }

    override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        if !isInPrivateExtension {
            return DeclSyntax(node)
        }
        if node.modifiers?.contains(where: { $0.name.tokenKind == .privateKeyword }) == true {
            return DeclSyntax(node)
        }
        return DeclSyntax(node.insertModifier(DeclModifierSyntax { builder in
            builder.useName(SyntaxFactory.makePrivateKeyword(trailingTrivia: .spaces(1)))
        }))
    }
}

private extension FunctionDeclSyntax {
    func insertModifier(_ element: DeclModifierSyntax) -> FunctionDeclSyntax {
        guard let modifiers = modifiers, let firstModifier = modifiers.first else {
            return addModifier(element.withLeadingTrivia(funcKeyword.leadingTrivia ?? .zero))
                .withFuncKeyword(funcKeyword.withLeadingTrivia(.zero))
        }
        return withModifiers(SyntaxFactory.makeModifierList([
            // DeclModifierSyntax
            element.withLeadingTrivia(firstModifier.leadingTrivia ?? element.leadingTrivia ?? .zero),
            firstModifier.withLeadingTrivia(.zero)
        ] + Array(modifiers.dropFirst())))
    }
}
