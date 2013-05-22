fs = require "fs"

# unsafe replace
# not escape any reg special chars
String.prototype.replaceAllUnsafe = (pattern,to)->
    return this.replace(new RegExp(pattern,"g"),to)
Regs = {
    token:"#?([a-z0-9_]*\\.)*([a-z_0-9]*)"
    ,variable:"[a-z_0-9]*"
    ,expression:"[#a-z_0-9\\-+=.]*"
    }
clauseMaps = [{type:"var",parser:"var:{expression}"}
    ,{type:"if",parser:"if:{expression}"}
    ,{type:"else",parser:"else"}
    ,{type:"end-if",parser:"/if"}
    ,{type:"set",parser:"set:{token}\\s*=\\s*{expression}"}
    ,{type:"each",parser:"each:{variable}\\s*=\\s*{expression}"}
    ,{type:"end-each",parser:"/each"}
    ]
# build clauesMap
for item in clauseMaps
    regString = item.parser
    for value of Regs
        regString = regString.replaceAllUnsafe(["\\{",value,"\\}"].join(""),Regs[value])
    item.reg = new RegExp(["^",regString,"$"].join(""),"i")

isCloseClause = (type)->
    return type in ["end-if","else"]
buildAST = (blocks,start,end)->
    # index is the largest unparsed node
    index = start or 0
    end = end or blocks.length-1
    bodyNode = new ASTNode()
    while true 
        if index > end
            break
        node = new ASTNode(blocks[index])
        if isCloseClause(node.type)
            console.log "break node ",node.clause
            return bodyNode
        if node.type is "else"
            throw new Error "unexpected else:"+node.block.csContentString
            
        if node.type is "if"
            index+=1
            while true
                #add node until else or end-if
                if index > end
                    throw new Error  "Unclosed If statement:"+node.block.csContentString
                closeIf = blocks[index]
                console.log "index",index,end,closeIf
                console.assert closeIf
                if closeIf.clause.type is "else"
                    console.log "else!"
                    if node.elseNode
                        throw Error "dumplicated else for if statement:"+node.block.csContentString
                    node.elseNode = new ASTNode(closeIf)
                    lastNode = node.elseNode.getLastNode()
                    index = lastNode.index + 1
                    continue
                else if closeIf.clause.type is "end-if"
                    console.log "~~END!!! break"
                    node.endIfNode = new ASTNode(closeIf)
                    index = closeIf.index + 1
                    break
                else
                    #normal node recursive parse
                    childNode = buildAST blocks,index+1,end
                    if node.elseNode
                        node.elseNode.add childNode
                    else
                        node.add childNode
                    lastNode = childNode.getLastNode()
                    index = lastNode.index+1
                    continue
            # only reach here if "if" closed
            console.assert node.endIfNode
        else
            index+=1
        bodyNode.add node
        continue
    return bodyNode
        
class ASTNode
    constructor:(block)-> 
        @body = [] 
        @block = block
        @index = block and block.index or -1
        @clause = block and block.clause or null
        @type = @clause and @clause.type or "body"
    getLastNode:()->
        if @type is "if"
            return @endIfNode
        if @body.length is 0
            return this
        else
            return @body[@body.length-1].getLastNode()
    add:(node)-> 
        console.assert node instanceof ASTNode
        if not node.clause and node.body.length is 0
            # ignore empty body node
            return null
        @body.push(node)
parseCSBlock = (csString,index)->
    parseCSClauseStart = (csString,index)->
        return csString.indexOf("<?cs",index)
    parseCSClauseEnd = (csString,index)->
        return csString.indexOf("?>",index)
    parseClause = (contentString)->
        for clauseType in clauseMaps
            if clauseType.reg.test(contentString)
                if clauseType.buildFromString
                    clause = clauseType.buildFromString(contentString)
                else
                    clause = {type:clauseType.type}
                return clause
        throw new Error "unknow block:"+contentString
    csStart = parseCSClauseStart(csString,index)
    if csStart < 0
        return null
    csEnd = parseCSClauseEnd(csString,csStart+2)
    if csEnd < 0
        return null
    csRawContentString = csString.substring(csStart+4,csEnd)
    csContentString = csRawContentString.trim()
    
    return {
        ,csStart:csStart
        ,csEnd:csEnd
        ,csContentString:csContentString
        ,clause:parseClause(csContentString)
        }

parseBlock = (csString)->
    blocks = []
    index = 0
    while csBlock = parseCSBlock(csString,index)
        blocks.push {
            csContentString:csString.substring(index,csBlock.csStart),
            index:blocks.length,
            csStart:index,
            csEnd:csBlock.csStart
            clause:{type:"echo"}
            }
        csBlock.index = blocks.length
        blocks.push csBlock
        index = csBlock.csEnd + 2
    blocks.push {
        csContentString:csString.substring(index),
        csStart:index,
        csEnd:csString.length
        index:blocks.length,
        clause:{type:"echo"}
    }
    return blocks
if not module.parent
    return
exports.buildAST = buildAST
exports.parseBlock = parseBlock