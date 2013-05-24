Operators = [
    ">=","<=","==","+","-","*","/","(",")",">","<",","
    ]
Token = {
    
    }
# string should be a String Object to give better performance
# which avoid a lot  string->String transfer
parseToken = (string,start,end)->
    
    index = start or 0
    end = end or string.length
    charReg = /[a-z_0-9\.]{1}/i
    #skip white spaces or tabs or something like that
    while true
        if string[index] in [" ","\t","\n","\r"]
            index++
        else
            break
    tokenBegin = index
    for operator in Operators
        if string.indexOf(operator,index) is tokenBegin
            return {position:index,string:operator}
    # end of string?
    if not string[index] 
        return "EOF"
    # is a word
    while true
        if charReg.test string[index]
            index+=1
        else
            break 
        if not string[index]
            break
    if index is tokenBegin
        throw new Error "Invalid Token Meet:"+string[index]+" at "+index
    return {position:tokenBegin,string:string.substring(tokenBegin,index)}
exports.parseTokens = (string)->
    index = 0
    tokens = []
    string = new String(string)
    while true
        token = parseToken(string,index,string.length)
        if token is "EOF"
            return tokens
        index = token.position + token.string.length
        tokens.push token
        if index >= string.length
            return tokens
            