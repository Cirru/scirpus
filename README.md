
Scirpus, JavaScript AST in Cirru grammer
------

Demo: http://repo.tiye.me/scirpus

### About

Scirpus is going to convert Cirru code to JavaScript IR, and generate code with escodegen.
For details, refer to resources below:

* https://speakerdeck.com/constellation/escodegen-and-esmangle-using-mozilla-javascript-ast-as-an-ir
* http://esprima.org/demo/parse.html
* https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API

### Usage

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