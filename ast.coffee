require("coffee-script")
fs = require "fs"
parseAST = (csString)->


parseCSClause = (csString,index)->
    parseCSClauseStart = (csString,index)->
        return csString.indexOf("<?",index)
    parseCSClauseEnd = (csString,index)->
        return csString.indexOf("?>",index)
    csStart = parseCSClauseStart(csString,index)
    if csStart < 0
        return null
    csEnd = parseCSClauseEnd(csString,csStart+2)
    if csEnd < 0
        return null
    csContentString = csString.substring(csStart,csEnd+2)
    return {
        ,type:"clause"
        ,source:null
        ,csStart:csStart
        ,csEnd:csEnd
        ,csContentString:csContentString
        }
buildAST = (csString)->
    blocks = []
    index = 0
    while csClause = parseCSClause(csString,index)
            blocks.push {
                type:"string",
                content:csString.substring(index,csClause.csStart)
                }
            blocks.push csClause
            index = csClause.csEnd + 2
    blocks.push {
        type:"string",
        content:csString.substring(index)
        }
    return blocks
if not module.parent
    return
exports.buildAST = buildAST
