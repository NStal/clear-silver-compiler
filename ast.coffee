fs = require "fs"
blockParser = require "./blockParser.coffee"
clauseParser = require "./clauseParser.coffee"
closeClauses = ["end-if","else","end-each"]
parseIfNode = (clauses,index,end)->
    clause = clauses[index]
    console.assert clause
    console.assert clause.type is "if"
    ifNode = new ASTNode(clause)
    index+=1
    ifBody = buildAST clauses,index,end
    ifNode.add ifBody
    # every node has an index unless it's an body node
    # and empty body node is
    # not allowed to add into another node
    # so every node.getLastNode on the tree
    # should finally return an
    # not empty node,thus should has index
    index = ifNode.getLastNode().index+1
    closeNode = new ASTNode(clauses[index])
    if index > end
        throw new Error "unclosed if:"+ifNode.string
    if closeNode.type is "else"
        elseNode = closeNode
        ifNode.elseNode = elseNode
        closeNode = null
        index += 1
        elseBody = buildAST clauses,index,end
        elseNode.add elseBody
        index = elseNode.getLastNode().index+1
        closeNode = new ASTNode(clauses[index])
    if index > end or closeNode.type isnt "end-if"
        throw new Error "unclosed if-else:"+ifNode.string
    ifNode.endIfNode = closeNode
    return ifNode

parseEachNode = (clauses,index,end)->
    clause = clauses[index]
    console.assert clause.type is "each"
    eachNode = new ASTNode(clause)
    index += 1
    if index > end 
        throw "unclosed each:"+eachNode.string
    eachBody = buildAST(clauses,index,end)
    eachNode.add eachBody
    index = eachNode.getLastNode().index+1
    endEachNode = new ASTNode(clauses[index])
    if endEachNode.type isnt "end-each"
        throw "unclosed each:"+eachNode.string
    eachNode.endEachNode = endEachNode
    return eachNode
buildAST = (clauses,start,end)->
    # last unparser clauses
    index = start or 0
    end = end  or clauses.length - 1
    bodyNode = new ASTNode()
    while true
        if index > end
            return bodyNode 
        clause = clauses[index]
        console.assert clause
        # close tag like /if throw to previous level to make it close
        if clause.type in closeClauses
            return bodyNode
        # encounter en open if tag
        if clause.type is "if"
            ifNode = parseIfNode clauses,index,end
            index = ifNode.getLastNode().index+1
            bodyNode.add ifNode
            console.assert (index is (ifNode.endIfNode.index+1)),"wrong index"
        else if clause.type is "each"
            eachNode = parseEachNode clauses,index,end
            index = eachNode.getLastNode().index + 1
            bodyNode.add eachNode
            console.assert (index is (eachNode.endEachNode.index+1)),"wrong index"
            # other match:TODO each;loop
        else
            #normal expression node
            # just add to body
            bodyNode.add new ASTNode(clause)
            index += 1
            console.assert (clause.index+1 is index),"wrong index"
    return true
class ASTNode
    constructor:(clause)-> 
        @body = []
        if not clause
            @type = "body"
            return
        for item of clause
            @[item] = clause[item]
        console.assert @type,"clause without type"
        console.assert (typeof @index is "number"),"clause without index"
    isEmptyBody:()->
        return (@type is "body") and (@body.length is 0)
        
    getLastNode:()->
        console.assert not @isEmptyBody(),"should'nt at last node from here"
        if @type is "if"
            if @endIfNode
                return @endIfNode
            else if @elseNode
                return @elseNode.getLastNode()
            else
                # as an normal node
        if @type is "each"
            if @endEachNode
                return @endEachNode
            else
                # as annormal node
        if @body.length is 0
            return this
        else
            return @body[@body.length-1].getLastNode()
    add:(node)-> 
        console.assert node instanceof ASTNode
        if node.isEmptyBody()
            # ignore empty body node
            return null
        @body.push(node)
if not module.parent
    return
exports.buildAST = buildAST
exports.parseBlocks = blockParser.parseBlocks
exports.parseClauses = clauseParser.parseClauses