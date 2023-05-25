import SwiftSyntax

final class PrivateExtensionConcatenator: SyntaxRewriter {
    override func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        let extensionDecls = findCorrespondingPrivateExtensionDecls(with: node)
        return DeclSyntax(node.withMembers(MemberDeclBlockSyntax { builder in
            for member in node.members.members {
                builder.addMember(member)
            }
            for extensionDecl in extensionDecls {
                for member in extensionDecl.members.members {
                    builder.addMember(member)
                }
            }
            builder.useLeftBrace(node.members.leftBrace)
            builder.useRightBrace(node.members.rightBrace)
        }))
    }

    override func visit(_ node: ExtensionDeclSyntax) -> DeclSyntax {
        guard node.modifiers?.contains(where: { $0.name.tokenKind == .privateKeyword }) == true else {
            return DeclSyntax(node)
        }
        if findCorrespondingClassDecl(with: node) != nil {
            return DeclSyntax(SyntaxFactory.makeBlankExtensionDecl())
        }
        return DeclSyntax(node)
    }

    private func findCorrespondingPrivateExtensionDecls(with node: ClassDeclSyntax) -> [ExtensionDeclSyntax] {
        findAllNodes(from: node.root) { candidate in
            guard let extensionDecl = candidate.as(ExtensionDeclSyntax.self) else {
                return false
            }
            return (
                extensionDecl.extendedType.as(SimpleTypeIdentifierSyntax.self)?.name.text == node.identifier.text &&
                extensionDecl.modifiers?.contains(where: { $0.name.tokenKind == .privateKeyword }) == true
            )
        }.map { $0.as(ExtensionDeclSyntax.self)! }
    }

    private func findCorrespondingClassDecl(with node: ExtensionDeclSyntax) -> ClassDeclSyntax? {
        findAllNodes(from: node.root) { candidate in
            guard let classDecl = candidate.as(ClassDeclSyntax.self) else {
                return false
            }
            return classDecl.identifier.text == node.extendedType.as(SimpleTypeIdentifierSyntax.self)?.name.text
        }.first?.as(ClassDeclSyntax.self)
    }

    private func findAllNodes(from node: Syntax, where predicate: (Syntax) -> Bool) -> [Syntax] {
        if predicate(node) {
            return [node]
        }
        return node.children.flatMap { findAllNodes(from: $0, where: predicate) }
    }
}
