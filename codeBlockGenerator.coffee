class Variable
    constructor:()->
        return true
class CodeBlock
    constructor:()->
        @variableDeclares = []
        @variableInit = []
        @code
    createVariable:(type,name)->

class Clause
    constructor:(node)->
        return true
Clause.fromASTNode = (node)->
    constructor = Clauses[node.type]
    if not constructor
        throw new Error "unsupported clause type",node.type
    return new constructor(node)
class BodyClause extends Clause
    constructor:(node)->
        @node = node
    generateCode:(globalScope)->
        codes = []
        for item in @node.body
            clause = Clause.fromASTNode(item)
            codes.push clause.generateCode(globalScope)
        return codes.join "\n"
class EachClause extends Clause
    constructor:()->
class SetClause extends Clause
    constructor:(node)->
        @node = node
    generateCode:(globalScope)->
        
class VarClause extends Clause
    constructor:(node)->
        @node = node
        @template = "CSVar(\"{hdfIndex}\");"
    generateCode:(globalScope)->
        return @template.replace("{hdfIndex}",@node.hdfIndex)
class IfClause extends Clause
    constructor:()->
class EchoClause extends Clause
    constructor:(node)->
        @node = node
        @template = "CSEcho(\"{content}\");"
    generateCode:(globalScope)->
        if not @node.string
            return ""
        return @template.replace("{content}",@node.string)
Clauses = {
    "if":IfClause
    ,"body":BodyClause
    ,"set":SetClause
    ,"var":VarClause
    ,"each":EachClause
    ,"echo":EchoClause
}
exports.Clause = Clause
exports.Clauses  = Clauses
exports.CodeBlock = CodeBlock