
Scirpus, JavaScript AST in Cirru grammer
------

Working in progress...

Demo(not ready): http://repo.tiye.me/scirpus

### Goal

Write JavaScript AST in Cirru grammar. Then it can be used as an IR for cross-language transforms.

Also read: http://segmentfault.com/a/1190000002646285

### About

Scirpus is going to convert Cirru code to JavaScript IR, and generate code with escodegen.
For details, refer to resources below:

* https://speakerdeck.com/constellation/escodegen-and-esmangle-using-mozilla-javascript-ast-as-an-ir
* http://esprima.org/demo/parse.html
* https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API

### Usage(, this project is currently during refactoring)

CommonJS:

```
npm install --save scirpus
```
```coffee
scirpus = require 'scirpus'
ast = scirpus.transform [['cirru tree']]
# then generate JS from AST
```

### License

MIT
