fs = require "fs"
parseAST = (csString)->


parseCSClause = (csString,index)->
    parseCSClauseStart = (csString,index)->
        return csString.indexOf("<?",index)
    parseCSClauseEnd = (csString,index)->
        return csString.indexOf("?>",index)
    parseCSContent
    csStart = parseCSClauseStart(csString,index)
    csEnd = parseCSClauseEnd(csString,csStart+2)
    
            
if not module.parent
    return    
