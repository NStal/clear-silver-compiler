fs = require "fs"
ast = require "./ast.coffee"
testFiles = [
    "test1.cs"
    ]
for file in testFiles
    blocks = ast.parseBlock(fs.readFileSync(file).toString())
    for item,index in blocks
        console.log index,item
    AST = ast.buildAST blocks,0
    console.log AST
 
    