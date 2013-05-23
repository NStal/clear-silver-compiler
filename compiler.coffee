codeBlockGenerator = require "./codeBlockGenerator.coffee"
CodeBlock = codeBlockGenerator.CodeBlock
Clause = codeBlockGenerator.Clause
generateCode = (AST)->
    root = Clause.fromASTNode(AST)
    globalScope = new CodeBlock()
    return root.generateCode(globalScope)
exports.generateCode = generateCode