parseCSBlock = (csString,index)->
    parseCSClauseStart = (csString,index)->
        return csString.indexOf("<?cs",index)
    parseCSClauseEnd = (csString,index)->
        return csString.indexOf("?>",index)
    csStart = parseCSClauseStart(csString,index)
    if csStart < 0
        return null
    csEnd = parseCSClauseEnd(csString,csStart+2)
    if csEnd < 0
        return null
    csRawContentString = csString.substring(csStart+4,csEnd)
    csContentString = csRawContentString.trim()
    
    return {
        csStart:csStart
        ,csEnd:csEnd
        ,csContentString:csContentString
        ,type:"cs"
        ,source:csString
        }

parseBlocks = (csString)->
    blocks = []
    index = 0
    while csBlock = parseCSBlock(csString,index)
        blocks.push {
            csContentString:csString.substring(index,csBlock.csStart),
            index:blocks.length,
            csStart:index,
            csEnd:csBlock.csStart,
            type:"string",
            source:csString
            
            }
        csBlock.index = blocks.length
        blocks.push csBlock
        index = csBlock.csEnd + 2
    blocks.push {
        csContentString:csString.substring(index),
        csStart:index,
        csEnd:csString.length,
        index:blocks.length,
        type:"string",
        source:csString
    }
    return blocks
exports.parseBlocks = parseBlocks