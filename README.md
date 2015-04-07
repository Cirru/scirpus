
Scirpus, ES6(subset) AST in Cirru grammar
------

Demo: http://repo.cirru.org/scirpus/

Read [`examples/`](https://github.com/Cirru/scirpus/tree/master/examples).

### Goal

Write JavaScript AST in Cirru grammar. Then it can be used as an IR for cross-language compilations.

Also read:

* http://segmentfault.com/a/1190000002646285
* https://speakerdeck.com/constellation/escodegen-and-esmangle-using-mozilla-javascript-ast-as-an-ir
* http://esprima.org/demo/parse.html
* https://github.com/estree/estree/blob/master/spec.md

### Usage

CommonJS:

```text
npm install --save scirpus
```

```coffee
scirpus = require 'scirpus'
ast = scirpus.transform [['cirru tree']]
# generates ES6 AST from Cirru AST
```

### License

MIT
