// Generated by CoffeeScript 1.6.2
(function() {
  var ASTNode, Regs, buildAST, clauseMaps, fs, isCloseClause, item, parseBlock, parseCSBlock, regString, value, _i, _len;

  fs = require("fs");

  String.prototype.replaceAllUnsafe = function(pattern, to) {
    return this.replace(new RegExp(pattern, "g"), to);
  };

  Regs = {
    token: "#?([a-z0-9_]*\\.)*([a-z_0-9]*)",
    variable: "[a-z_0-9]*",
    expression: "[#a-z_0-9\\-+=.]*"
  };

  clauseMaps = [
    {
      type: "var",
      parser: "var:{expression}"
    }, {
      type: "if",
      parser: "if:{expression}"
    }, {
      type: "else",
      parser: "else"
    }, {
      type: "end-if",
      parser: "/if"
    }, {
      type: "set",
      parser: "set:{token}\\s*=\\s*{expression}"
    }, {
      type: "each",
      parser: "each:{variable}\\s*=\\s*{expression}"
    }, {
      type: "end-each",
      parser: "/each"
    }
  ];

  for (_i = 0, _len = clauseMaps.length; _i < _len; _i++) {
    item = clauseMaps[_i];
    regString = item.parser;
    for (value in Regs) {
      regString = regString.replaceAllUnsafe(["\\{", value, "\\}"].join(""), Regs[value]);
    }
    item.reg = new RegExp(["^", regString, "$"].join(""), "i");
  }

  isCloseClause = function(type) {
    return type === "end-if" || type === "else";
  };

  buildAST = function(blocks, start, end) {
    var bodyNode, childNode, closeIf, index, lastNode, node;

    index = start || 0;
    end = end || blocks.length - 1;
    bodyNode = new ASTNode();
    while (true) {
      if (index > end) {
        break;
      }
      node = new ASTNode(blocks[index]);
      if (isCloseClause(node.type)) {
        console.log("break node ", node.clause);
        return bodyNode;
      }
      if (node.type === "else") {
        throw new Error("unexpected else:" + node.block.csContentString);
      }
      if (node.type === "if") {
        index += 1;
        while (true) {
          if (index > end) {
            throw new Error("Unclosed If statement:" + node.block.csContentString);
          }
          closeIf = blocks[index];
          console.log("index", index, end, closeIf);
          console.assert(closeIf);
          if (closeIf.clause.type === "else") {
            console.log("else!");
            if (node.elseNode) {
              throw Error("dumplicated else for if statement:" + node.block.csContentString);
            }
            node.elseNode = new ASTNode(closeIf);
            lastNode = node.elseNode.getLastNode();
            index = lastNode.index + 1;
            continue;
          } else if (closeIf.clause.type === "end-if") {
            console.log("~~END!!! break");
            node.endIfNode = new ASTNode(closeIf);
            index = closeIf.index + 1;
            break;
          } else {
            childNode = buildAST(blocks, index + 1, end);
            if (node.elseNode) {
              node.elseNode.add(childNode);
            } else {
              node.add(childNode);
            }
            lastNode = childNode.getLastNode();
            index = lastNode.index + 1;
            continue;
          }
        }
        console.assert(node.endIfNode);
      } else {
        index += 1;
      }
      bodyNode.add(node);
      continue;
    }
    return bodyNode;
  };

  ASTNode = (function() {
    function ASTNode(block) {
      this.body = [];
      this.block = block;
      this.index = block && block.index || -1;
      this.clause = block && block.clause || null;
      this.type = this.clause && this.clause.type || "body";
    }

    ASTNode.prototype.getLastNode = function() {
      if (this.type === "if") {
        return this.endIfNode;
      }
      if (this.body.length === 0) {
        return this;
      } else {
        return this.body[this.body.length - 1].getLastNode();
      }
    };

    ASTNode.prototype.add = function(node) {
      console.assert(node instanceof ASTNode);
      if (!node.clause && node.body.length === 0) {
        return null;
      }
      return this.body.push(node);
    };

    return ASTNode;

  })();

  parseCSBlock = function(csString, index) {
    var csContentString, csEnd, csRawContentString, csStart, parseCSClauseEnd, parseCSClauseStart, parseClause;

    parseCSClauseStart = function(csString, index) {
      return csString.indexOf("<?cs", index);
    };
    parseCSClauseEnd = function(csString, index) {
      return csString.indexOf("?>", index);
    };
    parseClause = function(contentString) {
      var clause, clauseType, _j, _len1;

      for (_j = 0, _len1 = clauseMaps.length; _j < _len1; _j++) {
        clauseType = clauseMaps[_j];
        if (clauseType.reg.test(contentString)) {
          if (clauseType.buildFromString) {
            clause = clauseType.buildFromString(contentString);
          } else {
            clause = {
              type: clauseType.type
            };
          }
          return clause;
        }
      }
      throw new Error("unknow block:" + contentString);
    };
    csStart = parseCSClauseStart(csString, index);
    if (csStart < 0) {
      return null;
    }
    csEnd = parseCSClauseEnd(csString, csStart + 2);
    if (csEnd < 0) {
      return null;
    }
    csRawContentString = csString.substring(csStart + 4, csEnd);
    csContentString = csRawContentString.trim();
    return {
      csStart: csStart,
      csEnd: csEnd,
      csContentString: csContentString,
      clause: parseClause(csContentString)
    };
  };

  parseBlock = function(csString) {
    var blocks, csBlock, index;

    blocks = [];
    index = 0;
    while (csBlock = parseCSBlock(csString, index)) {
      blocks.push({
        csContentString: csString.substring(index, csBlock.csStart),
        index: blocks.length,
        csStart: index,
        csEnd: csBlock.csStart,
        clause: {
          type: "echo"
        }
      });
      csBlock.index = blocks.length;
      blocks.push(csBlock);
      index = csBlock.csEnd + 2;
    }
    blocks.push({
      csContentString: csString.substring(index),
      csStart: index,
      csEnd: csString.length,
      index: blocks.length,
      clause: {
        type: "echo"
      }
    });
    return blocks;
  };

  if (!module.parent) {
    return;
  }

  exports.buildAST = buildAST;

  exports.parseBlock = parseBlock;

}).call(this);