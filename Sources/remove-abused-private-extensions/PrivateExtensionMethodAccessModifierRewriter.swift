import SwiftSyntax

/**
 * Modifies all methods in a private extension as private.
 */
final class PrivateExtensionMethodAccessModifierRewriter: SyntaxRewriter {
    private var isInPrivateExtension = false
    private var classNames: [String] = []

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

    override func visit(_ node: SourceFileSyntax) -> Syntax {
        classNames = findAllClassNames(from: Syntax(node))
        return super.visit(node)
    }

    override func visit(_ node: ExtensionDeclSyntax) -> DeclSyntax {
        if let extendedType = node.extendedType.as(SimpleTypeIdentifierSyntax.self), classNames.contains(extendedType.name.text) {
            return super.visit(node)
        }
        return DeclSyntax(node)
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

    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        if !isInPrivateExtension {
            return DeclSyntax(node)
        }
        if node.parent?.is(MemberDeclListItemSyntax.self) != true {
            return DeclSyntax(node)
        }
        if node.modifiers?.contains(where: { $0.name.tokenKind == .privateKeyword }) == true {
            return DeclSyntax(node)
        }
        return DeclSyntax(node.insertModifier(DeclModifierSyntax { builder in
            builder.useName(SyntaxFactory.makePrivateKeyword(trailingTrivia: .spaces(1)))
        }))
    }

    private func findAllClassNames(from node: Syntax) -> [String] {
        if let classDecl = node.as(ClassDeclSyntax.self) {
            return [classDecl.identifier.text]
        }
        return node.children.flatMap(findAllClassNames(from:))
    }
}

private extension FunctionDeclSyntax {
    func insertModifier(_ element: DeclModifierSyntax) -> FunctionDeclSyntax {
        guard let modifiers = modifiers, let firstModifier = modifiers.first else {
            return addModifier(element.withLeadingTrivia(funcKeyword.leadingTrivia ?? .zero))
                .withFuncKeyword(funcKeyword.withLeadingTrivia(.zero))
        }
        return withModifiers(SyntaxFactory.makeModifierList([
            element.withLeadingTrivia(firstModifier.leadingTrivia ?? element.leadingTrivia ?? .zero),
            firstModifier.withLeadingTrivia(.zero)
        ] + Array(modifiers.dropFirst())))
    }
}

private extension VariableDeclSyntax {
    func insertModifier(_ element: DeclModifierSyntax) -> VariableDeclSyntax {
        guard let modifiers = modifiers, let firstModifier = modifiers.first else {
            return addModifier(element.withLeadingTrivia(letOrVarKeyword.leadingTrivia ?? .zero))
                .withLetOrVarKeyword(letOrVarKeyword.withLeadingTrivia(.zero))
        }
        return withModifiers(SyntaxFactory.makeModifierList([
            element.withLeadingTrivia(firstModifier.leadingTrivia ?? element.leadingTrivia ?? .zero),
            firstModifier.withLeadingTrivia(.zero)
        ] + Array(modifiers.dropFirst())))
    }
}
