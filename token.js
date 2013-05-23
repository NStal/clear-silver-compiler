// Generated by CoffeeScript 1.6.2
(function() {
  var Operators, Token, parseToken;

  Operators = [">=", "<=", "==", "+", "-", "*", "/", "(", ")", ">", "<"];

  Token = {};

  parseToken = function(string, start, end) {
    var charReg, index, operator, tokenBegin, _i, _len, _ref;

    index = start || 0;
    end = end || string.length;
    charReg = /[a-z_0-9\.]{1}/i;
    while (true) {
      if ((_ref = string[index]) === " " || _ref === "\t" || _ref === "\n" || _ref === "\r") {
        index++;
      } else {
        break;
      }
    }
    tokenBegin = index;
    for (_i = 0, _len = Operators.length; _i < _len; _i++) {
      operator = Operators[_i];
      if (string.indexOf(operator, index) === tokenBegin) {
        return {
          position: index,
          string: operator
        };
      }
    }
    while (true) {
      if (!string[index]) {
        return "EOF";
      }
      if (charReg.test(string[index])) {
        index += 1;
      } else {
        break;
      }
    }
    if (index === tokenBegin) {
      throw new Error("Invalid Token Meet:" + string[index] + " at " + index);
    }
    return {
      position: tokenBegin,
      string: string.substring(tokenBegin, index)
    };
  };

  exports.parseTokens = function(string) {
    var index, token, tokens;

    index = 0;
    tokens = [];
    string = new String(string);
    while (true) {
      token = parseToken(string, index, string.length);
      if (token === "EOF") {
        return tokens;
      }
      index = token.position + token.string.length;
      tokens.push(token);
      if (index >= string.length) {
        return tokens;
      }
    }
  };

}).call(this);