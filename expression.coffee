token = require "./token.coffee"
Operators = ["+","-","*","/"]
Level = {"+":3,"-":3,"*":4,"/":4,"(":-100,")":-100}
Expect = {"+":2,"-":2,"*":2,"/":2,"(":99999}
isEntity = (item)->
    if item not in Operators
        return true
    return false
compareOperator = (a,b)->
    console.assert typeof Level[a] is "number"
    console.assert typeof Level[b] is "number"
    a = Level[a]
    b = Level[b]
    if a > b
        return 1
    else if a < b
        return -1
    return 0

class Node
    constructor:(token)->
        @children = []
        @setToken(token)
    setToken:(token)->
        @token = token
        @string = token.string
        # 1 for entities such functions or something else
        @expect = Expect[@string] or 1
    switchWith:(node)->
        _ = @token
        @setToken(node.token)
        node.setToken(_)
    getTopestUnFullNode:()->
        node = this
        while true
            if node.expect > node.children.length
                return node
            if node.parent
                node = node.parent
            else
                return null
            
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
    print:(indent)->
        createIndent = (num)->
            ("  " for _ in [0..num]).join("")
        indent = indent or 0
        console.log createIndent(indent)+@string
        for child in @children
            child.print(indent+1)
class Expression
    constructor:(string)->
        @tokens = token.parseTokens string
        @build()
    build:()->
        index = 0
        while true
            if not @tokens[index]
                console.log @tokens,index
                break
            cursor = new Node(@tokens[index])
            if not root
                # Situation 1.
                root = cursor
                current = cursor
                index+=1
                continue
            if cursor.string is "(" and current.string in Operators and current.expect > currect.children.length
                # Situation 10
                current.add cursor
                current = cursor
                index++ 
                continue 

            if cursor.string is "(" and current.string in Operators and current.expect is current.children.length
                # Situation 11 might be function call
                lastChild = current.children[current.children.length[-1]]
                if lastChild.children.length isnt 0
                    throw new Error "Situation 11.5"
                console.assert lastChild.string not in Operators
                lastChild.add cursor
                current = cursor
                index++
                continue
            if current.string is "(" and cursor.string not in Operators
                # Situation 12
                current.add cursor
                current = cursor
                index++
                continue
            if current.string is "(" and  cursor.string in Operators
                # Situation 13
                throw new Error "Situation 13"
            if current.string not in Operators and cursor.string is "("
                # Situation 14
                # curren is an entity means it's root or parenthensis's subroot
                console.assert (not current.parent ) or current.parent.string is "("
                current.add cursor 
                current = cursor
                index++
                continue
            if  current.string is "(" and cursor.string is ")" and current.parent and current.parent.string in Operators
                # Situation 15
                throw new Error "Situation 15"
            if  current.string is "(" and cursor.string is ")" and current.parent and current.parent.string not in Operators
                # Situation 16
                current.closed = true
                current = current.parent
                if current.parent and current.parent.string in Operators
                    current = current.parent
                index++
                continue
            if current.string in Operators and current.expect >current.children.length and cursor.string is ")"
                # Situation 17
                throw new Error "Situation 17"
            if current.string in Operators and current.expect is current.children.length and cursor.string is ")"
                # Situation 18
                node = current.parent
                while true
                    if not node
                        throw new Error "unexpected )"
                    if node.string is "("
                        node.closed = true
                        current = node.parent
                        if not current
                            current = node
                        break
                    if node.string in Operators and node.expect > node.children.length
                        throw new Error "Unexpect Token"+node.string
                index++
                continue
            if current.string not in Operators and current.parent and current.parent.string is "(" and cursor is ")"
                # 
                current = current.parent
            if current.string not in Operators and cursor.string not in Operators
                # Situation 2
                root.print()
                throw Error "Situation 2"
            if current.string not in Operators and cursor.string in Operators
                # Situation 3
                current.add cursor 
                cursor.switchWith current
                index++
                continue
            if current.string in Operators and cursor.string in Operators and current.expect > current.children.length
                # Situation 4 and # Situation 9
                throw new Error "Sitation 4 or 9"
            if current.string in Operators and cursor.string not in Operators and current.expect > current.children.length
                # Situation 5
                current.add cursor
                index++
                continue
            if current.string in Operators and cursor.string in Operators and current.expect is current.children.length and compareOperator(cursor.string,current.string) > 0
                # Situation 6
                lastChild = current.children[current.children.length-1]
                lastChild.add cursor
                cursor.switchWith lastChild
                current = lastChild
                index++
                continue
            if current.string in Operators and  cursor.string in Operators and current.expect is current.children.length and compareOperator(cursor.string,current.string) <= 0
                # situation 8 and situation 7
                target = current
                while compareOperator(target.string,cursor.string) >= 0
                    # note: ( is like root which is considered to be the
                    # lowest priority.

                    # until meet less priority or root
                    if target.parent
                        target = target.parent
                    else
                        # is root
                        break
                console.log "target:",target.string
                cursor.becomeParentOf target
                if not cursor.parent
                    root = cursor
                current = cursor
                index++
                continue
            root.print(0)
            console.log(current.string,cursor.string)
            throw new Error "Unexpected Situation"
            
            
        @root = root
        return root
    
exports.Expression = Expression        

