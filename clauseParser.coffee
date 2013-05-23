# unsafe replace
# not escape any reg special chars
String.prototype.replaceAllUnsafe = (pattern,to)->
    return this.replace(new RegExp(pattern,"g"),to)
Regs = {
    token:"#?([a-z0-9_]*\\.)*([a-z_0-9]*)"
    ,variable:"[a-z_0-9]*"
    ,expression:"[#a-z_0-9\\-+=.]*"
    }
clauseMaps = [{
    type:"var"
    ,parser:"var:({expression})"
    ,buildFromString:(string)->
        match = string.match @reg
        console.assert match
        if not match[1]
            throw new Error "Invalid var statement:"+string
        return {
            type:"var"
            ,string:string
            ,hdfIndex:match[1]
            }
    }
    ,{type:"if",parser:"if:{expression}"}
    ,{type:"else",parser:"else"}
    ,{type:"end-if",parser:"/if"}
    ,{
        type:"set"
        ,parser:"set:({token})\\s*=\\s*({expression})"
        ,buildFromString:(string)-> 
            match = string.match(@reg)
            console.assert match
            return {
                type:"set"
                ,string:string
                ,hdfIndex:match[1]
                ,expression:match[2]
            }
    }
    ,{type:"var",parser:"var:{token}"}
    ,{type:"each",parser:"each:{variable}\\s*=\\s*{expression}"}
    ,{type:"end-each",parser:"/each"}
    ]
# build clauesMap
for item in clauseMaps
    regString = item.parser
    for value of Regs
        regString = regString.replaceAllUnsafe(["\\{",value,"\\}"].join(""),Regs[value])
    item.reg = new RegExp(["^",regString,"$"].join(""),"i")

parseClause = (block)->
    console.assert block
    console.assert block.type
    if block.type is "string"
        return {
            type:"echo"
            ,string:block.csContentString
            ,block:block
        }
    contentString = block.csContentString
    for clauseType in clauseMaps
        if clauseType.reg.test(contentString)
            if clauseType.buildFromString
                clause = clauseType.buildFromString(contentString)
            else
                clause = {type:clauseType.type,string:contentString}
            clause.block = block
            return clause
    throw new Error "unknow block:"+contentString

parseClauses = (blocks)->
    clauses = []
    for item,index in blocks
        clause = parseClause(item)
        clause.index = index
        clause
exports.parseClauses = parseClauses