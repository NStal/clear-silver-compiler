expression = require "./expression.coffee"
fs = require "fs"
ast = require "./ast.coffee"
token = require "./token.coffee"
compiler = require "./compiler.coffee"
testFiles = [
    "tests/echo.cs"
    ,"tests/var.cs"
    ,"tests/var2.cs"
    ,"test/"
    #"test1.cs"
]

createIndentSpace = (indent)->
    ("  " for _ in [0..indent]).join("")

printAST = (ast,indent)->
    if ast.type isnt "body"
        console.log createIndentSpace(indent),"|","<"+ast.type+">",ast.string or ""
    for item in ast.body
        if item.type is "body"
            printAST item,indent+1
        else
            printAST item,indent
    
    if ast.elseNode 
        printAST ast.elseNode,indent
    
            

testFile = ()->
    for file in testFiles
        blocks = ast.parseBlocks(fs.readFileSync(file).toString())
        clauses = ast.parseClauses(blocks)
        for item,index in clauses
            false
            #console.log index,item 
        AST = ast.buildAST clauses,0
        printAST AST,0
        console.log "code",compiler.generateCode(AST)
testParseToken = ()->
    console.log token.parseTokens "( var1+var2 )<var5.x.y.0*3"
testExpression = ()->
    Expression = expression.Expression
    exp = new Expression("5+4*3+2-1*2/5/1/2/3+123+231")
    exp.root.print(0)
testExpression()
#testParseToken()
#testFile()