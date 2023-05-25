import Foundation
import SwiftSyntax
import SwiftSyntaxParser

let rewriters = [
    PrivateExtensionMethodAccessModifierRewriter(),
    PrivateExtensionConcatenator()
]

for path in CommandLine.arguments.dropFirst() {
    let url = URL(fileURLWithPath: path)
    let syntax = Syntax(try SyntaxParser.parse(url))
    let source = rewriters.reduce(syntax) { syntax, rewriter in
        rewriter.visit(syntax)
    }
    let data = Data(String(describing: source).utf8)
    try data.write(to: url)
}
