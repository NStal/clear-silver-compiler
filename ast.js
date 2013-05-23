// Generated by CoffeeScript 1.6.2
(function() {
  var ASTNode, blockParser, buildAST, clauseParser, closeClauses, fs, parseEachNode, parseIfNode,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require("fs");

  blockParser = require("./blockParser.coffee");

  clauseParser = require("./clauseParser.coffee");

  closeClauses = ["end-if", "else", "end-each"];

  parseIfNode = function(clauses, index, end) {
    var clause, closeNode, elseBody, elseNode, ifBody, ifNode;

    clause = clauses[index];
    console.assert(clause);
    console.assert(clause.type === "if");
    ifNode = new ASTNode(clause);
    index += 1;
    ifBody = buildAST(clauses, index, end);
    ifNode.add(ifBody);
    index = ifNode.getLastNode().index + 1;
    closeNode = new ASTNode(clauses[index]);
    if (index > end) {
      throw new Error("unclosed if:" + ifNode.string);
    }
    if (closeNode.type === "else") {
      elseNode = closeNode;
      ifNode.elseNode = elseNode;
      closeNode = null;
      index += 1;
      elseBody = buildAST(clauses, index, end);
      elseNode.add(elseBody);
      index = elseNode.getLastNode().index + 1;
      closeNode = new ASTNode(clauses[index]);
    }
    if (index > end || closeNode.type !== "end-if") {
      throw new Error("unclosed if-else:" + ifNode.string);
    }
    ifNode.endIfNode = closeNode;
    return ifNode;
  };

  parseEachNode = function(clauses, index, end) {
    var clause, eachBody, eachNode, endEachNode;

    clause = clauses[index];
    console.assert(clause.type === "each");
    eachNode = new ASTNode(clause);
    index += 1;
    if (index > end) {
      throw "unclosed each:" + eachNode.string;
    }
    eachBody = buildAST(clauses, index, end);
    eachNode.add(eachBody);
    index = eachNode.getLastNode().index + 1;
    endEachNode = new ASTNode(clauses[index]);
    if (endEachNode.type !== "end-each") {
      throw "unclosed each:" + eachNode.string;
    }
    eachNode.endEachNode = endEachNode;
    return eachNode;
  };

  buildAST = function(clauses, start, end) {
    var bodyNode, clause, eachNode, ifNode, index, _ref;

    index = start || 0;
    end = end || clauses.length - 1;
    bodyNode = new ASTNode();
    while (true) {
      if (index > end) {
        return bodyNode;
      }
      clause = clauses[index];
      console.assert(clause);
      if (_ref = clause.type, __indexOf.call(closeClauses, _ref) >= 0) {
        return bodyNode;
      }
      if (clause.type === "if") {
        ifNode = parseIfNode(clauses, index, end);
        index = ifNode.getLastNode().index + 1;
        bodyNode.add(ifNode);
        console.assert(index === (ifNode.endIfNode.index + 1), "wrong index");
      } else if (clause.type === "each") {
        eachNode = parseEachNode(clauses, index, end);
        index = eachNode.getLastNode().index + 1;
        bodyNode.add(eachNode);
        console.assert(index === (eachNode.endEachNode.index + 1), "wrong index");
      } else {
        bodyNode.add(new ASTNode(clause));
        index += 1;
        console.assert(clause.index + 1 === index, "wrong index");
      }
    }
    return true;
  };

  ASTNode = (function() {
    function ASTNode(clause) {
      var item;

      this.body = [];
      if (!clause) {
        this.type = "body";
        return;
      }
      for (item in clause) {
        this[item] = clause[item];
      }
      console.assert(this.type, "clause without type");
      console.assert(typeof this.index === "number", "clause without index");
    }

    ASTNode.prototype.isEmptyBody = function() {
      return (this.type === "body") && (this.body.length === 0);
    };

    ASTNode.prototype.getLastNode = function() {
      console.assert(!this.isEmptyBody(), "should'nt at last node from here");
      if (this.type === "if") {
        if (this.endIfNode) {
          return this.endIfNode;
        } else if (this.elseNode) {
          return this.elseNode.getLastNode();
        } else {

        }
      }
      if (this.type === "each") {
        if (this.endEachNode) {
          return this.endEachNode;
        } else {

        }
      }
      if (this.body.length === 0) {
        return this;
      } else {
        return this.body[this.body.length - 1].getLastNode();
      }
    };

    ASTNode.prototype.add = function(node) {
      console.assert(node instanceof ASTNode);
      if (node.isEmptyBody()) {
        return null;
      }
      return this.body.push(node);
    };

    return ASTNode;

  })();

  if (!module.parent) {
    return;
  }

  exports.buildAST = buildAST;

  exports.parseBlocks = blockParser.parseBlocks;

  exports.parseClauses = clauseParser.parseClauses;

}).call(this);
