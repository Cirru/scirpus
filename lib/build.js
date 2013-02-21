// Generated by CoffeeScript 1.4.0
var append_tpl, asNum, assign, calculate, call_tpl, choose, code, comment, compare, do_tpl, each_tpl, empty, err, fn_tpl, if_tpl, isArr, isStr, json, last, list, make_space, new_tpl, no_paras, not_arr, not_str, pair, read, refer, return_tpl, run_tpl, single, slice, switch_tpl, tpl, try_tpl, value, while_tpl;

isStr = function(str) {
  return typeof str === 'string';
};

isArr = function(arr) {
  return Array.isArray(arr);
};

asNum = function(x) {
  return !(isNaN(Number(x)));
};

empty = function(arr) {
  return arr.length === 0;
};

single = function(arr) {
  return arr.length === 1;
};

pair = function(arr) {
  return arr.length === 2;
};

last = function(arr) {
  return arr[arr.length - 1];
};

make_space = function(n) {
  var i, str;
  str = "";
  i = 0;
  while (i < n) {
    str += " ";
    i += 1;
  }
  return str;
};

choose = function(arr, choice) {
  var f, head, len, str;
  head = arr[0];
  choice = tpl[head] != null ? tpl[head] : run_tpl;
  len = arr.length;
  str = "=" + (String(len));
  f = choice[str] != null ? choice[str] : (len < 1) && (choice['<1'] != null) ? choice['<1'] : (len < 2) && (choice['<2'] != null) ? choice['<2'] : (len < 3) && (choice['<3'] != null) ? choice['<3'] : (len < 4) && (choice['<4'] != null) ? choice['<4'] : (len > 4) && (choice['>4'] != null) ? choice['>4'] : (len > 3) && (choice['>3'] != null) ? choice['>3'] : (len > 2) && (choice['>2'] != null) ? choice['>2'] : (len > 1) && (choice['>1'] != null) ? choice['>1'] : (len > 0) && (choice['>0'] != null) ? choice['>0'] : function() {
    throw new Error('no suitable tpl');
  };
  return f(arr);
};

err = function(info) {
  throw new Error(info);
};

no_paras = function() {
  return err('no paras');
};

not_arr = function() {
  return err('not arr');
};

not_str = function() {
  return err("no str");
};

code = {
  data: "",
  indent: 0,
  clear: function() {
    return this.data = "";
  },
  add: function(piece) {
    return this.data = this.data + piece;
  },
  "new": function(n) {
    var indentation;
    this.indent = this.indent + n;
    indentation = make_space(this.indent);
    return this.data += "\n" + indentation;
  }
};

read = function(x) {
  if (isStr(x)) {
    return code.add(x);
  } else if (x.length === 0) {
    return code.add('undefined');
  } else if ((x.length === 1) && (asNum(x[0]))) {
    return code.add(x[0]);
  } else {
    return choose(x);
  }
};

run_tpl = {
  '>0': function(arr) {
    var body;
    console.log("run:", arr);
    code.add(arr[0]);
    code.add("(");
    body = arr.slice(1);
    body.forEach(function(item, index) {
      if (isStr(item)) {
        code.add(item);
      } else {
        read(item);
      }
      if (body[index + 1] != null) {
        return code.add(", ");
      }
    });
    return code.add(")");
  }
};

append_tpl = {
  '<3': no_paras,
  '=3': function(arr) {
    read(arr[1]);
    code.add(" " + arr[0] + " ");
    return read(arr[2]);
  }
};

assign = {
  '<3': no_paras,
  '=3': function(arr) {
    code["new"](0);
    code.add("var ");
    read(arr[1]);
    code.add(" = ");
    return read(arr[2]);
  }
};

compare = {
  '<3': no_paras,
  '=3': function(arr) {
    code.add("(");
    read(arr[1]);
    code.add(" " + arr[0] + " ");
    read(arr[2]);
    return code.add(")");
  }
};

calculate = {
  '<2': no_paras,
  '>1': function(arr) {
    var body, head, _results;
    head = arr[0];
    body = arr.slice(1);
    read(body.shift());
    _results = [];
    while (body[0] != null) {
      code.add(" " + head + " ");
      _results.push(read(body.shift()));
    }
    return _results;
  }
};

list = {
  '>0': function(arr) {
    var body;
    code.add("[");
    body = arr.slice(1);
    if (body[0] != null) {
      read(body.shift());
    }
    while (body[0] != null) {
      code.add(", ");
      read(body.shift());
    }
    return code.add("]");
  }
};

json = {
  '>0': function(arr) {
    var write_pair;
    code.add("{");
    code["new"](2);
    write_pair = function() {
      var item;
      item = body.shift();
      code.add("" + item[0] + ": ");
      return read(item[1]);
    };
    if (body[0] != null) {
      write_pair();
    }
    while (body[0] != null) {
      code.add(", ");
      code["new"](0);
      write_pair();
    }
    code.add("}");
    return code["new"](-2);
  }
};

value = {
  '>0': function(arr) {
    return code.add(arr[0]);
  }
};

fn_tpl = {
  '<3': no_paras,
  '>2': function(arr) {
    var body, head;
    head = arr[1];
    body = arr.slice(2);
    code.add("(function(");
    if (head[0] != null) {
      code.add(head.shift());
    }
    while (head[0] != null) {
      code.add(", " + (head.shift()));
    }
    code.add("){");
    code["new"](2);
    body.forEach(function(line) {
      code["new"](0);
      read(line);
      return code.add(";");
    });
    code["new"](-2);
    return code.add("}");
  }
};

call_tpl = {
  "<2": no_paras,
  ">1": function(arr) {
    var body;
    read = arr[1];
    body = arr.slice(2);
    code.add("(");
    if (body[0] != null) {
      code.add(body.shift());
    }
    while (body[0] != null) {
      code.add(", ");
      code.add(body.shift());
    }
    return code.add(")");
  }
};

do_tpl = {
  "<2": no_paras,
  ">1": function(arr) {
    var body;
    body = arr.slice(1);
    return body.forEach(function(line, index) {
      code["new"](0);
      read(line);
      if (body[index] != null) {
        return code.add(";");
      }
    });
  }
};

if_tpl = {
  '=3': function(arr) {
    var body, head;
    head = arr[1];
    body = arr[2];
    "if(" + head + "){" + body + "}";
    code.add("if(");
    read(arr[1]);
    code.add("){");
    code["new"](2);
    read(arr[2]);
    code["new"](-2);
    return code.add("}");
  },
  '=4': function(arr) {
    this["=3"](arr);
    code.add("else{");
    code["new"](2);
    read(arr[3]);
    code["new"](-2);
    return code.add("}");
  }
};

while_tpl = {
  '<3': no_paras,
  '>2': function(arr) {
    var body, head;
    head = c(arr[1]);
    body = arr.slice(2).map(cl).join(';');
    code["new"](0, "while(" + head + "){" + body + "}");
    code.add("while(");
    read(head);
    code.add("){");
    code["new"](2);
    body.forEach(function(line) {
      code["new"](0);
      read(line);
      return code.add(";");
    });
    code["new"](-2);
    return code.add("}");
  }
};

each_tpl = {
  '<4': no_paras,
  '>3': function(arr) {
    var body, head, name;
    name = cc(arr[1]);
    head = arr[2];
    body = arr.slice(3).map(cl).join(';');
    value = head[1] != null ? "" + head[1] + " = " + name + "[" + head[0] + "];\n" : '';
    "for(" + head[0] + " in " + name + "){" + value + "\n" + body + "}";
    code.add("for(");
    code.add(arr[2]);
    code.add("in");
    read(arr[1]);
    code.add("){");
    code["new"](2);
    arr.slice(3).forEach(function(line) {
      code["new"](0);
      read(line);
      return code.add(";");
    });
    code["new"](-2);
    return code.add("}");
  }
};

try_tpl = {
  '<4': no_paras,
  '=4': function(arr) {
    var body, head, name;
    head = c(arr[1]);
    name = arr[2];
    body = arr.slice(3).map(cl).join('');
    "try{" + head + "}catch (" + name + "){" + body + "}";
    code.add("try{");
    code["new"](2);
    read(arr[2]);
    code["new"](-2);
    code.add("} catch (" + arr[1] + ")");
    code["new"](2);
    read(arr[3]);
    code["new"](-2);
    return code.add("}");
  }
};

switch_tpl = {
  '<3': no_paras,
  '>2': function(arr) {
    var body, item;
    code.add("switch(" + arr[1] + "){");
    code["new"](2);
    body = arr.slice(2);
    while (body[1] != null) {
      item = body.shift();
      code.add("case ");
      read(item[0]);
      code.add(":");
      code["new"](2);
      read(item[1]);
      code.add(";");
      code["new"](0);
      code.add("break;");
      code["new"](-2);
    }
    if (body[0] != null) {
      code.add("default:");
      code["new"](2);
      read(body[0][1]);
      code["new"](-2);
    }
    code["new"](-2);
    return code.add("}");
  }
};

refer = {
  '<3': no_paras,
  '>2': function(arr) {
    var body, item, _results;
    read(arr[1]);
    body = arr.slice(2);
    _results = [];
    while (body[0] != null) {
      item = body.shift();
      code.add("[");
      if (item[0] === '"') {
        code.add(item);
      } else {
        code.add(JSON.stringify(item));
      }
      _results.push(code.add("]"));
    }
    return _results;
  }
};

slice = {
  '<3': no_paras,
  '>2': function(arr) {
    code.add(read);
    code.add(".slice(");
    read(arr[1]);
    if (arr[2] != null) {
      code.add(", ");
      read(arr[2]);
    }
    return code.add(")");
  }
};

return_tpl = {
  '=2': function(arr) {
    code.add("return ");
    read(arr[1]);
    return code.add(";");
  }
};

comment = {
  '>0': function(arr) {
    return code.add("//" + (arr.slice(1).join(" ")));
  }
};

new_tpl = {
  '=3': function(arr) {
    "new " + arr[1] + "(" + (c(arr[2])) + ");";
    code.add("new ");
    code.add(arr[1]);
    return read(arr[2]);
  }
};

tpl = {
  '=': assign,
  '+=': append_tpl,
  '-=': append_tpl,
  '*=': append_tpl,
  '/=': append_tpl,
  '%=': append_tpl,
  '<': compare,
  '>': compare,
  '==': compare,
  '<=': compare,
  '>=': compare,
  '+': calculate,
  '-': calculate,
  '*': calculate,
  '/': calculate,
  '%': calculate,
  '#': list,
  '&': json,
  '&&': calculate,
  '||': calculate,
  'undefined': value,
  'break': value,
  'continue': value,
  'true': value,
  'null': value,
  'false': value,
  'typeof': run_tpl,
  'not': run_tpl,
  '!': run_tpl,
  '<-': return_tpl,
  'do': do_tpl,
  '->': fn_tpl,
  'if': if_tpl,
  'while': while_tpl,
  'each': each_tpl,
  'catch': try_tpl,
  'switch': switch_tpl,
  '.': refer,
  '..': slice,
  '--': comment,
  'new': new_tpl
};

exports.build = function(tree) {
  code.clear();
  tree.forEach(function(line) {
    code["new"](0);
    read(line);
    return code.add(";");
  });
  return code.data;
};