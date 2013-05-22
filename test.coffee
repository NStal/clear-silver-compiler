require "coffee-script"
ast = require "./ast.coffee"
fs = require "fs"
testFiles = [
    "test1.cs"
    ]
for file in testFiles
    console.log ast.buildAST(fs.readFileSync(file).toString())
    