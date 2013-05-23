token = require "./token.coffee"
Operators = ["+","-","*","/","(",")"]
Level = {"+":3,"-":3,"*":4,"/":4,"(":100,")":100}
Expect = {"+":2,"-":2,"*":2,"/":2}
isEntity = (item)->
    if item not in Operators
        return true
    return false
compareOperator = (a,b)->
    console.assert typeof Level[a] is "number"
    console.assert typeof Level[b] is "number"
    if a > b
        return 1
    else if a < b
        return -1
    return 0

class Node
    constructor:(token)->
        @token = token
        @children = []
        @string = token.string
        @expect = Expect[@string]
    switchWith:(node)->
        _ = @token
        @token = node.token
        @node.token = _
    add:(node)->
        @children.push node
        node.parent = this
        if @children.length > @expect
            throw new Error "more than expect:"+@string
    replaceChild:(from,to)->
        for child,index in @children
            if child is from
                @children[index] = to
                delete from.parent
                return
        throw new Error "children not exists,cant be replaced"
    becomeParentOf:(node)->
        if this in node.children
            throw new Error "Can't become father of child"
        if node.parent
            node.parent.replaceChild(node,this)
        this.add node
        
class Expression
    constructor:(string)->
        @tokens = token.parseTokens string
        @build()
    build:()->
        index = 0
        while true
            cursor = new Node(tokens[index])
            if not root
                # Situation 1.
                root = cursor
                current = cursor
                index+=1
                continue
            if current.string not in Operators and cursor.string not in Operators
                # Situation 2
                throw Error "Situation 2"
            if current.string not in Operators and cursor.string in Operators
                # Situation 3
                current.add cursor 
                cursor.switchWith current
                index ++
                continue
            if current.string in Operators and cursor.string in Operators and current.expect > current.children.length
                # Situation 4
                throw new Error "Sitation 4"
            if current.string in Operators and cursor.string not in Operators and current.expect > current.children.length
                # Situation 5
                current.add cursor
                index++
                continue
            if current.string in Operators and
                cursor.string in Operators and
                current.expect is current.children.length and
                compareOperator(cursor.string,current.string) > 0
                # Situation 6
                lastChild = current.children[current.children.length-1]
                lastChild.add cursor
                cursor.switchWith lastChild
                current = lastChild
                index++
                continue
            if current.string in Operators and
                cursor.string in Operators and
                current.expect is current.children.length and
                cursor.string is current.string) = 0
                 # situation 7 
                cursor.becomeParentOf current
                current = cursor
                index++
                continue
            if current.string in Operators and
                cursor.string in Operators and
                current.expect is current.children.length and
                cursor.string is current.string) < 0 
                # situation 8
                target = current
                while compareOperator(target.string,cursor.string) > 0
                    # higher priority 
                    # until meet less priority or root
                    if target.parent
                        target = target.parent
                    else
                        # is root
                        break
                cursor.becomeParentOf target
                
            cursor

        







